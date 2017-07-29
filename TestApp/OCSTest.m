//
//  OCSTest.m
//  ocstrings
//
//  Created by Uli Kusterer on 29.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "OCSTest.h"
#import "ObjCTestfileStrings.h"


@implementation OCSTest

+(void) runObjCTest
{
	NSLog( @"ObjC Test:\n%@\n%@\n%@\n%@", ObjCTestfileStrings.faveNumber( 123, 0.5 ),
			ObjCTestfileStrings.welcomeFormat(@"Grace"),
			ObjCTestfileStrings.welcomeToStrings,
			ObjCTestfileStrings.welcomeLoggedOut);
}

@end
