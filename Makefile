# Generated automatically from Makefile.in by configure.
# Makefile for gltron

CC = gcc
OPT = -O3 -ffast-math -mcpu=604e -funroll-loops -fomit-frame-pointer 
CFLAGS = -c -Wall -DSOUND -D__USE_INLINE__ -DM_PI=3.1415926 \
		-ISDK:Local/clib2/include/SDL -ISDK:Local/clib2/include/libpng
GL_LIBS = -lglu -lglut -lgl
XLIBS = 
SNDLIBS = -lsdl_mixer -lvorbisfile -lvorbis -logg -lsdl_image -ljpeg -lpng -lz -lsdl
LIBS =  -lpthread -lauto -lm -lunix

CFILES = \
	sgi_texture.c \
	png_texture.c \
	switchCallbacks.c \
	computer.c \
	engine.c \
	graphics.c \
	settings.c \
	texture.c \
	load_texture.c \
	fonttex.c \
	fonts.c \
	menu.c \
	file.c \
	model.c \
	screenshot.c \
	mtllib.c \
	geom.c \
	gui.c \
	pause.c \
	gltron.c \
	gamegraphics.c \
	input.c \
	modelgraphics.c \
	system.c \

SOUND_CFILES = \
	sound.c

OBJ = $(CFILES:.c=.o)
OBJ_SOUND = $(OBJ) $(SOUND_CFILES:.c=.o)

all: gltron

.c.o:
	$(CC) $(CFLAGS) $(OPT) $<

gltron: $(OBJ_SOUND)
	$(CC) $(OPT) -o gltron $(OBJ_SOUND) $(GL_LIBS) $(XLIBS) $(SNDLIBS) $(LIBS)
	strip -R.comment gltron

clean: 
	delete *.o gltron
