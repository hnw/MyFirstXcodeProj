//
//  exec.c
//  MyFirstXcodeProj
//
//  Created by hnw on 2016/06/01.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

#include "myexec.h"
#include <string.h>

void exec_ls(void)
{
    char * const argv[] = {"/bin/sh", "-c", "ls -la /sbin", NULL};
//    char * const argv[] = {"/bin/sh", "-c", "/sbin/ifconfig", NULL};
    pid_t pid;
    char * const *envp;
    
    int status = posix_spawn(&pid, argv[0], NULL, NULL, argv, envp);
    
    if (status == 0) {
        printf("Child pid: %i\n", pid);
    } else {
        printf("posix_spawn: %s\n", strerror(status));
    }
}
int my_posix_spawn(pid_t *restrict pid, const char *restrict path, const posix_spawn_file_actions_t *file_actions, const posix_spawnattr_t *restrict attrp, char *const argv[restrict], char *const envp[restrict])
{
    printf("%s\n", path);
    printf("%s\n", argv[0]);
    printf("%s\n", argv[1]);
    printf("%s\n", argv[2]);

    int status = posix_spawn(pid, path, file_actions, attrp, argv, envp);
    return status;
}