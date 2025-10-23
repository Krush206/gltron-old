#include "gltron.h"

@implementation GLtron (Texture)
- (void) deleteTexturesWithDisplay: (gDisplay *) d
{
  glDeleteTextures(1, &(d->texFloor));
  glDeleteTextures(1, &(d->texWall));
  glDeleteTextures(1, &(d->texGui));
  glDeleteTextures(1, &(d->texCrash));
}

- (void) loadTextureWithFile: (char *) filename
         format: (int) format
{
  char *path;
  sgi_texture *tex;

  path = [self fullPathWithFile: filename];
  if(path != 0)
    tex = [self loadSGITextureWithFile: path];
  else {
    fprintf(stderr, "fatal: could not load %s, exiting...\n", filename);
    exit(1);
  }
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glTexImage2D(GL_TEXTURE_2D, 0, format, tex->width, tex->height, 0,
	       GL_RGBA, GL_UNSIGNED_BYTE, tex->data);
  free(tex->data);
  free(tex);
}

- (void) initTextureWithDisplay: (gDisplay *) d
{
  [self checkGLErrorWithSignature: "initTextureWithDisplay: - start"];

  /* floor texture */
  glGenTextures(1, &(d->texFloor));
  glBindTexture(GL_TEXTURE_2D, d->texFloor);
  [self loadTextureWithFile: "gltron_floor.sgi" format: GL_RGB16];
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  [self checkGLErrorWithSignature: "initTextureWithDisplay: - floor"];
  /* menu icon */
  glGenTextures(1, &(d->texGui));
  glBindTexture(GL_TEXTURE_2D, d->texGui);
  [self loadTextureWithFile: "gltron.sgi" format: GL_RGBA];
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  [self checkGLErrorWithSignature: "initTextureWithDisplay: - gui"];

  /* wall texture */
  glGenTextures(1, &(d->texWall));
  glBindTexture(GL_TEXTURE_2D, d->texWall);
  [self loadTextureWithFile: "gltron_wall.sgi" format: GL_RGBA];
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  /* crash texture */
  glGenTextures(1, &(d->texCrash));
  glBindTexture(GL_TEXTURE_2D, d->texCrash);
  [self loadTextureWithFile: "gltron_crash.sgi" format: GL_RGBA];
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

  [self checkGLErrorWithSignature: "initTextureWithDisplay: - end"];
}
@end
