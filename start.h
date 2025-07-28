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

@interface SoundMenu: NSObject
- (void) show;
- (void) back;
- (void) apply;
- (void) list;
@end

@interface GameMenu: NSObject
- (void) show;
- (void) showFPS;
@end

@interface Start: NSWindow <NSWindowDelegate>
- (void) windowShouldClose: (NSWindow *) sender;
@end

@interface App: NSApplication <NSApplicationDelegate>
- (void) playGame;
- (void) loop;
- (void) run;
@end
#endif
