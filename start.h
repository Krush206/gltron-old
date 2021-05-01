#ifndef START_H
#define START_H 1
#include <AppKit/AppKit.h>

extern const char *drivers;
extern unsigned int md_device;
extern struct Game *game;

@interface Field: NSTextField <NSTextFieldDelegate>
- (BOOL) textShouldBeginEditing: (NSText *) textObject;
- (void) textDidChange: (NSNotification *) notification;
@end

@interface Driver: NSObject
- (void) apply;
@end

@interface List: NSWindow <NSWindowDelegate>
- (void) show;
@end

@interface Start: NSWindow <NSWindowDelegate>
- (void) windowShouldClose: (NSWindow *) sender;
@end

@interface App: NSApplication <NSApplicationDelegate>
- (void) run;
@end
#endif
