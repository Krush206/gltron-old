#import "gltron.h"
#import "geom.h"

@implementation GameGraphics
- (void) drawDebugTex: (GDisplay *) d {
  int x = 100;
  int y = 100;

  rasonly(d);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glColor4f(.0, 1.0, .0, 1.0);
  glRasterPos2i(x, y);
  glBitmap(colwidth * 8 , GSIZE, 0, 0, 0, 0, colmap);
  glBegin(GL_LINE_LOOP);
  glVertex2i(x - 1, y - 1);
  glVertex2i(x + colwidth * 8, y - 1);
  glVertex2i(x + colwidth * 8, y + GSIZE);
  glVertex2i(x - 1, y + GSIZE);
  glEnd();
  polycount++;
}

- (void) drawScore: (Player *) p display: (GDisplay *) d {
  char tmp[10]; /* hey, they won't reach such a score */

  sprintf(tmp, "%d", [[p getData] getScore]);
  rasonly(d);
  glColor4f(1.0, 1.0, 0.2, 1.0);
  drawText(5, 5, 32, tmp);
}
  
- (void) drawFloor: (GDisplay *) d {
  int j, k, l, t;
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];

  if([settings getShowFloorTexture]) {
    glDepthMask(GL_TRUE);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, [[game getScreen] getTexFloor]);
    /* there are some strange clipping artefacts in software mode */
    /* try subdividing things... */
    glColor4f(1.0, 1.0, 1.0, 1.0);
    l = GSIZE / 4;
    t = 5;
    for(j = 0; j < GSIZE; j += l)
      for(k = 0; k < GSIZE; k += l) {
	glBegin(GL_QUADS);
	glTexCoord2i(0, 0);
	glVertex2i(j, k);
	glTexCoord2i(t, 0);
	glVertex2i(j + l, k);
	glTexCoord2i(t, t);
	glVertex2i(j + l, k + l);
	glTexCoord2i(0, t);
	glVertex2i(j, k + l);
	glEnd();
	polycount++;
      }
    glDisable(GL_TEXTURE_2D);
    glDepthMask(GL_FALSE);
  } else {
    /* lines as floor... */
    glColor3f(0.0, 0.0, 1.0);
    glBegin(GL_LINES);
    for(j = 0; j <= GSIZE; j += [settings getLineSpacing]) {
      glVertex3i(0, j, 0);
      glVertex3i(GSIZE, j, 0);
      glVertex3i(j, 0, 0);
      glVertex3i(j, GSIZE, 0);
      polycount += 2;
    }
    glEnd();
  }
}

- (void) drawTraces: (Player *) p display: (GDisplay *) instance: (int) instance {
  Line *line;
  float height;
  Data *data;
  Settings *settings = [Settings getSettings];

  data = [p getData];
  height = [data getTrailHeight];
  if(height > 0) {
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glColor4fv([[p getModel] getColorAlpha]);
    /* glColor4f(0.5, 0.5, 0.5, 0.8); */
    line = &([data getTrails][0]);
    glBegin(GL_TRIANGLE_STRIP);
    glVertex3f([line getSX], [line getSY], 0.0);
    glVertex3f([line getSX], [line getSY], height);
    while(line != [data getTrail]) {
      glVertex3f([line getEX], [line getEY], 0.0);
      glVertex3f([line getEX], [line getEY], height);    
      line++;
      polycount++;
    }
    glVertex3f([line getEX], [line getEY], 0.0);
    glVertex3f([line getEX], [line getEY], height);
    polycount += 2;
    glEnd();

    if([settings getCamType] == 1) {
      //       glLineWidth(3);
      // glBegin(GL_LINES);
      glBegin(GL_QUADS);
#define LINE_D 0.05
      glVertex2f(data->trail->sx - LINE_D, [[data getTrail] getSY] - LINE_D);
      glVertex2f(data->trail->sx + LINE_D, [[data getTrail] getSY] + LINE_D);
      glVertex2f(data->trail->ex + LINE_D, [[data getTrail] getEY] + LINE_D);
      glVertex2f(data->trail->ex - LINE_D, [[data getTrail] getEY] - LINE_D);

      glEnd();
      // glLineWidth(1);
      polycount++;
    }
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }
}

- (void) drawCrash: (float) radius {
#define CRASH_W 20
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];

  glColor4f(1.0, 1.0, 1.0, (EXP_RADIUS_MAX - radius) / EXP_RADIUS_MAX);
  /* printf("exp_r: %.2f\n", (EXP_RADIUS_MAX - radius) / EXP_RADIUS_MAX); */
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, [[game getScreen] getTexCrash]);
  glEnable(GL_BLEND);
  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0);
  glVertex3f(- CRASH_W, 0.0, 0.0);
  glTexCoord2f(1.0, 0.0);
  glVertex3f(CRASH_W, 0.0, 0.0);
  glTexCoord2f(1.0, .5);
  glVertex3f(CRASH_W, 0.0, CRASH_W);
  glTexCoord2f(0.0, .5);
  glVertex3f(- CRASH_W, 0.0, CRASH_W);
  glEnd();
  glDisable(GL_TEXTURE_2D);
  if([settings getShowAlpha] == 0) glDisable(GL_BLEND);
}

- (void) drawCycle (Player *) p {
  float dirangles[] = { 180, 90, 0, 270 , 360, -90 };
  int time;
  int last_dir;
  float dirangle;
  Mesh *cycle;
  Settings *settings = [Settings getSettings];

#define turn_length 500

  cycle = [[p getModel] getMesh];
    
  glPushMatrix();
  glTranslatef([[p getData] getPosX], [[p getData] getPosY], .0);

  if([settings getTurnCycle]) {
    time = abs([[p getData] getTurnTime] - getElapsedTime());
    if(time < turn_length) {
      last_dir = [[p getData] getLastDir];
      if([[p getData] getDir] == 3 && last_dir == 2)
	last_dir = 4;
      if([[p getData] getDir] == 2 && last_dir == 3)
	last_dir = 5;
      dirangle = ((turn_length - time) * dirangles[last_dir] +
		  time * dirangles[[[p getData] getDir]]) / turn_length;
    } else
      dirangle = dirangles[[[p getData] getDir]];
  } else dirangle = dirangles[[[p getData] getDir]];

  glRotatef(dirangle, 0, 0.0, 1.0);

  if([settings getShowCrashTexture])
    if([[p getData] getExpRadius] > 0 && [[p getData] getExpRadius] < EXP_RADIUS_MAX)
      drawCrash([[p getData] getExpRadius]);

#define neigung 25
  if([settings getTurnCycle]) {
    if(time < turn_length) {
      float axis = 1.0;
      if([[p getData] getDir] < [[p getData] getLastDir] && [[p getData] getLastDir] != 3)
	axis = -1.0;
      else if(([[p getData] getLastDir] == 3 && [[p getData] getDir] == 2) ||
	      ([[p getData] getLastDir] == 0 && [[p getData] getDir] == 3))
	axis = -1.0;
      glRotatef(neigung * sin(M_PI * time / turn_length),
		0.0, axis, 0.0);
    }
  }

  glTranslatef(-[cycle getBBox][0] / 2, -[cycle getBBox][1] / 2, .0);
  /* glTranslatef(-cycle->bbox[0] / 2, 0, .0); */
  /* glTranslatef(-cycle->bbox[0] / 2, -cycle->bbox[1], .0); */

  glEnable(GL_LIGHTING);
  glEnable(GL_DEPTH_TEST);
  glDepthMask(GL_TRUE);

  if([[p getData] getExpRadius] == 0)
    drawModel(cycle, MODEL_USE_MATERIAL, 0);
  else if([[p getData] getExpRadius] < EXP_RADIUS_MAX) {
    float alpha;
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    alpha = (float) (EXP_RADIUS_MAX - [[p getData] getExpRadius]) /
      (float) EXP_RADIUS_MAX;
    setMaterialAlphas(cycle, alpha);
    drawExplosion(cycle, [[p getData] getExpRadius], MODEL_USE_MATERIAL, 0);
  }

  if([settings getShowAlpha] == 0) glDisable(GL_BLEND);

  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
  glDepthMask(GL_FALSE);

  glPopMatrix();
}

- (int) playerVisible: (Player *) eye target: (Player *) target {
  float v1[3];
  float v2[3];
  float tmp[3];
  float s;
  float d;
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];

  vsub([[eye getCamera] getTarget], [[eye getCamera] getCam], v1);
  normalize(v1);
  tmp[0] = [[target getData] getPosX];
  tmp[1] = [[target getData] getPosY];
  tmp[2] = 0;
  vsub(tmp, [[eye getCamera] getCam], v2);
  normalize(v2);
  s = scalarprod(v1, v2);
  /* maybe that's not exactly correct, but I didn't notice anything */
  d = cos([settings getFOV] / 2) * 2 * M_PI / 360.0);
  /*
  printf("v1: %.2f %.2f %.2f\nv2: %.2f %.2f %.2f\ns: %.2f d: %.2f\n\n",
	 v1[0], v1[1], v1[2], v2[0], v2[1], v2[2],
	 s, d);
  */
  if(s < d)
    return 0;
  else return 1;
}
	    
- (void) drawPlayers: (Player *) p {
  int i;
  int dir;
  float l = 5.0;
  float height;
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];

  glShadeModel(GL_SMOOTH);
  glEnable(GL_BLEND);
  for(i = 0; i < [game getPlayers]; i++) {
    height = [[[game getPlayer][i] getData] getTrailHeight];
    if(height > 0) {
      glPushMatrix();
      glTranslatef([[[game getPlayer][i] getData] getPosX],
		   [[[game getPlayer][i] getData] getPosY],
		   0);
      /* draw Quad */
      dir = [[[game getPlayer][i] getData] getDir];
      glColor3fv([[[game getPlayer][i] getModel] getColorModel]);
      glBegin(GL_QUADS);
      glVertex3f(0, 0, 0);
      glColor4f(0, 0, 0, 0);
      glVertex3f(-dirsX[dir] * l, -dirsY[dir] * l, 0);
      glVertex3f(-dirsX[dir] * l, -dirsY[dir] * l, height);
      glColor3fv([[[game getPlayer][i] getModel] getColorModel]);
      glVertex3f(0, 0, height);
      glEnd();
      polycount++;
      glPopMatrix();
    }
    if(playerVisible(p, &([game getPlayer][i]))) {
      if([settings getShowModel])
	drawCycle(&([game getPlayer][i]));
    }
  }
  if([settings getShowAlpha] != 1) glDisable(GL_BLEND);
  glShadeModel(GL_FLAT);
}

- (void) drawGlow: (Player *) p display: (GDisplay *) d dimension: (float) dim {
  float mat[4*4];
  Game *game = [Game getGame];
  Settings *settings = [Settings getSettings];
  
  glPushMatrix();
  glTranslatef([[p getData] getPosX],
               [[p getData] getPosY],
               0);
  /* draw Model */

  glShadeModel(GL_SMOOTH);
  glBlendFunc(GL_ONE, GL_ONE);
  glEnable(GL_BLEND);
  glGetFloatv(GL_MODELVIEW_MATRIX, mat);
  mat[0] = mat[5] = mat[10] = 1.0;
  mat[1] = mat[2] = 0.0;
  mat[4] = mat[6] = 0.0;
  mat[8] = mat[9] = 0.0;
  glLoadMatrixf(mat);
  glBegin(GL_TRIANGLE_FAN);
  glColor3fv([[p getModel] getColorModel]);

  glVertex3f(0,TRAIL_HEIGHT/2, 0);
  glColor4f(0,0,0,0.0);
  glVertex3f(dim*cos(-0.2*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(-0.2*3.1415/5.0), 0);
  glVertex3f(dim*cos(1.0*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(1.0*3.1415/5.0), 0);
  glVertex3f(dim*cos(2.0*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(2.0*3.1415/5.0), 0);
  glVertex3f(dim*cos(3.0*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(3.0*3.1415/5.0), 0);
  glVertex3f(dim*cos(4.0*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(4.0*3.1415/5.0), 0);
  glVertex3f(dim*cos(5.2*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(5.2*3.1415/5.0), 0);
  glEnd();
  polycount += 5;


  glBegin(GL_TRIANGLES);
  glColor3fv([[p getModel] getColorModel]);
  glVertex3f(0,TRAIL_HEIGHT/2, 0);
  glColor4f(0,0,0,0.0);
  glVertex3f(0,-TRAIL_HEIGHT/4,0);
  glVertex3f(dim*cos(-0.2*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(-0.2*3.1415/5.0), 0);

  glColor3fv([[p getModel] getColorModel]);
  glVertex3f(0,TRAIL_HEIGHT/2, 0);
  glColor4f(0,0,0,0.0);
  glVertex3f(dim*cos(5.2*3.1415/5.0),
	     TRAIL_HEIGHT/2+dim*sin(5.2*3.1415/5.0), 0);
  glVertex3f(0,-TRAIL_HEIGHT/4,0);
  glEnd();
  polycount += 3;


  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  if([settings getShowAlpha] != 1) glDisable(GL_BLEND);
  glShadeModel(GL_FLAT);
  glPopMatrix();  
}

- (void) drawWalls (GDisplay *) d {
  float t = 4;
  glColor4f(1.0, 1.0, 1.0, 1.0);

  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  /* glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); */

  glEnable(GL_CULL_FACE);

  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, [[game getScreen] getTexWall]);
  glBegin(GL_QUADS);
  glTexCoord2f(t, 0.0); glVertex3f(0.0, 0.0, 0.0);
  glTexCoord2f(t, 1.0); glVertex3f(0.0, 0.0, WALL_H);
  glTexCoord2f(0.0, 1.0); glVertex3f(GSIZE, 0.0, WALL_H);
  glTexCoord2f(0.0, 0.0); glVertex3f(GSIZE, 0.0, 0.0);

  glTexCoord2f(t, 1.0); glVertex3f(GSIZE, 0.0, 0.0);
  glTexCoord2f(t, 0.0); glVertex3f(GSIZE, 0.0, WALL_H);
  glTexCoord2f(0.0, 0.0); glVertex3f(GSIZE, GSIZE, WALL_H);
  glTexCoord2f(0.0, 1.0); glVertex3f(GSIZE, GSIZE, 0.0);

  glTexCoord2f(t, 1.0); glVertex3f(GSIZE, GSIZE, 0.0);
  glTexCoord2f(t, 0.0); glVertex3f(GSIZE, GSIZE, WALL_H);
  glTexCoord2f(0.0, 0.0); glVertex3f(0.0, GSIZE, WALL_H);
  glTexCoord2f(0.0, 1.0); glVertex3f(0.0, GSIZE, 0.0);

  glTexCoord2f(t, 1.0); glVertex3f(0.0, GSIZE, 0.0);
  glTexCoord2f(t, 0.0); glVertex3f(0.0, GSIZE, WALL_H);
  glTexCoord2f(0.0, 0.0); glVertex3f(0.0, 0.0, WALL_H);
  glTexCoord2f(0.0, 1.0); glVertex3f(0.0, 0.0, 0.0);

  glEnd();
  polycount += 4;

  glDisable(GL_TEXTURE_2D);

  glDisable(GL_CULL_FACE);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

/*
void drawHelp(GDisplay *d) {
  rasonly(d);
  glColor4f(0.2, 0.2, 0.2, 0.8);
  glEnable(GL_BLEND);
  glBegin(GL_QUADS);
  glVertex2i(0,0);
  glVertex2i(d->vp_w - 1, 0);
  glVertex2i(d->vp_w - 1, d->vp_h - 1);
  glVertex2i(0, d->vp_h - 1);
  glEnd();
  if(game->settings->show_alpha != 1) glDisable(GL_BLEND);
  glColor3f(1.0, 1.0, 0.0);
  drawLines(d->vp_w, d->vp_h,
	    help, HELP_LINES, 0);
}
*/

- (void) drawCam: (Player *) p display: (GDisplay *) d {
  int i;
  Settings *settings = [Settings getSettings];

  if ([d getFog] == 1) glEnable(GL_FOG);

  glColor3f(0.0, 1.0, 0.0);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective([settings getFOV], [d getVPW] / [d getVPH], 3.0, GSIZE);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  glLightfv(GL_LIGHT0, GL_POSITION, [[p getCamera] getCam]);

  gluLookAt([[p getCamera] getCam][0], [[p getCamera] getCam][1], [[p getCamera] getCam][2],
	    [[p getCamera] getTarget][0], [[p getCamera] getTarget][1], [[p getCamera] getTarget][2],
	    0, 0, 1);

  drawFloor(d);
  if([settings getShowWall] == 1)
    drawWalls(d);

  for(i = 0; i < [game getPlayers]; i++)
    drawTraces(&([game getPlayer][i]), d, i);

  drawPlayers(p);

  /* draw the glow around the other players: */
  if([settings getShowGlow] == 1)
    for(i = 0; i < [game getPlayers]; i++)
      if ((p != &([game getPlayer][i])) && ([[[game getPlayer][i] getData] getSpeed] > 0))
	drawGlow(&([game getPlayer][i]), d, TRAIL_HEIGHT * 4);


  /* highLight crashed player */

  /*
  if(p->data->speed < 0 && game->settings->erase_crashed == 0) {
    glPushMatrix();
    glColor4f(1.0, 1.0, 0.1, 0.1);
    glTranslatef(p->data->posx, p->data->posy, TRAIL_HEIGHT / 2);
    if(game->settings->show_alpha == 1) 
      glutSolidSphere(8.0, 10, 10);
    glColor4f(1.0, 1.0, 0.3, 1.0);
    glutWireSphere(8.0, 10, 10);
    glPopMatrix();
  }
  */

  glDisable(GL_FOG);
}

- (void) drawAI: (GDisplay *) d {
  char ai[] = "computer player";

  rasonly(d);
  glColor3f(1.0, 1.0, 1.0);
  drawText(d->vp_w / 4, 10, d->vp_w / (2 * strlen(ai)), ai);
  /* glRasterPos2i(100, 0); */
}

- (void) drawPause: (GDisplay *) display {
  char pause[] = "Game is paused";
  char winner[] = "Player %d wins";
  char buf[100];
  char *message;
  static float d = 0;
  static float lt = 0;
  float delta;
  long now;
  Game *game = [Game getGame];

  now = getElapsedTime();
  delta = now - lt;
  lt = now;
  delta /= 500.0;
  d += delta;
  /* printf("%.5f\n", delta); */
  
  if(d > 2 * M_PI) { 
    d -= 2 * M_PI;
  }

  if([game getPauseFlag] & PAUSE_GAME_FINISHED &&
     [game getWinner] != -1) {
    message = buf;
    sprintf(message, winner, [game getWinner] + 1);
  } else {
    message = pause;
  }

  rasonly([game getScreen]);
  glColor3f(1.0, (sin(d) + 1) / 2, (sin(d) + 1) / 2);
  drawText([display getVPW] / 6, 20, 
	   [display getVPW] / (6.0 / 4.0 * strlen(message)), message);
}
@end
