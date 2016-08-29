#import <Foundation/Foundation.h>
#include <stdio.h>

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
    MyDelegate *myDelegate = [ [ MyDelegate alloc ] init ];

    NSURLRequest *request = [ [ NSURLRequest alloc ] 
        initWithURL: [ NSURL URLWithString: @"https://www.paypal.com" ]
    ];

    NSURLConnection *connection = [ [ NSURLConnection alloc ] 
        initWithRequest: request delegate: myDelegate ];

    if (!connection) {
       NSLog(@"%s connection failed");
    } 

    CFRunLoopRun();
    return 0;
}

