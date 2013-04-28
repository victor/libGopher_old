//
//  HFAGopherProtocol.h
//  gopher
//
//  Created by Victor Jalencas on 27/04/13.
//  Copyright (c) 2013 Hand Forged Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HFAGopherProtocol : NSURLProtocol<NSStreamDelegate>

+ (void) registerGopherProtocol;

@end
