#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>

#define MIN(a, b) (((a) < (b)) ? (a) : (b))

int wipe_file(const char *path, int pass) {
    int fd = open(path, O_RDWR);
    unsigned char buf[1024];
    struct stat s;
    int nw, bw, r;

    if (fd < 0) {
        fprintf(stderr, "%s unable to open %s: %s", __func__, path, 
            strerror(errno));
        return fd;
    }

    if ((r=fstat(fd, &s))!=0) {
        fprintf(stderr, "%s unable to stat file %s: %s", __func__, path,
            strerror(errno));
    }

    switch(pass) {
        case 1:
            memset(buf, 0x55, sizeof(buf));
            break;
        case 2:
            memset(buf, 0xAA, sizeof(buf));
            break;
        case 3:
            for(r=0;r<sizeof(buf);++r) 
                buf[r] = arc4random() % 255;
            break;
        default:
            fprintf(stderr, "%s invalid pass: %d", __func__, pass);
            return -1;
    }

    nw = s.st_size;
    for( ; nw; nw -= bw)
        bw = write(fd, buf, MIN(nw,sizeof(buf)));
    return close(fd);
}
