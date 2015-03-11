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


- (RACSignal*) rac_oauthWithURI:(NSURL*) uri redirectUrl:(NSURL*) redirectURL {
    __weak CMBOAuthViewController* delegate = self;
    RACSignal* terminationSignal = [[self rac_signalForSelector:@selector(viewWillDisappear:)] logNext];
    return [[[RACObserve(self, webView) ignore:nil] take:1] flattenMap:^RACStream *(UIWebView* webView) {
        
        
        webView.delegate = delegate;
        NSURLRequest* request = [NSURLRequest requestWithURL:uri];
        
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
        
        return [[[RACSignal merge:@[tokenSignal,errorSignal]]
                 take:1]
                takeUntil:terminationSignal];
    }];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType { return YES;}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {;}


- (RACSignal*) rac_oauthInstagramWithClientId:(NSString*) clientId redirectURI:(NSURL*) redirectURI {
    NSURL* instagramURI = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token",clientId,redirectURI.absoluteString]];
    return [[self rac_oauthWithURI:instagramURI redirectUrl:redirectURI] map:^id(NSURL* value) {
        NSRange range = [value.absoluteString rangeOfString:@"#access_token="];
        if (range.location != NSNotFound) {
            return [value.absoluteString substringFromIndex:(range.location+range.length)];
        }
        return nil;
    }];
    
}

- (RACSignal*) rac_oauthLinkedinWithClientId:(NSString*) clientId redirectURI:(NSURL*) redirectURI state:(NSString*) state clientSecret:(NSString*) clientSecret scope:(NSString*) scope {
    scope = [scope stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* linkedinURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.linkedin.com/uas/oauth2/authorization?client_id=%@&redirect_uri=%@&response_type=code&state=%@&scope=%@",clientId,redirectURI.absoluteString,state,scope]];
    
    return [[[self rac_oauthWithURI:linkedinURL redirectUrl:redirectURI]
             map:^id(NSURL* value) {
                 NSRange range = [value.absoluteString rangeOfString:@"?code="];
                 if (range.location != NSNotFound) {
                     return [[value.absoluteString substringFromIndex:(range.location+range.length)] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"&state=%@",state] withString:@""];
                 }
                 return nil;
             }]
            
            flattenMap:^RACStream *(NSString* value) {
                return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                    NSURLSession *session = [NSURLSession sharedSession];
                    
                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.linkedin.com/uas/oauth2/accessToken"]];
                    request.HTTPMethod = @"POST";
                    [request addValue:@"application/x-www-form-urlencoded"  forHTTPHeaderField:@"Content-Type"];
                    [request addValue:@"application/json"                   forHTTPHeaderField:@"Accept"];
                    NSString* code = value;
                    NSString* params =[NSString stringWithFormat:@"grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@",code,redirectURI.absoluteString,clientId,clientSecret] ;
                    request.HTTPBody = [params dataUsingEncoding:NSUTF8StringEncoding];
                    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSLog(@"%@", json);
                        if (json[@"access_token"]) {
                            [subscriber sendNext:json[@"access_token"]];
                            [subscriber sendCompleted];
                        }
                        else {
                            [subscriber sendError:[NSError errorWithDomain:@"" code:0 userInfo:nil]];
                        }
                        
                    }];
                    
                    [dataTask resume];
                    return [RACDisposable disposableWithBlock:^{
                        [dataTask cancel];
                    }];
                }]
                        deliverOn:[RACScheduler mainThreadScheduler]];
            }];
}


@end
