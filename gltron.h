/*
  gltron 0.50 beta
  Copyright (C) 1999 by Andreas Umbach <marvin@dataway.ch>
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <objc/Object.h>

#ifndef GLTRON_H
#define GLTRON_H

#define SEPERATOR '/'
#define RC_NAME ".gltronrc"
#define CURRENT_DIR "."
#define HOMEVAR "HOME"

/* win32 additions by Jean-Bruno Richard <jean-bruno.richard@mg2.com> */

#ifdef WIN32
#include <windows.h>
#define SOUND
#define M_PI 3.141592654
#define SEPERATOR '\\'
#define RC_NAME "gltron.ini"
#define HOMEVAR "HOMEPATH"
#endif

/* FreeBSD additions by Andrey Zakhatov <andy@icc.surw.chel.su>  */

#ifdef __FreeBSD__
#include <floatingpoint.h>
#endif

/* MacOS additions by Stefan Buchholtz <sbuchholtz@online.de> */

#ifdef macintosh
#include <string.h>
#include <console.h>
#define M_PI 3.141592654
#define SEPERATOR ':'
#define RC_NAME "gltron.ini"
#endif

#define COS(X)	cos( (X) * M_PI/180.0 )
#define SIN(X)	sin( (X) * M_PI/180.0 )

/* glut includes all necessary GL - Headers */

#ifdef FREEGLUT
#include "freeglut.h"
#else
#include <GL/glut.h>
/* #include <freeglut.h> */
#endif

/* use texfont for rendering fonts as textured quads */
/* todo: get rid of that (it's not free) */

/* #include "TexFont.h" */
#include "fonttex.h"

/* menu stuff */

#include "menu.h"

/* TODO(3): incorporate model stuff */
/* model stuff */
#include "model.h"
/* poly-soup stuff */
/* #include "polysoup.h" */

/* do Sound */

#ifdef SOUND
#include "sound.h"
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

typedef struct line {
  float sx, sy, ex, ey;
} line;

typedef struct Model {
  Mesh* mesh; /* model */
  float color_alpha[4]; /* alpha trail */
  float color_trail[4]; /* solid edges of trail */
  float color_model[4]; /* model color */
} Model;

typedef struct Data {
  float posx; float posy;

  int dir; int last_dir;
  int turn_time;
  
  int score;
  float speed; /* set to -1 when dead */
  float trail_height; /* countdown to zero when dead */
  float exp_radius; /* explosion of the cycle model */
  line trails[MAX_TRAIL];
  line *trail; /* current trail */
} Data;

typedef struct Camera {
  float cam[3];
  float target[3];
  float angle;
  int camType;
} Camera;

typedef struct AI {
  int active;
  int tdiff; /*  */
  int moves;
  int danger;
} AI;

typedef struct gDisplay {
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
} gDisplay;

typedef struct Player {
  Model *model;
  Data *data;
  Camera *camera;
  gDisplay *display;
  AI *ai;
} Player;

/* if you want to add something and make it permanent (via
   .gltronrc) then
   1) add it to Settings in gltron.h
   2) add it to settings.txt
   3) add pointer to initSettingsData() in settings.c
   4) add a default to initMainGameSettings() in settings.c
   5) make a menu entry in menu.txt
*/
typedef struct Settings {
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

} Settings;

typedef struct Game {
  gDisplay *screen;
  Settings *settings;
  Player player[MAX_PLAYERS];
  int players;
  int winner;
  int pauseflag;
  int running;
} Game;

typedef struct settings_int {
  char name[32];
  int *value;
} settings_int;

typedef struct settings_float {
  char name[32];
  float *value;
} settings_float;

#define PAUSE_GAME_FINISHED 1

extern callbacks guiCallbacks;
extern callbacks pauseCallbacks;
extern callbacks gameCallbacks;

extern int gl_error;

extern settings_int *si;
extern int si_count;
extern settings_float *sf;
extern int sf_count;

extern Game main_game;
extern Game *game;
extern float camAngle;

/* extern TexFont *txf; */
extern fonttex *ftx;
extern int fontID;
#define MAX_FONTS 17

extern Menu** pMenuList;
extern Menu* pRootMenu;
extern Menu* pCurrent;

extern unsigned char* colmap;
extern int colwidth;

extern int dirsX[];
extern int dirsY[];

extern int lasttime; 
extern double dt; /* milliseconds since last frame */

extern int polycount;

extern float colors_alpha[][4];
extern float colors_trail[][4];
extern float colors_model[][4];
extern int vp_max[];
extern float vp_x[3][4];
extern float vp_y[3][4];
extern float vp_w[3][4];
extern float vp_h[3][4];

#define HELP_LINES 18
#define HELP_FONT GLUT_BITMAP_9_BY_15
#define HELP_DY 20

extern char *help[];

@interface GLtron: Object
- (int) getElapsedTime;
- (void) mouseWarp;
- (void) drawGame;
- (void) displayGame;
- (void) initCustomLights;
- (void) initGLGame;
- (int) initWindow;
- (void) shutdownDisplayWithDisplay: (gDisplay *) d;
- (void) setupDisplayWithDisplay: (gDisplay *) d;
+ (int) argc: (int *) argc argv: (char *[]) argv;
+ (id) getInstance;
@end

@interface GLtron (Computer)
- (int) freewayWithData: (Data *) data direction: (int) dir;
- (void) getDistancePointWithData: (Data *) data
         direction: (int) d
         x: (int *) x
         y: (int *) y;
- (void) doComputerWithPlayer: (Player *) me data: (Data *) him;
@end

@interface GLtron (Engine)
- (void) setColWithX: (int) x y: (int) y;
- (void) clearColWithX: (int) x y: (int) y;
- (int) getColWithX: (int) x y: (int) y;
- (void) turnWithData: (Data *) data direction: (int) direction;
- (void) initDisplayWithDisplay: (gDisplay *) d
         type: (int) type
         player: (int) p
         onScreen: (int) onScreen;
- (void) changeDisplay;
- (void) initGame;
- (void) initGameStructures;
- (void) initData;
- (int) collDetectWithX: (float) sx
         y: (float) sy
         x: (float) ex
         y: (float) ey
         direction: (int) dir
         x: (int *) x
         y: (int *) y;
- (void) doTrailWithLine: (line *) t
         mark: (IMP) mark
         selector: (SEL) sel;
- (void) fixTrails;
- (void) clearTrailsWithData: (Data *) data;
- (void) idleGame;
- (void) defaultDisplayWithNumber: (int) n;
- (void) initGameDisplay;
- (void) cycleDisplay: (int) p;
- (void) resetScores;
- (void) movePlayers;
- (void) timeDiff;
- (void) chaseCamMove;
- (void) camMove;
@end

@interface GLtron (File)
- (char *) fullPathWithFile: (char *) filename;
@end

@interface GLtron (Fonts)
- (void) initFonts;
- (void) deleteFonts;
@end

@interface GLtron (FontTexture)
- (void) getLineWithBuffer: (char *) buf
         size: (int) size
         file: (FILE *) f;
- (fonttex *) loadFontWithFile: (char *) filename;
- (void) unloadFontWithFontTexture: (fonttex *) ftx;
- (void) establishTextureWithFontTexture: (fonttex *) ftx
         mipmaps: (unsigned char) setupMipmaps;
- (void) renderStringWithFontTexture: (fonttex *) ftx
         string: (char *) string
         length: (int) len;
@end

@interface GLtron (GameGraphics)
- (void) drawDebugTextureWithDisplay: (gDisplay *) d;
- (void) drawScoreWithPlayer: (Player *) p display: (gDisplay *) d;
- (void) drawFloorWithDisplay: (gDisplay *) d;
- (void) drawTracesWithPlayer: (Player *) p
         display: (gDisplay *) d
         instance: (int) instance;
- (void) drawCrashWithRadius: (float) radius;
- (void) drawCycleWithPlayer: (Player *) p;
- (int) playerVisibleWithPlayer: (Player *) eye
        player: (Player *) target;
- (void) drawPlayersWithPlayer: (Player *) p;
- (void) drawGlowWithPlayer: (Player *) p
         display: (gDisplay *) d
         dimension: (float) dim;
- (void) drawWallsWithDisplay: (gDisplay *) d;
- (void) drawCameraWithPlayer: (Player *) p display: (gDisplay *) d;
- (void) drawAIWithDisplay: (gDisplay *) d;
- (void) drawPauseWithDisplay: (gDisplay *) display;
@end

@interface GLtron (Geometry)
- (float) lengthWithVertice: (float[3]) v;
- (void) normalizeWithVertice: (float[3]) v;
- (void) crossProdWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout;
- (void) normalizeCrossProdWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout;
- (float) scalarProdWithVertice: (float[3]) v1 vertice: (float[3]) v2;
- (void) verticeSubWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout;
- (void) verticeAddWithVertice: (float[3]) v1
         vertice: (float[3]) v2
         out: (float[3]) vout;
@end

@interface GLtron (Graphics)
- (void) checkGLErrorWithSignature: (char *) where;
- (void) rasterizerOnlyWithDisplay: (gDisplay *) d;
- (void) drawFPSWithDisplay: (gDisplay *) d;
- (void) drawTextWithX: (int) x
         y: (int) y
         size: (int) size
         text: (char *) text;
- (int) HSVToRGBWithH: (float) h
        s: (float) s
        v: (float) v
        r: (float *) r
        g: (float *) g
        b: (float *) b;
- (void) colorDisc;
@end

@interface GLtron (GUI)
- (void) guiProjectionWithX: (int) x y: (int) y;
- (void) displayGui;
- (void) idleGui;
- (void) keyboardGuiWithKey: (unsigned char) k
         x: (int) x
         y: (int) y;
- (void) specialGuiWithKey: (int) key x: (int) x y: (int) y;
- (void) initGui;
- (void) initGLGui;
@end

@interface GLtron (Input)
- (void) keyGameWithKey: (unsigned char) k
         x: (int) x
         y: (int) y;
- (void) specialGameWithKey: (int) k
         x: (int) x
         y: (int) y;
- (void) parseArgumentsWithCount: (int *) argc
         vector: (char *[]) argv;
@end

@interface GLtron (Menu)
- (void) changeActionWithName: (char *) name;
- (void) menuActionWithMenu: (Menu *) activated;
- (void) initMenuCaptionWithMenu: (Menu *) m;
- (void) getNextLineWithBuffer: (char *) buf
         size: (int) bufsize
         file: (FILE *) f;
- (Menu *) loadMenuWithFile: (FILE *) f
           buffer: (char *) buf
           parent: (Menu *) parent
           level: (int) level;
- (Menu **) loadMenuWithFile: (char *) filename;
- (void) drawMenuWithDisplay: (gDisplay *) d;
@end

@interface GLtron (Model)
- (void) rescaleVertices: (float *) vertices
         size: (float) size
         count: (int) nVertices
         box: (float *) bbox;
- (Mesh *) loadModelWithFile: (const char *) filename
           size: (float) size
           flags: (int) flags;
- (void) setAmbientWithMesh: (Mesh *) mesh
         material: (int) material
         color: (float[4]) color;
- (void) setDiffuseWithMesh: (Mesh *) mesh
         material: (int) material
         color: (float[4]) color;
- (void) setSpecularWithMesh: (Mesh *) mesh
         material: (int) material
         color: (float[4]) color;
- (void) setAlphaWithMesh: (Mesh *) mesh alpha: (float) alpha;
- (void) unloadModelWithMesh: (Mesh *) mesh;
@end

@interface GLtron (ModelGraphics)
- (void) drawWithMeshPart: (MeshPart *) meshpart flag: (int) flag;
- (void) drawExplosionWithMeshPart: (MeshPart *) meshpart
         radius: (float) radius
         flag: (int) flag;
- (void) printColorWithValues: (float *) values count: (int) count;
- (void) drawModelWithMesh: (Mesh *) mesh
         mode: (int) mode
         flag: (int) flag;
- (void) drawExplosionWithMesh: (Mesh *) mesh
         radius: (float) radius
         mode: (int) mode
         flag: (int) flag;
@end

@interface GLtron (Material)
- (int) loadMaterialsWithFile: (const char *) filename
        materials: (Material **) materials;
@end

@interface GLtron (Pause)
- (void) idlePause;
- (void) displayPause;
- (void) keyboardPauseWithKey: (unsigned char) k
         x: (int) x
         y: (int) y;
- (void) specialPauseWithKey: (int) k
         x: (int) x
         y: (int) y;
- (void) initPause;
- (void) initPauseGL;
@end

@interface GLtron (Settings)
- (void) initSettingDataWithFile: (char *) filename;
- (int *) getViWithName: (char *) name;
- (void) initSettingsWithFile: (char *) filename;
- (void) saveSettings;
@end

@interface GLtron (SGI)
- (sgi_texture *) loadSGITextureWithFile: (char *) filename;
- (void) unloadSGITextureWithSGITexture: (sgi_texture *) tex;
@end

@interface GLtron (Sound)
- (void) initSound;
- (int) loadSoundWithFile: (char *) name;
- (int) playSound;
- (int) stopSound;
- (void) deleteSound;
- (void) soundIdle;
@end

@interface GLtron (Callbacks)
- (void) switchCallbacksWithCallbacks: (callbacks *) new;
- (void) updateCallbacks;
- (void) restoreCallbacks;
- (void) chooseCallbackWithName: (char *) name;
@end

@interface GLtron (Texture)
- (void) deleteTexturesWithDisplay: (gDisplay *) d;
- (void) loadTextureWithFile: (char *) filename
         format: (int) format;
- (void) initTextureWithDisplay: (gDisplay *) d;
@end

static inline void displayGui(void)
{
  [[GLtron getInstance] displayGui];
}

static inline void idleGui(void)
{
  [[GLtron getInstance] idleGui];
}

static inline void keyboardGui(unsigned char k, int x, int y)
{
  [[GLtron getInstance] keyboardGuiWithKey: k x: x y: y];
}

static inline void specialGui(int k, int x, int y)
{
  [[GLtron getInstance] specialGuiWithKey: k x: x y: y];
}

static inline void initGui(void)
{
  [[GLtron getInstance] initGui];
}

static inline void initGLGui(void)
{
  [[GLtron getInstance] initGLGui];
}

static inline void displayPause(void)
{
  [[GLtron getInstance] displayPause];
}

static inline void idlePause(void)
{
  [[GLtron getInstance] idlePause];
}

static inline void keyboardPause(unsigned char k, int x, int y)
{
  [[GLtron getInstance] keyboardPauseWithKey: k x: x y: y];
}

static inline void specialPause(int k, int x, int y)
{
  [[GLtron getInstance] specialPauseWithKey: k x: x y: y];
}

static inline void initPause(void)
{
  [[GLtron getInstance] initPause];
}

static inline void initPauseGL(void)
{
  [[GLtron getInstance] initPauseGL];
}

static inline void displayGame(void)
{
  [[GLtron getInstance] displayGame];
}

static inline void idleGame(void)
{
  [[GLtron getInstance] idleGame];
}

static inline void keyGame(unsigned char k, int x, int y)
{
  [[GLtron getInstance] keyGameWithKey: k x: x y: y];
}

static inline void specialGame(int k, int x, int y)
{
  [[GLtron getInstance] specialGameWithKey: k x: x y: y];
}

static inline void initGame(void)
{
  [[GLtron getInstance] initGame];
}

static inline void initGLGame(void)
{
  [[GLtron getInstance] initGLGame];
}

#endif
