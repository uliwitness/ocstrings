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


-(void) extractParamsFromFormatString: (NSString*)valString intoParams: (NSString**)outParamsStr paramNames: (NSString**)outParamNamesStr
{
	NSError * err = nil;
	NSMutableString * paramsStr = [NSMutableString string];
	NSMutableString * paramNamesStr = [NSMutableString string];
	static NSDictionary<NSString*,NSString*>* sTypesForFormats = nil;
	if (!sTypesForFormats) {
		sTypesForFormats = @{ @"d": @"int",
							  @"u": @"unsigned int",
							  @"x": @"unsigned int",
							  @"X": @"unsigned int",
							  @"o": @"unsigned int",
							  @"ld": @"long",
							  @"lu": @"unsigned long",
							  @"lx": @"unsigned long",
							  @"lX": @"unsigned long",
							  @"lo": @"unsigned long",
							  @"lld": @"long long",
							  @"llu": @"unsigned long long",
							  @"llx": @"unsigned long long",
							  @"llX": @"unsigned long long",
							  @"llo": @"unsigned long long",
							  @"f": @"double",
							  @"F": @"double",
							  @"e": @"double",
							  @"E": @"double",
							  @"g": @"double",
							  @"G": @"double",
							  @"a": @"double",
							  @"A": @"double",
							  @"c": @"char",
							  @"C": @"unichar",
							  @"p": @"void*",
							  @"s": @"char*",
							  @"n": @"int*"};
	}
	
	NSRegularExpression * regEx = [NSRegularExpression regularExpressionWithPattern: @"%(([0-9]+)[$])*([0-9]+)*(\\.([0-9]+))*([l]*[aAcCpnsxXdufFgGoieE@])" options: 0 error: &err];
	if( !regEx ) {
		NSLog(@"Couldn't parse format regex %@", err);
		return;
	}
	
	NSInteger x = 1;
	NSArray<NSTextCheckingResult*>* matches = [regEx matchesInString: valString options:0 range:(NSRange){0,valString.length}];
	for (NSTextCheckingResult * match in matches) {
		NSRange positionRange = [match rangeAtIndex: 2];
		NSString * positionStr = (positionRange.location != NSNotFound) ? [valString substringWithRange: positionRange] : nil;
		if (positionStr) x = positionStr.integerValue;
//		NSRange widthRange = [match rangeAtIndex: 3];
//		NSString * widthStr = (widthRange.location != NSNotFound) ? [valString substringWithRange: widthRange] : nil;
//		NSRange precisionRange = [match rangeAtIndex: 5];
//		NSString * precisionStr = (precisionRange.location != NSNotFound) ? [valString substringWithRange: precisionRange] : nil;
		NSRange lengthAndSpecifierRange = [match rangeAtIndex: 6];
		NSString * lengthAndSpecifierStr = (lengthAndSpecifierRange.location != NSNotFound) ? [valString substringWithRange: lengthAndSpecifierRange] : nil;
		
		NSString * typeForFormat = sTypesForFormats[lengthAndSpecifierStr];
		if (!typeForFormat) typeForFormat = @"id";
		
		[paramsStr appendFormat: @":(%@)arg%ld", typeForFormat, x];
		[paramNamesStr appendFormat: @", arg%ld", x];
		
		++x;
	}
	
	*outParamsStr = paramsStr;
	*outParamNamesStr = paramNamesStr;
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
		NSString * paramsStr = nil;
		NSString * paramNamesStr = nil;
		[self extractParamsFromFormatString: valString intoParams: &paramsStr paramNames: &paramNamesStr];
		NSString * keyAsIdentifier = [self unescapeStringAndMakeIdentifier: keyString];
		[stringsHeaderContents appendFormat: @"+ (NSString*)%1$@%2$@;", keyAsIdentifier, paramsStr];
		[stringsSourceContents appendFormat: @"+ (NSString*)%1$@%5$@\n{\n\treturn %6$sNSLocalizedStringFromTable(@\"%2$@\", @\"%3$@\", @\"%4$@\")%7$@%8$s;\n}\n\n", keyAsIdentifier, keyString, tableName, valString, paramsStr, (paramsStr.length > 0) ? "[NSString stringWithFormat: " : "", paramNamesStr, (paramsStr.length > 0) ? "]" : ""];
		
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