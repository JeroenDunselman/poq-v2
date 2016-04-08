//
//  ConversationViewController.m
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

#import <SVProgressHUD/SVProgressHUD.h>
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import "ConversationViewController.h"
#import "ParticipantTableViewController.h"
#import "UserManager.h"

@interface ConversationViewController () <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate, ATLParticipantTableViewControllerDelegate>

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSArray *usersArray;

@end

@implementation ConversationViewController
//@synthesize poqLYRQueryController;

UIViewController *aVC;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    self.addressBarController.delegate = self;
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
//jd 10-X-2015
    self.shouldDisplayAvatarItemForOneOtherParticipant = YES;
    [self configureUI];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Terug" style: UIBarButtonItemStylePlain
                                         target:self action:@selector(dismissMyView)];
//    [self setLYRQueryControllerForUnread];
//    [self makeBanner];
}

//-(void)makeBanner{
//    aVC = [[UIViewController alloc]  init];
//    UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
//    theLabel.backgroundColor = [UIColor clearColor];
//    theLabel.textColor = [UIColor whiteColor];
//    NSString *txtBadge = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber ];
//    if ([txtBadge isEqualToString:@"0"]) {
//        return;
//    }
//    theLabel.text = txtBadge;
//    [aVC.view addSubview:theLabel];
//    aVC.view.backgroundColor = [UIColor redColor];
//    aVC.view.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 64);
//    [self addChildViewController:aVC];
//    [self.view addSubview:aVC.view];
//}
//
//-(void)setLYRQueryControllerForUnread{
//    //set up query delegate for unread msgs
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread"  predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
//    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"receivedAt" ascending:NO] ];
//    NSError *error;
////    poqLYRQueryController = [self.layerClient queryControllerWithQuery:query error:&error];
////    [poqLYRQueryController execute:&error];
////    poqLYRQueryController.delegate = self;
//}
//
//- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
//{
//    if (queryController.count > 0) {
//        //int x = [self.childViewControllers count]; => 1 for the searchbar probably
//        if ([self.childViewControllers count] > 1) {
//            return;
//        }
////        [self showBanner];
//    }
//}
//
//- (void)showBanner{
////        aVC = [[UIViewController alloc]  init];
//    UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
//    theLabel.backgroundColor = [UIColor clearColor];
//    theLabel.textColor = [UIColor whiteColor];
//    NSString *txtBadge = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber ];
//    //        if ([txtBadge isEqualToString:@"0"]) {
//    //            return;
//    //        }
//    theLabel.text = txtBadge;
//    [aVC.view addSubview:theLabel];
//    [aVC.view setHidden:false];
//    //        aVC.view.backgroundColor = [UIColor redColor];
//    //        aVC.view.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 64);
//    //        [self addChildViewController:aVC];
//    //        [self.view addSubview:aVC.view];
//    [NSTimer scheduledTimerWithTimeInterval:2.0
//                                     target:self
//                                   selector:@selector(unloadVw)
//                                   userInfo:nil
//                                    repeats:NO];
//    
//}
//
//-(void)unloadVw {
//    //    [redVC removeFromParentViewController];
//    [aVC.view setHidden:true];
////    [aVC removeFromParentViewController];
////    aVC = nil;
//}

- (void)dismissMyView {
//    [self removeFromParentViewController];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self.navigationController dismissViewControllerAnimated:self completion:nil];
}
#pragma mark - UI Configuration methods

- (void)configureUI
{
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
    [[ATLOutgoingMessageCollectionViewCell appearance] setBubbleViewColor: [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0]];
}

#pragma mark - ATLConversationViewControllerDelegate methods

- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Message sent!");
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error
{
    NSLog(@"Message failed to sent with error: %@", error);
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    NSLog(@"Message selected");
}

#pragma mark - ATLConversationViewControllerDataSource methods

- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if ([participantIdentifier isEqualToString:[PFUser currentUser].objectId]) return [PFUser currentUser];
    PFUser *user = [[UserManager sharedManager] cachedUserForUserID:participantIdentifier];
    if (!user) {
        [[UserManager sharedManager] queryAndCacheUsersWithIDs:@[participantIdentifier] completion:^(NSArray *participants, NSError *error) {
            if (participants && error == nil) {
                [self.addressBarController reloadView];
                // TODO: Need a good way to refresh all the messages for the refreshed participants...
                [self reloadCellsForMessagesSentByParticipantWithIdentifier:participantIdentifier];
            } else {
                NSLog(@"Error querying for users: %@", error);
            }
        }];
    }
    return user;
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];

    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:self.layerClient.authenticatedUserID]) {
            return;
        }

        NSString *checkmark = @"✔︎";
        UIColor *textColor = [UIColor lightGrayColor];
        if (status == LYRRecipientStatusSent) {
            textColor = [UIColor lightGrayColor];
        } else if (status == LYRRecipientStatusDelivered) {
            textColor = [UIColor orangeColor];
        } else if (status == LYRRecipientStatusRead) {
            textColor = [UIColor greenColor];
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:checkmark attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    return mergedStatuses;
}

#pragma mark - ATLAddressBarViewController Delegate methods methods

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    [[UserManager sharedManager] queryForAllUsersWithCompletion:^(NSArray *users, NSError *error) {
        if (!error) {
            ParticipantTableViewController *controller = [ParticipantTableViewController participantTableViewControllerWithParticipants:[NSSet setWithArray:users] sortType:ATLParticipantPickerSortTypeFirstName];
            controller.delegate = self;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        } else {
            NSLog(@"Error querying for All Users: %@", error);
        }
    }];
}

-(void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *))completion
{
    [[UserManager sharedManager] queryForUserWithName:searchText completion:^(NSArray *participants, NSError *error) {
        if (!error) {
            if (completion) completion(participants);
        } else {
            NSLog(@"Error search for participants: %@", error);
        }
    }];
}

#pragma mark - ATLParticipantTableViewController Delegate Methods

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSelectParticipant:(id<ATLParticipant>)participant
{    
    NSLog(@"participant: %@", participant);
    [self.addressBarController selectParticipant:participant];
    NSLog(@"selectedParticipants: %@", [self.addressBarController selectedParticipants]);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)participantTableViewController:(ATLParticipantTableViewController *)participantTableViewController didSearchWithString:(NSString *)searchText completion:(void (^)(NSSet *))completion
{
    [[UserManager sharedManager] queryForUserWithName:searchText completion:^(NSArray *participants, NSError *error) {
        if (!error) {
            if (completion) completion([NSSet setWithArray:participants]);
        } else {
            NSLog(@"Error search for participants: %@", error);
        }
    }];
}

@end
