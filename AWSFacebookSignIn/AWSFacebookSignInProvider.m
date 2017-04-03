//
//  AWSFacebookSignInProvider.m
//  AWSFacebookSignIn
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//

#import <AWSMobileHubHelper/AWSSignInManager.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AWSFacebookSignInProvider.h"

static NSTimeInterval const AWSFacebookSignInProviderTokenRefreshBuffer = 10 * 60;

typedef void (^AWSSignInManagerCompletionBlock)(id result, AWSIdentityManagerAuthState authState, NSError *error);

@interface AWSSignInManager()

- (void)completeLogin;

@end

@interface AWSFacebookSignInProvider()

@property (strong, nonatomic) FBSDKLoginManager *facebookLogin;

@property (assign, nonatomic) FBSDKLoginBehavior savedLoginBehavior;
@property (strong, nonatomic) NSArray *requestedPermissions;
@property (strong, nonatomic) UIViewController *signInViewController;
@property (atomic, copy) AWSSignInManagerCompletionBlock completionHandler;

@end

@implementation AWSFacebookSignInProvider

+ (instancetype)sharedInstance {
    static AWSFacebookSignInProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[AWSFacebookSignInProvider alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        _requestedPermissions = nil;
        _signInViewController = nil;
        if (NSClassFromString(@"SFSafariViewController")) {
            _savedLoginBehavior = FBSDKLoginBehaviorNative;
        } else {
            _savedLoginBehavior = FBSDKLoginBehaviorWeb;
        }
        return self;
    }
    return nil;
}

- (void) createFBSDKLoginManager {
    self.facebookLogin = [FBSDKLoginManager new];
    self.facebookLogin.loginBehavior = self.savedLoginBehavior;
}

#pragma mark - MobileHub user interface

- (void)setLoginBehavior:(NSUInteger)loginBehavior {
    // FBSDKLoginBehavior enum values 0 thru 3
    // FBSDK v4.13.1
    if (loginBehavior > 3) {
        [NSException raise:NSInvalidArgumentException
                    format:@"%@", @"Failed to set Facebook login behavior with provided login behavior."];
        return;
    }
    
    if (self.facebookLogin) {
        self.facebookLogin.loginBehavior = loginBehavior;
    } else {
        self.savedLoginBehavior = loginBehavior;
    }
}

- (void)setPermissions:(NSArray *)requestedPermissions {
    self.requestedPermissions = requestedPermissions;
}

- (void)setViewControllerForFacebookSignIn:(UIViewController *)signInViewController {
    self.signInViewController = signInViewController;
}

#pragma mark - AWSIdentityProvider

- (NSString *)identityProviderName {
    return AWSIdentityProviderFacebook;
}

- (AWSTask<NSString *> *)token {
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    NSString *tokenString = token.tokenString;
    NSDate *idTokenExpirationDate = token.expirationDate;
    
    if (tokenString
        // If the cached token expires within 10 min, tries refreshing a token.
        && [idTokenExpirationDate compare:[NSDate dateWithTimeIntervalSinceNow:AWSFacebookSignInProviderTokenRefreshBuffer]] == NSOrderedDescending) {
        return [AWSTask taskWithResult:tokenString];
    }
    
    AWSTaskCompletionSource *taskCompletionSource = [AWSTaskCompletionSource taskCompletionSource];
    [FBSDKLoginManager renewSystemCredentials:^(ACAccountCredentialRenewResult result, NSError *error) {
        if (result == ACAccountCredentialRenewResultRenewed) {
            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
            NSString *tokenString = token.tokenString;
            taskCompletionSource.result = tokenString;
        } else {
            taskCompletionSource.error = error;
        }
    }];
    return taskCompletionSource.task;
}

#pragma mark -

- (BOOL)isLoggedIn {
    return [FBSDKAccessToken currentAccessToken] != nil;
}

- (void)reloadSession {
    if ([FBSDKAccessToken currentAccessToken]) {
        [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error) {
                AWSLogError(@"'refreshCurrentAccessToken' failed: %@", error);
            } else {
                [self completeLogin];
            }
        }];
    }
}

- (void)completeLogin {
    [[AWSSignInManager sharedInstance] completeLogin];
}

- (void)login:(AWSSignInManagerCompletionBlock) completionHandler {
    self.completionHandler = completionHandler;
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self completeLogin];
        return;
    }
    
    if (!self.facebookLogin)
        [self createFBSDKLoginManager];
    
    [self.facebookLogin logInWithReadPermissions:self.requestedPermissions
                              fromViewController:self.signInViewController
                                         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {

                                             // Determine Auth State
                                             AWSIdentityManagerAuthState authState = [AWSSignInManager sharedInstance].authState;
                                             if (error) {
                                                    self.completionHandler(result, authState, error);
                                             } else if (result.isCancelled) {
                                                 // Login canceled, allow completionhandler to know about it
                                                 NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                                                 userInfo[@"message"] = @"User Cancelled Login";
                                                 NSError *resultError = [NSError errorWithDomain:FBSDKLoginErrorDomain code:FBSDKLoginUnknownErrorCode userInfo:userInfo];
                                                 self.completionHandler(result, authState, resultError);
                                             } else {
                                                 [self completeLogin];
                                             }
                                         }];
}

- (void)logout {
    if (!self.facebookLogin) {
        [self createFBSDKLoginManager];
    }
    [self.facebookLogin logOut];
}

- (BOOL)interceptApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)interceptApplication:(UIApplication *)application
                     openURL:(NSURL *)url
           sourceApplication:(NSString *)sourceApplication
                  annotation:(id)annotation {
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
    
    return NO;
}

@end
