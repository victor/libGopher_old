//
//  HFAGopherProtocol.m
//  gopher
//
//  Created by Victor Jalencas on 27/04/13.
//  Copyright (c) 2013 Hand Forged Apps. All rights reserved.
//

#import "HFAGopherProtocol.h"
#import "NSStream+StreamToHost.h"

@interface HFAGopherProtocol ()
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSMutableData *dataToSend;
@property (nonatomic, weak) id delegate;
@end

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

    NSString *hostname = request.URL.host;
    NSNumber *port = request.URL.port;
    if (!port)
        port = @(70);


    NSData *responseData;

    if ([hostname isEqualToString:@"test"])
    {
        responseData = [@"Registration successful!" dataUsingEncoding:NSUTF8StringEncoding];
        [self respondRequest:request withData:responseData];
        return;
    }
    // process URL normally

    NSString *selector = [NSString stringWithFormat:@"%@\r\n", [request.URL.path substringFromIndex:1]];

    self.dataToSend = [[selector dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    NSInputStream *readStream;
    NSOutputStream *writeStream;
    [NSStream getStreamsToHostNamed:hostname
                               port:[port integerValue]
                        inputStream:&readStream
                       outputStream:&writeStream];

    

    [readStream setDelegate:self];
    [writeStream setDelegate:self];

    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                          forMode:NSDefaultRunLoopMode];


    [readStream open];
    [writeStream open];
    [[NSRunLoop currentRunLoop] run];
}

- (void)respondRequest:(NSURLRequest *)request withData:(NSData *)responseData
{
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

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
        
            (void) self.receivedData;
            if (!self.receivedData) {
                self.receivedData = [[NSMutableData alloc] init];
            }
            uint8_t buf[1024];
            int numBytesRead = [(NSInputStream *)stream read:buf maxLength:1024];
            if (numBytesRead > 0) {
                [self.receivedData appendBytes:(const void *)buf length:numBytesRead];
                NSLog(@"%d bytes read", numBytesRead);
            } else if (numBytesRead == 0) {
                NSLog(@"End of stream reached");
            } else {
                NSLog(@"Read error occurred");
            }
            break;

        case NSStreamEventErrorOccurred: {
            NSError *error = [stream streamError];
            NSLog(@"Failed while reading stream; error '%@' (code %d)",
                  error.localizedDescription, error.code);
            if ([self.delegate respondsToSelector: @selector(networkingResultsDidFail:)]) {
                //                [self.delegate networkingResultsDidFail:
                //               @"An unexpected error occurred while reading from the warehouse server."];
            }
            [self cleanupStream:stream];
        }
            break;
        case NSStreamEventEndEncountered: {
            if ([stream isKindOfClass:[NSInputStream class]]) {
                [self respondRequest:self.request withData:self.receivedData];
                self.receivedData = nil;
            }
            [self cleanupStream:stream];
        }
            break;

        case NSStreamEventNone: {
            NSLog(@"Nothing to see here. Move along.");
        }
            break;
        case NSStreamEventHasSpaceAvailable: {
            if ([stream isKindOfClass:[NSOutputStream class]]) {
                if (self.dataToSend) {
                    NSInteger bytesWritten = [(NSOutputStream *)stream write:[self.dataToSend bytes] maxLength:[self.dataToSend length]];
                    NSLog(@"%d bytes written out of %d", bytesWritten, [self.dataToSend length]);
                    self.dataToSend = nil;
                }
            }
            break;
        }
        default:
            break;

    
    }
}

- (void)cleanupStream:(NSStream *)stream
{
    [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
    [stream close];
    stream = nil;
}
@end
