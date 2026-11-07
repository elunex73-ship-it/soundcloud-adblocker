#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>

static BOOL isAdURL(NSURL *url) {
    if (!url) return NO;
    NSString *s = url.absoluteString.lowercaseString;
    NSArray *keywords = @[@"audio-ads", @"promoted", @"doubleclick", @"googlesyndication", @"pagead"];
    for (NSString *k in keywords) {
        if ([s containsString:k]) return YES;
    }
    return NO;
}

static void (*orig_replaceItem)(id, SEL, AVPlayerItem *) = NULL;
static void hook_replaceItem(id self, SEL _cmd, AVPlayerItem *item) {
    if (orig_replaceItem) orig_replaceItem(self, _cmd, item);
    @try {
        AVAsset *asset = item.asset;
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            NSURL *u = ((AVURLAsset *)asset).URL;
            if (isAdURL(u)) {
                [self pause];
            }
        }
    } @catch (NSException *e) {}
}

__attribute__((constructor))
static void init(void) {
    Class c2 = objc_getClass("AVPlayer");
    if (!c2) return;
    SEL sel2 = sel_registerName("replaceCurrentItemWithPlayerItem:");
    Method m2 = class_getInstanceMethod(c2, sel2);
    if (!m2) return;
    orig_replaceItem = (void *)method_getImplementation(m2);
    method_setImplementation(m2, (IMP)hook_replaceItem);
}