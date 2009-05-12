//
//  ShowDetailController.m
//  KATG.com
//
//  Created by Doug Russell on 5/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShowDetailController.h"
#import "MREntitiesConverter.h"


@implementation ShowDetailController

@synthesize detailTitle; // Label to display event title
@synthesize detailLink;  // Label to display event date
@synthesize detailBody;  // Label to display event description
@synthesize TitleTemp;   // Variable to store title passed from SecondViewController
@synthesize LinkTemp;    // Variable to store time passed from SecondViewController
@synthesize BodyTemp;    // Variable to store description passed from SecondViewController
@synthesize button;
@synthesize moviePlayer;
@synthesize activityIndicator;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.navigationItem.title = @"Show Details";
	
	self.setButtonImage;
	
	CGRect rect = CGRectMake(20, 140, 280, 190);
	
	detailBody = [[[UITextView alloc] initWithFrame:rect] autorelease];
	detailBody.textColor = [UIColor blackColor];
	detailBody.backgroundColor = [UIColor colorWithRed:(CGFloat)0.627 green:(CGFloat).745 blue:(CGFloat)0.667 alpha:(CGFloat)1.0]; 
	detailBody.dataDetectorTypes = UIDataDetectorTypeAll; // Only works in 3.0
	detailBody.editable = NO;
	detailBody.font = [UIFont systemFontOfSize:15.0];
	
	[self.view addSubview:detailBody];
	
	detailTitle.text = TitleTemp;
	MREntitiesConverter *cleaner = [[MREntitiesConverter alloc] init];
	detailBody.text = [cleaner convertEntitiesInString:BodyTemp];

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
}

//*******************************************************
//* buttonPressed
//* 
//* 
//*******************************************************
- (IBAction)buttonPressed:(id)sender {
	NSURL *movieURL = [[NSURL alloc] initWithString: LinkTemp];
	[self playMovie:movieURL];
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
		
		[activityIndicator startAnimating];
	}
}

//  Notification called when the movie finished preloading.
- (void) moviePreloadDidFinish:(NSNotification*)notification
{
	
	NSLog(@"Movie Preload Notification");
	
	[activityIndicator stopAnimating];
	
	//[[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
	//[[UIApplication sharedApplication] setStatusBarOrientation: UIInterfaceOrientationPortrait animated: NO];
	[self.moviePlayer play];
}

//  Notification called when the movie finished playing.
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; 
}

- (void)setButtonImage {
	UIImage *feedButtonImage = [UIImage imageNamed:@"feedButtonNormal.png"];
	UIImage *normal = [feedButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	UIImage *feedButtonHighlightedImage = [UIImage imageNamed:@"feedButtonPressed.png"];
	UIImage *highlight = [feedButtonHighlightedImage stretchableImageWithLeftCapWidth:12 topCapHeight:12];
	
	[button setBackgroundImage:(UIImage *)normal forState:UIControlStateNormal];
	[button setBackgroundImage:(UIImage *)highlight forState:UIControlStateHighlighted];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
