//
//  grabRSSFeed.m
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
#import "grabRSSFeed.h"
#import "TouchXML.h"

@implementation grabRSSFeed


// Creates the object with primary key and title is brought into memory.
- (id)initWithFeed:(NSString *)feedAddress XPath:(NSString *)xPath {
	
	// Initialize the feedEntries MutableArray that we declared in the header
    feedEntries = [[NSMutableArray alloc] init];
	
    // Convert the supplied URL string into a usable URL object
    NSURL *url = [NSURL URLWithString: feedAddress];
	
	// Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
	// object that actually grabs and processes the RSS data
	
	CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
	
	// Create a new Array object to be used with the looping of the results from the rssParser
	NSArray *resultNodes = NULL;
	
	// Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed	
	resultNodes = [rssParser nodesForXPath:xPath error:nil];
	
	// Loop through the resultNodes to access each items actual data
	for (CXMLElement *resultElement in resultNodes) {
		
		// Create a temporary MutableDictionary to store the items fields in, which will eventually end up in feedEntries
		NSMutableDictionary *feedItem = [[NSMutableDictionary alloc] init];
		
		// Create a counter variable as type "int"
		int counter;
		
		// Loop through the children of the current  node
		for(counter = 0; counter < [resultElement childCount]; counter++) {
			
			NSString *strVal = [[resultElement childAtIndex:counter] stringValue];
			
			if (strVal == nil) {
				strVal = @"NULL";
			}
			
			// Add each field to the feedItem Dictionary with the node name as key and node value as the value
			[feedItem setObject:strVal forKey:[[resultElement childAtIndex:counter] name]];
		}
	
		// Add the feedItem to the global feedEntries Array so that the view can access it.
		[feedEntries addObject:feedItem];
		
		[feedItem release];
	}
	
	return self;
}

- (id)entries {
	return feedEntries;
}

- (void)dealloc {
	[feedEntries release];
	[super dealloc];
}

@end