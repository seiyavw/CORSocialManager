//
//  CORSocialManager.m
//  CORKit
//
//  Created by Seiya Sasaki on 2014/05/23.
//  Copyright (c) 2014年 corleonis.jp. All rights reserved.
//

#import "CORSocialManager.h"
#import "STTwitter.h"

@implementation CORSocialManager
{
    NSString *_twitterApiKey;
    NSString *_twitterSecretKey;
    
    NSString *_facebookAppIdKey;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static CORSocialManager *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - register app key

- (void)registerFacebookAppIdKey:(NSString *)appIdKey
{
    _facebookAppIdKey = appIdKey;
}

- (void)registerTwitterApiKey:(NSString *)apiKey secretKey:(NSString *)secretKey
{
    _twitterApiKey = apiKey;
    _twitterSecretKey = secretKey;
}

#pragma mark - request accounts

- (void)requestTwitterAccountsWithPickingBlock:(CORSocialManagerPickingBlock)pickingBlock
{
    
    [self requestSocialAccountsWithServiceType:SLServiceTypeTwitter options:nil pickingBlock:pickingBlock];
}

- (void)requestFacebookAccountsWithPickingBlock:(CORSocialManagerPickingBlock)pickingBlock
{
    NSAssert(_facebookAppIdKey != nil, @"Facebook app id key is requred.");
    
    NSDictionary *options = @{@"ACFacebookAppIdKey": _facebookAppIdKey,
                              @"ACFacebookPermissionsKey": @[@"email"],
                              @"ACFacebookAudienceKey": ACFacebookAudienceFriends};
    
    [self requestSocialAccountsWithServiceType:SLServiceTypeFacebook options:options pickingBlock:pickingBlock];
}

#pragma mark - common method for Account framework

- (void)requestSocialAccountsWithServiceType:(NSString *)serviceType
                                     options:(NSDictionary*)options
                                pickingBlock:(CORSocialManagerPickingBlock)pickingBlock
{
    
    CORSocialManagerPickingBlock copiedPickingBlock = [pickingBlock copy];
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        BOOL isFacebook = [serviceType isEqualToString:SLServiceTypeFacebook];
        
        ACAccountStore *accountStore = [ACAccountStore new];
        NSString *accountTypeIdentifier = (isFacebook) ? ACAccountTypeIdentifierFacebook : ACAccountTypeIdentifierTwitter;
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:accountTypeIdentifier];
        
        [accountStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error) {
            if (error == nil) {
                
                NSArray *accounts = [accountStore accountsWithAccountType:accountType];
                
                copiedPickingBlock(accounts, nil);
                
            } else {
                
                copiedPickingBlock(nil, error);
            }
        }];
        
    } else {
        
        // specified service is unavailable
        NSError *error = [[NSError alloc] initWithDomain:@"" code:503 userInfo:@{@"error":@"A specified service is unavailable"}];
        copiedPickingBlock(nil, error);
    }

}

#pragma mark - for Twitter Auth

- (void)requestTwitterAccountInfo:(ACAccount *)account completion:(CORSocialManagerTwitterAuthCompletion)completion
{
    
    CORSocialManagerTwitterAuthCompletion copiedCompletion = [completion copy];
    
    NSAssert(_twitterApiKey != nil, @"Twitter api key is required.");
    NSAssert(_twitterSecretKey != nil, @"Twitter secret key is required.");
    
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIWithOAuthConsumerName:nil consumerKey:_twitterApiKey consumerSecret:_twitterSecretKey];
    
    [twitter postReverseOAuthTokenRequest:^(NSString *authenticationHeader) {
        
        STTwitterAPI *twitterAPIOS = [STTwitterAPI twitterAPIOSWithFirstAccount];
        
        [twitterAPIOS verifyCredentialsWithSuccessBlock:^(NSString *username) {
            
            [twitterAPIOS postReverseAuthAccessTokenWithAuthenticationHeader:authenticationHeader
                                                                successBlock:^(NSString *oAuthToken,
                                                                               NSString *oAuthTokenSecret,
                                                                               NSString *userID,
                                                                               NSString *screenName) {
                                                                    
                                                                    NSDictionary *authInfo = @{
                                                                                               @"oAuthToken": oAuthToken,
                                                                                               @"oAuthTokenSecret": oAuthTokenSecret,
                                                                                               @"userID": userID,
                                                                                               @"screenName": screenName
                                                                                               };
                                                                    
                                                                    copiedCompletion(authInfo, nil);
                                                                    
                                                                } errorBlock:^(NSError *error) {
                                                                    
                                                                    copiedCompletion(nil, error);
                                                                    
                                                                }];
            
        } errorBlock:^(NSError *error) {
            
            copiedCompletion(nil, error);
        }];
        
    } errorBlock:^(NSError *error) {
        
            copiedCompletion(nil, error);
    }];

}

@end

