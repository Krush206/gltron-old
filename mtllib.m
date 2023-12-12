#define MAX_MATERIALS 100

#include "model.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

@implementation MTLlib
- (int) loadMaterial: (NSString *) filename materials: (NSArray **) materials {
  NSMutableArray *m = [NSMutableArray new];
  FILE *f;
  char buf[120];
  char namebuf[120];
  int iMaterial = -1;
  int iLine = 0;

  if((f = fopen(filename, "r")) == 0) {
    fprintf(stderr, "could not open file '%s'\n", filename);
    return -1;
  }
  while(fgets(buf, sizeof(buf), f)) {
    switch(buf[0]) {
    case 'n':
      if(sscanf(buf, "newmtl %s ", namebuf) == 1) {
	iMaterial++;
	[m addObject: [Materials new]];
	[[m objectAtIndex: iMaterial] setName: [[NSString alloc] initWithUTF8String: namebuf]];
	
	[[m objectAtIndex: iMaterial] getAmbient][3] = 1.0;
	[[m objectAtIndex: iMaterial] getDiffuse][3] = 1.0;
	[[m objectAtIndex: iMaterial] getSpecular][3] = 1.0;
      } else {
	fprintf(stderr, "warning: ignored line %d\n", iLine);
      }
      break;
    case 'K':
      if(iMaterial >= 0) {
	switch(buf[1]) {
	case 'a': sscanf(buf, "Ka %f %f %f",
			 [[m objectAtIndex: iMaterial] getAmbient],
			 &[[m objectAtIndex: iMaterial] getAmbient][1],
			 &[[m objectAtIndex: iMaterial] getAmbient][2];
	break;
	case 'd': sscanf(buf, "Kd %f %f %f",
			 [[m objectAtIndex: iMaterial] getDiffuse],
			 &[[m objectAtIndex: iMaterial] getDiffuse][1],
			 &[[m objectAtIndex: iMaterial] getDiffuse][2];
	break;
	case 's': sscanf(buf, "Ks %f %f %f",
			 [[m objectAtIndex: iMaterial] getSpecular],
			 &[[m objectAtIndex: iMaterial] getSpecular][1],
			 &[[m objectAtIndex: iMaterial] getSpecular][2];
	break;
	default: 
	  fprintf(stderr, "unknown light model at line %d\n", iLine);
	  break;
	}
      }
      break;
      /* ignore the rest... */
    }
    iLine++;
  }
  /* allocate the needed materials */
  /* copy the data */
  /* free the temporary memory */
  /* return number of materials */
  *materials = m;
  return iMaterial + 1;
}
@end
