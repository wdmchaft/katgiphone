//
//  TweetViewController.h
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

#import <UIKit/UIKit.h>

@interface TweetViewController : UITableViewController <UITableViewDelegate, UIAccelerometerDelegate> {
	IBOutlet UINavigationController	*navigationController; // 
	UIActivityIndicatorView			*activityIndicator;
    
	NSMutableArray					*tweets;
	NSMutableDictionary				*iconDict;
	
	NSMutableDictionary *isURL;
	NSMutableDictionary *urlDict;
	
	UIBarButtonItem *refButton;
	UIButton *button;
	UIBarButtonItem *othButton;
}

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) UIActivityIndicatorView			*activityIndicator;

- (void) pollFeed;
- (void)createNotificationForTermination;
- (void) saveData;

@end
