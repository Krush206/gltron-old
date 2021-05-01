#include "start.h"
#include "gltron.h"

static NSText *drvString;
static NSNumber *drvOption;

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

@implementation Driver
- (void) apply
{
  NSWindow *i;

  md_device = game->settings->sound_driver = [drvOption unsignedIntValue];
  for(i in [NSApp windows])
    [i close];
  [NSApp stop: self];
}
@end

@implementation List
- (void) show
{
  NSWindow *window;
  NSText *text;

  window = [[NSWindow alloc] initWithContentRect: NSMakeRect(0, 0, 250, 350)
                             styleMask: NSWindowStyleMaskTitled |
                                        NSWindowStyleMaskClosable |
                                        NSWindowStyleMaskMiniaturizable
                             backing: NSBackingStoreBuffered defer: NO];
  [window setTitle: @"Drivers"];
  [window center];
  [window setIsVisible: YES];
  text = [[NSText alloc] initWithFrame: NSMakeRect(0, 0, 250, 250)];
  [text setString: [[NSString alloc] initWithUTF8String: drivers]];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [[window contentView] addSubview: text];
}
@end

@implementation Start
- (void) windowShouldClose: (NSWindow *) sender
{
  [NSThread exit];
}
@end

@implementation App
- (void) run
{
  Start *start;
  NSEvent *event;
  NSButton *button;
  Field *field;
  NSView *view;
  NSText *text;
  NSRect rect, dockRect;
  NSWindow *dock;
  NSImage *img;
  NSImageView *imgView;
  NSDockTile *tile;

  start = [[Start alloc] initWithContentRect: rect = NSMakeRect(0, 0, 300, 250)
                         styleMask: NSWindowStyleMaskTitled |
                                    NSWindowStyleMaskClosable |
                                    NSWindowStyleMaskMiniaturizable
                         backing: NSBackingStoreBuffered defer: NO];
  img = [self applicationIconImage];
  dock = [[NSWindow alloc] initWithContentRect: dockRect = NSMakeRect(0, 0, [img size].width, [img size].height)
                           styleMask: NSWindowStyleMaskBorderless
                           backing: NSBackingStoreBuffered defer: NO];
  imgView = [[NSImageView alloc] initWithFrame: dockRect];
  [dock setTitle: @"GLtron"];
  [dock setOpaque: NO];
  [dock setBackgroundColor: [NSColor clearColor]];
  [imgView setImage: [[NSImage alloc] initWithContentsOfFile: @"/home/garcia/Downloads/GLTron.png"]];
  [dock setMiniwindowImage: [imgView image]];
  [[dock contentView] addSubview: imgView];
  [dock setIsVisible: YES];
  [[[tile = [self dockTile] contentView] window] close];
  [tile setContentView: [dock contentView]];
  [tile display];
  [start setTitle: @"GLtron"];
  [start center];
  [start setIsVisible: YES];
  button = [[NSButton alloc] initWithFrame: NSMakeRect(NSMaxX(rect) / 2, NSMaxY(rect) / 4, 50, 25)];
  [button setTitle: @"List"];
  [button setTarget: [List new]];
  [button setAction: @selector(show)];
  [view = [start contentView] addSubview: button];
  button = [[NSButton alloc] initWithFrame: NSMakeRect(NSMaxX(rect) / 3, NSMaxY(rect) / 4, 50, 25)];
  [button setTitle: @"Apply"];
  [button setTarget: [Driver new]];
  [button setAction: @selector(apply)];
  [view addSubview: button];
  field = [[Field alloc] initWithFrame: NSMakeRect(NSMaxX(rect) / 4, NSMaxY(rect) / 2, 155, 25)];
  [field setDelegate: field];
  [view addSubview: field];
  text = [[NSText alloc] initWithFrame: NSMakeRect(NSMaxX(rect) / 4, NSMaxY(rect) / 2, 155, 100)];
  [text setEditable: NO];
  [text setDrawsBackground: NO];
  [text setSelectable: NO];
  [text setAlignment: NSTextAlignmentCenter];
  [text setString: @"Select audio driver."];
  [view addSubview: text];
  [start setDelegate: start];
  [self setDelegate: self];
  [self finishLaunching];
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
@end
