#import "gltron.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#define BUFSIZE 100

@implementation Settings
- (Settings *) initSettingData: (NSString *) filename
{
  Settings *settings = [Settings new];
  FILE *f;
  int n, i, count, j;
  char buf[BUFSIZE], c;

  f = fopen([filename UTF8String], "r");
  fgets(buf, BUFSIZE, f);
  sscanf(buf, "%d ", &n);
  for(i = 0; i < n; i++) {
    fgets(buf, BUFSIZE, f);
    sscanf(buf, "%c%d ", &c, &count);
    switch(c) {
    case 'i': /* it's int */
    {
      NSMutableArray *si_arr = [NSMutableArray new];

      for(j = 0; j < count; j++) {
        SettingsInt *si = [SettingsInt new];

        fgets(buf, BUFSIZE, f);
	buf[31] = 0;
	[si setName: [[NSString alloc] initWithUTF8String: buf]];
        [si_arr addObject: si];
      }
      [settings setSettingsInt: si_arr];

      break;
    }
    case 'f': /* float */
    {
      NSMutableArray *sf_arr = [NSMutableArray new];

      for(j = 0; j < count; j++) {
        SettingsFloat *sf = [SettingsFloat new];

        fgets(buf, BUFSIZE, f);
	buf[31] = 0;
	[sf setName: [[NSString alloc] initWithUTF8String: buf]];
        [sf_arr addObject: sf];
      }
      [settings setSettingsFloat: sf_arr];

      break;
    }
    default:
      printf("unrecognized type '%c' in settings.txt\n", c);
      exit(1);
    }
  }
  fclose(f);

  [[[settings getSettingsInt] objectAtIndex: 0] setValue: [settings getShowHelpAddr]];
  [[[settings getSettingsInt] objectAtIndex: 1] setValue: [settings getShowFPSAddr]];
  [[[settings getSettingsInt] objectAtIndex: 2] setValue: [settings getShowWallAddr]];
  [[[settings getSettingsInt] objectAtIndex: 3] setValue: [settings getShowGlowAddr]];
  [[[settings getSettingsInt] objectAtIndex: 4] setValue: [settings getShow2DAddr]];
  [[[settings getSettingsInt] objectAtIndex: 5] setValue: [settings getShowAlphaAddr]];
  [[[settings getSettingsInt] objectAtIndex: 6] setValue: [settings getShowFloorTextureAddr]];
  [[[settings getSettingsInt] objectAtIndex: 7] setValue: [settings getLineSpacingAddr]];
  [[[settings getSettingsInt] objectAtIndex: 8] setValue: [settings getEraseCrashedAddr]];
  [[[settings getSettingsInt] objectAtIndex: 9] setValue: [settings getFastFinishAddr]];
  [[[settings getSettingsInt] objectAtIndex: 10] setValue: [settings getFOVAddr]];
  [[[settings getSettingsInt] objectAtIndex: 11] setValue: [settings getWidthAddr]];
  [[[settings getSettingsInt] objectAtIndex: 12] setValue: [settings getHeightAddr]];
  [[[settings getSettingsInt] objectAtIndex: 13] setValue: [settings getAIStatusAddr]];
  [[[settings getSettingsInt] objectAtIndex: 14] setValue: [settings getCamTypeAddr]];
  [[[settings getSettingsInt] objectAtIndex: 15] setValue: [settings getDisplayTypeAddr]];
  [[[settings getSettingsInt] objectAtIndex: 16] setValue: [settings getPlaySoundAddr]];
  [[[settings getSettingsInt] objectAtIndex: 17] setValue: [settings getShowModelAddr]];
  [[[settings getSettingsInt] objectAtIndex: 18] setValue: [settings getAIPlayer1Addr]];
  [[[settings getSettingsInt] objectAtIndex: 19] setValue: [settings getAIPlayer2Addr]];
  [[[settings getSettingsInt] objectAtIndex: 20] setValue: [settings getAIPlayer3Addr]];
  [[[settings getSettingsInt] objectAtIndex: 21] setValue: [settings getAIPlayer4Addr]];
  [[[settings getSettingsInt] objectAtIndex: 22] setValue: [settings getShowCrashTextureAddr]];
  [[[settings getSettingsInt] objectAtIndex: 23] setValue: [settings getTurnCycleAddr]];
  [[[settings getSettingsInt] objectAtIndex: 24] setValue: [settings getMouseWarpAddr]];
  [[[settings getSettingsInt] objectAtIndex: 25] setValue: [settings getSoundDriverAddr]];

  [[[settings getSettingsFloat] objectAtIndex: 0] setValue: [settings getSpeedAddr]];

  return settings;
}

- (int) getVi: (char *) name settingsInt: (NSArray *) si
{
  int i;
  
  for(i = 0; i < [si count]; i++) {
    if(strstr(name, [[[si objectAtIndex: i] getName] UTF8String]) == name) 
      return [[si objectAtIndex: i] getValue];
  }
  return 0;
}

- (Settings *) initMainGameSettings: (NSString *) filename gameObject: (Game *) game
{
  Settings *settings;
  NSString *fname;
  NSArray *si = [game getSettingsInt], *sf = [game getSettingsFloat];
  FILE *f;
  char *home, buf[100];
  int i;

  settings = [self initSettingData: filename gameObject: game];

  /* initialize defaults, then load modifications from file */

  [game setPauseFlag: 0];

  [settings setShowHelp: 0];
  [settings setShowFPS: 1];
  [settings setShowWall: 1];
  [settings setShowGlow: 1];
  [settings setShow2D: 0];
  [settings setShowAlpha: 1];
  [settings setShowFloorTexture: 1];
  [settings setShowCrashTexture: 1];
  [settings setShowModel: 1];
  [settings setTurnCycle: 1];
  [settings setLineSpacing: 1];
  [settings setEraseCrashed: 0];
  [settings setFastFinish: 1];
  [settings setFOV: 105];
  [settings setSpeed: 4.2];
  [settings setWidth: 640];
  [settings setHeight: 480];
  [settings setShowAIStatus: 1];
  [settings setCamType: 0];
  [settings setMouseWarp: 0];

  [settings setDisplayType: 0];
  [settings setPlaySound: 1];

  [settings setAIPlayer1: 0];
  [settings setAIPlayer2: 1];
  [settings setAIPlayer3: 1];
  [settings setAIPlayer4: 1];
  
  [settings setSoundDriver: 0];

  /* not included in .gltronrc */

  [settings setScreenSaver: 0];
  [settings setWindowMode: 0];
  [settings setContent: 0 index: 0];
  [settings setContent: 1 index: 1];
  [settings setContent: 2 index: 2];
  [settings setContent: 3 index: 3];

  /* go for .gltronrc (or whatever is defined in RC_NAME) */

  home = getenv(HOMEVAR);
  if(home == NULL)
    fname = [[NSString alloc] initWithFormat: @"%@%c%@", CURRENT_DIR, SEPERATOR, RC_NAME];
  else
    fname = [[NSString alloc] initWithFormat: @"%@%c%@", home, SEPERATOR, RC_NAME];
  f = fopen([fname UTF8String], "r");
  if(f == 0) {
    printf("no %s found - using defaults\n", fname);
    return; /* no rc exists */
  }
  while(fgets(buf, sizeof(buf), f)) {
    /* process rc-file */
    NSString *expbuf;

    if(strstr(buf, "iset") == buf) {
      /* linear search through settings */
      /* first: integer */
      for(i = 0; i < [si count]; i++) {
        expbuf = [[NSString alloc] initWithFormat: @"iset %@ ", [[si objectAtIndex: i] getName]];
	if(strstr(buf, [expbuf UTF8String]) == buf) {
          int *si_value = [[si objectAtIndex: i] getValue];

	  sscanf(buf + [expbuf length], "%d ", si_value);
	  printf("assignment: %s\t%d\n", [[[si objectAtIndex: i] getName] UTF8String], *si_value);
	  break;
	}
      }
    } else if(strstr(buf, "fset") == buf) {
      for(i = 0; i < [sf count]; i++) {
        expbuf = [[NSString alloc] initWithFormat: @"fset %@ ", [[sf objectAtIndex: i] getName]];
	if(strstr(buf, [expbuf UTF8String]) == buf) {
          float *sf_value = [[sf objectAtIndex: i] getValue];

	  sscanf(buf + [expbuf length], "%f ", sf_value);
	  printf("assignment: %s\t%.2f\n", [[[sf objectAtIndex: i] getName] UTF8String], *sf_value);
	  break;
	}
      }
    }
  }
  fclose(f);

  return settings;
}

- (void) saveSettings: (NSArray *) si settingsFloat: (NSArray *) sf
{
  FILE *f;
  NSString *fname;
  char *home;
  int i;

  home = getenv(HOMEVAR);
  if(home == NULL)
    fname = [[NSString alloc] initWithFormat: @"%@%c%@", CURRENT_DIR, SEPERATOR, RC_NAME];
  else
    fname = [[NSString alloc] initWithFormat: @"%@%c%@", home, SEPERATOR, RC_NAME];
  f = fopen([fname UTF8String], "w");
  if(f == 0) {
    printf("can't open %s ", [fname UTF8String]);
    perror("for writing");
    return; /* can't write rc */
  }
  for(i = 0; i < [si count]; i++) {
    int *si_value = [[si objectAtIndex: i] getValue];

    fprintf(f, "iset %s %d\n", [[[si objectAtIndex: i] getName] UTF8String], *si_value);
  }
  for(i = 0; i < [sf count]; i++) {
    int *sf_value = [[sf objectAtIndex: i] getValue];

    fprintf(f, "fset %s %.2f\n", [[[sf objectAtIndex: i] getName] UTF8String], *sf_value);
  }
  printf("written settings to %s\n", [fname UTF8String]);
  fclose(f);
}
@end
