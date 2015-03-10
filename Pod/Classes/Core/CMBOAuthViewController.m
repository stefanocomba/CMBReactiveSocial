//
//  CMBOAuthViewController.m
//  Pods
//
//  Created by Stefano Comba on 10/03/15.
//
//

#import "CMBOAuthViewController.h"
#import <EXTScope.h>
@interface CMBOAuthViewController () <UIWebViewDelegate>
@property (nonatomic,strong) NSString* redirectUrl;
@property (nonatomic,strong) NSURL* oauthUrl;
@end

@implementation CMBOAuthViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.webView) {
        UIWebView* webView = [[UIWebView alloc] init] ;
        self.webView = webView;
        [self.view addSubview:webView];
        [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(webView)]];
        [self.view addConstraints:[NSLayoutConstraint
                                             constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                             options:NSLayoutFormatDirectionLeadingToTrailing
                                             metrics:nil
                                             views:NSDictionaryOfVariableBindings(webView)]];
    }
    self.webView.delegate = self;
    // Do any additional setup after loading the view.
}


- (RACSignal*) rac_oauthWithURL:(NSURL*) url redirectUrl:(NSURL*) redirectURL {
    __weak id<UIWebViewDelegate> delegate = self;
    return [[RACObserve(self, webView) ignore:nil] flattenMap:^RACStream *(UIWebView* webView) {
        
    
        webView.delegate = delegate;
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    RACSignal* tokenSignal = [[[self rac_signalForSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)] map:^id(RACTuple* value) {
        NSURLRequest* request =  [value second];
        return request.URL;
    }] filter:^BOOL(NSURL* value) {
     return [value.absoluteString rangeOfString:redirectURL.absoluteString].location == 0;
    }];
    
    RACSignal* errorSignal = [[self rac_signalForSelector:@selector(webView:didFailLoadWithError:)] flattenMap:^RACStream *(RACTuple* value) {
        return [RACSignal error:value.second];
    }];
    [webView stopLoading];
    [webView loadRequest:request];
    return [[RACSignal merge:@[tokenSignal,errorSignal]] take:1];
    }];
    
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { return YES;}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {;}
@end
