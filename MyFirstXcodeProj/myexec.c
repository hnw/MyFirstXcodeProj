//
//  exec.c
//  MyFirstXcodeProj
//
//  Created by hnw on 2016/06/01.
//  Copyright © 2016年 hanawa-y. All rights reserved.
//

#include "myexec.h"
#include <string.h>
#include <sys/stat.h>
#include <dirent.h>
#include <sys/types.h>

void exec_ls(void)
{
    char * const argv[] = {"/bin/sh", "-c", "ls -la /sbin", NULL};
//    char * const argv[] = {"/bin/sh", "-c", "/sbin/ifconfig", NULL};
    pid_t pid;
    char * const *envp;
    
    int status = posix_spawn(&pid, argv[0], NULL, NULL, argv, envp);

    printf("Child pid: %i\n", pid);

    if (status != 0) {
        printf("posix_spawn: %s\n", strerror(status));
    }
}

void my_stat(const char *restrict path)
{

    struct stat buf;
    int ret;
    ret = stat(path, &buf);
    if (ret == 0) {
        printf("st_mode=%o\n", buf.st_mode);
        printf("st_nlink=%d\n", buf.st_nlink);
        printf("st_uid=%d\n", buf.st_uid);
        printf("st_gid=%d\n", buf.st_gid);
        printf("st_size=%lld\n", buf.st_size);

        if (S_ISDIR(buf.st_mode)) {
            printf("ISDIR!\n");

            DIR *dp;
            struct dirent *ep;
            dp = opendir(path);
            if (dp != NULL) {
                while (ep = readdir (dp)) {
                    printf("%s\n", ep->d_name);
                }
                (void) closedir(dp);
            }
        } else {
            FILE *fp = fopen(path, "r");
            char buf[1025];
            while ((fgets(buf, 1024, fp)) != NULL) {
                printf("%s", buf);
            }
            fclose(fp);
        }
    }
}

int my_posix_spawnp(pid_t *restrict pid, const char *restrict file,
                    const posix_spawn_file_actions_t *file_actions,
                    const posix_spawnattr_t *restrict attrp, char *const argv[restrict],
                    char *const envp[restrict])
{
    printf("%s\n", file);
    printf("%s\n", argv[0]);
    printf("%s\n", argv[1]);
    printf("%s\n", argv[2]);
    
    int status = posix_spawnp(pid, file, file_actions, attrp, argv, envp);
    return status;
}