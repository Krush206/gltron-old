#include "gltron.h"

/* very brief - just the pause mode */

@implementation GLtron (Pause)
- (void) idlePause
{
#ifdef SOUND
  [self soundIdle];
#endif
  if([self getElapsedTime] - lasttime < 10) return;
  [self timeDiff];

  glutPostRedisplay();
}

- (void) displayPause
{
  [self drawGame];
  [self drawPauseWithDisplay: game->screen];

  if(game->settings->mouse_warp)
    [self mouseWarp];
  glutSwapBuffers();
}

- (void) keyboardPauseWithKey: (unsigned char) key
         x: (int) x
         y: (int) y
{
  switch(key) {
  case 27:
    [self switchCallbacksWithCallbacks: &guiCallbacks];
    break;
  case ' ':
    if(game->pauseflag & PAUSE_GAME_FINISHED)
      [self initData];
    lasttime = [self getElapsedTime];
    [self switchCallbacksWithCallbacks: &gameCallbacks];
    break;
  case 'q':
    exit(1);
    break;
  }
}

- (void) specialPauseWithKey: (int) key
         x: (int) x
         y: (int) y
{
  int i;

  switch(key) {
  case GLUT_KEY_F1: [self defaultDisplayWithNumber: 0]; break;
  case GLUT_KEY_F2: [self defaultDisplayWithNumber: 1]; break;
  case GLUT_KEY_F3: [self defaultDisplayWithNumber: 2]; break;

  case GLUT_KEY_F10:
    game->settings->camType = (game->settings->camType + 1) % CAM_COUNT;
    for(i = 0; i < game->players; i++)
      game->player[i].camera->camType = game->settings->camType;
    break;

  case GLUT_KEY_F5: [self saveSettings]; break;
  }
}

- (void) initPause
{
}

- (void) initPauseGL
{
  [self initGLGame];
}
@end

callbacks pauseCallbacks = {
  displayPause, idlePause, keyboardPause, specialPause, initPause, initPauseGL
};
