#include "gltron.h"

@implementation GLtron (Computer)
- (int) freewayWithData: (Data *) data direction: (int) dir
{
  int i;
  int wd = 20;

  for(i = 1; i < wd; i++)
    if([self getColWithX: data->posx + dirsX[dir] * i
             y: data->posy + dirsY[dir] * i]) break;
  return i;
}

- (void) getDistancePointWithData: (Data *) data
         direction: (int) d
	 x: (int *) x
	 y: (int *) y
{
  *x = data->posx + dirsX[data->dir] * d;
  *y = data->posy + dirsY[data->dir] * d;
}
  
- (void) doComputerWithPlayer: (Player *) me data: (Data *) him
{
  AI *ai;
  Data *data;
  int x, y;
  int i;
  int dtest[] = { 5, 10, 15 };
  int dn = 3;

  int fd = 15;

  int maxmoves = 100;
  int dir1, dir2;
  int s1, s2;
  int d1, d2;

  int tvalue = 0;

  if(me->ai == NULL) {
    printf("This player has no AI!\n");
    return;
  }
  
  data = me->data;
  ai = me->ai;
  ai->moves++;

  if(ai->danger <= 0) {
    for(i = 0; i < dn; i++) {
      [self getDistancePointWithData: me->data
            direction: dtest[i]
            x: &x
            y: &y];
      if([self getColWithX: x y: y]) ai->danger = dtest[i];
    }
  }

  if(ai->danger > 0) {
    dir1 = (data->dir + 1) % 4;
    dir2 = (data->dir + 3) % 4;
    s1 = [self freewayWithData: data direction: dir1];
    s2 = [self freewayWithData: data direction: dir2];

    if(s1 > ai->danger && s2 > ai->danger) { /* turn ok */
      if(s1 > fd && s1 - ai->tdiff > s2)
	tvalue = 1;
      else if(s2 > fd && s1 - ai->tdiff < s2)
	tvalue = 3;
      else tvalue = (s1 > s2) ? 1 : 3;
      [self turnWithData: data direction: tvalue];
      ai->tdiff += (tvalue == 1) ? 1 : -1;
      ai->danger = 0;
    } else {
      ai->danger--;
    }
  } else if(ai->moves >= maxmoves) {
    dir1 = (data->dir + 1) % 4;
    dir2 = (data->dir + 3) % 4;
    d1 = abs(data->posx + dirsX[dir1] - him->posx) +
      abs(data->posy + dirsY[dir1] - him->posy);
    d2 = abs(data->posx + dirsX[dir2] - him->posx) +
      abs(data->posy + dirsY[dir2] - him->posy);
    tvalue = (d1 < d2) ? 1 : 3;
    if([self freewayWithData: data
             direction: (data->dir + tvalue) % 4] > fd) {
      [self turnWithData: data direction: tvalue];
      ai->tdiff += (tvalue == 1) ? 1 : -1;
      ai->moves = 0;
    } else {
      ai->moves -= 20;
    }
  }
}
@end
