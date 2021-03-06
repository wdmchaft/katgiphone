//
//  WebViewController.h
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

@interface WebViewController : UIViewController <UIWebViewDelegate> {
//	UINavigationController	*navigationController;
	UIView *view;
	UIWebView *webView;
	UIToolbar *toolBar;
	NSString *urlAddress;
}

//@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIToolbar *toolBar;
@property (nonatomic, retain) NSString *urlAddress;

@end