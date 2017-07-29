//
//  OCSTest.m
//  ocstrings
//
//  Created by Uli Kusterer on 29.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "OCSTest.h"
#import "ULIObjCTestfileStrings.h"


@implementation OCSTest

+(void) runObjCTest
{
	NSLog( @"ObjC Test:\n%@\n%@\n%@\n%@", [ULIObjCTestfileStrings faveNumber:42 :42.0009],
		  [ULIObjCTestfileStrings welcomeFormat: @"Sandy"],
			ULIObjCTestfileStrings.welcomeToStrings,
			ULIObjCTestfileStrings.welcomeLoggedOut);
}

@end
