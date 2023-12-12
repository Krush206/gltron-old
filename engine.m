#import "gltron.h"

@implementation Engine
static Engine *engine;

static float colors_alpha[][4] = { { .8, 0.1, 0.2 , 0.6}, { 0.856, 0.42, 0.25, 0.6},
		       { 0.1, 1.0, 0.2, 0.6 }, { 0.7, 0.7, 0.7, 0.6 } };
static float colors_trail[][4] = { { 1.0, 0.2, 0.4, 1.0 }, { 0.2, 0.3, 1.0, 1.0 },
		       { 0.2, 1.0, 0.5, 1.0 }, { 0.5, 0.5, 0.5, 1.0 } };
static float colors_model[][4] = { { 1.0, 1.0, 0.0, 1.0 }, { 1.0, 0.1, 0.1, 1.0 },
		       { 0.3, 1.0, 0.8, 1.0 }, { 0.8, 0.8, 0.8, 1.0 } };

static int vp_max[] = { 1, 2, 4 },
	   dirsX[] = { 0, -1, 0, 1 },
	   dirsY[] = { -1, 0, 1, 0 };
static float vp_x[3][4] = { { 1 },    { 1, 1 },  { 1, 16, 1, 16 } };
static float vp_y[3][4] = { { 1 },    { 0.5, 12.5 },   { 1, 1, 12.5, 12.5 } };
static float vp_w[3][4] = { { 30 },   { 30, 30 }, { 14, 14, 14, 14 } };
static float vp_h[3][4] = { { 22.5 }, { 11.5, 11.5 }, { 10.5, 10.5, 10.5, 10.5 } };
static double dt;

- (void) setCol: (int) x y: (int) y
{
  int offset, mask;

  if(x < 0 || x > GSIZE - 1 || y < 0 || y > GSIZE - 1) {
    printf("setCol: %d %d is out of range!\n", x, y);
    return;
  }
  offset = x / 8 + y * colwidth;
  mask = 128 >> (x % 8);
  ((unsigned char *) [colmap mutableBytes])[offset] |= mask;
}

- (void) clearCol: (int) x y: (int) y
{
  int offset, mask;

  if(x < 0 || x > GSIZE - 1 || y < 0 || y > GSIZE - 1) {
    printf("clearCol: %d %d is out of range!\n", x, y);
    return;
  }
  offset = x / 8 + y * colwidth;
  mask = 128 >> (x % 8);
  ((unsigned char *) [colmap mutableBytes])[offset] &= !mask;
}

- (int) getCol: (int) x y: (int) y
{
  int offset, mask;

  if(x < 0 || x > GSIZE - 1 || y < 0 || y > GSIZE - 1)
    return -1;
  offset = x / 8 + y * colwidth;
  mask = 128 >> (x % 8);
  return ((unsigned char *) [colmap mutableBytes])[offset] & mask;
}

- (void) turn: (Data *) data direction: (int) direction
{
  Line *new;

  if([data getSpeed] > 0) { /* only allow turning when in-game */
    [[data getTrail] setEX: [data getPosX]];
    [[data getTrail] setEY: [data getPosY]];

    /* smooth turning */
    [data setLastDir: [data getDir]];
    [data setTurnTime: [super getElapsedTime]];

    [data setDir: &[data getDir][direction] % 4];

    new = [&[data getTrail[1] new];
    [new setEX: [[data getTrail] getEX];
    [new setSX: [new getEX]];
    [new setEY: [[data getTrail] getEY];
    [new setSY: [new getEY]];

    [data setTrail: new];
  }
}


- (void) initDisplay: (GDisplay *) d type: (int) type index: (int) p onScreen: (int) onScreen {
  Game *game = [Game getGame];
  GDisplay *gdisplay = [game getScreen];
  int field;

  field = [gdisplay getVPW] / 32;
  [d setH: [gdisplay getW]];
  [d setW: [gdisplay getH]];
  [d setVPX: vp_x[type][p] * field];
  [d setVPY: vp_y[type][p] * field];
  [d setVPW: vp_w[type][p] * field];
  [d setVPH: vp_h[type][p] * field];
  [d setBlending: 1];
  [d setFog: 0];
  [d setWall: 0];
  [d setOnScreen: onScreen];
}  

- (void) changeDisplay {
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];
  int i;

  for(i = 0; i < [game getPlayers]; i++)
    [[[game getPlayer][i] getDisplay] setOnScreen: 0];
  for(i = 0; i < vp_max[game->settings->display_type]; i++)
       initDisplay([[game getPlayer][[settings getContent][i]] getDisplay], 
		   [settings getDisplayType], i, 1);
}

- (void) initGameStructures { /* called only once */
  /* init game screen */
  /* init players. for each player: */
  /*   init model */
  /*   init display */
  /*   init ai */
  /*   create data */
  /*   create camera */

  Game *game = [Game getGame];
  Model *model = [Model new];
  GDisplay *d;
  int i, j;
  /* int onScreen; */
  /* Data *data; */
  /* Camera *c; */
  /* Model *m; */
  AI *ai;
  Player *p;
  NSString *path;

  [game setWinner: -1];
  [game setScreen: d = [GDisplay new]];
  [d setH: [game getHeight]];
  [d setW: [game getWidth]];
  [d setVPX: 0];
  [d setVPY: 0];
  [d setVPH: [d getH]];
  [d setVPW: [d getW]];
  [d setBlending: 1];
  [d setFog: 0];
  [d setWall: 1];
  [d setOnScreen: -1];

  [game setPlayers: PLAYERS];
  for(i = 0; i < game->players; i++) {
    [p[i] = [Player new]];
    [p[i] setModel: [Model new]];
    [p[i] setDisplay: [Display new]];
    [p[i] setAI: [AI new]];
    [p[i] setData: [Data new]];
    [p[i] setCamera: [Camera new]];

    // init model & display & ai

    // load player mesh, currently only one type
    path = getFullPath(@"t-u-low.obj");
    // path = getFullPath("tron-med.obj");
    if(path != nil)
      // model size == CYCLE_HEIGHT
      [[p[i] getModel] setMesh: [model loadModel: path size: CYCLE_HEIGHT flags: 1];
    else {
      printf("fatal: could not load model - exiting...\n");
      exit(1);
    }

    /* copy contents from colors_a[] to model struct */
    for(j = 0; j < 4; j++) {
      p->model->color_alpha[j] = colors_alpha[i][j];
      p->model->color_trail[j] = colors_trail[i][j];
      p->model->color_model[j] = colors_model[i][j];
    }
    // set material 0 to color_model
    setMaterialAmbient(p->model->mesh, 0, p->model->color_model);
    setMaterialDiffuse(p->model->mesh, 0, p->model->color_model);

    ai = [p[i] getAI];
    [ai setActive: (i == 0 && [[Settings getSettings] getScreensaver] == 0) ? -1 : 1];
    [ai setTDiff: 0];
    [ai setMoves: 0];
    [ai setDanger: 0];
  }

  [self changeDisplay];
  [self initData];
}

- (void) initData {
  /* for each player */
  /*   init camera (if any) */
  /*   init data */
  /*   reset ai (if any) */
  int i;
  Game *game = [Game getGame];
  Player *player = [game getPlayer];
  Settings *settings = [Settings getSettings];
  Camera *cam;
  Data *data;
  AI *ai;
  Model *model;

  for(i = 0; i < [game getPlayers]; i++) {
    data = [player[i] getData];
    cam = [player[i] getCamera];
    ai = [player[i] getAI];
    model = [player[i] getModel];

    setMaterialAlphas(model->mesh, 1.0);

    [cam setType: [settings getCamType]];
    [cam getTarget][0] = [data getPosX];
    [cam getTarget][1] = [data getPosY];
    [cam getTarget][2] = 0;

    [cam getCam][0] = [data getPosX] + CAM_CIRCLE_DIST;
    [cam getCam][1] = [data getPosY];
    [cam getCam][2] = CAM_CIRCLE_Z;

    [data setPosX: GSIZE / 2 + GSIZE / 4 *
      cos (((float) (i * 2 * M_PI) / (float) [game getPlayers])];
    [data setPosY: GSIZE / 2 + GSIZE / 4 * 
      sin ((float) (i * 2 * M_PI) / (float) [game getPlayers])];

    [data setDir: rand() & 3];
    [data setLastDir: [data getDir]];
    [data setTurnTime: 0];

    [data setSpeed: [settings getSpeed]];
    [data setTrailHeight: TRAIL_HEIGHT];
    [data setTrail: [data getTrails]];
    [data setExpRadius: 0];

    [data setTrailEX: [data getPosX]];
    [data setTrailSX: [data getPosX]];
    [data setTrailEY: [data getPosY]];
    [data setTrailSY: [data getPosY]];

    [ai setTDiff: 0];
    [ai setMoves: 0];
    [ai setDanger: 0];
  }

  [game setRunning: [game getPlayers]]; /* everyone is alive */
  [game setWinner: -1];
  /* colmap */
  colwidth = (GSIZE + 7) / 8;
  if(colmap == nil) colmap = [[NSMutableData alloc] initWithLength: colwidth * GSIZE];

  lasttime = getElapsedTime();
  [game setPauseFlag: 0];
}


- (int) collDetect: (float) sx sy: (float) sy ex: (float) ex ey: (float) ey dir: (int) dir x: (int *) x y: (int *) y {
  if(getenv("TRON_NO_COLL")) return 0;
  *x = (int) sx;
  *y = (int) sy;

  while(*x != (int) ex || *y != (int) ey) {
    *x += dirsX[dir];
    *y += dirsY[dir];
    if([self getCol: *x y: *y]) {
      /* check if x/y are in bounds and correct it */
      if(*x < 0) *x = 0;
      if(*x >= GSIZE) *x = GSIZE -1; 
      if(*y < 0) *y = 0;
      if(*y >= GSIZE) *y = GSIZE -1; 
      return 1;
    }
  }
  return 0;
}

- (void) doTrail: (Line *) t selector: (SEL) mark
  int x, y, ex, ey, dx, dy;

  x = ([t getSX] < [t getEX]) ? [t getSX] : [t getEX];
  y = ([t getSY] < [t getEY]) ? [t getSY] : [t getEY];
  ex = ([t getSX] > [t getSY]) ? [t getSX] : [t getEX];
  ey = ([t getSY] > [t getEY]) ? [t getSY] : [t getEY];
  dx = (x == ex) ? 0 : 1;
  dy = (y == ey) ? 0 : 1;
  if(dx == 0 && dy == 0) {
    (*[self methodForSelector: mark])(self, mark, x, y);
  } else 
    while(x <= ex && y <= ey) {
      (*[self methodForSelector: mark])(self, mark, x, y);
      x += dx;
      y += dy;
    }
}

- (void) fixTrails {
  int i;
  Data *d;
  Line *t;
  Game *game = [Game getGame];

  for(i = 0; i < [game getPlayers]; i++) {
    d = [[game getPlayer][i] getData];
    if([d getSpeed] > 0) {
      t = &([d getTrails][0]);
      while(t != [d getTrail]) {
	[self doTrail: t selector: @selector(setCol:y:)];
	t++;
      }
      [self doTrail: t selector: @selector(setCol:y:)];
    }
  }
}

- (void) clearTrails: (Data *) data {
  Line *t = &([d getTrails][0]);

  while(t != [data getTrail]) {
    [self doTrail: t selector: @selector(clearCol:y:)];
    t++;
  }
  [self doTrail: t selector: @selector(clearCol:y:)];
}

- (void) idleGame {
  int i, j;
  int loop; 
  Game *game = [Game getGame];

#ifdef SOUND
  Sound *sound = [Sound getSound];

  soundIdle();
#endif

  if([[game getSettings] getFastFinish] == 1) {
    loop = FAST_FINISH;
    for(i = 0; i < [game getPlayers]; i++)
      if([[[game getPlayer][i] getAI] getActive] != 1 &&
	 [[[game getPlayer][i] getData] getExpRadius] < EXP_RADIUS_MAX)
	 /* game->player[i].data->speed > 0) */
	loop = 1;
  } else loop = 1;

  if(getElapsedTime() - lasttime < 10 && loop == 1) return;
  timediff();
  for(j = 0; j < loop; j++) {
    if(loop == FAST_FINISH)
      dt = 20;
    movePlayers();

    /* do AI */
    for(i = 0; i < [game getPlayers]; i++)
      if([[game getPlayer][i] getAI] != NULL)
	if([[[game getPlayer][i] getAI] getActive] == 1)
	  doComputer(&(game->player[i]), game->player[i].data);
  }

  /* chase-cam movement here */
  camMove();
  chaseCamMove();

  glutPostRedisplay();
}

- (void) defaultDisplay: (int) n {
  Game *game = [Game getGame];
 
  [[game getSettings] setDisplayType: n];
  [[game getSettings] getContent][0] = 0;
  [[game getSettings] getContent][1] = 1;
  [[game getSettings] getContent][2] = 2;
  [[game getSettings] getContent][3] = 3;
  changeDisplay();
}

- (void) initGameScreen {
  GDisplay *d;
  Game *game = [Game getGame];
  
  d = [[game getSettings] getScreen];
  [d setH: [[game getSettings] getHeight]];
  [d setW: [[game getSettings] getWidth]];
  [d setVPX: 0];
  [d setVPY: 0];
  [d setVPW: [d getW]];
  [d setVPH: [d getH]];
}

- (void) cycleDisplay: (int) p {
  int q;
  Game *game = [Game getGame];

  q = ([[game getSettings] getContent][p] + 1) % [game getPlayers];
  while(q != [[game getSettings] getContent][p]) {
    if([[[game getPlayer][q] getDisplay] getOnScreen] == 0)
      [[game getSettings] getContent][p] = q;
    else q = (q + 1) % [game getPlayers];
  }
  changeDisplay();
}

- (void) resetScores {
  int i;
  Game *game = [Game getGame];

  for(i = 0; i < [game getPlayers]; i++)
    [[[game getPlayer][i] getData] getScore] = 0;
}

- (void) movePlayers {
  int i, j;
  float newx, newy;
  int x, y;
  int col;
  int winner;
  Data *data;
  Game *game = [Game getGame];

  /* do movement and collision */
  for(i = 0; i < [game getPlayers]; i++) {
    data = [[game getPlayer][i] getData];
    if(data->speed > 0) { /* still alive */
      newx = [data getPosX] + dt / 100 * [data getSpeed] * dirsX[[data getDir]];
      newy = [data getPosY] + dt / 100 * [data getSpeed] * dirsY[[data getDir]];
      
      if((int) [data getPosX] != newx || (int) [data getPosY] != newy) {
	/* collision-test here */
	/* boundary-test here */
	col = colldetect([data getPosX], [data getPosY], newx, newy,
			 [data getDir], &x, &y);
	if (col) {
#ifdef SOUND
	  /* playCrash(); */
#endif
	  /* set endpoint to collision coordinates */
	  newx = x;
	  newy = y;
	  /* update scores; */
	  if([[game getSettings] getScreenSaver] != 1)
	  for(j = 0; j < [game getPlayers]; j++) {
	    if(j != i && [[[game getPlayer][j] getData] getSpeed] > 0)
	      [[[game getPlayer][j] getData] getScore]++;
	  }
	  [data setSpeed: SPEED_CRASHED];
	}

	/* now draw marks in the bitfield */
	x = (int) [data getPosX];
	y = (int) [data getPosY];
	while(x != (int)newx ||
	      y != (int)newy ) {
	  x += dirsX[[data getDir]];
	  y += dirsY[[data getDir]];
	  [self setCol: x y: y];
	}
	[[data getTrail] setEX: newx];
	[[data getTrail] setEY: newy];
	[data setPosX: newx];
	[data setPosY: newy];

	if(col && [[game getSettings] getEraseCrashed] == 1) {
	  clearTrails(data);
	  [self fixTrails]; /* clearTrails does too much... */
	}
      }
    } else { /* do trail countdown && explosion */
      if([data getExpRadius] < EXP_RADIUS_MAX)
	data->exp_radius += (float)dt * EXP_RADIUS_DELTA;
      else if (data->speed == SPEED_CRASHED) {
	[data setSpeed: SPEED_GONE];
	[game setRunning: [game getRunning] - 1];
	if([game getRunning] <= 1) { /* all dead, find survivor */
	  for(winner = 0; winner < [game getPlayers]; winner++)
	    if([[[game getPlayer][winner] getData] getSpeed] > 0) break;
	  [game setWinner: (winner == [game getWinner]) ? -1 : winner];
	  printf("winner: %d\n", winner);
	  switchCallbacks(&pauseCallbacks);
	  /* screenSaverCheck(0); */
	  [game setPauseFlag: PAUSE_GAME_FINISHED];
	}
      }
      if([[game getSettings] getEraseCrashed] == 1 && [data getTrailHeight] > 0)
	[data setTrailHeight: [data getTrailHeight] - (float)(dt * TRAIL_HEIGHT) / 1000];
    }
  }
}

- (void) timediff {
  int t;
  t = getElapsedTime();
  dt = t - lasttime;
  lasttime = t;
}


void chaseCamMove() {
  int i;
  Game *game = [Game getGame];
  Camera *cam;
  Data *data;
  float dest[3];
  float dcamx;
  float dcamy;
  float d;

  for(i = 0; i < game->players; i++) {
      
    cam = [[game getPlayer[i]] getCamera];
    data = [[game getPlayer[i]] getData];

    switch(cam->camType) {
    case 0: /* Andi-cam */
      [cam getCam][0] = [data getPosX] + CAM_CIRCLE_DIST * COS(camAngle);
      [cam getCam][1] = [data getPosY] + CAM_CIRCLE_DIST * SIN(camAngle);
      [cam getCam][2] = CAM_CIRCLE_Z;
      [cam getTarget][0] = [data getPosX];
      [cam getTarget][1] = [data getPosY];
      [cam getTarget][2] = B_HEIGHT;
      break;
    case 1: // Mike-cam
      [cam getTarget][0] = [data getPosX];
      [cam getTarget][1] = [data getPosY];
      [cam getTarget][2] = B_HEIGHT;
      
      dest[0] = [cam getTarget][0] - CAM_FOLLOW_DIST * dirsX[[data getDir]];
      dest[1] = [cam getTarget][1] - CAM_FOLLOW_DIST * dirsY[[data getDir]];

      d = sqrt((dest[0] - [cam getCam][0]) * (dest[0] - [cam getCam][0]) +
	       (dest[1] - [cam getCam][1]) * (dest[1] - [cam getCam][1]));
      if(d != 0) {
	dcamx = (float)dt * CAM_FOLLOW_SPEED * (dest[0] - [cam getCam][0]) / d;
	dcamy = (float)dt * CAM_FOLLOW_SPEED * (dest[1] - [cam getCam][1]) / d;

	if((dest[0] - [cam getCam][0] > 0 && dest[0] - [cam getCam][0] < dcamx) ||
	   (dest[0] - [cam getCam][0] < 0 && dest[0] - [cam getCam][0] > dcamx)) {
	  cam->cam[0] = dest[0];
	} else cam->cam[0] += dcamx;

	if((dest[1] - [cam getCam][1] > 0 && dest[1] - [cam getCam][1] < dcamy) ||
	   (dest[1] - [cam getCam][1] < 0 && dest[1] - [cam getCam][1] > dcamy)) {
	  [cam getCam][1] = dest[1];
	} else [cam getCam][1] += dcamy;
      }
      break;
    case 2: /* 1st person */
#define H 3
      [cam getTarget][0] = [data getPosX] + dirsX[[data getDir]];
      [cam getTarget][1] = [data getPosY] + dirsY[[data getDir]];
      [cam getTarget][2] = H;

      [cam getCam][0] = [data getPosX];
      [cam getCam][1] = [data getPosY];
      [cam getCam][2] = H + 0.5;
      break;
    }
  }
}

- (void) camMove {
  camAngle += CAM_SPEED * dt / 100;
  while(camAngle > 360) camAngle -= 360;
}
@end
