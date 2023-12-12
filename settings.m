#import "gltron.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>

#define BUFSIZE 100

@implementation Settings
static Settings *settings;

- (void) initSettingData: (NSString *) filename
{
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
      settings_int = si_arr;

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
      settings_float = sf_arr;

      break;
    }
    default:
      printf("unrecognized type '%c' in settings.txt\n", c);
      exit(1);
    }
  }
  fclose(f);

  [[settings_int objectAtIndex: 0] setValue: &show_help];
  [[settings_int objectAtIndex: 1] setValue: &show_fps];
  [[settings_int objectAtIndex: 2] setValue: &show_wall];
  [[settings_int objectAtIndex: 3] setValue: &show_glow];
  [[settings_int objectAtIndex: 4] setValue: &show_2d];
  [[settings_int objectAtIndex: 5] setValue: &show_alpha];
  [[settings_int objectAtIndex: 6] setValue: &show_floor_texture];
  [[settings_int objectAtIndex: 7] setValue: &show_line_spacing];
  [[settings_int objectAtIndex: 8] setValue: &erase_crashed];
  [[settings_int objectAtIndex: 9] setValue: &fast_finish];
  [[settings_int objectAtIndex: 10] setValue: &fov];
  [[settings_int objectAtIndex: 11] setValue: &width];
  [[settings_int objectAtIndex: 12] setValue: &height];
  [[settings_int objectAtIndex: 13] setValue: &show_ai_status];
  [[settings_int objectAtIndex: 14] setValue: &camType];
  [[settings_int objectAtIndex: 15] setValue: &display_type];
  [[settings_int objectAtIndex: 16] setValue: &playSound];
  [[settings_int objectAtIndex: 17] setValue: &show_model];
  [[settings_int objectAtIndex: 18] setValue: &ai_player1];
  [[settings_int objectAtIndex: 19] setValue: &ai_player2];
  [[settings_int objectAtIndex: 20] setValue: &ai_player3];
  [[settings_int objectAtIndex: 21] setValue: &ai_player4];
  [[settings_int objectAtIndex: 22] setValue: &show_crash_texture];
  [[settings_int objectAtIndex: 23] setValue: &turn_cycle];
  [[settings_int objectAtIndex: 24] setValue: &mouse_warp];
  [[settings_int objectAtIndex: 25] setValue: &sound_driver];

  [[settings_float objectAtIndex: 0] setValue: &speed];
}

- (int) getVi: (char *) name
{
  int i;
  
  for(i = 0; i < [settings_int count]; i++) {
    if(strstr(name, [[[settings_int objectAtIndex: i] getName] UTF8String]) == name) 
      return [[settings_int objectAtIndex: i] getValue];
  }
  return 0;
}

- (void) initMainGameSettings: (NSString *) filename
{
  Game *game = [Game getGame];
  NSString *fname;
  FILE *f;
  char *home, buf[100];
  int i;

  [self initSettingData: filename];

  /* initialize defaults, then load modifications from file */

  [game setPauseFlag: 0];

  show_help = 0;
  show_fps = 1;
  show_wall = 1;
  show_glow = 1;
  show_2d = 0;
  show_alpha = 1;
  show_floor_texture = 1;
  show_crash_texture = 1;
  show_model = 1;
  turn_cycle = 1;
  line_spacing = 1;
  erase_crashed = 0;
  fast_finish = 1;
  fov = 105;
  speed = 4.2;
  width = 640;
  height = 480;
  show_ai_status = 1;
  camType = 0;
  mouse_warp = 0;

  display_type = 0;
  playSound = 1;

  ai_player1 = 0;
  ai_player2 = 1;
  ai_player3 = 1;
  ai_player4 = 1;
  
  sound_driver = 0;

  /* not included in .gltronrc */

  screenSaver = 0;
  windowMode = 0;
  content[0] = 0;
  content[1] = 1;
  content[2] = 2;
  content[3] = 3;

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
      for(i = 0; i < [settings_int count]; i++) {
        expbuf = [[NSString alloc] initWithFormat: @"iset %@ ", [[settings_int objectAtIndex: i] getName]];
	if(strstr(buf, [expbuf UTF8String]) == buf) {
          int *si_value = [[settings_int objectAtIndex: i] getValue];

	  sscanf(buf + [expbuf length], "%d ", si_value);
	  printf("assignment: %s\t%d\n", [[[settings_int objectAtIndex: i] getName] UTF8String], *si_value);
	  break;
	}
      }
    } else if(strstr(buf, "fset") == buf) {
      for(i = 0; i < [settings_float count]; i++) {
        expbuf = [[NSString alloc] initWithFormat: @"fset %@ ", [[settings_float objectAtIndex: i] getName]];
	if(strstr(buf, [expbuf UTF8String]) == buf) {
          float *sf_value = [[settings_float objectAtIndex: i] getValue];

	  sscanf(buf + [expbuf length], "%f ", sf_value);
	  printf("assignment: %s\t%.2f\n", [[[settings_float objectAtIndex: i] getName] UTF8String], *sf_value);
	  break;
	}
      }
    }
  }
  fclose(f);
}

- (void) saveSettings
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
  for(i = 0; i < [settings_int count]; i++) {
    int *si_value = [[settings_int objectAtIndex: i] getValue];

    fprintf(f, "iset %s %d\n", [[[settings_int objectAtIndex: i] getName] UTF8String], *si_value);
  }
  for(i = 0; i < [settings_float count]; i++) {
    int *sf_value = [[settings_float objectAtIndex: i] getValue];

    fprintf(f, "fset %s %.2f\n", [[[settings_float objectAtIndex: i] getName] UTF8String], *sf_value);
  }
  printf("written settings to %s\n", [fname UTF8String]);
  fclose(f);
}
@end
