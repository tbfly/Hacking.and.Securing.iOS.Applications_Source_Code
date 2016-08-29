#include <Foundation/Foundation.h>
#include <objc/objc.h>
#include <objc/runtime.h>

void didReceiveAuthenticationChallenge(
    id self, 
    SEL op, 
    NSURLConnection *connection, 
    NSURLAuthenticationChallenge *challenge)
{
  if ( [ challenge.protectionSpace.authenticationMethod
        isEqualToString:NSURLAuthenticationMethodServerTrust ])
    {
        [ challenge.sender useCredential:
            [ NSURLCredential credentialForTrust:
                challenge.protectionSpace.serverTrust]
        forAuthenticationChallenge: challenge];
    }

    [ challenge.sender continueWithoutCredentialForAuthenticationChallenge:
      challenge ];
}

BOOL canAuthenticateAgainstProtectionSpace(
    id self,
    SEL op,
    NSURLConnection *connection,
    NSURLProtectionSpace *protectionSpace)
{
    if ( [ [ protectionSpace authenticationMethod ]
        isEqualToString: NSURLAuthenticationMethodServerTrust ])
    {
        return YES;
    }
}

static void __attribute__((constructor)) initialize(void) {

    class_addMethod(
        objc_getClass("MyDelegate"),
        sel_registerName("connection:didReceiveAuthenticationChallenge:"),
        didReceiveAuthenticationChallenge,
        "@:@@");

    class_addMethod(
        objc_getClass("MyDelegate"),
        sel_registerName("connection:canAuthenticateAgainstProtectionSpace:"),
        canAuthenticateAgainstProtectionSpace,
        "@:@@");
}
