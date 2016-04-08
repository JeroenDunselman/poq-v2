//
//  ConversationListViewController.m
//  Layer-Parse-iOS-Example
//
//  Created by Abir Majumdar on 2/28/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//


#import "MyConversationListViewController.h"
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UserManager.h"
#import "ATLConstants.h"
#import "MyConversationViewController.h"
#import "POQSettingsVC.h"
#import "POQRequestStore.h"
#import "ATLAvatarItem.h"
#import "Mixpanel.h"
#import "PFUser+ATLParticipant.h"
@interface MyConversationListViewController () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

@end


@implementation MyConversationListViewController

#pragma mark - Lifecycle Methods
- (void)viewDidAppear:(BOOL)animated
    {if (!self.view.isFirstResponder) {
        [self.view becomeFirstResponder];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    [self.navigationController.navigationBar setTintColor:ATLBlueColor()];
//    [self.navigationController setNavigationBarHidden:true];
//    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutButtonTapped:)];
//    [self.navigationItem setLeftBarButtonItem:logoutItem];
//    self.tableView.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
    self.view.backgroundColor = [UIColor whiteColor];
//                                 colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
    
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(backButtonTapped:)];
//    [self.navigationItem setLeftBarButtonItem:backItem];
//    UIImage *imgInvite = [UIImage imageNamed:@"btn invite.png"];
//    UIBarButtonItem *btnInvite = [[UIBarButtonItem alloc] initWithImage:imgInvite style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
//    [self.navigationItem setLeftBarButtonItem:nil];

//    UIImage *imgSet = [UIImage imageNamed:@"btn settings.png"];
//    UIBarButtonItem *btnSet = [[UIBarButtonItem alloc] initWithImage:imgSet style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
//     [self.navigationItem setRightBarButtonItem:btnSet];
    //    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeButtonTapped:)];
//    [self.navigationItem setRightBarButtonItem:composeItem];
}

- (void)dismissMyView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backButtonTapped:(id)sender
{
    NSLog(@"backButtonTapAction");
    NSLog(@"showSettingsPage: called");
    POQSettingsVC *settingsVC = [[POQSettingsVC alloc] initWithNibName:@"POQSettingsVC" bundle:nil];
    [self.navigationController presentViewController:settingsVC animated:YES completion:nil];
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
//    [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
//    UINavigationController *navcon = [[UINavigationController alloc] initWithRootViewController:settingsVC];
//    UINavigationController *navcon = [[UINavigationController alloc]];
//    settingsVC.navigationController = navcon;
    settingsVC.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];

    [self.navigationController presentViewController:settingsVC animated:YES completion:nil];
    
//    [self requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"Loca", @"FB", @"Invite", @"Notif", nil]];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [[self delegate] showSettingsPage];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    //    ?self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
    //    UIViewController* viewController = [self.viewControllers objectAtIndex:0];
    //    viewController.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
//    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    self.hidesBottomBarWhenPushed = false;
    return self;
}
#pragma mark - ATLConversationListViewControllerDelegate Methods
- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation
{
    NSString *userID = conversation.lastMessage.sender.userID;
//    // Get ATLParticipant for that userID
//    // [YourCode getATLParticipant] is pseudocode
//    NSMutableDictionary *theDict = [[POQRequestStore sharedStore] avatars];
////    ATLParticipant *lastUser = [YourCode getATLParticipant:userID];
//    id<ATLAvatarItem> myItem = [[id<ATLAvatarItem> alloc] init];
//
//    id<ATLAvatarItem> avatarItem = [self.dataSource conversationListViewController:self avatarItemForConversation:conversation];
    PFUser *resultUser = [[POQRequestStore sharedStore] getPFUserWithId:userID];
    return resultUser;// ;
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    ConversationViewController *controller = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.conversation = conversation;
    controller.displaysAddressBar = NO;
//wordt in convoview op yes gezet    controller.shouldDisplayAvatarItemForOneOtherParticipant = NO;//YES;
    
    controller.hidesBottomBarWhenPushed = NO;
    
//    [controller.view setBounds:CGRectMake(40, 70, 100,200)];
    
//**1    If you want to show the Conversation View without a Conversation List you can wrap the ATLConversationViewController into a UINavigationController as the rootViewController as a workaround.
    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Conversatie gekozen"];
    if (![[[PFUser currentUser] objectForKey:@"UserIsBanned"] isEqualToString:@"true"]) {
        [self.view.window.rootViewController presentViewController:conversationViewNavController animated:YES completion:nil];
//       werkt [self.parentViewController presentViewController:conversationViewNavController animated:YES completion:nil];
//        crasht [self presentViewController:conversationViewNavController animated:YES completion:nil];
    }
#pragma mark - todo present
//**2    default
//    [self.navigationController pushViewController:controller animated:YES];

//**
//    UIViewController *mySubVC = [[UIViewController alloc] init];
//    [mySubVC.view setBounds:CGRectMake(40, 70, 100,200)];
//    [self addChildViewController:mySubVC];
//    mySubVC.view.backgroundColor = [UIColor greenColor];
//    [mySubVC presentViewController:controller animated:YES completion:nil];
    
//    UINavigationController *conversationViewNavController = [[UINavigationController alloc] initWithRootViewController:controller];
//      [conversationViewNavController.view setFrame:CGRectMake(40, 70, 100,200)];
////    [conversationViewNavController.view setFrame:CGRectMake(10, 10, 60, 30)];
//    [self.view.window.rootViewController presentViewController:conversationViewNavController animated:YES completion:nil];

//    [self.view addSubview:mySubVC.view];
//    mySubVC 
//    [mySubVC presentViewController:conversationViewNavController animated:YES completion:nil];
    
//    [self.view.window.rootViewController presentViewController:conversationViewNavController animated:YES completion:nil];
//    self presentViewController:conversationViewNavController animated:<#(BOOL)#> completion:<#^(void)completion#>
//    [self addChildViewController:conversationViewNavController];
}

-(BOOL)hidesBottomBarWhenPushed
{
    return NO;
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion
{
    [[UserManager sharedManager] queryForUserWithName:searchText completion:^(NSArray *participants, NSError *error) {
        if (!error) {
            if (completion) completion([NSSet setWithArray:participants]);
        } else {
            if (completion) completion(nil);
            NSLog(@"Error searching for Users by name: %@", error);
        }
    }];
}

#pragma mark - ATLConversationListViewControllerDataSource Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    if ([conversation.metadata valueForKey:@"title"]){
        return [conversation.metadata valueForKey:@"title"];
    } else {
        NSArray *unresolvedParticipants = [[UserManager sharedManager] unCachedUserIDsFromParticipants:[conversation.participants allObjects]];
        NSArray *resolvedNames = [[UserManager sharedManager] resolvedNamesFromParticipants:[conversation.participants allObjects]];
        if ([unresolvedParticipants count]) {
            [[UserManager sharedManager] queryAndCacheUsersWithIDs:unresolvedParticipants completion:^(NSArray *participants, NSError *error) {
                if (!error) {
                    if (participants.count) {
                        [self reloadCellForConversation:conversation];
                    }
                } else {
                    NSLog(@"Error querying for Users: %@", error);
                }
            }];
        }
        
        NSString *result = nil;
        if ([resolvedNames count] && [unresolvedParticipants count]) {
            result = [NSString stringWithFormat:@"%@ and %lu others", [resolvedNames componentsJoinedByString:@", "], (unsigned long)[unresolvedParticipants count]];
        } else if ([resolvedNames count] && [unresolvedParticipants count] == 0) {
            result = [NSString stringWithFormat:@"%@", [resolvedNames componentsJoinedByString:@", "]];
        } else {
            result =[NSString stringWithFormat:@"Poq gesprek met %lu users...", (unsigned long)conversation.participants.count];
        }
        return result;
    }
}

#pragma mark - Actions

- (void)composeButtonTapped:(id)sender
{
    ConversationViewController *controller = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient];
    controller.displaysAddressBar = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

//- (void)logoutButtonTapped:(id)sender
//{
//    NSLog(@"logOutButtonTapAction");
//    
//    [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
//        if (!error) {
//            [PFUser logOut];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        } else {
//            NSLog(@"Failed to deauthenticate: %@", error);
//        }
//    }];
//}

@end
