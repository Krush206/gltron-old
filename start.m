#include "start.h"
#include "gltron.h"

static NSText *drvString;
static NSNumber *drvOption;
static Start *start;
static NSView *superview, *view[8];
static NSWindow *dock;
static NSButton *speedButton;
static struct Speed {
  float speed;
  const char *name;
  struct Speed *next,
               *prev;
} speedSet[] = { { 2.8, "Very slow", &speedSet[1], &speedSet[4] },
                 { 3.5, "Slow", &speedSet[2], &speedSet[0] },
                 { 4.2, "Normal", &speedSet[3], &speedSet[1] },
                 { 4.8, "Fast", &speedSet[4], &speedSet[2] },
                 { 5.2, "Very fast", &speedSet[0], &speedSet[3] } },
  *currentSet = speedSet;

@implementation Field
- (BOOL) textShouldBeginEditing: (NSText *) textObject
{
  drvString = textObject;

  return YES;
}

- (void) textDidChange: (NSNotification *) notification
{
  if([[drvString string] rangeOfCharacterFromSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location != NSNotFound)
  {
    [drvString setString: @""];
    return;
  }
  drvOption = [[NSNumberFormatter new] numberFromString: [drvString string]];
}
@end

@implementation SoundMenu
- (void) list
{
  id i;

  [superview replaceSubview: view[1] with: view[2]];
  for(i in [view[2] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[2]];
}

- (void) show
{
  id i;

  [superview replaceSubview: view[0] with: view[1]];
  for(i in [view[1] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[1]];
}

- (void) apply
{
  game->settings->sound_driver = [drvOption unsignedIntValue];
  saveSettings();
  [NSThread exit];
}

- (void) cancel
{
  id i;

  [superview replaceSubview: view[1] with: view[0]];
  for(i in [view[0] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[0]];
}

- (void) back
{
  id i;

  [superview replaceSubview: view[2] with: view[1]];
  for(i in [view[1] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[1]];
}
@end

@implementation GameMenu
- (void) speed
{
  game->settings->speed = (currentSet = currentSet->next)->speed;
  [speedButton setTitle: [[NSString alloc] initWithUTF8String: currentSet->name]];
}

- (void) eraseCrashed
{
  game->settings->erase_crashed = !game->settings->erase_crashed;
}

- (void) fastFinish
{
  game->settings->fast_finish = !game->settings->fast_finish;
}

- (void) show
{
  id i;

  [superview replaceSubview: view[0] with: view[3]];
  for(i in [view[3] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[3]];
}

- (void) showFPS
{
  game->settings->show_fps = !game->settings->show_fps;
}

- (void) back
{
  id i;

  [superview replaceSubview: view[3] with: view[0]];
  for(i in [view[0] subviews])
    [start makeFirstResponder: i];
  [start makeFirstResponder: view[0]];
}
@end

@implementation Start
- (BOOL) windowShouldClose: (NSWindow *) sender
{
  [NSThread exit];

  return YES;
}
@end

@implementation App
- (void) playGame
{
  NSOperationQueue *operation;
  static void (^glutOperation)(void) = ^{ glutInit(args.argc, args.argv);
                                          glutSetOption(GLUT_ACTION_ON_WINDOW_CLOSE,
                                                        GLUT_ACTION_GLUTMAINLOOP_RETURNS);
                                          setupDisplay(game->screen);
                                          switchCallbacks(&gameCallbacks);
                                          glutMainLoop();
                                          [start setIsVisible: YES]; };

  [start setIsVisible: NO];
  resetScores();
  initData();
  saveSettings();
  operation = [NSOperationQueue new];
  [operation addOperationWithBlock: glutOperation];
}

- (void) loop
{
  NSEvent *event;

  while((event = [self nextEventMatchingMask: NSAnyEventMask
                       untilDate: [NSDate distantFuture]
                       inMode: NSDefaultRunLoopMode
                       dequeue: YES]) != nil)
  {
    // Process event...

    if([[event window] isEqual: dock] &&
       [event type] == NSEventTypeLeftMouseDown)
    {
      BOOL keepOn;
      NSPoint lastDragLocation, newDragLocation, thisOrigin;

      lastDragLocation = [NSEvent mouseLocation];
      keepOn = YES;
      while(keepOn)
        switch([[dock nextEventMatchingMask: NSLeftMouseDraggedMask | NSLeftMouseUpMask] type])
	{
        case NSLeftMouseDragged:
          newDragLocation = [NSEvent mouseLocation];
          thisOrigin = [dock frame].origin;
          thisOrigin.x += (-lastDragLocation.x + newDragLocation.x);
          thisOrigin.y += (-lastDragLocation.y + newDragLocation.y);
          [dock setFrameOrigin: thisOrigin];
          lastDragLocation = newDragLocation;
	  break;
	case NSLeftMouseUp:
	  keepOn = NO;
	  break;
	default:
	  break;
	}
    }

    [self sendEvent: event];
    [self updateWindows];
  }
}

- (void) applicationDidFinishLaunching: (NSNotification *) notification
{
  NSButton *button;
  Field *field;
  NSText *text;
  NSRect rect;
  NSImage *img;
  NSImageView *imgView;
  SoundMenu *soundMenu;
  GameMenu *gameMenu;
  NSMenu *menu;
  NSMenuItem *item;
  char *path;

  /* Initial setup. */
#ifdef __FreeBSD__
  fpsetmask(0);
#endif
  /* Load settings. */
  path = getFullPath("settings.txt");
  if(path != 0)
    initMainGameSettings(path); /* reads defaults from ~/.gltronrc */
  else {
    printf("fatal: could not settings.txt, exiting...\n");
    exit(1);
  }
  /* Parse arguments. */
  parse_args(*args.argc, args.argv);
  /* Load sound. */
#ifdef SOUND
  printf("initializing sound\n");
  initSound();
  path = getFullPath("gltron.it");
  if(path == 0 || loadSound(path)) 
    printf("error trying to load sound\n");
  else {
    if(game->settings->playSound) {
      playSound();
      free(path);
    }
  }
#endif
  /* Window setup. */
  superview = [start = [[Start alloc] initWithContentRect: rect = NSMakeRect(0, 0, 400, 300)
                           styleMask: NSWindowStyleMaskTitled |
                                      NSWindowStyleMaskClosable |
                                      NSWindowStyleMaskMiniaturizable
                             backing: NSBackingStoreBuffered defer: NO] contentView];
  [start setDelegate: start];
  [start setIsVisible: YES];
  [start setTitle: @"GLtron"];
  [start center];
  [self setMainMenu: menu = [[NSMenu alloc] initWithTitle: @"GLtron"]];
  item = [NSMenuItem new];
  [item setTitle: @"Exit"];
  [item setTarget: [NSThread class]];
  [item setAction: @selector(exit)];
  [menu addItem: item];
  /* Main menu. */
  view[0] = [[NSView alloc] initWithFrame: rect];
  img = [[NSImage alloc] initWithContentsOfFile: @"./gltron.tiff"];
  imgView = [[NSImageView alloc] initWithFrame: NSMakeRect(NSMaxX(rect) - 325, -300, [img size].height * 4, [img size].width * 4)];
  [imgView setImage: img];
  [view[0] addSubview: imgView];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) + 10, NSMinY(rect) + 100, 50, 25)];
  [button setTitle: @"Sound"];
  [button setTarget: soundMenu = [SoundMenu new]];
  [button setAction: @selector(show)];
  [view[0] addSubview: button];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 25, NSMinY(rect) + 50, 50, 25)];
  [button setTitle: @"Play"];
  [button setTarget: self];
  [button setAction: @selector(playGame)];
  [view[0] addSubview: button];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 60, NSMinY(rect) + 100, 50, 25)];
  [button setTitle: @"Game"];
  [button setTarget: gameMenu = [GameMenu new]];
  [button setAction: @selector(show)];
  [view[0] addSubview: button];
  /* Sound driver selection menu. */
  view[1] = [[NSView alloc] initWithFrame: rect];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) + 10, NSMinY(rect) + 70, 50, 25)];
  [button setTitle: @"List"];
  [button setTarget: soundMenu];
  [button setAction: @selector(list)];
  [view[1] addSubview: button];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 60, NSMinY(rect) + 70, 50, 25)];
  [button setTitle: @"Apply"];
  [button setTarget: soundMenu];
  [button setAction: @selector(apply)];
  [view[1] addSubview: button];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 35, NSMinY(rect) + 20, 70, 25)];
  [button setTitle: @"Cancel"];
  [button setTarget: soundMenu];
  [button setAction: @selector(cancel)];
  [view[1] addSubview: button];
  field = [[Field alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 80, NSMinY(rect) + 150, 155, 25)];
  [field setDelegate: field];
  [field setStringValue: [[NSString alloc] initWithFormat: @"%u", game->settings->sound_driver]];
  [view[1] addSubview: field];
  text = [[NSText alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 80, NSMaxY(rect) / 2, 155, 100)];
  [text setEditable: NO];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [text setString: @"Select audio driver."];
  [view[1] addSubview: text];
  /* Sound drivers listing menu. */
  view[2] = [[NSView alloc] initWithFrame: rect];
  text = [[NSText alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 125, (NSMaxY(rect) / 2) - 150, 250, 250)];
  [text setString: [[NSString alloc] initWithUTF8String: drivers]];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [view[2] addSubview: text];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 25, NSMinY(rect) + 20, 50, 25)];
  [button setTitle: @"OK"];
  [button setTarget: soundMenu];
  [button setAction: @selector(back)];
  [view[2] addSubview: button];
  /* Game settings menu. */
  view[3] = [[NSView alloc] initWithFrame: rect];
  button = [[NSButton alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 10, NSMaxY(rect) - 25, 15, 15)];
  [button setTitle: @""];
  [button setTarget: gameMenu];
  [button setAction: @selector(fastFinish)];
  [button setButtonType: NSOnOffButton];
  [button setIntValue: game->settings->fast_finish];
  [view[3] addSubview: button];
  text = [[NSText alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 25, NSMaxY(rect) - 25, 75, 0)];
  [text setString: @"Fast finish"];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [view[3] addSubview: text];
  button = [[NSButton alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 10, NSMaxY(rect) - 50, 15, 15)];
  [button setTitle: @""];
  [button setTarget: gameMenu];
  [button setAction: @selector(eraseCrashed)];
  [button setButtonType: NSOnOffButton];
  [button setIntValue: game->settings->erase_crashed];
  [view[3] addSubview: button];
  text = [[NSText alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 25, NSMaxY(rect) - 50, 100, 0)];
  [text setString: @"Erase crashed"];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [view[3] addSubview: text];
  button = [[NSButton alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 10, NSMaxY(rect) - 75, 15, 15)];
  [button setTitle: @""];
  [button setTarget: gameMenu];
  [button setAction: @selector(showFPS)];
  [button setButtonType: NSOnOffButton];
  [button setIntValue: game->settings->show_fps];
  [view[3] addSubview: button];
  text = [[NSText alloc] initWithFrame: NSMakeRect(NSMinX(rect) + 25, NSMaxY(rect) - 75, 75, 0)];
  [text setString: @"Show FPS"];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [view[3] addSubview: text];
  speedButton = [[NSButton alloc] initWithFrame: NSMakeRect(NSMaxX(rect) - 100, NSMaxY(rect) - 60, 85, 25)];
  do
    if(currentSet->speed == game->settings->speed)
    {
      [speedButton setTitle: [[NSString alloc] initWithUTF8String: currentSet->name]];

      break;
    }
  while((currentSet = currentSet->next) != speedSet);
  [speedButton setTarget: gameMenu];
  [speedButton setAction: @selector(speed)];
  [view[3] addSubview: speedButton];
  text = [[NSText alloc] initWithFrame: NSMakeRect(NSMaxX(rect) - 95, NSMaxY(rect) - 25, 75, 0)];
  [text setString: @"Speed"];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [view[3] addSubview: text];
  button = [[NSButton alloc] initWithFrame: NSMakeRect((NSMaxX(rect) / 2) - 35, NSMinY(rect) + 20, 70, 25)];
  [button setTitle: @"Back"];
  [button setTarget: gameMenu];
  [button setAction: @selector(back)];
  [view[3] addSubview: button];
  /* Setup structures. */
  initGameStructures();
  /* Show main menu. */
  [superview addSubview: view[0]];
  [self loop];
}
@end
