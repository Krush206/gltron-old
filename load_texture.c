#include "gltron.h"

#ifdef SGI_TEX
#include "sgi_texture.h"
typedef sgi_texture texture;
#define LOAD_TEX(x) load_sgi_texture(x)
#endif

#ifdef PNG_TEX
#include "png_texture.h"
#include <png.h>
typedef png_texture texture;
#define LOAD_TEX(x) load_png_texture(x)
#endif

#ifndef SDL_TEX

#ifdef __amigaos4__

// code from the 0.70 version...

#define TARGET(X, Y, I) (mip->data + I + mip->channels * (X + Y * mip->width))
#define SOURCE(X, Y, I) (source->data + I + \
     source->channels * (X + Y * source->width))

png_texture* mipmap_png_texture(png_texture *source, int level,
        int clamp_u, int clamp_v) {
  png_texture *mip;
  int i;
  int x, y;
  int fx, fy;

  if(level != 1) return NULL;
  mip = (png_texture*) malloc(sizeof(png_texture));
  mip->channels = source->channels;
  fx = (source->width > 1) ? 2 : 1;
  fy = (source->height > 1) ? 2 : 1;

  mip->width = source->width / fx;
  mip->height = source->height / fy;
  mip->data = (unsigned char*) malloc(mip->width * mip->height *
          mip->channels);

  /* simple linear filtering */
  for(i = 0; i < mip->channels; i++) {
    for(y = 0; y < mip->height; y++) {
      for(x = 0; x < mip->width; x++) {
    /*
    *( TARGET(x, y, i) ) = ( *( SOURCE(x * fx, y * fy, i) )  +
     *( SOURCE((x + 1) * fx, (y + 1) * fy, i) ) +
     *( SOURCE((x + 1) * fx, y * fy, i) ) +
     *( SOURCE(x * fx, (y + 1) * fy, i) ) ) / 4;
     */
    int sx, sy, xoff, yoff;
    sx = fx * x;
    sy = fy * y;
    xoff = fx - 1;
    yoff = fy - 1;

    *( mip->data + i + mip->channels * ( x + y * mip->width ) ) =
      ( *( source->data + i + source->channels * ( sx + sy * source->width) ) +
        *( source->data + i + source->channels * ( sx + xoff + sy * source->width) ) +
        *( source->data + i + source->channels * ( sx + xoff + (sy + yoff) * source->width) ) +
        *( source->data + i + source->channels * ( sx + (sy + yoff) * source->width) ) ) / 4;

      }
    }
  }
  return mip;
}
void freeTextureData(texture *tex) {
  free(tex->data);
  free(tex);
}


texture* loadTextureData(char *filename) {
  texture *tex = NULL;
  char *path;

  path = getFullPath(filename);
  if(path != 0)
    tex = LOAD_TEX(path);
  else {
    fprintf(stdout, "fatal: could not load %s, exiting...\n", filename);
    exit(1);
  }

  if(tex == 0) {
    fprintf(stdout, "fatal: failed load %s, exiting...\n", filename);
    exit(1);
  }
  return tex;
}

void loadTexture(char *filename, int format) {
  texture *tex;
  GLint internal;
  int maxSize;

  glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxSize);

  tex = loadTextureData(filename);
  if(tex->channels == 3) internal = GL_RGB;
  else internal = GL_RGBA;
  if(format == GL_DONT_CARE) {
    if(tex->channels == 3) format = GL_RGB;
    if(tex->channels == 4) format = GL_RGBA;
  }
  /* TODO: build mipmaps the proper way, box filters suck */
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);

  {
    texture *newtex;
    int level = 0;

    while (tex->width > 1 || tex->height > 1) {
      if(tex->width <= maxSize && tex->height <= maxSize) {
        glTexImage2D(GL_TEXTURE_2D, level, format,
                     tex->width, tex->height,
                     0, internal, GL_UNSIGNED_BYTE, tex->data);
        level++;
      }

      newtex = mipmap_png_texture(tex, 1, 0, 0);
      freeTextureData(tex);
      tex = newtex;
    }
    /* upload 1x1 mip level */
    glTexImage2D(GL_TEXTURE_2D, level, format,
                 tex->width, tex->height,
                 0, internal, GL_UNSIGNED_BYTE, tex->data);
    freeTextureData(tex);
  }
}
#else

void loadTexture(char *filename, int format) {
  char *path;
  texture *tex;
  GLint internal;

  path = getFullPath(filename);
  if(path != 0)
    tex = LOAD_TEX(path);
  else {
    fprintf(stdout, "fatal: could not load %s, exiting...\n", filename);
    exit(1);
  }

  if(tex == 0) {    
    fprintf(stdout, "fatal: failed load %s, exiting...\n", filename);
    exit(1);
  }

  if(tex->channels == 3) internal = GL_RGB;
  else internal = GL_RGBA;
  /* TODO: build mipmaps the proper way, box filters suck */
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  if(game->settings->use_mipmaps) {
    gluBuild2DMipmaps(GL_TEXTURE_2D, format, tex->width, tex->height, 
              internal, GL_UNSIGNED_BYTE, tex->data);
  } else { 
    glTexImage2D(GL_TEXTURE_2D, 0, format, tex->width, tex->height, 0,
         internal, GL_UNSIGNED_BYTE, tex->data);
  }

  free(tex->data);
  free(tex);
}
#endif


/* the following code uses SDL_image to load textures */
/* not used currently */

#ifdef SDL_TEX
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

void loadTexture(char *name, int wantedFormat) {
  /* wantedFormat is ignored */
  SDL_surface *image;
  int tex_id;
  int format;
  int x, y;
  int bpp;
  unsigned char *data;
  char *path;

  path = getFullPath(name);
  if(path != 0) {
    image = IMG_Load(path);
  } else {
    fprintf(stdout, "fatal: could not load %s, exiting...\n", name);
    exit(1);
  }

  if(image == 0) {
    fprintf(stdout, "can't load image: %s\n", SDL_GetError());
    exit(1);
  }

  /* now make the thing a usable OpenGL texture */

  /* support 24 & 32 bit images */
  bpp = image->format->BitsPerPixel;
  if(bpp != 24 && bpp != 32) {
    SDL_FreeSurface(image);
    return -1;
  }
  
  printf("bpp: %d\n", bpp);
  data = (unsigned char*) malloc(image->w * image->h * bpp / 8);
  /* copy every pixel */
  for(y = 0; y < image->h; y++) {
    for(x = 0; x < image->w; x++) {

      Uint8 *bufp;
      bufp = (Uint8 *)image->pixels + (image->h - y - 1) * image->pitch +
    (bpp / 8) * x;
      *(data + (bpp / 8) * (y * image->w + x) + 0) =
    *(bufp + image->format->Rshift / 8);
      *(data + (bpp / 8) * (y * image->w + x) + 1) =
    *(bufp + image->format->Gshift / 8);
      *(data + (bpp / 8) * (y * image->w + x) + 2) =
    *(bufp + image->format->Bshift / 8);
      /* why on earth are the alpha values reversed? */
      if(bpp == 32) {
    *(data + (bpp / 8) * (y * image->w + x) + 3) =
      255 - *(bufp + image->format->Ashift / 8);
      }
    }
  }

  format = (bpp == 24) ? GL_RGB : GL_RGBA;

  /* load the texture into OGL */
  /* TODO: build mipmaps the proper way, box filters suck */

  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  if(game->settings->use_mipmaps) {
    gluBuild2DMipmaps(GL_TEXTURE_2D, format, image->w, image->h, 
              format, GL_UNSIGNED_BYTE, data);
  } else { 
    glTexImage2D(GL_TEXTURE_2D, 0, format, image->w, image->h, 0,
         format, GL_UNSIGNED_BYTE, data);
  }

  free(data);
  SDL_FreeSurface(image);
  return 0;
}

#endif
#endif // __amigaos4__

