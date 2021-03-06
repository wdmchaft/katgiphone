//
//  extractURL.m
//  KATG.com
//
//  Copyright 2008 Doug Russell
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "extractURL.h"
#import "RegexKitLite.h"


@implementation extractURL

//*******************************************************
//* init
//* 
//* Set up object
//*******************************************************
- (id)init {
	self = [super init];
	return self;
}

//*******************************************************
//* newURLList:(NSString *)stringWithURLs
//* 
//* Create an array of URL strings
//*******************************************************
- (id)newURLList:(NSString *)stringWithURLs {
	NSMutableArray *urlList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *urlDict;
	
	urlDict = [self makeURL:stringWithURLs];
	if (urlDict != nil) {
		NSString *protocolString = [urlDict objectForKey:@"protocol"];
		NSString *hostString = [urlDict objectForKey:@"host"];
		NSString *pathString = [urlDict objectForKey:@"path"];
		NSString *url = [protocolString stringByAppendingString:hostString]; 
		if (pathString != nil) {
			url = [url stringByAppendingString:pathString];
		}
		
		[urlList addObject:url];
	}
	
	int offset = 0;
	while (urlDict != nil) {
		offset += [[urlDict objectForKey:@"location"] intValue] + [[urlDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithURLs.length - offset;
		urlDict = [self makeURL:[stringWithURLs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (urlDict != nil) {
			NSString *protocolString = [urlDict objectForKey:@"protocol"];
			NSString *hostString = [urlDict objectForKey:@"host"];
			NSString *pathString = [urlDict objectForKey:@"path"];
			NSString *url = [protocolString stringByAppendingString:hostString]; 
			if (pathString != nil) {
				url = [url stringByAppendingString:pathString];
			}
			
			[urlList addObject:url];
		}
	}
	
	return urlList;
}

//*******************************************************
//* makeURL:(NSString *)searchString
//* 
//* Create an array of tweet user dictionaries
//*******************************************************
- (id)makeURL:(NSString *)searchString {
	NSString *regexString = @"\\b(https?://)(?:(\\S+?)(?::(\\S+?))?@)?([a-zA-Z0-9\\-.]+)(?::(\\d+))?((?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	//NSRange matchedRange = NSMakeRange(NSNotFound, 0UL); 
	NSRange matchedRange;
	
	if ([searchString isMatchedByRegex:regexString]) {
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *protocolString = [searchString stringByMatching:regexString capture:1L];
		//NSString *userString = [searchString stringByMatching:regexString capture:2L];
		//NSString *passwordString = [searchString stringByMatching:regexString capture:3L];
		NSString *hostString = [searchString stringByMatching:regexString capture:4L];
		//NSString *portString = [searchString stringByMatching:regexString capture:5L];
		NSString *pathString = [searchString stringByMatching:regexString capture:6L];
		
		regexString = @"\\.$|\\?$|\\!$";
		//matchedRange = NSMakeRange(NSNotFound, 0UL);
		matchedRange = [pathString rangeOfRegex:regexString];
		if (matchedRange.location != NSNotFound) {
			pathString = [pathString substringWithRange:NSMakeRange(0, pathString.length - 1)];
		}
		
		if (location)       {[urlDictionary setObject:location forKey:@"location"];}
		if (length)         {[urlDictionary setObject:length forKey:@"length"];}
		if (protocolString) {[urlDictionary setObject:protocolString forKey:@"protocol"];} 
		//if (userString)     {[urlDictionary setObject:userString forKey:@"user"];} 
		//if (passwordString) {[urlDictionary setObject:passwordString forKey:@"password"];}
		if (hostString)     {[urlDictionary setObject:hostString forKey:@"host"];}
		//if (portString)     {[urlDictionary setObject:portString forKey:@"port"];}
		if (pathString)     {[urlDictionary setObject:pathString forKey:@"path"];}
		//NSLog(@"urlDictionary: %@", urlDictionary);
		
		[location release];
		[length release];
		
		return urlDictionary;
	} else {
		return nil;
	}
}

//*******************************************************
//* newTWTList:(NSString *)stringWithTWTs
//* 
//* Extract, using regular expressions,
//* the first URL that occurs in a string
//* Results are compiled in an array
//*******************************************************

- (id)newTWTList:(NSString *)stringWithTWTs {
	NSMutableArray *twtList = [[NSMutableArray alloc] initWithCapacity:12];
	NSMutableDictionary *twtDict;
	
	twtDict = [self makeTwitterSearchURL:stringWithTWTs];
	if (twtDict != nil) {
		[twtList addObject:[twtDict objectForKey:@"user"]];
	}
	
	int offset = 0;
	while (twtDict != nil) {
		offset += [[twtDict objectForKey:@"location"] intValue] + [[twtDict objectForKey:@"length"] intValue] - 1;
		int length = stringWithTWTs.length - offset;
		twtDict = [self makeTwitterSearchURL:[stringWithTWTs substringWithRange:NSMakeRange( offset, length ) ]];		
		if (twtDict != nil) {
			[twtList addObject:[twtDict objectForKey:@"user"]];
		}
	}
	
	return twtList;
}

//*******************************************************
//* makeTwitterSearchURL:(NSString *)searchString
//* 
//* Extract, using regular expressions,
//* the first twitter user name that
//* occurs in a string
//* Results are compiled in a dictionary as
//* the the user name and the json library
//* URL
//*******************************************************
- (id)makeTwitterSearchURL:(NSString *)searchString {
	NSString *regexString = @"@([0-9a-zA-Z_]+)";
	NSMutableDictionary *urlDictionary = [NSMutableDictionary dictionary];
	//NSRange matchedRange = NSMakeRange(NSNotFound, 0UL); 
	NSRange matchedRange;
	
	if ([searchString isMatchedByRegex:regexString]) {
		matchedRange = [searchString rangeOfRegex:regexString];
		int Location = matchedRange.location;
		int Length = matchedRange.length;
		NSNumber *location = [[NSNumber alloc] initWithInt:Location];
		NSNumber *length = [[NSNumber alloc] initWithInt:Length];
		NSString *twtUser = [searchString stringByMatching:regexString capture:1L];
		
		if (location)         {[urlDictionary setObject:location forKey:@"location"];}
		if (length)           {[urlDictionary setObject:length forKey:@"length"];}
		if (twtUser)          {[urlDictionary setObject:twtUser forKey:@"user"];} 
		
		[location release];
		[length release];
		
		return urlDictionary;
	} else {
		return nil;
	}
}

- (void)dealloc {
    [super dealloc];
}

@end
