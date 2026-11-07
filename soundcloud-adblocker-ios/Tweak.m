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

// NSURLSession
static NSURLSessionDataTask *(*orig_dataTask)(id, SEL, NSURLRequest *, void (^)(NSData *, NSURLResponse *, NSError *)) = NULL;
static NSURLSessionDataTask *hook_dataTask(id self, SEL _cmd, NSURLRequest *request, void (^completion)(NSData *, NSURLResponse *, NSError *)) {
    if (isAdURL(request.URL)) {
        if (completion) completion(nil, nil, [NSError errorWithDomain:@"AdBlock" code:1 userInfo:nil]);
        return nil;
    }
    return orig_dataTask(self, _cmd, request, completion);
}

// AVPlayer
static void (*orig_replaceItem)(id, SEL, AVPlayerItem *) = NULL;
static void hook_replaceItem(id self, SEL _cmd, AVPlayerItem *item) {
    orig_replaceItem(self, _cmd, item);
    AVAsset *asset = item.asset;
    if ([asset isKindOfClass:[AVURLAsset class]]) {
        NSURL *u = ((AVURLAsset *)asset).URL;
        if (isAdURL(u)) {
            [self pause];
        }
    }
}

__attribute__((constructor))
static void init(void) {
    // NSURLSession
    Class c = objc_getClass("NSURLSession");
    SEL sel = sel_registerName("dataTaskWithRequest:completionHandler:");
    Method m = class_getInstanceMethod(c, sel);
    orig_dataTask = (void *)method_getImplementation(m);
    method_setImplementation(m, (IMP)hook_dataTask);

    // AVPlayer
    Class c2 = objc_getClass("AVPlayer");
    SEL sel2 = sel_registerName("replaceCurrentItemWithPlayerItem:");
    Method m2 = class_getInstanceMethod(c2, sel2);
    orig_replaceItem = (void *)method_getImplementation(m2);
    method_setImplementation(m2, (IMP)hook_replaceItem);
}