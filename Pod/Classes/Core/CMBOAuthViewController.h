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
- (RACSignal*) rac_oauthWithURI:(NSURL*) uri redirectUrl:(NSURL*) redirectURL;

- (RACSignal*) rac_oauthInstagramWithClientId:(NSString*) clientId redirectURI:(NSURL*) redirectURI;



/**
 Returns a signal which will send the final LinkedIn access token upon successful authentication or an empty error otherwise. The authentication chain of events won't start until view controller is successfully presented on screen.
 
 @param clientId: The LinkedIn App's client ID
 @param redirectURI : The LinkedIn App's redirectURI. 
 @param state : A custom string used to avoid CSRF. Current implementation ignores it
 @param clientSecret : The LinkedIn App's client secret. 
 @param scope : A space delimited list of member permissions your application is requesting on behalf of the user.  If you do not specify a scope in your call, we will fall back to using the default member permissions by implementation
 
 */
- (RACSignal*) rac_oauthLinkedinWithClientId:(NSString*) clientId redirectURI:(NSURL*) redirectURI state:(NSString*) state  clientSecret:(NSString*) clientSecret scope:(NSString*) scope;
@end
