//
//  CMBOAuthViewController.h
//  Pods
//
//  Created by Stefano Comba on 10/03/15.
//
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>

@interface CMBOAuthViewController : UIViewController

@property (nonatomic,weak) IBOutlet UIWebView* webView;
- (RACSignal*) rac_oauthWithURL:(NSURL*) url redirectUrl:(NSURL*) redirectURL;

@end
