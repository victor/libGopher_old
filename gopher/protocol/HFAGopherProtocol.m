//
//  HFAGopherProtocol.m
//  gopher
//
//  Created by Victor Jalencas on 27/04/13.
//  Copyright (c) 2013 Hand Forged Apps. All rights reserved.
//

#import "HFAGopherProtocol.h"

@implementation HFAGopherProtocol

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id < NSURLProtocolClient >)client
{
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {

    }
    return self;
}

- (void)startLoading
{
    NSURLRequest *request = self.request;
    
    NSString *host = request.URL.host;
    NSData *responseData;

    if ([host isEqualToString:@"test"])
    {
        responseData = [@"Registration successful!" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        // process URL normally
    }

    // create response
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL
                                                        MIMEType:@"text/plain"
                                           expectedContentLength:-1
                                                textEncodingName:@"UTF-8"];

    id<NSURLProtocolClient> client = self.client;

    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];

    [client URLProtocol:self didLoadData:responseData];

    [client URLProtocolDidFinishLoading:self];


    NSLog(@"%@ received %@ - end", self, NSStringFromSelector(_cmd));

}

- (void)stopLoading
{
	NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));
}

# pragma mark - class methods
+ (void) registerGopherProtocol
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[HFAGopherProtocol class]];
    });
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    return ([request.URL.scheme isEqualToString:@"gopher"]);
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {

	NSLog(@"%@ received %@", self, NSStringFromSelector(_cmd));

	/* we don't do any special processing here, though we include this
     method because all subclasses must implement this method. */

    return request;
}
@end
