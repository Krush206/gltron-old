#include "gltron.h"

@implementation GLtron (Fonts)
- (void) initFonts
{
  char *path;

  if(ftx != NULL) [self unloadFontWithFontTexture: ftx];
  path = [self fullPathWithFile: "xenotron.ftx"];
  if(path != 0) {
    ftx = [self loadFontWithFile: path];
  
    if(ftx == NULL) {
      // fprintf(stderr, "fatal: no Fonts available - %s, %s\n",
      //       path, txfErrorString());
      exit(1);
    }
    // printf("using font from '%s'\n", path);
    // txfEstablishTexture(txf, 1, GL_TRUE);
    [self establishTextureWithFontTexture: ftx
          mipmaps: GL_TRUE];
  } else {
    printf("fatal: could not load font\n");
    exit(1);
  }
}

- (void) deleteFonts
{
  if(ftx != NULL)
    [self unloadFontWithFontTexture: ftx];
  ftx = NULL;
}
@end
