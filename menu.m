#include "gltron.h"
#include <string.h>

#define MENU_BUFSIZE 100

Menu *pCurrent;

@implementation GLtron (Menu)
- (void) changeActionWithName: (char *) name
{
#ifdef SOUND
  if(strstr(name, "playSound") == name) {
    if(game->settings->playSound == 0)
      [self stopSound];
    else [self playSound];
  }
#endif
  if(strstr(name, "resetScores") == name)
    [self resetScores];
  if(strstr(name, "ai_player") == name) {
    int c;
    int *v;

    /* printf("changing AI status\n"); */
    c = name[9] - '0';
    v = [self getViWithName: name];
    game->player[c - 1].ai->active = *v;
    /* printf("changed AI status for player %c\n", c + '0'); */
  }
}

- (void) menuActionWithMenu: (Menu *) activated
{
  int x, y;
  char c;
  int *piValue;
  if(activated->nEntries > 0) {
    pCurrent = activated;
    pCurrent->iHighlight = 0;
  } else {
    switch(activated->szName[1]) { /* second char */
    case 'q': [self saveSettings]; exit(0); break;
    case 'r': 
      [self initData];
      [self switchCallbacksWithCallbacks: &pauseCallbacks];
      break;
    case 'v':
      sscanf(activated->szName, "%cv%dx%d ", &c, &x, &y);
      game->settings->width = x;
      game->settings->height = y;

      [self initGameDisplay];
      [self shutdownDisplayWithDisplay: game->screen];
      [self setupDisplayWithDisplay: game->screen];

      [self updateCallbacks];
      [self changeDisplay];
      break;
    case 't':
      piValue = [self getViWithName: activated->szName + 4];
      if(piValue != 0) {
	*piValue = (*piValue - 1) * (-1);
	[self initMenuCaptionWithMenu: activated];
	[self changeActionWithName: activated->szName + 4];
      }
      break;
    case 'p':
      [self changeActionWithName: activated->szName + 4];
    case 'c':
      [self chooseCallbackWithName: activated->szName + 3];
      break;
    default: printf("got action for menu %s\n", activated->szName); break;
    }
  }
}

- (void) initMenuCaptionWithMenu: (Menu *) m
{
  int *piValue;

  /* TODO support all kinds of types */
  switch(m->szName[0]) {
  case 's':
    switch(m->szName[1]) {
    case 't': case 'T':
      switch(m->szName[2]) {
      case 'i':
	/* printf("dealing with %s\n", m->szName); */
	piValue = [self getViWithName: m->szName + 4];
	if(piValue != 0) {
	  if(*piValue == 0) sprintf(m->display.szCaption,
				    m->szCapFormat, "off");
	  else sprintf(m->display.szCaption, m->szCapFormat, "on");
	  /* printf("changed caption to %s\n", m->display.szCaption); */
	} /* else printf("can't find value for %s\n", m->szName + 4); */
	break;
      }
    }
    break;
    /* c entries change the callback */

  default:
    sprintf(m->display.szCaption, "%s", m->szCapFormat);
  }
}

- (void) getNextLineWithBuffer: (char *) buf
         size: (int) bufsize
	 file: (FILE *) f
{
  fgets(buf, bufsize, f);
  while((buf[0] == '\n' || buf[0] == '#') && /* ignore empty lines, comments */
	fgets(buf, bufsize, f));
}

- (Menu *) loadMenuWithFile: (FILE *) f
           buffer: (char *) buf
	   parent: (Menu *) parent
	   level: (int) level
{
  Menu* m;
  int i;


  if(level > 4) {
    printf("recursing level > 4 - aborting\n");
    exit(1);
  }

  m = (Menu*) malloc(sizeof(Menu));
  m->parent = parent;
  [self getNextLineWithBuffer: buf
        size: MENU_BUFSIZE
        file: f];
  sscanf(buf, "%d ", &(m->nEntries));

  [self getNextLineWithBuffer: buf
        size: MENU_BUFSIZE
        file: f];
  buf[31] = 0; /* enforce menu name limit; */
  sprintf(m->szName, "%s", buf);
  if(*(m->szName + strlen(m->szName) - 1) == '\n')
    *(m->szName + strlen(m->szName) - 1) = 0;
  

  [self getNextLineWithBuffer: buf
        size: MENU_BUFSIZE
        file: f];
  buf[31] = 0; /* enforce menu caption limit; */
  sprintf(m->szCapFormat, "%s", buf);
  /* remove newline */
  for(i = 0; *(m->szCapFormat + i) != 0; i++)
    if (*(m->szCapFormat + i) == '\n') {
      *(m->szCapFormat + i) = 0;
      break;
    }

  [self initMenuCaptionWithMenu: m];
	
  /* printf("menu '%s': %d entries\n", m->szName, m->nEntries); */
  if(m->nEntries > 0) {
    m->pEntries = malloc(sizeof(Menu*) * m->nEntries);
    for(i = 0; i < m->nEntries; i++) {
      /* printf("loading menu number %d\n", i); */
      if(i > 10) {
	printf("item limit reached - aborting\n");
	exit(1);
      }
      *(m->pEntries + i) = [self loadMenuWithFile: f
                                 buffer: buf
                                 parent: m
                                 level: level + 1];
    }
  }

  return m;
}

- (Menu **) loadMenuWithFile: (char *) filename
{
  char buf[MENU_BUFSIZE];
  FILE* f;
  Menu* m;
  Menu** list = NULL;
  int nMenus;
  int i, j;
  node *head;
  node *t;
  node *z;
  int sp = 0;

  if((f = fopen(filename, "r")) == NULL)
    return 0;
  /* read count of Menus */
  [self getNextLineWithBuffer: buf
        size: MENU_BUFSIZE
        file: f];
  sscanf(buf, "%d ", &nMenus);
  if(nMenus <= 0) return 0;

  /* allocate space for data structures */
  list = (Menu**) malloc(sizeof(Menu*) * nMenus);

  /* load data */
  for(i = 0; i < nMenus; i++) {
    /* printf("loading menu set %d\n", i); */
    if(i > 10) exit(1);
    *(list + i) = [self loadMenuWithFile: f
                        buffer: buf
                        parent: NULL
                        level: 0];
  }

  /* TODO(3): now since I eliminated the need for cx/cy, why */
  /* do I need to traverse the Menu Tree? Just to set the colors??? */

  /* traverse Menu Tree and set Menu Color to some boring default */
  /* printf("finished parsing file - now traversing menus\n"); */
  /* setup stack */
  z = (node*) malloc(sizeof(node));
  z->next = z;
  head = (node*) malloc(sizeof(node));
  head->next = z;
  
  for(i = 0; i < nMenus; i++) {
    t = (node*) malloc(sizeof(node));
    t->data = *(list + i);
    t->next = head->next;
    head->next = t;
    sp++;
    while(head->next != z) {
      t = head->next;
      head->next = t->next;
      m = (Menu*) t->data;
      free(t);
      /* printf("stack count: %d\n", --sp); */
      /* printf("visiting %s\n", m->szName); */
      /* visit m */

      /* TODO(0): put the color defaults somewhere else */

      m->display.fgColor[0] = 0.0;
      m->display.fgColor[1] = 0.0;
      m->display.fgColor[2] = 0.0;
      m->display.fgColor[3] = 1.0;
      m->display.hlColor[0] = 255.0 / 255.0;
      m->display.hlColor[1] = 20.0 / 255.0;
      m->display.hlColor[2] = 20.0 / 255.0;
      m->display.hlColor[3] = 1.0;

      /* push all of m's submenus */
      for(j = 0; j < m->nEntries; j++) {
	t = (node*) malloc(sizeof(node));
	t->data = *(m->pEntries + j);
	t->next = head->next;
	head->next = t;
	/* printf("pushing %s\n", ((Menu*)t->data)->szName); */
	/* printf("stack count: %d\n", ++sp); */
	
      }
    }
  }
  return list;
}

- (void) drawMenuWithDisplay: (gDisplay *) d
{
  /* draw Menu pCurrent */
  int i;
  int x, y, size, lineheight;

  [self rasterizerOnlyWithDisplay: d];

  x = d->vp_w / 6;
  size = d->vp_w / 32;
  y = 2 * d->vp_h / 3;
  lineheight = size * 2;

  /* draw the entries */
  for(i = 0; i < pCurrent->nEntries; i++) {
    if(i == pCurrent->iHighlight)
      glColor4fv(pCurrent->display.hlColor);
    else glColor4fv(pCurrent->display.fgColor);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [self rasterizerOnlyWithDisplay: d];
    [self drawTextWithX: x
          y: y
          size: size
          text: ((Menu *) *(pCurrent->pEntries + i))->display.szCaption];
    y -= lineheight;
  }
}
@end
