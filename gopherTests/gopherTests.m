//
//  gopherTests.m
//  gopherTests
//
//  Created by Victor Jalencas on 27/04/13.
//  Copyright (c) 2013 Hand Forged Apps. All rights reserved.
//


#import <SenTestingKit/SenTestingKit.h>

@interface gopherTests : SenTestCase

@end


@implementation gopherTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSchemeRegistration
{
//    NSURL *gopherURL = [NSURL URLWithString:@"gopher://gopher.floodgap.com:70/"];
    NSURL *gopherURL = [NSURL URLWithString:@"gopher://test"];

    NSData *result = [NSData dataWithContentsOfURL:gopherURL];

    STAssertEqualObjects(@"Registration successful!", [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding], @"Not successfully registered");
}
@end
