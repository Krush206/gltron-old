# Makefile for gltron

PROG := gltron
CC := gcc
OPT := -O2

CFLAGS := -Wall \
	  -I/usr/local/GNUstep/Local/Library/Headers \
	  -I/usr/local/include
LDFLAGS := -L/usr/local/GNUstep/Local/Library/Libraries \
	   -L/usr/local/lib

LIBS := -lobjc -lGL -lGLU -lglut -lm

SRC := sgi_texture.m \
       switchCallbacks.m \
       gui.m \
       pause.m \
       computer.m \
       engine.m \
       $(PROG).m \
       graphics.m \
       gamegraphics.m \
       input.m \
       settings.m \
       texture.m \
       fonttex.m \
       fonts.m \
       menu.m \
       file.m \
       model.m \
       modelgraphics.m \
       mtllib.m \
       geom.m
OBJ := $(SRC:.m=.o)

all: $(OBJ)
	$(CC) -o ./$(PROG) $(LDFLAGS) $(OBJ) $(LIBS)
	strip ./$(PROG)

%.o: %.m
	$(CC) -c $(OPT) $(CFLAGS) $<

clean: 
	rm -f ./*.o ./$(PROG)
