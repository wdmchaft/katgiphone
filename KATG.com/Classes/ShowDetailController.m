//
//  ShowDetailController.m
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

#import "ShowDetailController.h"
#import "MREntitiesConverter.h"
#import "grabRSSFeed.h"
#import "ImagePageViewController.h"

@implementation ShowDetailController

BOOL Stream = NO;
BOOL mpPlaying = NO;
int imageNumber = 0;

NSMutableArray *imageArray;

@synthesize button, activityIndicator, lblTitle, showTitle, showLink, feedAddress, moviePlayer;

@synthesize txtNotes, showNotes;

@synthesize segmentedControl, imageActivityIndicator, showNumber, scrollView, pageControl, viewControllers, blackBox;

- (void)viewDidLoad {
	showLink = @"";
	
	feedAddress = [NSString stringWithFormat: @"http://app.keithandthegirl.com/Api/Feed/Show/?ShowId=%@", showNumber];
	//feedAddress = @"http://getitdownonpaper.com/katg/test.xml";
	
	self.navigationItem.title = @"Show Details";
	
	self.setButtonImage;
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(moviePreloadDidFinish:) 
	 name:MPMoviePlayerContentPreloadDidFinishNotification 
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self 
	 selector:@selector(moviePlayBackDidFinish:) 
	 name:MPMoviePlayerPlaybackDidFinishNotification 
	 object:nil];
	
	imageArray = [[NSMutableArray alloc] initWithCapacity:10];
		
	[self pollFeed];
	[self updateView];
	[self createNotificationForTermination];
}

- (void)viewDidAppear:(BOOL)animated {
	imageDictionary = [[NSMutableDictionary alloc] init];
	
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * imageFilePath = [documentsPath stringByAppendingPathComponent: @"showimages.plist"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: imageFilePath]) {
		[imageDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile: imageFilePath]];
	}
	
	if (imageDictionary.count >= 1000) {
		[imageDictionary removeAllObjects];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * imageFilePath = [documentsPath stringByAppendingPathComponent: @"showimages.plist"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: imageFilePath]) {
		[fm removeItemAtPath: imageFilePath error:NULL];
	}
	
	[imageDictionary writeToFile:imageFilePath atomically:YES];
	[imageDictionary release];
}

- (void)setButtonImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[button setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
	
}

#pragma mark Feed
- (void)pollFeed {
	// Create the feed string
	NSString *xPath = @"//root";
	// Call the grabRSSFeed function with the above string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:feedAddress XPath:xPath];
	// Fill feedEntries with the results of parsing the show feed
	NSArray *feedEntries = [NSArray arrayWithArray:[feed entries]];
	[feed release];
		
	if (feedEntries.count != 0) {
		NSDictionary *feedEntry = [feedEntries objectAtIndex:0];
		showTitle = [feedEntry objectForKey: @"Title"];
		showLink = [[feedEntry objectForKey: @"FileUrl"] retain];
		showNotes = [feedEntry objectForKey: @"Detail"];
	} else {
		showTitle = @"Unable To Download Show";
		showLink = @"NULL";
		showNotes = @"NULL";
	}
	
	[self.activityIndicator stopAnimating];
}

- (void)updateView {
	CGRect rect = CGRectMake(5, 125, 315, 230);
	
	txtNotes = [[[UITextView alloc] initWithFrame:rect] autorelease];
	txtNotes.textColor = [UIColor blackColor];
	txtNotes.backgroundColor = [UIColor clearColor]; 
	
	txtNotes.dataDetectorTypes = UIDataDetectorTypeAll;
	
	txtNotes.editable = NO;
	txtNotes.font = [UIFont systemFontOfSize:15.0];
	
	[self.view addSubview:txtNotes];
	
	lblTitle.text = showTitle;
	
	if (![showNotes isEqualToString:@"NULL"]) {
		MREntitiesConverter *cleaner = [[MREntitiesConverter alloc] init];
		NSString *body = @" • ";
		body = [body stringByAppendingString:[showNotes stringByReplacingOccurrencesOfString:@"\n" withString:@"\n • "]];
		txtNotes.text = [cleaner convertEntitiesInString:body];
		[cleaner release];
	} else {
		txtNotes.text = @" • No Show Notes";
	}
	
	if ([showLink isEqualToString:@"NULL"]) {
		[button setHidden:YES];
		[button setEnabled:NO];
	}
}

//*******************************************************
//* buttonPressed
//* 
//* 
//*******************************************************
- (IBAction)buttonPressed:(id)sender {
	if (mpPlaying) {
		return;
	}
	[activityIndicator startAnimating];
	mpPlaying = YES;
	NSURL *theURL = [NSURL URLWithString:[self showLink]];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:theURL
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection 
			 willSendRequest:(NSURLRequest *)request 
			redirectResponse:(NSURLResponse *)redirectResponse {
	
	[urlDescription release];
	urlDescription = nil;
	
	urlDescription = [[request URL] description];
	[urlDescription retain];
	
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	if (Stream) {
		NSURL *url = [NSURL URLWithString:urlDescription];
		[self playMovie:url];
	} else {
		NSString *alertMessage = @"Streaming shows over cellular network is disabled, enable Wifi to stream";
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Past Shows Streaming Disabled"
							  message:alertMessage 
							  delegate:nil
							  cancelButtonTitle:@"Continue" 
							  otherButtonTitles:nil];
		[alert show];
		[alert autorelease];
		mpPlaying = NO;
	}
	
	[theConnection cancel];
	[theConnection release];
	theConnection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	
}

- (IBAction)segmentedController:(id)sender {
	if ([segmentedControl selectedSegmentIndex] == 0) {
		[txtNotes setHidden:NO];
		[blackBox setHidden:YES];
		[scrollView setHidden:YES];
		[pageControl setHidden:YES];
	} else if ([segmentedControl selectedSegmentIndex] == 1) {
		[imageActivityIndicator startAnimating];
		[NSThread detachNewThreadSelector:@selector(autoPool) toTarget:self withObject:nil];
		[txtNotes setHidden:YES];
		[blackBox setHidden:NO];
		[scrollView setHidden:NO];
		[pageControl setHidden:NO];
	}
}

#pragma mark imageFeed
- (void)autoPool {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self pollImageFeed];
	[pool release];
}

- (void)pollImageFeed {
	if (imageArray.count != 0) {
		[imageActivityIndicator stopAnimating];
		return;
	}
	// Create the feed string
	NSString *imageFeedAddress = [NSString stringWithFormat:@"http://app.keithandthegirl.com/Api/Feed/Pictures-By-Show/?ShowId=%@", showNumber];
	NSString *xPath = @"//picture";
	// Call the grabRSSFeed function with the above string as a parameter
	grabRSSFeed *feed = [[grabRSSFeed alloc] initWithFeed:imageFeedAddress XPath:xPath];
	// Fill feedEntries with the results of parsing the show feed
	NSArray *feedEntries = [NSArray arrayWithArray:[feed entries]];
	[feed release];
	
	for (NSDictionary *entry in feedEntries) {
		if ([imageDictionary objectForKey:[entry objectForKey:@"url"]] != nil) {
			[imageArray addObject:[imageDictionary objectForKey:[entry objectForKey:@"url"]]];
		} else {
		NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[entry objectForKey:@"url"]]];
		if (imageData == nil || [imageData length] == 0) {
			imageData = [NSData dataWithContentsOfFile:@"BG3.png"];
		}
		NSString *imageTitle = [entry objectForKey:@"title"];
		if (imageTitle == nil || [imageTitle length] == 0 || [imageTitle isEqualToString:@"NULL"]) {
			imageTitle = @"";
		}
		MREntitiesConverter *converter = [[MREntitiesConverter alloc] init];
		NSString *imageDesc = [converter convertEntitiesInString:[entry objectForKey:@"description"]];
		if (imageDesc == nil || [imageDesc length] == 0 || [imageDesc isEqualToString:@"NULL"]) {
			imageDesc = @"";
		}
		NSString *hiResURLString = [[entry objectForKey:@"url"] stringByReplacingOccurrencesOfString:@"-Thumb" withString:@"-Display"];
		if (hiResURLString == nil || [hiResURLString length] == 0 || [hiResURLString isEqualToString:@"NULL"]) {
			hiResURLString = @"";
		}
		NSDictionary *imDic = [NSDictionary dictionaryWithObjectsAndKeys:imageData, @"imagedata", 
																		imageTitle, @"title", 
																		 imageDesc, @"description", 
																	hiResURLString, @"hiresurl", nil];
		[converter release];
		[imageDictionary setObject:imDic forKey:[entry objectForKey:@"url"]];
		[imageArray addObject:imDic];
		}
	}
	[imageActivityIndicator stopAnimating];
	if (imageArray.count > 0) {
		NSMutableArray *controllers = [[NSMutableArray alloc] init];
		for (unsigned i = 0; i < imageArray.count; i++) {
			[controllers addObject:[NSNull null]];
		}
		self.viewControllers = controllers;
		[controllers release];
		
		scrollView.pagingEnabled = YES;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * imageArray.count, scrollView.frame.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
		scrollView.showsVerticalScrollIndicator = NO;
		scrollView.scrollsToTop = NO;
		scrollView.delegate = self;
		
		pageControl.numberOfPages = imageArray.count;
		pageControl.currentPage = 0;
		
		[self loadScrollViewWithPage:0];
		[self loadScrollViewWithPage:1];
	}
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= imageArray.count) return;
	
    
	ImagePageViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[ImagePageViewController alloc] init];
		[controller loadView];
		// Calculate the image size and the x offset that will center it
		UIImage *imageLo = [UIImage imageWithData:[[imageArray objectAtIndex:page] objectForKey:@"imagedata"]];
		CGSize size = imageLo.size;
		CGFloat x = 270 - size.width;
		x = x / 2;
		CGRect rect = CGRectMake(x, 40, size.width, size.height);
		controller.imageView.frame = rect;
		[controller.imageView setImage:imageLo];
	    controller.lblTitle.text = [[imageArray objectAtIndex:page] objectForKey:@"title"];
		controller.lblDescription = [[imageArray objectAtIndex:page] objectForKey:@"description"];
	
		controller.hiResURL = [NSURL URLWithString:[[imageArray objectAtIndex:page] objectForKey:@"hiresurl"]];
		[viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
}

- (void)removeViewsBeforePage:(int)page {
	if (page < 1) return;
    if (page >= imageArray.count) return;
	for (int i = 0; i < page; i++) {
		[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}

- (void)removeViewsAfterPage:(int)page {
	if (page < 1) return;
    if (page > imageArray.count) return;
	for (int i = page; i < imageArray.count; i++) {
		[viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
	[self removeViewsBeforePage:page - 1];
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
	[self removeViewsAfterPage:page + 2];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {
    int page = pageControl.currentPage;
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

- (BOOL)Stream {
	return Stream;
}

- (void)setStream:(BOOL)stream {
	Stream = stream;
}

//*******************************************************
//* playMovie
//* 
//* 
//*******************************************************
-(void)playMovie:(NSURL *)movieURL {
	// Initialize a movie player object with the specified URL
	MPMoviePlayerController *mp = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
	if (mp) {
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
	}
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	//NSLog(@"Movie Preload Notification");
	
	[activityIndicator stopAnimating];
	
	[self.moviePlayer play];
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
	mpPlaying = NO;
}

- (void)createNotificationForTermination { 
	//NSLog(@"createNotificationTwo"); 
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self 
	 selector:@selector(handleTerminationNotification:) 
	 name:@"ApplicationWillTerminate" 
	 object:nil]; 
}

-(void)handleTerminationNotification:(NSNotification *)pNotification {
	NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString * imageFilePath = [documentsPath stringByAppendingPathComponent: @"showimages.plist"];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath: imageFilePath]) {
		[fm removeItemAtPath: imageFilePath error:NULL];
	}
	
	[imageDictionary writeToFile:imageFilePath atomically:YES];
	[imageDictionary release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[self.moviePlayer stop];
	[scrollView removeFromSuperview];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self];
	[urlDescription release];
	[theConnection release];
	[viewControllers release];
    [scrollView release];
    [pageControl release];
	[blackBox release];
	[showLink release];
	[imageArray release];
	[super dealloc];
}

@end