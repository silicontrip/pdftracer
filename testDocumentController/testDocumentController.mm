//
//  testDocumentController.m
//  testDocumentController
//
//  Created by Mark Heath on 10/2/21.
//  Copyright © 2021 silicontrip. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "QPDFDocumentController.h"

@interface testDocumentController : XCTestCase
{
	QPDFDocumentController * doc;
}
@end

@implementation testDocumentController

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.

//	 doc = [QPDFDocumentController sharedDocumentController];
	
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	//[doc release];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
	
}

- (void)testSharedInstance {
	QPDFDocumentController * dd = [QPDFDocumentController sharedDocumentController];
	XCTAssertNotNil(dd,@"get shared instance");
}

- (void)testClasses {
	QPDFDocumentController * dd = [QPDFDocumentController sharedDocumentController];
	

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
