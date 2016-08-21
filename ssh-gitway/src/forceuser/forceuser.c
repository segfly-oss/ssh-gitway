#define _GNU_SOURCE
#include <stdio.h>
#include <sys/types.h>
#include <pwd.h>
#include <string.h>
#include <dlfcn.h>
#include <stdlib.h>

typedef struct passwd *(*getpwnam_type)(const char *name);

struct passwd *getpwnam(const char *name) {
  struct passwd *pw;

  // Get a handle the the original getpwnam function
  getpwnam_type orig_getpwnam;
  orig_getpwnam = (getpwnam_type)dlsym(RTLD_NEXT, "getpwnam");

  // Check if we are to force call to a specific user
  const char *force_user = getenv("FORCE_USER");
  if (force_user != NULL) {
    pw = orig_getpwnam(force_user);
    if (pw != NULL) {
      // If the forced user exists, look it up and replace the name with the intended user
      //printf("forcepw.so: forcing getpwnam(): %s\n", force_user);
      pw->pw_name = strdup(name);
#ifdef HAVE_STRUCT_PASSWD_PW_GECOS
      pw->pw_gecos = strdup(name);
#endif
    } else {
      //printf("forcepw.so: FORCE_USER not found: %s\n", force_user);
    }
  } else {
    //printf("forcepw.so: FORCE_USER not set. Passing through: %s\n", name);
    pw = orig_getpwnam(name);
  }

  return pw;
}