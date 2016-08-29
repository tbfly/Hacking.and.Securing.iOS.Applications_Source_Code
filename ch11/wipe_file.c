#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>

#define MIN(a, b) (((a) < (b)) ? (a) : (b))

int wipe_file(const char *path) {
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
    nw = s.st_size;
    memset(buf, 0, sizeof(buf));

    for( ; nw; nw -= bw) 
        bw = write(fd, buf, MIN(nw,sizeof(buf)));
    return close(fd);
}

int main() {
    wipe_file("./foo");
}
