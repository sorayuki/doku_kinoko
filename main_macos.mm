#include "doku.h"
#include <Cocoa/Cocoa.h>
#include <QuartzCore/QuartzCore.h> // For CALayer
#include <iostream>

// Globals
GLEnv g_glEnv;
RenderDoku g_renderDoku;
bool g_running = true;

@interface DokuView : NSView
@end

@implementation DokuView

- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    [self setWantsLayer:YES];
    self.layer = [CALayer layer];
    self.layer.contentsScale = [NSScreen mainScreen].backingScaleFactor;
  }
  return self;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

// Handle key down similar to WM_KEYDOWN
- (void)keyDown:(NSEvent *)event {
  if (event.keyCode == 53) { // Escape key
    g_running = false;
    [NSApp terminate:nil];
  }
}

@end

@interface DokuAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) DokuView *view;
@end

@implementation DokuAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  std::cout << "Starting doku on macOS..." << std::endl;

  NSRect frame = NSMakeRect(0, 0, 800, 600);
  NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                         NSWindowStyleMaskMiniaturizable |
                         NSWindowStyleMaskResizable;

  self.window = [[NSWindow alloc] initWithContentRect:frame
                                            styleMask:styleMask
                                              backing:NSBackingStoreBuffered
                                                defer:NO];
  [self.window setTitle:@"Doku Native"];
  [self.window center];

  self.view = [[DokuView alloc] initWithFrame:frame];
  [self.window setContentView:self.view];
  [self.window setDelegate:self];
  [self.window makeKeyAndOrderFront:nil];
  [self.window makeFirstResponder:self.view];

  // Initialize rendering
  // ANGLE on macOS typically expects a CALayer as the window handle
  if (!g_glEnv.Init((__bridge void *)self.view.layer)) {
    std::cerr << "Failed to initialize generic GL environment" << std::endl;
  }

  g_renderDoku.Init();
  g_renderDoku.Resize(frame.size.width, frame.size.height);
}

- (void)windowDidResize:(NSNotification *)notification {
  if (!g_running)
    return;
  NSSize size = [self.view bounds].size;
  g_renderDoku.Resize(size.width, size.height);
}

- (void)windowWillClose:(NSNotification *)notification {
  g_running = false;
  [NSApp terminate:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:
    (NSApplication *)sender {
  return YES;
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSApplication *app = [NSApplication sharedApplication];
    DokuAppDelegate *delegate = [[DokuAppDelegate alloc] init];
    [app setDelegate:delegate];
    [app setActivationPolicy:NSApplicationActivationPolicyRegular];

    [app finishLaunching];

    while (g_running) {
      NSEvent *event;
      while ((event = [app nextEventMatchingMask:NSEventMaskAny
                                       untilDate:[NSDate distantPast]
                                          inMode:NSDefaultRunLoopMode
                                         dequeue:YES])) {
        [app sendEvent:event];
        [app updateWindows];
      }

      if (!g_running)
        break;

      // Render loop
      g_renderDoku.Tick();
      g_renderDoku.Render();
      g_glEnv.Swap();

      // Simple sleep to prevent 100% CPU usage in this simple loop
      [NSThread sleepForTimeInterval:0.001];
    }

    g_glEnv.Destroy();
  }
  return 0;
}
