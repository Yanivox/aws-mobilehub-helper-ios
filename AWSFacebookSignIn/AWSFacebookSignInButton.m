//
//  AWSFacebookSignInButton.m
//  AWSFacebookSignIn
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//

#import "AWSFacebookSignInButton.h"
#import "AWSFacebookSignInProvider.h"

typedef void (^AWSSignInManagerCompletionBlock)(id result, AWSIdentityManagerAuthState authState, NSError *error);

static NSString *FacebookLogoImageKey = @"fb-no-text";
static NSString *FacebookTextImageKey = @"fb-text";
static NSString *ResourceBundle = @"AWSFacebookSignInResources";
static NSString *BundleExtension = @"bundle";

@interface AWSFacebookSignInButton()

@property (nonatomic, strong) id<AWSSignInProvider> signInProvider;

@property (nonatomic, strong) UIImageView *signInButton;

@end

@implementation AWSFacebookSignInButton

@synthesize delegate;
@synthesize buttonStyle;
UIButton *facebookButton;

- (id)initWithCoder:(NSCoder*)aDecoder {

    if (self = [super initWithCoder:aDecoder]) {
        _signInProvider = [AWSFacebookSignInProvider sharedInstance];
    }
    
    [self initFacebookButton];
    [self addSubview:facebookButton];

    return self;
}

- (void)dealloc {
    @try {
        [self removeObserver:self forKeyPath:@"buttonStyle" context:nil];
    } @catch(id exception) {
        // ignore exception
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // property set
    if ([keyPath isEqualToString:@"buttonStyle"]) {
        if (buttonStyle == AWSSignInButtonStyleTextLogo) {
            [self setupFacebookTextButton];
        } else {
            [self setupFacebookLogoButton];
        }
        // refresh views
        [facebookButton setNeedsDisplay];
        [self setNeedsDisplay];
    }
}

- (void)initFacebookButton {
    facebookButton = [[UIButton alloc] init];
    [self addObserver:self forKeyPath:@"buttonStyle" options:0 context:nil];
    self.buttonStyle = AWSSignInButtonStyleLogo;
    self.clipsToBounds = YES;
    [facebookButton addTarget:self
                       action:@selector(logInWithProvider:)
             forControlEvents:UIControlEventTouchDown];
}

- (UIImage *)getImageFromBundle:(NSString *)imageName {
    NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
    NSURL *bundleUrl = [currentBundle URLForResource:ResourceBundle withExtension:BundleExtension];
    NSBundle *imageBundle = [NSBundle bundleWithURL:bundleUrl];
    return [UIImage imageNamed:imageName
                      inBundle:imageBundle
 compatibleWithTraitCollection:nil];
}

- (void)setupFacebookLogoButton {
    CGRect buttonFrame = facebookButton.frame;
    buttonFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    facebookButton.frame = buttonFrame;
    UIImage *providerImage = [self getImageFromBundle:FacebookLogoImageKey];
    facebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [facebookButton setImage:providerImage forState:UIControlStateNormal];
}

- (void)setupFacebookTextButton {
    CGRect buttonFrame = facebookButton.frame;
    buttonFrame.size = CGSizeMake(self.frame.size.width, self.frame.size.height);
    facebookButton.frame = buttonFrame;
    UIImage *providerImage = [self getImageFromBundle:FacebookTextImageKey];
    facebookButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [facebookButton setImage:providerImage forState:UIControlStateNormal];
}

- (void)setSignInProvider:(id<AWSSignInProvider>)signInProvider {
    self.signInProvider = signInProvider;
}

- (void)logInWithProvider:(id)sender {

    [[AWSSignInManager sharedInstance] loginWithSignInProviderKey:[self.signInProvider identityProviderName]
                                                completionHandler:^(id result, AWSIdentityManagerAuthState authState, NSError *error) {
        [self.delegate onLoginWithSignInProvider:self.signInProvider
                                          result:result
                                       authState:authState
                                           error:error];
    }];
}

@end
