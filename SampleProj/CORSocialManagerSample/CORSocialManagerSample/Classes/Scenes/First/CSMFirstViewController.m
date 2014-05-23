//
//  CSMFirstViewController.m
//  CORSocialManagerSample
//
//  Created by Seiya Sasaki on 2014/05/23.
//  Copyright (c) 2014年 corleonis. All rights reserved.
//

#import "CSMFirstViewController.h"
#import "CORSocialManager.h"

@interface CSMFirstViewController () <UIActionSheetDelegate>

@end

@implementation CSMFirstViewController
{
    NSArray *_twitterAccounts;
    NSArray *_facebookAccounts;
}

static NSString *const kFacebookAppIdKey    = @"716360685074427";
static NSString *const kTwitterAPIKey       = @"e7alwabVMicnC397QxIPBB40F";
static NSString *const kTwitterSecretKey    = @"4j9BxniT4oJtLosSLmxD3Zh5fIHXGA6jR9SZAVAGXqFWioGe41";

static const NSInteger kActionSheetTagForFacebook = 1000;
static const NSInteger kActionSheetTagForTwitter  = 2000;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[CORSocialManager sharedManager] registerFacebookAppIdKey:kFacebookAppIdKey];
    [[CORSocialManager sharedManager] registerTwitterApiKey:kTwitterAPIKey secretKey:kTwitterSecretKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)didTapFacebookButton:(id)sender {
    
    __weak typeof (self) weakSelf = self;
    
    [[CORSocialManager sharedManager] requestFacebookAccountsWithPickingBlock:^(NSArray *accounts, NSError *error) {
        
        if (!error) {
            // save
            _facebookAccounts = accounts;
            
            UIActionSheet *actionSheet = [weakSelf createActionSheetWithAccounts:accounts tag:kActionSheetTagForFacebook];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [actionSheet showInView:weakSelf.view];
            });
            
            
        } else {
            
            NSLog(@"completion error %@", error);
        }
    }];

}


- (IBAction)didTapTwitterButton:(id)sender {
    
    __weak typeof (self) weakSelf = self;
    
    [[CORSocialManager sharedManager] requestTwitterAccountsWithPickingBlock:^(NSArray *accounts, NSError *error) {
        
        if (error == nil) {
            
            _twitterAccounts = accounts;
            
            UIActionSheet *actionSheet = [weakSelf createActionSheetWithAccounts:accounts tag:kActionSheetTagForTwitter];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [actionSheet showInView:weakSelf.view];
            });

        
        } else {
            
            NSLog(@"completion error %@", error);
        }
        
    }];
    
}

#pragma mark - Helper

- (UIActionSheet *)createActionSheetWithAccounts:(NSArray *)accounts tag:(NSInteger)tag
{
    NSString *title = (tag == kActionSheetTagForTwitter) ? @"twitter accounts": @"facebook accounts";

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    actionSheet.tag = tag;
    
    for (ACAccount *account in accounts)
    {
        NSString *name = account.username;
        [actionSheet addButtonWithTitle:name];
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"cancel", @"cancel")];
    actionSheet.cancelButtonIndex = [accounts count];

    return actionSheet;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    switch (actionSheet.tag) {
        case kActionSheetTagForFacebook: {
            
            if (buttonIndex != actionSheet.cancelButtonIndex) {
                
                ACAccount *pickedAccount = [_facebookAccounts objectAtIndex:buttonIndex];
                NSLog(@"fb picked account: %@", pickedAccount);
                
            } else {
                // cancel button
            }
            
            break;
        }
        case kActionSheetTagForTwitter: {
        
            if (buttonIndex != actionSheet.cancelButtonIndex) {
                
                ACAccount *pickedAccount = [_twitterAccounts objectAtIndex:buttonIndex];
                
                [[CORSocialManager sharedManager] requestTwitterAccountInfo:pickedAccount completion:^(NSDictionary *authInfo, NSError *error) {
                    
                    if (error == nil) {
                    
                        NSLog(@"picked account info %@", authInfo);
                        
                    } else {
                        
                        NSLog(@"auth failed: %@" ,error);
                    
                    }
                }];
                
            } else {
                
                // cancel button
            
            }
            
            break;
        }
        default:
            break;
    }
    
}

@end
