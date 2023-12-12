#ifndef MENUS
#define MENUS

@interface MDisplay: NSObject
{
  /* fonttex *font; */
  float fgColor[4]; /* entries */
  float hlColor[4]; /* the highlighted one */

  char szCaption[32];
}

- (void) setFGColor: (float *) o;
- (void) setHLColor: (float *) o;
- (void) setSZCaption: (char *) o;
- (float *) getFGColor;
- (float *) getHLColor;
- (char *) getSZCaption;
@end

@interface Menu: NSObject
{
  int nEntries;
  int iHighlight;
  mDisplay display;
  char szName[32];
  char szCapFormat[32];
  struct Menu** pEntries;
  struct Menu* parent;
  void* param; /* reserved to bind parameters at runtime */
}

- (void) setNEntries: (int) o;
- (void) setIHighlight: (int) o;
- (void) setMDisplay: (MDisplay *) o;
- (void) setSZName: (char *) o;
- (void) setSZCapFormat: (char *) o;
- (void) setPEntries: (NSArray *) o;
- (void) setParent: (Menu *) o;
- (void) setParam: (void *) o;
- (int) getNEntries;
- (int) getIHighlight;
- (MDisplay *) getMDisplay;
- (char *) getSZName;
- (char *) getSZCapFormat;
- (NSArray *) getPEntries;
- (Menu *) getParent;
- (void *) getParam;
@end

@interface Node: NSObject
{
  void* data;
  void* next;
}

- (void) setData: (void *) o;
- (void) setNext: (void *) o;
- (void *) getData;
- (void *) getNext;
@end

#endif
