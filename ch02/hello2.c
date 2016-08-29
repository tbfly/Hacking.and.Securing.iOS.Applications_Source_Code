#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

#define FILE "/var/mobile/Library/AddressBook/AddressBook.sqlitedb"

int main() {
    int fd = open(FILE, O_RDONLY);
    char buf[128]; 
    int nr;

    if (fd < 0)
        exit -1;
    while ((nr = read(fd, buf, sizeof(buf))) > 0) {
        write(fileno(stdout), buf, nr);
    }
    close(fd);
}
