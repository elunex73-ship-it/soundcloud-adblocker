#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static BOOL isAdURL(NSURL *url) {
    if (!url) return NO;
    NSString *s = url.absoluteString.lowercaseString;
    NSArray *keywords = @[@"ad", @"ads", @"advert", @"audio-ads", @"promoted", @"doubleclick", @"googlesyndication", @"pagead"];
    for (NSString *k in keywords) {
        if ([s containsString:k]) return YES;
    }
    return NO;
}

// Block ad network requests
%hook NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData *, NSURLResponse *, NSError *))completionHandler {
    if (isAdURL(request.URL)) {
        if (completionHandler) completionHandler(nil, nil, [NSError errorWithDomain:@"AdBlock" code:1 userInfo:nil]);
    }
    return %orig;
}
%end

%hook NSURLConnection
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
    if (isAdURL(request.URL)) {
        if (error) *error = [NSError errorWithDomain:@"AdBlock" code:1 userInfo:nil];
        return nil;
    }
    return %orig;
}
%end

// Skip video/audio ads in AVPlayer by observing current item
%hook AVPlayer
- (void)replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item {
    %orig;
    // If the item's asset URL looks like an ad, skip by seeking to end
    AVAsset *asset = item.asset;
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        NSURL *u = ((AVURLAsset *)asset).URL;
        if (isAdURL(u)) {
            [self seekToTime:CMTimeGetSeconds(item.duration) > 0 ? item.duration : kCMTimeZero];
            [self pause];
        }
    }
}
%end

// Attempt to skip ads via SoundCloud player notification (best-effort)
%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"SCAdStarted" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *n) {
        // post a skip notification if app supports it
    }];
}