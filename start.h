#ifndef START_H
#define START_H 1
#include <AppKit/AppKit.h>

extern const char *drivers;
extern unsigned int md_device;
extern struct Game *game;
extern struct Arguments args;

@interface Field: NSTextField <NSTextFieldDelegate>
- (BOOL) textShouldBeginEditing: (NSText *) textObject;
- (void) textDidChange: (NSNotification *) notification;
@end

@interface SoundMenu: NSObject
- (void) show;
- (void) back;
- (void) cancel;
- (void) apply;
- (void) list;
@end

@interface GameMenu: NSObject
- (void) show;
- (void) showFPS;
- (void) eraseCrashed;
- (void) fastFinish;
- (void) back;
@end

@interface Start: NSWindow <NSWindowDelegate>
- (BOOL) windowShouldClose: (NSWindow *) sender;
@end

@interface App: NSApplication <NSApplicationDelegate>
- (void) stop: (id) sender;
- (void) playGame;
- (void) loop;
- (void) applicationDidFinishLaunching: (NSNotification *) notification;
@end
#endif
