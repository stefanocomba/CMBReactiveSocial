//
//  GPPSignIn+RACExtensions.m
//  Pods
//
//  Created by Stefano Comba on 27/03/14.
//
//

#import "GPPSignIn+RACExtensions.h"
#import <EXTScope.h>
@interface GPPSignIn () <GPPSignInDelegate>

@end

@implementation GPPSignIn (RACExtensions)

- (RACSignal *) rac_signInWithScopes: (NSArray *) scopes {
    __weak GPPSignIn *gpp = self;
    gpp.attemptSSO = YES;
    BOOL isAppInstalled=[[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"gplus://"]];
    if (isAppInstalled) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            RACDisposable* disposable = [[gpp rac_signalForSelector:@selector(finishedWithAuth:error:) fromProtocol:@protocol(GPPSignInDelegate)] subscribeNext:^(RACTuple *x) {
                NSError *error = x.second;
                if (error) {
                    [subscriber sendError:error];
                }
                else {
                    [subscriber sendNext:x.first];
                    [subscriber sendCompleted];
                }
            }];
            
            gpp.delegate = nil;
            gpp.delegate = gpp;
            gpp.scopes= scopes;
            [gpp authenticate];
            
            return disposable;
        }];
    }
    else {
        self.scopes = scopes;
        UIViewController* vc = [self googleSignInViewController];
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:vc animated:YES completion:nil];
        return [self rac_getGoogleAuthSignal];
    }
}
- (void)didDisconnectWithError:(NSError *)error {;}


- (RACSignal*) rac_getGoogleAuthSignal {
    @weakify(self);
    return [[RACSignal defer:^RACSignal *{
        @strongify(self);
        //        [self presentGoogleSignIn];
        return [[self rac_signalForSelector:@selector(viewController:finishedWithAuth:error:)] flattenMap:^RACStream *(RACTuple* value) {
            //if (!value.second) return [RACSignal error:[NSError otr_errorWithMessage:@"Errore durante l'autenticazione con Google+"]];
            ;
            return [RACSignal return:value.second];
        }];
    }] take:1];
}

- (UIViewController*) googleSignInViewController {
    GTMOAuth2ViewControllerTouch *viewController;
    NSString* scopes = [self.scopes componentsJoinedByString:@" "];
    
    viewController = [GTMOAuth2ViewControllerTouch controllerWithScope:scopes
                                                              clientID: self.clientID
                                                          clientSecret:nil
                                                      keychainItemName:self.keychainName
                                                              delegate:self
                                                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:viewController.view.frame];
    viewController.webView = webView;
    [viewController.view addSubview:webView];
    [webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [viewController.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"H:|-0-[webView]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(webView)]];
    [viewController.view addConstraints:[NSLayoutConstraint
                                         constraintsWithVisualFormat:@"V:|-0-[webView]-0-|"
                                         options:NSLayoutFormatDirectionLeadingToTrailing
                                         metrics:nil
                                         views:NSDictionaryOfVariableBindings(webView)]];    webView.delegate = viewController;
    viewController.signIn.shouldFetchGoogleUserEmail = self.shouldFetchGoogleUserEmail;
    viewController.signIn.shouldFetchGoogleUserProfile = self.shouldFetchGooglePlusUser;
    return viewController;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {

    [viewController.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}


@end
