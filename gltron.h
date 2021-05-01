/*
  gltron 0.50 beta
  Copyright (C) 1999 by Andreas Umbach <marvin@dataway.ch>
*/

#import <Foundation/Foundation.h>

#ifndef GLTRON_H
#define GLTRON_H

#define SEPERATOR '/'
#define RC_NAME ".gltronrc"
#define CURRENT_DIR "."
#define HOMEVAR "HOME"

/* win32 additions by Jean-Bruno Richard <jean-bruno.richard@mg2.com> */

#ifdef WIN32
#import <windows.h>
#define SOUND
#define M_PI 3.141592654
#define SEPERATOR '\\'
#define RC_NAME "gltron.ini"
#define HOMEVAR "HOMEPATH"
#endif

/* FreeBSD additions by Andrey Zakhatov <andy@icc.surw.chel.su>  */

#ifdef __FreeBSD__
#import <floatingpoint.h>
#endif

/* MacOS additions by Stefan Buchholtz <sbuchholtz@online.de> */

#ifdef macintosh
#import <string.h>
#import <console.h>
#define M_PI 3.141592654
#define SEPERATOR ':'
#define RC_NAME "gltron.ini"
#endif

#define COS(X)	cos( (X) * M_PI/180.0 )
#define SIN(X)	sin( (X) * M_PI/180.0 )

/* glut imports all necessary GL - Headers */

#ifdef FREEGLUT
#import <GL/freeglut.h>
#else
#import <GL/glut.h>
/* #import <freeglut.h> */
#endif

/* use texfont for rendering fonts as textured quads */
/* todo: get rid of that (it's not free) */

/* #import "TexFont.h" */
#import "fonttex.h"

/* menu stuff */

#import "menu.h"

/* TODO(3): incorporate model stuff */
/* model stuff */
#import "model.h"
/* poly-soup stuff */
/* #import "polysoup.h" */

/* do Sound */

#ifdef SOUND
#import "sound.h"
#endif

/* global constants */

#define PLAYERS 4
#define MAX_PLAYERS 4
#define MAX_TRAIL 1000

#define GSIZE 200

#define B_HEIGHT 0
#define TRAIL_HEIGHT 3.5
#define CYCLE_HEIGHT 8
#define WALL_H 12

#define CAM_COUNT 3
#define CAM_CIRCLE_DIST 15
#define CAM_CIRCLE_Z 8.0
#define CAM_FOLLOW_DIST 12
#define CAM_FOLLOW_Z 6.0
#define CAM_FOLLOW_SPEED 0.05
#define CAM_SPEED 2.0

#define EXP_RADIUS_MAX 30
#define EXP_RADIUS_DELTA 0.01

/* these must be < 0 */
#define SPEED_CRASHED -1
#define SPEED_GONE -2

#define FAST_FINISH 40

/* when running as screen saver, wait SCREENSAVER_WAIT ms after each round */

#define SCREENSAVER_WAIT 2000

/* data structures */
/* todo: move to seperate file */

typedef struct callbacks {
  void (*display)(void);
  void (*idle)(void);
  void (*keyboard)(unsigned char, int, int);
  void (*special)(int, int, int);
  void (*init)(void);
  void (*initGL)(void);
} callbacks;

@interface ReadLine: NSObject
- (NSMutableString *) readLine: (const char **) s;
@end

@interface Line: NSObject
{
  float sx, sy, ex, ey;
}

- (void) setSX: (float) o;
- (void) setSY: (float) o;
- (void) setEX: (float) o;
- (void) setEY: (float) o;
- (float) getSX;
- (float) getSY;
- (float) getEX;
- (float) getEY;
@end

@interface Model: NSObject
{
  Mesh *mesh; /* model */
  float color_alpha[4]; /* alpha trail */
  float color_trail[4]; /* solid edges of trail */
  float color_model[4]; /* model color */
}

- (void) setMesh: (Mesh *) o;
- (void) setColorAlpha: (float *) o;
- (void) setColorTrail: (float *) o;
- (void) setColorModel: (float *) o;
- (Mesh *) getMesh;
- (float *) getColorAlpha;
- (float *) getColorTrail;
- (float *) getColorModel;
@end

@interface Data: NSObject
{
  float posx; float posy;

  int dir;
  int last_dir;
  int turn_time;
  
  int score;
  float speed; /* set to -1 when dead */
  float trail_height; /* countdown to zero when dead */
  float exp_radius; /* explosion of the cycle model */
  Line *trails[MAX_TRAIL];
  Line *trail; /* current trail */
}

- (void) setPosX: (float) o;
- (void) setPosY: (float) o;
- (void) setDir: (int) o;
- (void) setLastDir: (int) o;
- (void) setTurnTime: (int) o;
- (void) setScore: (int) o;
- (void) setSpeed: (float) o;
- (void) setTrailHeight: (float) o;
- (void) setExpRadius: (float) o;
- (void) setTrails: (Line *) o index: (int) i;
- (void) setTrail: (float) o;
- (float) getPosX;
- (float) getPosY;
- (int) getDir;
- (int) getLastDir;
- (int) getTurnTime;
- (int) getScore;
- (float) getSpeed;
- (float) getTrailHeight;
- (float) getExpRadius;
- (Line **) getTrails;
- (Line *) getTrail;
@end

@interface Camera: NSObject
{
  float cam[3];
  float target[3];
  float angle;
  int camType;
}

- (void) setCam: (float *) o;
- (void) setTarget: (float *) o;
- (void) setAngle: (float) o;
- (void) setCamType: (int) o;
- (void) getCam: (float *) o;
- (void) getTarget: (float *) o;
- (void) getAngle: (float) o;
- (void) getCamType: (int) o;
@end

@interface AI: NSObject
{
  int active;
  int tdiff; /*  */
  int moves;
  int danger;
}

- (void) setActive: (int) o;
- (void) setTDiff: (int) o;
- (void) setMoves: (int) o;
- (void) setDanger: (int) o;
- (void) getActive: (int) o;
- (void) getTDiff: (int) o;
- (void) getMoves: (int) o;
- (void) getDanger: (int) o;
@end

@interface GDisplay: NSObject
{
  int win_id;     /* nur das globale Window hat eine */
  int h, w;       /* window */
  int vp_x, vp_y; /* viewport */
  int vp_h, vp_w;
  int blending;
  int fog;
  int wall;
  int onScreen;

  unsigned int texFloor; 
  unsigned int texWall;
  unsigned int texGui;
  unsigned int texCrash;
}

- (void) setWinID: (int) o;
- (void) setH: (int) o;
- (void) setW: (int) o;
- (void) setVPX: (int) o;
- (void) setVPY: (int) o;
- (void) setVPH: (int) o;
- (void) setVPW: (int) o;
- (void) setBlending: (int) o;
- (void) setFog: (int) o;
- (void) setWall: (int) o;
- (void) setOnScreen: (int) o;
- (void) setTexFloor: (unsigned int) o;
- (void) setTexWall: (unsigned int) o;
- (void) setTexGUI: (unsigned int) o;
- (void) setTexCrash: (unsigned int) o;
- (int) getWinID;
- (int) getH;
- (int) getW;
- (int) getVPX;
- (int) getVPY;
- (int) getVPH;
- (int) getVPW;
- (int) getBlending;
- (int) getFog;
- (int) getWall;
- (int) getOnScreen;
- (unsigned int) getTexFloor;
- (unsigned int) getTexWall;
- (unsigned int) getTexGUI;
- (unsigned int) getTexCrash;
@end

@interface Player: NSObject
{
  Model *model;
  Data *data;
  Camera *camera;
  GDisplay *display;
  AI *ai;
}

- (void) setModel: (Model *) o;
- (void) setData: (Data *) o;
- (void) setCamera: (Camera *) o;
- (void) setGDisplay: (GDisplay *) o;
- (void) setAI: (AI *) o;
- (Model *) getModel;
- (Data *) getData;
- (Camera *) getCamera;
- (GDisplay *) getGDisplay;
- (AI *) getAI;
@end

@interface SettingsInt: NSObject
{
  NSString *name;
  int *value;
}

- (void) setName: (NSString *) o;
- (void) setValue: (int *) o;
- (NSString *) getName;
- (int *) getValue;
@end

@interface SettingsFloat: NSObject
{
  NSString *name;
  float *value;
}

- (void) setName: (NSString *) o;
- (void) setValue: (float *) o;
- (NSString *) getName;
- (float *) getValue;
@end

/* if you want to add something and make it permanent (via
   .gltronrc) then
   1) add it to Settings in gltron.h
   2) add it to settings.txt
   3) add pointer to initSettingsData() in settings.c
   4) add a default to initMainGameSettings() in settings.c
   5) make a menu entry in menu.txt
*/
@interface Settings: NSObject
{
  int show_help;
  int show_fps;
  int show_wall;
  int show_2d;
  int show_alpha;
  int show_floor_texture;
  int show_glow;
  int show_ai_status;
  int show_model;
  int show_crash_texture;
  int turn_cycle;
  int erase_crashed;
  int fast_finish;
  int display_type; /* 0-2 -> 1, 2 or 4 displays on the screen */
  int content[4]; /* max. 4 individual viewports on the screen */
  int playSound;
  int screenSaver; /* 1: all for players are AIs when the game starts */
  int windowMode;
  int line_spacing;
  int camType;
  int mouse_warp;
  float speed;

  int ai_player1;
  int ai_player2;
  int ai_player3;
  int ai_player4;

  int fov;
  int width;
  int height;

  int sound_driver;

  NSArray *settings_int,
          *settings_float;
}

- (void) setShowHelp: (int) o;
- (void) setShowFPS: (int) o;
- (void) setShowWall: (int) o;
- (void) setShow2D: (int) o;
- (void) setShowAlpha: (int) o;
- (void) setShowFloorTexture: (int) o;
- (void) setShowGlow: (int) o;
- (void) setShowAIStatus: (int) o;
- (void) setShowModel: (int) o;
- (void) setShowCrashTextures: (int) o;
- (void) setTurnCycle: (int) o;
- (void) setEraseCrashed: (int) o;
- (void) setFastFinish: (int) o;
- (void) setDisplayType: (int) o;
- (void) setContent: (int) o index: (int) i;
- (void) setPlaySound: (int) o;
- (void) setScreenSaver: (int) o;
- (void) setWindowMode: (int) o;
- (void) setLineSpacing: (int) o;
- (void) setCamType: (int) o;
- (void) setMouseWarp: (int) o;
- (void) setSpeed: (int) o;
- (void) setAIPlayer1: (int) o;
- (void) setAIPlayer2: (int) o;
- (void) setAIPlayer3: (int) o;
- (void) setAIPlayer4: (int) o;
- (void) setFOV: (int) o;
- (void) setWidth: (int) o;
- (void) setHeight: (int) o;
- (void) setSoundDriver: (int) o;
- (void) setSettingsInt: (NSArray *) o;
- (void) setSettingsFloat: (NSArray *) o;
- (int) getShowHelp;
- (int) getShowFPS;
- (int) getShowWall;
- (int) getShow2D;
- (int) getShowAlpha;
- (int) getShowFloorTexture;
- (int) getShowGlow;
- (int) getShowAIStatus;
- (int) getShowModel;
- (int) getShowCrashTextures;
- (int) getTurnCycle;
- (int) getEraseCrashed;
- (int) getFastFinish;
- (int) getDisplayType;
- (int *) getContent;
- (int) getPlaySound;
- (int) getScreenSaver;
- (int) getWindowMode;
- (int) getLineSpacing;
- (int) getCamType;
- (int) getMouseWarp;
- (int) getSpeed;
- (int) getAIPlayer1;
- (int) getAIPlayer2;
- (int) getAIPlayer3;
- (int) getAIPlayer4;
- (int) getFOV;
- (int) getWidth;
- (int) getHeight;
- (int) getSoundDriver;
- (int) getShowHelpAddr;
- (int *) getShowFPSAddr;
- (int *) getShowWallAddr;
- (int *) getShow2DAddr;
- (int *) getShowAlphaAddr;
- (int *) getShowFloorTextureAddr;
- (int *) getShowGlowAddr;
- (int *) getShowAIStatusAddr;
- (int *) getShowModelAddr;
- (int *) getShowCrashTexturesAddr;
- (int *) getTurnCycleAddr;
- (int *) getEraseCrashedAddr;
- (int *) getFastFinishAddr;
- (int *) getDisplayTypeAddr;
- (int *) getPlaySoundAddr;
- (int *) getScreenSaverAddr;
- (int *) getWindowModeAddr;
- (int *) getLineSpacingAddr;
- (int *) getCamTypeAddr;
- (int *) getMouseWarpAddr;
- (int *) getSpeedAddr;
- (int *) getAIPlayer1Addr;
- (int *) getAIPlayer2Addr;
- (int *) getAIPlayer3Addr;
- (int *) getAIPlayer4Addr;
- (int *) getFOVAddr;
- (int *) getWidthAddr;
- (int *) getHeightAddr;
- (int *) getSoundDriverAddr;
- (NSArray *) getSettingsInt;
- (NSArray *) getSettingsFloat;
@end

@interface Game: NSObject
{
  GDisplay *screen;
  Settings *settings;
  Player *player[MAX_PLAYERS];
  int players;
  int winner;
  int pauseflag;
  int running;

  int gl_error;

  float camAngle;

  fonttex *ftx;
  int fontID;

  Menu** pMenuList;
  Menu* pRootMenu;
  Menu* pCurrent;

  unsigned char* colmap;
  int colwidth;

  int dirsX[];
  int dirsY[];
  
  int lasttime; 
  double dt;

  int polycount;

  float colors_alpha[][4];
  float colors_trail[][4];
  float colors_model[][4];
  int vp_max[];
  float vp_x[3][4];
  float vp_y[3][4];
  float vp_w[3][4];
  float vp_h[3][4];

  char *help[];
}

- (void) setGDisplay: (GDisplay *) o;
- (void) setSettings: (Settings *) o;
- (void) setPlayer: (Player *) o index: (int) i;
- (void) setPlayers: (int) o;
- (void) setWinner: (int) o;
- (void) setPauseFlag: (int) o;
- (void) setRunning: (int) o;
- (GDisplay *) getGDisplay;
- (Settings *) getSettings;
- (Player **) getPlayer;
- (int) getPlayers;
- (int) getWinner;
- (int) getPauseFlag;
- (int) getRunning;
@end

#define PAUSE_GAME_FINISHED 1

#define MAX_FONTS 17

#define HELP_LINES 18
#define HELP_FONT GLUT_BITMAP_9_BY_15
#define HELP_DY 20

/* function prototypes */

/* TODO: sort these */
/* engine.c */

extern void setCol(int x, int y);
extern void clearCol(int x, int y);
extern int getCol(int x, int y);
extern void turn(Data* data, int direction);

extern void idleGame();

extern void initGame();
extern void initGameStructures();

extern void initGameScreen();
extern void initDisplay(GDisplay *d, int type, int p, int onScreen);
extern void changeDisplay();
extern void defaultDisplay(int n);
extern void cycleDisplay(int p);

extern void doTrail(line *t, void(*mark)(int, int));
extern void fixTrails();
extern void clearTrails(Data *data);

/* gltron.c */

extern void mouseWarp();

extern void initData();
extern void drawGame();
extern void displayGame();
extern void initGLGame();

extern void shutdownDisplay(GDisplay *d);
extern void setupDisplay(GDisplay *d);

extern int colldetect(float sx, float sy, float ex, float ey, int dir, int *x, int *y);

extern int allAI();
extern int getElapsedTime(void);
extern void setGameIdleFunc(void);
extern void initGlobals(void);
extern int screenSaverCheck(int t);
extern void scaleDownModel(float height, int i);
extern void setMainIdleFunc(void);

/* various initializations -> init.c */

extern void initFonts();

/* texture initializing -> texture.c */

extern void initTexture();
extern void deleteTextures();

/* help -> character.c */

/* extern void drawLines(int, int, char**, int, int); */

/* ai -> computer.c */

extern int freeway(Data *data, int dir);
extern void getDistPoint(Data *data, int d, int *x, int *y);
extern void doComputer(Player *me, Data *him);

/* keyboard -> input.c */

extern void keyGame(unsigned char k, int x, int y);
extern void specialGame(int k, int x, int y);
extern void parse_args(int argc, char *argv[]);

/* settings -> settings.c */

extern void initMainGameSettings();
extern void saveSettings();

/* menu -> menu.c */

extern void menuAction(Menu* activated);
extern Menu** loadMenuFile(char* filename);
extern void drawMenu(GDisplay *d);
extern void showMenu();
extern void removeMenu();
extern void initMenuCaption(Menu *m);
extern int* getVi(char *szName);

/* file handling -> file.c */

extern char* getFullPath(char* filename);

/* callback stuff -> switchCallbacks.c */

extern void chooseCallback(char*);
extern void restoreCallbacks();
extern void switchCallbacks(callbacks*);
extern void updateCallbacks();

/* probably common graphics stuff -> graphics.c */

extern void checkGLError(char *where);
extern void rasonly(GDisplay *d);
extern void drawFPS(GDisplay *d);
extern void drawText(int x, int y, int size, char *text);
extern int hsv2rgb(float, float, float, float*, float*, float*);
extern void colorDisc();

/* gltron game graphics -> gamegraphics.c */
extern void drawDebugTex(GDisplay *d);
extern void drawScore(Player *p, GDisplay *d);
extern void drawFloor(GDisplay *d);
extern void drawTraces(Player *, GDisplay *d, int instance);
extern void drawPlayers(Player *);
extern void drawWalls(GDisplay *d);
extern void drawCam(Player *p, GDisplay *d);
extern void drawAI(GDisplay *d);
extern void drawPause(GDisplay *d);
extern void drawHelp(GDisplay *d);

/* font stuff ->fonts.c */
extern void initFonts();
extern void deleteFonts();

extern void resetScores();


extern void draw( void );


extern void chaseCamMove();
extern void timediff();
extern void camMove();

extern void movePlayers();

extern callbacks gameCallbacks;
extern callbacks guiCallbacks;
/* extern callbacks chooseModelCallbacks; */
extern callbacks pauseCallbacks;

#endif






