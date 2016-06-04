//
//  exec.h
//  MyFirstXcodeProj
//
//  Created by hnw on 2016/06/01.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

#ifndef exec_h
#define exec_h

#include <stdio.h>
#include <spawn.h>

void exec_ls(void);

void my_stat(const char *restrict path);

int my_posix_spawnp(pid_t *restrict pid, const char *restrict file,
                   const posix_spawn_file_actions_t *file_actions,
                   const posix_spawnattr_t *restrict attrp, char *const argv[restrict],
                   char *const envp[restrict]);

#endif /* exec_h */
