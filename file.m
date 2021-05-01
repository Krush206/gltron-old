#include "gltron.h"

@implementation File
- (NSString *) getFullPath: (NSString *) filename
{
  NSString *base, *path;
  NSFileHandle *fp;

  NSString *share1 = [[NSString alloc] initWithString: @"/usr/share/games/gltron"];
  NSString *share2 = [[NSString alloc] initWithString: @"/usr/local/share/games/gltron"];

  /* check a few directories for the files and */
  /* return the full path. */
  
  /* check: current directory, GLTRON_HOME, and, for UNIX only: */
  /* /usr/share/games/gltron and /usr/local/share/games/gltron */

  path = [[NSString alloc] initWithString: filename];

  printf("checking '%s'...", [path UTF8String]);
  fp = [NSFileHandle fileForReadingAtPath: path];
  if(fp != nil) {
    printf("ok\n");
    return path;
  }
  printf("unsuccessful\n");

  base = [[NSString alloc] initWithUTF8String: getenv("GLTRON_HOME")];
  if(base != nil) {
    path = [[NSString alloc] initWithFormat: @"%@%c%@", base, SEPERATOR, filename];

    printf("checking '%s'...", [path UTF8String]);
    fp = [NSFileHandle fileForReadingAtPath: path];
    if(fp != nil) {
      printf("ok\n");
      return path;
    }
    printf("unsuccessful\n");
  }

  path = [[NSString alloc] initWithFormat: @"%@%c%@", share1, SEPERATOR, filename];

  printf("checking '%s'", [path UTF8String]);
  fp = [NSFileHandle fileForReadingAtPath: path];
  if(fp != nil) {
    printf("ok\n");
    return path;
  }
  printf("unsuccessful\n");

  path = [[NSString alloc] initWithFormat: @"%@%c%@", share2, SEPERATOR, filename];
  
  printf("checking '%s'", [path UTF8String]);
  fp = [NSFileHandle fileForReadingAtPath: path];
  if(fp != nil) {
    printf("ok\n");
    return path;
  }  
  printf("unsuccessful\n");

  return nil;
}
@end
