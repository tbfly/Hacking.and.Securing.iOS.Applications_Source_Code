#import <Foundation/Foundation.h>
#include <stdio.h>
#include <dlfcn.h>
#include <objc/objc.h>
#include <objc/runtime.h>

static inline BOOL validate_methods(const char *cls, const char *fname) {
    Class aClass = objc_getClass(cls);
    Method *methods;
    unsigned int nMethods;
    Dl_info info;
    IMP imp;
    char buf[128];
    Method m;

    if (!aClass)
        return NO;
    methods = class_copyMethodList(aClass, &nMethods);
    while(nMethods--) {
        m = methods[nMethods];
        printf("validating [ %s %s ]\n",
            (const char *) class_getName(aClass),
            (const char *) method_getName(m));

        imp = method_getImplementation(m);
        if (!imp) {
            printf("error: method_getImplementation(%s) failed\n",
                (const char *) method_getName(m));
            free(methods);
            return NO;
        }

        if (! dladdr(imp, &info)) {
            printf("error: dladdr() failed for %s\n",
                (const char *)method_getName(m));
            free(methods);
            return NO;
        }

        /* Validate image path */
        if (strcmp(info.dli_fname, fname))
            goto FAIL;

        /* Validate class name in symbol */
        snprintf(buf, sizeof(buf), "[%s ",
            (const char *) class_getName(aClass));
        if (strncmp(info.dli_sname+1, buf, strlen(buf)))
        {
            snprintf(buf, sizeof(buf), "[%s(",
                (const char *) class_getName(aClass));
            if (strncmp(info.dli_sname+1, buf, strlen(buf)))
                goto FAIL;
        }

        /* Validate selector in symbol */
        snprintf(buf, sizeof(buf), " %s]",
            (const char *) method_getName(m));
        if (strncmp(info.dli_sname + (strlen(info.dli_sname) - strlen(buf)),
            buf, strlen(buf)))
        {
            goto FAIL;
        }
    }
    return YES;

FAIL:
    printf("method %s failed integrity test:\n",
        (const char *)method_getName(m));
    printf("   dli_fname: %s\n", info.dli_fname);
    printf("   dli_sname: %s\n", info.dli_sname);
    printf("   dli_fbase: %p\n", info.dli_fbase);
    printf("   dli_saddr: %p\n", info.dli_saddr);
    free(methods);
    return NO;
}

@interface MyDelegate : NSObject
{

}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
-(void)connection:(NSURLConnection *)connection 
    didFailWithError:(NSError *)error;
@end

@implementation MyDelegate

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%s connection finished successfully", __func__);
    [ connection release ];
}

-(void)connection:(NSURLConnection *)connection 
    didFailWithError:(NSError *)error
{
    NSLog(@"%s connection failed: %@", 
        __func__, 
        [ error localizedDescription ]);
    [ connection release ];
}
@end

int main(void) {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    MyDelegate *myDelegate = [ [ MyDelegate alloc ] init ];
    char buf[256];

    snprintf(buf, sizeof(buf), "%s/TestConnection",
        [ [ [ NSBundle mainBundle ] resourcePath ] UTF8String ]);

    /* Some tests that should succeed */

    if (NO == validate_methods("NSURLConnection", 
        "/System/Library/Frameworks/Foundation.framework/Foundation"))
    exit(0);

    if (NO == validate_methods("NSMutableURLRequest",
        "/System/Library/Frameworks/Foundation.framework/Foundation"))
    exit(0);

    if (NO == validate_methods("NSString",
        "/System/Library/Frameworks/Foundation.framework/Foundation"))
    exit(0);

    if (NO == validate_methods("MyDelegate", buf))
    exit(0);

    /* Some tests that should fail */

    if (YES == validate_methods("MyDelegate",
        "/System/Library/Frameworks/Foundation.framework/Foundation"))
    exit(0);

    if (YES == validate_methods("NSURLConnection",
        "/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation"))
    exit(0);

    /* We're validated. Time to work. */

    NSURLRequest *request = [ [ NSURLRequest alloc ] 
        initWithURL: [ NSURL URLWithString: @"https://www.paypal.com" ]
    ];

    NSURLConnection *connection = [ [ NSURLConnection alloc ] 
        initWithRequest: request delegate: myDelegate ];

    if (!connection) {
       NSLog(@"%s connection failed");
    } 

    CFRunLoopRun();
    [ pool release ];
    return 0;
}

