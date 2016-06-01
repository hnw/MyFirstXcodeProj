//
//  exec.c
//  MyFirstXcodeProj
//
//  Created by hnw on 2016/06/01.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

#include "myexec.h"
#include <stdio.h>
#include <string.h>
#include <spawn.h>

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