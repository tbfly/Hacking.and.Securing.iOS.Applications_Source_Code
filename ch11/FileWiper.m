#import <Foundation/Foundation.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>

@interface FileWiper
{

}

+(BOOL)wipe:(NSString *)path phase:(int)phase;
+(BOOL)wipe:(NSString *)path;
@end

@implementation FileWiper

+(BOOL) wipe: (NSString *)path phase:(int)phase
{
    int fd = open([ path UTF8String ], O_RDWR);
    unsigned char buf[1024];
    struct stat s;
    int nw, bw, r;

    if (fd < 0) {
        NSLog(@"%s unable to open %s: %s", __func__, path, 
            strerror(errno));
        return NO;
    }

    if ((r=fstat(fd, &s))!=0) {
        NSLog(@"%s unable to stat file %s: %s", __func__, path,
            strerror(errno));
        return NO;
    }

    switch(phase) {
        case 1:
            memset(buf, 0x55, sizeof(buf));
            break;
        case 2:
            memset(buf, 0xAA, sizeof(buf));
            break;
        case 3:
            srandomdev();
            for(r=0;r<sizeof(buf);++r)
                buf[r] = random() % 255;
            break;
        default:
            NSLog(@"%s invalid wipe phase: %d", __func__, phase);
            return NO;
    }

    nw = s.st_size;
    for( ; nw; nw -= bw) 
        bw = write(fd, buf, MIN(nw,sizeof(buf)));
        
    if (close(fd) == 0)
        return YES;
    return NO;
}

+ (BOOL) wipe: (NSString *)path
{
    if ([ self wipe: path phase: 1 ] == NO)
        return NO;

    if ([ self wipe: path phase: 2 ] == NO)
        return NO;

    if ([ self wipe: path phase: 3 ] == NO)
        return NO;

    return YES;
}
@end

int main() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString *documents = [ paths objectAtIndex: 0 ];
    NSString *path = [
        documents stringByAppendingPathComponent: @"private.sqlite" ];

    if ([ FileWiper wipe: path ] == YES)
        [ [ NSFileManager defaultManager ] removeItemAtPath: path 
                                                      error: NULL ];
    else
        NSLog(@"%s unable to delete file %@", __func__, path); 
}
