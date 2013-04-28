//
//  NSStream+StreamToHost.h
//  gopher
//
//  Created by Victor Jalencas on 28/04/13.
//  Copyright (c) 2013 Hand Forged Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (StreamToHost)
+ (void)getStreamsToHostNamed:(NSString *)hostName
                                           port:(NSInteger)port
                                    inputStream:(out NSInputStream **)inputStreamPtr
                                   outputStream:(out NSOutputStream **)outputStreamPtr;

@end
