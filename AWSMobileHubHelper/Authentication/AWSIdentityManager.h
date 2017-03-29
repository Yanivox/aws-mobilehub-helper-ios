//
//  AWSIdentityManager.h
//
// Copyright 2016 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
#import <UIKit/UIKit.h>
#import <AWSCore/AWSCore.h>
#import <Foundation/Foundation.h>
#import "AWSSignInProvider.h"
#import "AWSSignInProviderApplicationIntercept.h"

NS_ASSUME_NONNULL_BEGIN

@interface AWSIdentityManager : NSObject<AWSIdentityProviderManager>

/**
 * User Info acquired from third party identity provider, such as Facebook or Google.
 * @return userInfo object of the underlying signInProvider
 */
@property (nonatomic, readonly, nullable) AWSUserInfo *userInfo;

/**
 * Amazon Cognito User Identity ID. This uniquely identifies the user, regardless of
 * whether or not the user is signed-in, if User Sign-in is enabled in the project.
 * @return unique user identifier
 */
@property (nonatomic, readonly, nullable) NSString *identityId;

/**
 * Amazon Cognito Credentials Provider. This is the credential provider used by the Identity Manager.
 *
 * @return the cognito credentials provider
 */
@property (nonatomic, readonly, strong) AWSCognitoCredentialsProvider *credentialsProvider;

/**
 Returns the Identity Manager singleton instance configured using the information provided in `Info.plist` file.
 
 *Swift*
 
 let identityManager = AWSIdentityManager.default()
 
 *Objective-C*
 
 AWSIdentityManager *identityManager = [AWSIdentityManager defaultIdentityManager];
 */
+ (instancetype)defaultIdentityManager;


@end

NS_ASSUME_NONNULL_END