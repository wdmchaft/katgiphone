//
//  TweetViewController.m
//  KATG.com
//  

#import "TweetViewController.h"
#import <JSON/JSON.h>
#import "TweetCell.h"
#import "WebViewController.h"
#import "grabRSSFeed.h"
#import "MREntitiesConverter.h"

static BOOL otherTweets;


@implementation TweetViewController

@synthesize navigationController;
@synthesize activityIndicator;

//*******************************************************
//* viewDidLoad:
//*
//* Set row height, you could add buttons to the
//* navigation controller here.
//*
//*******************************************************
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"The Twitters";
		
	tweets = [[NSMutableArray alloc] initWithCapacity: 100];
	iconDict = [[NSMutableDictionary alloc] init];
	isURL = [[NSMutableDictionary alloc] init];
	urlDict = [[NSMutableDictionary alloc] init];
	
	// Create a 'right hand button' that is a activity Indicator
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self.activityIndicator = [[UIActivityIndicatorView alloc]
							  initWithFrame:frame];
	[self.activityIndicator sizeToFit];
	self.activityIndicator.autoresizingMask =
	(UIViewAutoresizingFlexibleLeftMargin |
	 UIViewAutoresizingFlexibleRightMargin |
	 UIViewAutoresizingFlexibleTopMargin |
	 UIViewAutoresizingFlexibleBottomMargin);
	
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
									initWithCustomView:self.activityIndicator];
	loadingView.target = self;
	self.navigationItem.rightBarButtonItem = loadingView;
	
	otherTweets = NO;
	
	[self.activityIndicator startAnimating];
	[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
	
	/*refButton = [[[UIBarButtonItem alloc]
				  initWithTitle:NSLocalizedString(@"Update", @"On")
				  style:UIBarButtonItemStyleBordered
				  target:self
				  action:@selector(refTweets:)] autorelease];
    self.navigationItem.leftBarButtonItem = refButton;*/
	
	othButton = [[[UIBarButtonItem alloc]
				  initWithTitle:NSLocalizedString(@"Other Tweets", @"On")
				  style:UIBarButtonItemStyleBordered
				  target:self
				  action:@selector(othTweets:)] autorelease];
    self.navigationItem.leftBarButtonItem = othButton;
}

- (void)refTweets:(id)sender{
	otherTweets = YES;
	[self pollFeed];
}

- (void)othTweets:(id)sender{
	if ( otherTweets ) {
		otherTweets = NO;
	} else {
		otherTweets = YES;
	}
	[self.activityIndicator startAnimating];
	[self pollFeed];
	//[ NSThread detachNewThreadSelector: @selector(autoPool) toTarget: self withObject: nil ];
}

- (void)autoPool {
    NSAutoreleasePool *pool = [ [ NSAutoreleasePool alloc ] init ];
    [self pollFeed];
	[ pool release ];
}

//*******************************************************
//* pollFeed
//*
//* Get Tweets
//*******************************************************
- (void) pollFeed {
	NSString *searchString = @"http://search.twitter.com/search.json?q=from%3Akeithandthegirl+OR+from%3AKeithMalley";
	
	if ( otherTweets ) // Changed Code this line
		searchString = [searchString stringByAppendingString: @"+OR+keithandthegirl+OR+katg+OR+%22keith+and+the+girl%22"];
	
	searchString = [searchString stringByAppendingFormat: @"&rpp=%i", 20]; // Changed Code this line
	
	NSURL *url = [NSURL URLWithString:searchString];
	NSString *queryResult = [[NSString alloc] initWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];	
	
	SBJSON *jsonParser = [[SBJSON alloc] init];
	NSError *error;
	NSDictionary *queryDict = [jsonParser objectWithString: queryResult error: &error];
	NSArray *results = [queryDict objectForKey: @"results"];
	//*******************************************************
	//* Clear out the old tweets and icons
	//*******************************************************
	[tweets removeAllObjects];
	
	if (iconDict.count >= 1000)
		[iconDict removeAllObjects];
	
	//*******************************************************
	//* Set up the date formatter - has to use 10.4 format for iPhone
	//*******************************************************
	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle: NSDateFormatterLongStyle];
	[formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
	[formatter setDateFormat: @"EEE, dd MMM yyyy HH:mm:ss +0000"];
	
	//*******************************************************
	//* Process the results 1 tweet at a time
	//*******************************************************
	NSDictionary * tweet;
	
	for (tweet in results) {
		NSString * from = [tweet objectForKey: @"from_user"];
		NSString * text = [tweet objectForKey: @"text"];
		NSDate * createdAt = [formatter dateFromString: [tweet objectForKey: @"created_at"]];
		
		//*******************************************************
		//* Calculate the time & units since creation
		//*******************************************************
		NSString * interval = @"s";
		int timeSince = -[createdAt timeIntervalSinceNow];
		
		//*******************************************************
		//* Convert from GMT to local time
		//*******************************************************
		NSInteger seconds = [[NSTimeZone defaultTimeZone] secondsFromGMT];
		timeSince -= seconds;
		
		if (timeSince > 60) {
			interval = @"m";
			timeSince /= 60;
			
			if (timeSince > 60) {
				interval = @"h";
				timeSince /= 60;
				
				if (timeSince > 24) {
					interval = @"d";
					timeSince /= 24;
					
					if (timeSince > 7) {
						interval = @"w";
						timeSince /= 7;
					}
				}
			}
		}
		
		NSString * since = [NSString stringWithFormat:@"%i%@", timeSince, interval];
		
		//*******************************************************
		//* Check to see if this image URL has been seen (and stored)
		//* already. If not, send an asychronous request for the 
		//* image, and store the necessary info in a CFDictionary with connection
		//* as the key, so we can find it again when the data is received.
		//*******************************************************
		NSString * imageURLString = [tweet objectForKey: @"profile_image_url"];
		
		//*******************************************************
		//* Put everything in a dictionary and add to tweet array
		//*******************************************************
		NSDictionary * tweetDict = [NSDictionary dictionaryWithObjectsAndKeys: from, @"from_user", 
									text, @"text", 
									since, @"since",
									imageURLString, @"profile_image_url", nil];
		
		
		[tweets addObject: tweetDict];
		
	}
	
	[jsonParser release];
	[formatter release];
	[queryResult release];
	
	[self.activityIndicator stopAnimating];
	
	[self.tableView reloadData];
}

#pragma mark Table view methodss
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//*******************************************************
//* tableView:numberOfRowsInSection
//*
//*  Customize the number of rows in the table view
//*
//*******************************************************
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tweets.count;
}

//*******************************************************
//* tableView:cellForRowAtIndexPath
//*
//* Customize the appearance of table view cells.
//* Assign icons to event types
//*
//*******************************************************
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TweetCell";
	
	MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
	
	TweetCell *cell = (TweetCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TweetCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.lblTitle.text = [converter convertEntitiesInString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"text"]];
	cell.lblSince.text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"since"];
	cell.lblFrom.text =  [[tweets objectAtIndex: indexPath.row] objectForKey: @"from_user"];
	
	cell.backgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	UIColor *color1 = [UIColor colorWithRed:(CGFloat)0.92 green:(CGFloat).973 blue:(CGFloat)0.92 alpha:(CGFloat)1.0];
	UIColor *color2 = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0];
	if (indexPath.row%2 == 0) {
		cell.lblTitle.backgroundColor = color1;
		cell.lblSince.backgroundColor = color1;
		cell.lblFrom.backgroundColor = color1;
		cell.backgroundView.backgroundColor = color1;
	} else {
		cell.lblTitle.backgroundColor = color2;
		cell.lblSince.backgroundColor = color2;
		cell.lblFrom.backgroundColor = color2;
		cell.backgroundView.backgroundColor = color2;
	}
	
	cell.selectedBackgroundView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0.72 green:(CGFloat).773 blue:(CGFloat)0.72 alpha:(CGFloat)1.0];
	
	if ([iconDict objectForKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]] == nil) {
		
		NSURL *url = [[NSURL alloc] initWithString:[[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
		NSData *data = [NSData dataWithContentsOfURL:url];
		UIImage * tweetIcon = [UIImage imageWithData:data];
		
		[iconDict setObject: tweetIcon forKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
	}
	
	cell.imgSquare.image = [iconDict objectForKey: [[tweets objectAtIndex: indexPath.row] objectForKey: @"profile_image_url"]];
	
	//***************************************************
	//* Add a disclosure indicator if the text contains web stuff
	//***************************************************
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row]; // Added Code This Line
	if ([cell.lblTitle.text rangeOfString: @"www" options:1].location != NSNotFound ||
		[cell.lblTitle.text rangeOfString: @"http:" options:1].location != NSNotFound ||
		[cell.lblTitle.text rangeOfString: @".com" options:1].location != NSNotFound) {
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		[isURL setObject:@"YES" forKey: index];
		[urlDict setObject:cell.lblTitle.text forKey: index];
	}
	
	return cell;
}

//*************************************************
//* tableView:heightForRowAtIndexPath:
//*
//* Get the size of the bounding rectangle for the 
//* tweet text, and add 20 to that height for the 
//* cell height. Minimum height is 46.
//*************************************************
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString * text = [[tweets objectAtIndex: indexPath.row] objectForKey: @"text"];
	CGSize maxTextSize = CGSizeMake(120.0, 200.0);
	CGSize textSize = [text sizeWithFont: [UIFont systemFontOfSize: 12] constrainedToSize: maxTextSize];
	CGFloat height = MAX((textSize.height + 20.0f), 80.0f);
	return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *index = [NSString stringWithFormat:@"%d", indexPath.row];
	NSString *temp1 = [isURL objectForKey: index];
	NSString *temp2 = [urlDict objectForKey: index];
	if ( [[isURL objectForKey: index] isEqualToString:@"YES"] ) {
		WebViewController *viewController = [[WebViewController alloc] initWithNibName:@"WebView" bundle:[NSBundle mainBundle]];
		
		NSString *tweetURL = [urlDict objectForKey: [NSString stringWithFormat:@"%d", indexPath.row]];
		
		NSString *urlAddress = nil;
		
		if ([tweetURL rangeOfString: @"http:" options:1].location != NSNotFound) {
			int tweetLength = tweetURL.length;
			int urlStart = [tweetURL rangeOfString: @"http:" options:1].location;
			NSRange tweetRange = {urlStart, tweetLength-urlStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength ) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
		} else if ( [tweetURL rangeOfString: @"www." options:1].location != NSNotFound ) {
			int tweetLength = tweetURL.length;
			int urlStart = [tweetURL rangeOfString: @"www." options:1].location;
			NSRange tweetRange = {urlStart, tweetLength-urlStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:tweetRange];
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength ) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = @"http://";
			NSString *urlStub = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
			urlAddress = [urlAddress stringByAppendingString:urlStub];
		} else if ( [tweetURL rangeOfString: @".com" options:1].location != NSNotFound ) {
			int tweetLength = tweetURL.length;
			int comStart = [tweetURL rangeOfString: @".com" options:1].location;
			NSRange startRange = {0, comStart};
			NSRange endRange = {comStart, tweetLength - comStart};
			NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
			NSRange urlStartRange = [tweetURL rangeOfCharacterFromSet:charSet options:5 range:startRange];
			NSRange urlEndRange = [tweetURL rangeOfCharacterFromSet:charSet options:1 range:endRange];
			int urlStart = urlStartRange.location + 1;
			if (urlStart < 0) {
				urlStart = 0;
			}
			int urlEnd = urlEndRange.location;
			if (urlEnd > tweetLength) {
				urlEnd = tweetLength;
			}
			int urlLength = urlEnd - urlStart;
			urlAddress = @"http://";
			NSString *urlStub = [tweetURL substringWithRange:NSMakeRange( urlStart, urlLength ) ];
			urlAddress = [urlAddress stringByAppendingString:urlStub];
		}
		
		viewController.urlAddress = urlAddress;
		[[self navigationController] pushViewController:viewController animated:YES];
		[viewController release];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

- (void)dealloc {
	[iconDict release];
	[tweets release];
	[isURL release];
	[urlDict release];
    [super dealloc];
}

@end

