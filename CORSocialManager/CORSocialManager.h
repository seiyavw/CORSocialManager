//
//  CORSocialManager.h
//  CORKit
//
//  Created by Seiya Sasaki on 2014/05/23.
//  Copyright (c) 2014年 corleonis.jp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

typedef void(^CORSocialManagerPickingBlock)(NSArray *accounts, NSError *error);
typedef void(^CORSocialManagerTwitterAuthCompletion)(NSDictionary *authInfo, NSError *error);

@interface CORSocialManager : NSObject

+ (instancetype)sharedManager;

- (void)registerFacebookAppIdKey:(NSString *)appIdKey;
- (void)registerTwitterApiKey:(NSString *)apiKey secretKey:(NSString *)secretKey;

- (void)requestTwitterAccountsWithPickingBlock:(CORSocialManagerPickingBlock)pickingBlock;
- (void)requestFacebookAccountsWithPickingBlock:(CORSocialManagerPickingBlock)pickingBlock;
- (void)requestTwitterAccountInfo:(ACAccount *)account completion:(CORSocialManagerTwitterAuthCompletion)completion;

@end
