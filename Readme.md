# OCSTRINGS

A stupid little preprocessor that generates compiler-checkable identifiers
for all strings in a .strings file.

## Why?

When you write

	myField.stringValue = NSLocalizedStringFromTable( @"fooBar", @"FoobarFile", @"" )

it is easy to mistype the key and the compiler can't tell you. ocstrings wraps
these calls in an ObjC class so you can instead retrieve them like

	myField.stringValue = FoobarFileStrings.fooBar

which the compiler can check and error on if you mis-type. Also, if your
strings file contains a format string like

	"fooBar2" = "Hello %@, are you still %d years old?";

it will generate a method that returns a block taking the appropriate parameters
and fills out the format, so you can call it like

	myField.stringValue = FoobarFileStrings.fooBar2(@"Georgia", 56)

The reason this is a block is that this lets us simulate Swift-style parameter syntax
and I find that more readable than unnamed ObjC parameters.

## Syntax

	ocstrings [--language {swift|objective-c}] <stringsFilePath>

If the language option is not specified, it defaults to generating Swift code.

## License

	Copyright 2017 by Uli Kusterer.
	
	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.
	
	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:
	
	1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.
	
	2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.
	
	3. This notice may not be removed or altered from any source
	distribution.
