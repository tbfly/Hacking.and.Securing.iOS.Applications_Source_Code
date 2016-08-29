#include <stdio.h>
#include <objc/objc.h>

id evil_say(id self, SEL op) {

    printf("Bawhawhawhaw! I'm Evil!\n");

    return self;
}

static void __attribute__((constructor)) initialize(void) {

    class_replaceMethod(
        objc_getClass("SaySomething"),
        sel_registerName("say:"),
        evil_say,
        "@:"
    );

}
