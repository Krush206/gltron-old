/* system specific functions (basically, an SDL wrapper) */

#include "system.h"
#include "dos.h"

static int win_x, win_y;
static int width, height;
static int flags;
static unsigned char fullscreen;
static callbacks *current = 0;

void SystemExit() {

  stopSound();
  sleep(0.50);

  shutdownSound();

  SDL_Quit();
}

void SystemInit(int *argc, char **argv) {
  if(SDL_Init(SDL_INIT_AUDIO) < 0 ){
    fprintf(stdout, "Couldn't initialize SDL: %s\n", SDL_GetError());
    exit(1);
  }
  glutInit(argc, argv);
}

void SystemPostRedisplay() {
  glutPostRedisplay();
}

int SystemGetElapsedTime() {
#ifdef WIN32
    return timeGetTime();
#elif defined (__amigaos4__)
  return clock() * 10;
#else
  return glutGet(GLUT_ELAPSED_TIME);
#endif
}

void SystemSwapBuffers() {
  glutSwapBuffers();
}

void SystemWarpPointer(int x, int y) {
#ifndef __amigaos4__
  glutWarpPointer(x, y);
#endif
}

void SystemMainLoop() {
  glutMainLoop();
}

void SystemKeyboard(unsigned char key, int x, int y) {
  if(current)
    current->keyboard(key, x, y);
}

void SystemSpecial(int key, int x, int y) {
  if(current)
    current->keyboard(key, x, y);
}
  
void SystemRegisterCallbacks(callbacks *cb) {
  current = cb;
  glutIdleFunc(cb->idle);
  glutDisplayFunc(cb->display);
  glutKeyboardFunc(SystemKeyboard);
  glutSpecialFunc(SystemKeyboard);
}

void SystemInitWindow(int x, int y, int w, int h) {
  win_x = x;
  win_y = y;
  width = w;
  height = h;
}

void SystemInitDisplayMode(int f, unsigned char full) {
  flags = f;
  fullscreen = full;
}

int SystemCreateWindow(char *name) {
  if(fullscreen) {
    // do glut game mode stuff
  } else {
    glutInitWindowPosition(win_x, win_y);  
    glutInitWindowSize(width, height);
    glutInitDisplayMode(flags);
    return glutCreateWindow(name);
  }
}

void SystemDestroyWindow(int id) {
  glutDestroyWindow(id);
}

void SystemReshapeFunc(void(*reshape)(int, int)) {
  glutReshapeFunc(reshape);
}

extern char* SystemGetKeyName(int key) {
  char *buf;

  buf = malloc(2);
  buf[0] = (char)key;
  buf[1] = 0;
  return buf;
}  





