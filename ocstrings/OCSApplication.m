//
//  OCSApplication.m
//  ocstrings
//
//  Created by Uli Kusterer on 27.07.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#import "OCSApplication.h"

@implementation OCSApplication

-(NSString*) unescapeStringAndMakeIdentifier: (NSString*)keyString
{
	keyString = [keyString stringByReplacingOccurrencesOfString: @" " withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"," withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"." withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @":" withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"\\\"" withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"\\r" withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"\\n" withString: @"_"];
	keyString = [keyString stringByReplacingOccurrencesOfString: @"\\\\" withString: @"_"];
	while ([keyString rangeOfString: @"__"].location != NSNotFound) {
		keyString = [keyString stringByReplacingOccurrencesOfString: @"__" withString: @"_"];
	}
	return keyString;
}

-(BOOL) openFile:(NSString *)filePath
{
	NSError * err = nil;
	NSString * stringsStr = [NSString stringWithContentsOfFile: filePath encoding:NSUTF8StringEncoding error: &err];
	if (!stringsStr) {
		NSLog(@"Couldn't open file \"%@\": %@", filePath, err);
		return NO;
	}
	
	NSString * tableName = filePath.lastPathComponent.stringByDeletingPathExtension;
	
	NSMutableString * stringsHeaderContents = [NSMutableString string];
	NSMutableString * stringsSourceContents = [NSMutableString string];
	
	[stringsHeaderContents appendFormat: @"@interface %1$@Strings : NSObject\n", tableName];
	[stringsSourceContents appendFormat: @"@implementation %1$@Strings\n", tableName];
	
	NSScanner * scanner = [NSScanner scannerWithString: stringsStr];
	scanner.charactersToBeSkipped = nil;
	NSCharacterSet * wsCS = [NSCharacterSet whitespaceCharacterSet];
	
	while (!scanner.atEnd) {
		NSString * inbetweenStr = nil;
		[scanner scanUpToString: @"\"" intoString: &inbetweenStr];
		if (inbetweenStr) {
			[stringsHeaderContents appendString: inbetweenStr];
		}
		[scanner scanString: @"\"" intoString: nil];
		
		// Parse key:
		NSMutableString * keyString = [NSMutableString string];
		BOOL keyIsDone = NO;
		while (!scanner.atEnd && !keyIsDone) {
			NSString * keyPart = nil;
			[scanner scanUpToString: @"\"" intoString: &keyPart];
			if (keyPart) {
				[keyString appendString: keyPart];
			}
			if (![keyPart hasSuffix: @"\\"]) {
				keyIsDone = YES;
				[scanner scanString: @"\"" intoString: nil];
			} else {
				[scanner scanString: @"\"" intoString: &keyPart];
				if (keyPart) {
					[keyString appendString: keyPart];
				}
			}
		}
		
		// Parse equals sign:
		[scanner scanCharactersFromSet: wsCS intoString: nil];
		[scanner scanString: @"=" intoString: nil];
		[scanner scanCharactersFromSet: wsCS intoString: nil];
		[scanner scanString: @"\"" intoString: nil];

		// Parse value:
		NSMutableString * valString = [NSMutableString string];
		BOOL valIsDone = NO;
		while (!scanner.atEnd && !valIsDone) {
			NSString * valPart = nil;
			[scanner scanUpToString: @"\"" intoString: &valPart];
			if (valPart) {
				[valString appendString: valPart];
			}
			if (![valPart hasSuffix: @"\\"]) {
				valIsDone = YES;
				[scanner scanString: @"\"" intoString: nil];
			} else {
				[scanner scanString: @"\"" intoString: &valPart];
				if (valPart) {
					[valString appendString: valPart];
				}
			}
		}

		[scanner scanCharactersFromSet: wsCS intoString: nil];
		[scanner scanString: @";" intoString: nil];
		[scanner scanCharactersFromSet: wsCS intoString: nil];

		// Generate code for this pair:
		NSString * keyAsIdentifier = [self unescapeStringAndMakeIdentifier: keyString];
		[stringsHeaderContents appendFormat: @"+ (NSString*)%1$@;", keyAsIdentifier];
		[stringsSourceContents appendFormat: @"+ (NSString*)%1$@ { return NSLocalizedStringFromTable(@\"%2$@\", @\"%3$@\", @\"%4$@\"); }", keyAsIdentifier, keyString, tableName, valString];
		
		[scanner scanUpToString: @"\"" intoString: &inbetweenStr];
		if (inbetweenStr) {
			[stringsHeaderContents appendString: inbetweenStr];
		}
	}

	[stringsHeaderContents appendString: @"\n@end\n"];
	[stringsSourceContents appendString: @"\n@end\n"];
	
	// Write out:
	NSString * headerPath = [[filePath stringByDeletingPathExtension] stringByAppendingString: @"Strings.h"];
	if (![stringsHeaderContents writeToFile: headerPath atomically: YES encoding: NSUTF8StringEncoding error: &err]) {
		NSLog(@"Couldn't write header: %@", err);
		return NO;
	}
	NSString * sourcePath = [[filePath stringByDeletingPathExtension] stringByAppendingString: @"Strings.m"];
	if (![stringsSourceContents writeToFile: sourcePath atomically: YES encoding: NSUTF8StringEncoding error: &err]) {
		NSLog(@"Couldn't write sources: %@", err);
		return NO;
	}
	return YES;
}

@end
