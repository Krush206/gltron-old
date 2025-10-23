/*
  gltron 0.50 beta
  Copyright (C) 1999 by Andreas Umbach <marvin@dataway.ch>
*/

#include "gltron.h"

/* todo: define the globals where I need them */
/* declare them only in gltron.h */

#include "globals.h"

@implementation GLtron
- (int) getElapsedTime
{
#ifdef WIN32
	return timeGetTime();
#else
  return glutGet(GLUT_ELAPSED_TIME);
#endif
}

- (void) mouseWarp
{
  glutWarpPointer(game->screen->w / 2, game->screen->h / 2);
}

- (void) drawGame
{
  GLint i;
  gDisplay *d;
  Player *p;

  polycount = 0;
  glClearColor(.0, .0, .0, .0);
  glDepthMask(GL_TRUE);
  glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  glDepthMask(GL_FALSE);

  for(i = 0; i < vp_max[ game->settings->display_type]; i++) {
    p = &(game->player[ game->settings->content[i] ]);
    if(p->display->onScreen == 1) {
      d = p->display;
      glViewport(d->vp_x, d->vp_y, d->vp_w, d->vp_h);
      [self drawCameraWithPlayer: p display: d];
      [self drawScoreWithPlayer: p display: d];
      if(game->settings->show_ai_status)
	if(p->ai->active == 1)
          [self drawAIWithDisplay: d];
    }
  }

  if(game->settings->show_2d > 0)
    [self drawDebugTextureWithDisplay: game->screen];
  if(game->settings->show_fps)
    [self drawFPSWithDisplay: game->screen];

  /*
  if(game->settings->show_help == 1)
    drawHelp(game->screen);
  */

  /* printf("%d polys\n", polycount); */
}

- (void) displayGame
{
  [self drawGame];
  if(game->settings->mouse_warp)
    [self mouseWarp];
  glutSwapBuffers();
}

- (void) initCustomLights
{
  float col[] = { .77, .77, .77, 1.0 };
  float dif[] =  { 0.4, 0.4, 0.4, 1};
  float amb[] = { 0.25, 0.25, 0.25, 1};

  glEnable(GL_LIGHT0);
  glLightfv(GL_LIGHT0, GL_AMBIENT, amb);
  glLightfv(GL_LIGHT0, GL_SPECULAR, col);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, dif);
}

- (void) initGLGame
{
  printf("OpenGL Info: '%s'\n%s - %s\n", glGetString(GL_VENDOR),
	 glGetString(GL_RENDERER), glGetString(GL_VERSION));

  glShadeModel( GL_FLAT ); /* ugly debug mode */


  if(game->settings->show_alpha) 
    glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
  glFogf(GL_FOG_START, 50.0);
  glFogf(GL_FOG_END, 100.0);
  glFogf(GL_FOG_MODE, GL_LINEAR);
  glFogf(GL_FOG_DENSITY, 0.1);
  glDisable(GL_FOG);


  /* TODO(3): incorporate model stuff */
  /* initLightAndMaterial(); */
  [self initCustomLights];

  glDepthMask(GL_FALSE);
  glDisable(GL_DEPTH_TEST);
}

- (int) initWindow
{
  int win_id;
  /* char buf[20]; */

  glutInitWindowSize(game->settings->width, game->settings->height);
  glutInitWindowPosition(0, 0);

  glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH);

  /*
  sprintf(buf, "%dx%d:16", game->settings->width, game->settings->height);
  glutGameModeString(buf);

  if(glutGameModeGet(GLUT_GAME_MODE_POSSIBLE) &&
     !game->settings->windowMode) {
     win_id = glutEnterGameMode();
  */
    /* check glutGameMode results */
  /*
    printf("Glut game mode status\n");
    printf("  active: %d\n", glutGameModeGet( GLUT_GAME_MODE_ACTIVE));
    printf("  possible: %d\n", glutGameModeGet( GLUT_GAME_MODE_POSSIBLE));
    printf("  width: %d\n", glutGameModeGet( GLUT_GAME_MODE_WIDTH));
    printf("  height: %d\n", glutGameModeGet( GLUT_GAME_MODE_HEIGHT));
    printf("  depth: %d\n", glutGameModeGet( GLUT_GAME_MODE_PIXEL_DEPTH));
    printf("  refresh: %d\n", glutGameModeGet( GLUT_GAME_MODE_REFRESH_RATE));
    printf("  changed display: %d\n",
	   glutGameModeGet( GLUT_GAME_MODE_DISPLAY_CHANGED));

  } else
  */
    win_id = glutCreateWindow("gltron");
  if (win_id < 0) {
    printf("could not create window...exiting\n");
    exit(1);
  }
  return win_id;
}

- (void) shutdownDisplayWithDisplay: (gDisplay *) d
{
  [self deleteTexturesWithDisplay: d];
  [self deleteFonts];
  glutDestroyWindow(d->win_id);
  printf("window destroyed\n");
}

- (void) setupDisplayWithDisplay: (gDisplay *) d
{
  printf("trying to create window\n");
  d->win_id = [self initWindow];
  printf("window created\n");
  /* printf("win_id is %d\n", d->win_id); */
  printf("loading fonts...\n");
  [self initFonts];
  printf("loading textures...\n");
  [self initTextureWithDisplay: game->screen];
}

+ (id) getInstance
{
  static id obj;

  if(obj != nil)
    return obj;

  return obj = [self new];
}

+ (int) argc: (int *) argc argv: (char *[]) argv
{
  char *path;
  id gltron;

#ifdef __FreeBSD__
  fpsetmask(0);
#endif

  glutInit(argc, argv);

  gltron = [self getInstance];
  path = [gltron fullPathWithFile: "settings.txt"];
  if(path != 0)
    [gltron initSettingsWithFile: path]; /* reads defaults from ~/.gltronrc */
  else {
    printf("fatal: could not settings.txt, exiting...\n");
    exit(1);
  }

  [gltron parseArgumentsWithCount: argc vector: argv];

  /* sound */

#ifdef SOUND
  printf("initializing sound\n");
  [gltron initSound];
  path = [gltron fullPathWithFile: "gltron.it"];
  if(path == 0 || [gltron loadSoundWithFile: path])
    printf("error trying to load sound\n");
  else {
    if(game->settings->playSound) {
      [gltron playSound];
      free(path);
    }
  }
#endif

  printf("loading menu\n");
  path = [gltron fullPathWithFile: "menu.txt"];
  if(path != 0)
    pMenuList = [gltron loadMenuWithFile: path];
  else {
    printf("fatal: could not load menu.txt, exiting...\n");
    exit(1);
  }
  printf("menu loaded\n");
  free(path);

  [gltron initGameStructures];
  [gltron resetScores];

  [gltron initData];

  [gltron setupDisplayWithDisplay: game->screen];
  [gltron switchCallbacksWithCallbacks: &guiCallbacks];
  [gltron switchCallbacksWithCallbacks: &guiCallbacks];

  glutMainLoop();

  return 0;
}
@end

int main(int argc, char *argv[])
{
  return [GLtron argc: &argc argv: argv];
}

callbacks gameCallbacks = {
  displayGame,
  idleGame,
  keyGame,
  specialGame,
  initGame,
  initGLGame
};
