//
//  AppDelegate.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "AppDelegate.h"
#import "POQRequest.h"
#import "Parse/Parse.h"
#import <Atlas/Atlas.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseFacebookUtilsV4/PFFacebookUtils.h"
#import "ViewController.h"
#import <FirstInstallVC.h>
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
@interface AppDelegate ()

@end

@implementation AppDelegate
//#pragma - mark LYRClientDelegate Delegate Methods
//
//- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce
//{
//    NSLog(@"Layer Client did recieve authentication challenge with nonce: %@", nonce);
//}
//
//- (void)layerClientDidDisconnect:(LYRClient *)client
//{
//    NSLog(@"Layer Client did disconnect");
//}
//- (void)layerClientDidConnect:(LYRClient *)client
//{
//    NSLog(@"Layer Client did connect");
//}
#pragma mark Push Notifications

NSString * const NotificationCategoryIdent  = @"ACTIONABLE";
NSString * const NotificationActionOneIdent = @"ACTION_ONE";
NSString * const NotificationActionTwoIdent = @"ACTION_TWO";

- (void)registerForRequestNotification {
    
    UIMutableUserNotificationAction *action1;
    action1 = [[UIMutableUserNotificationAction alloc] init];
    [action1 setActivationMode:UIUserNotificationActivationModeForeground];
    [action1 setTitle:@"Reageer"];
    [action1 setIdentifier:NotificationActionOneIdent];
    [action1 setDestructive:NO];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationAction *action2;
    action2 = [[UIMutableUserNotificationAction alloc] init];
    [action2 setActivationMode:UIUserNotificationActivationModeBackground];
    [action2 setTitle:@"Verwijder"];
    [action2 setIdentifier:NotificationActionTwoIdent];
    [action2 setDestructive:NO];
    [action2 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *actionCategory;
    actionCategory = [[UIMutableUserNotificationCategory alloc] init];
    [actionCategory setIdentifier:NotificationCategoryIdent];
    [actionCategory setActions:@[action1, action2]
                    forContext:UIUserNotificationActionContextDefault];
    
    NSSet *categories = [NSSet setWithObject:actionCategory];
    UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                    UIUserNotificationTypeSound|
                                    UIUserNotificationTypeBadge);
    
    UIUserNotificationSettings *settings;
    settings = [UIUserNotificationSettings settingsForTypes:types
                                                 categories:categories];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;

    if ([identifier isEqualToString:NotificationActionOneIdent]) {
        [self initChatwithUserID:userInfo];
    }
    else if ([identifier isEqualToString:NotificationActionTwoIdent]) {}
    
    if (completionHandler) {
        completionHandler();
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //Best belangrijk. Hiermee registreert Parse de install.
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
    
    NSError *error;
    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
    NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    Layer example payload:
//    {aps: {content-available: 1}}
//    {aps: {alert: "hey there, how you doing?"}}
    NSDictionary *aps = userInfo[@"aps"];
    id alert = nil;
    alert = aps[@"category"];
    if (alert) {
//        poq request example payload
//        category : "ACTIONABLE",
        [self showRequestAVwithUserInfo:userInfo];
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [POQRequest registerSubclass];
    
    [self registerForRequestNotification];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

    [application registerForRemoteNotifications]; //toestemming usert, 
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // Enable Parse local data store for user persistence
    [Parse enableLocalDatastore];
    static NSString *const ParseAppIDString = @"Ueur5UeqNJQYZLWbMiTEMcJyfBFu6pbYC7GbnFNo";
    static NSString *const ParseClientKeyString = @"J3UF3j2gXCz4SjxPAhtgJlEqL8yUL4oKhgwGZBqm";
    [Parse setApplicationId:ParseAppIDString
                  clientKey:ParseClientKeyString];
    PFACL *defaultACL = [PFACL ACL];
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    //jeroduns@gmail.com
//    static NSString *const LayerAppIDString = @"layer:///apps/staging/0e7b0b8c-5def-11e5-b579-4fd01f000f3c";
    
//poqapp@gmail.com
     static NSString *const LayerAppIDString = @"layer:///apps/production/0e7b1078-5def-11e5-8f32-4fd01f000f3c";
//    static NSString *const LayerAppIDString = @"layer:///apps/staging/9f3d165a-9a86-11e5-86c7-02c404003dc4";
//    
    //     Initializes a LYRClient object
    NSURL *appID = [NSURL URLWithString:LayerAppIDString];
    self.layerClient = [LYRClient clientWithAppID:appID];
    self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation, nil];
    self.layerClient.delegate = self;
    [self showHomeVC];
    
//    //todo weghalen
//    //    // handle push at app launch, pre refact
//    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (localNotif &&
//        application.applicationState != UIApplicationStateBackground) {
//        [self showRequestAVwithUserInfo:(NSDictionary *)localNotif];
//    }
    
    return YES;
}

-(void) showHomeVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"PoqHome"];
    // Make it use our layerclient
    self.controller.layerClient = self.layerClient;
    //    self.window.rootViewController = self.controller;
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.controller];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

-(void) showRequestAVwithUserInfo:(NSDictionary *)userInfo {
    
    NSString *userId = userInfo[@"userid"];
    NSString *userName = userInfo[@"username"];
    NSString *itemDesc = userInfo[@"item"];
    BOOL rqstSentByUser = [self.layerClient.authenticatedUserID isEqualToString:userId];
    
    NSDictionary *aps = userInfo[@"aps"];
    id alert = aps[@"alert"];
    
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    NSString *rqstDate = [[NSString alloc] initWithFormat:@"[%@]", [dateFormatter stringFromDate: currentTime] ];
    NSString *rqstDescSupplyOrDemand = userInfo[@"supplyordemand"];
    
    NSString *message = nil;
    NSString *controllerTitle = nil;
    
    if ([alert isKindOfClass:[NSString class]]) {
        NSLog(@"ALERT: %@", alert);
        if (rqstSentByUser) {
            controllerTitle = @"Bedankt voor je oproep!";
            message = [NSString stringWithFormat:@"%@", @"Poq is voor je aan het rondvragen."];}
        else {
            controllerTitle = [NSString stringWithFormat:@"%@ %@ \n%@", userName, rqstDescSupplyOrDemand, itemDesc];
            message = [NSString stringWithFormat:@"%@ %@", rqstDate, alert];
        }
    }
    
    if (message) {
        
        UIAlertController * alert =   [UIAlertController
                                       alertControllerWithTitle:controllerTitle
                                       message:message
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = nil;
        if (rqstSentByUser) {
            ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
            [alert addAction:ok];
        } else {
            ok = [UIAlertAction
                  actionWithTitle:@"Ja"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      [alert dismissViewControllerAnimated:YES completion:nil];
                      [self initChatwithUserID:userInfo];
                  }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Nee"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
            [alert addAction:cancel];
            [alert addAction:ok];
        }
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void) initChatwithUserID:(NSDictionary *)userInfo {
    [SVProgressHUD dismiss];
    POQRequest *rqst = [[POQRequest alloc] init];
    rqst.requestUserId = userInfo[@"userid"];
    rqst.requestLocationTitle = userInfo[@"username"];
    rqst.requestTitle = userInfo[@"item"];
    rqst.requestPriceDeliveryLocationUser = userInfo[@"price"];
    if ([userInfo[@"supplyordemand"] isEqualToString:@" zoekt naar: "]) {
        rqst.requestSupplyOrDemand = true;
    } else {
        rqst.requestSupplyOrDemand = false;
    }
    
    LYRConversation *rqstConvo = [rqst requestConversationWithLYRClient:self.layerClient];
 
    NSError *error = nil;
//    NSDictionary *aps = userInfo[@"aps"];
//    id alert = aps[@"alert"];
//    NSString *alertText = nil;
//    if ([alert isKindOfClass:[NSString class]]) {
//        alertText = alert;
//    }
//    NSString *convoTitle = [NSString stringWithFormat:@"%@ %@ %@ \n%@.", rqsterName, rqstMode, rqstItem, msgInitChat];
    NSString *convoTitle = [rqst textFirstMessage];//[NSString stringWithFormat:@"%@ \n'%@'", msgInitChat, alertText];
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: convoTitle];
    NSArray *mA = @[part];
    LYRMessage *msgOpenNegotiation = [self.layerClient newMessageWithParts:mA
                                                           options:nil //todo test
                                                             error:&error];
    // Fetch all conversations between authenticated user, supplied user and add admin to convo
//    NSMutableArray *userSet = [[NSMutableArray alloc] init];
//    [userSet addObject:self.layerClient.authenticatedUserID];
//    
//    //add admin if not authenticatedUser
//    NSString *adminId = [PFCloud callFunction:@"getPoqChatBotId" withParameters:nil error:&error];
//    if (![self.layerClient.authenticatedUserID isEqualToString: adminId] &&
//        ![adminId isEqualToString:@""]) {
//        [userSet addObject:adminId];
//    }
//    //add rqsterId if not admin
//    if (![rqsterId isEqualToString: adminId]) {
//        [userSet addObject:rqsterId];
//    }
//    NSSet *participants = [userSet copy];
//    
//    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:participants];
//    
//    NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];
//    if (!error) {
//        LYRConversation *conversation = nil;
//        NSLog(@"%tu conversations with participants %@", conversations.count, participants);
//        if (conversations.count > 0) {
//            conversation = [conversations objectAtIndex:0];
//        } else {
//            // Creates and returns a new conversation object
//            BOOL deliveryReceiptsEnabled = true; //participants.count <= 5;
//            NSDictionary *options = @{LYRConversationOptionsDeliveryReceiptsEnabledKey: @(deliveryReceiptsEnabled)};
//            
//            conversation = [self.layerClient newConversationWithParticipants:[NSSet setWithArray:@[rqsterId, adminId]] options:options error:&error];
//        }
        NSDictionary *metadata = @{@"title" : convoTitle,
                                   @"theme" : @{
                                           @"background_color" : @"335333",
                                           @"text_color" : @"F8F8EC",
                                           @"link_color" : @"21AAE1"},
                                   @"created_at" : @"Dec, 01, 2014",
                                   @"img_url" : @"/path/to/img/url"};
        [rqstConvo setValuesForMetadataKeyPathsWithDictionary:metadata merge:YES];
        [rqstConvo sendMessage:msgOpenNegotiation error:&error];
        
        ConversationViewController *negotiationVC = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient ];
        negotiationVC.conversation = rqstConvo;
        
        [self.controller.navigationController pushViewController:negotiationVC animated:YES];
//    } else {
//        NSLog(@"Query failed with error %@", error);
//    }
}

//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                    didFinishLaunchingWithOptions:launchOptions];
//}
//
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   application.applicationIconBadgeNumber = 0;   
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

//    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
//    query.predicate = [LYRPredicate predicateWithProperty:@"hasUnreadMessages" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
//    LYRQueryController *queryController = [self.layerClient queryControllerWithQuery:query];
//    queryController.delegate = self;


//    - (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error
//self.layerClient send
//    [LYRConversation sendMessage:error:].

//    LYRMessage *msgOpenNegotiation = [LYRMessage messageWithConversation:conversation parts:mA];
//    + (instancetype)messageWithConversation:(LYRConversation *)conversation parts:(NSArray *)messageParts


//    [self.window.rootViewController presentViewController:negotiationVC animated:YES completion:nil];

//    negotiationVC = [negotiationVC initWithNibName:@"View" bundle:nil];
//    negotiationVC.layerClient = self.layerClient;

//    [self.navigationController pushViewController:rqstVC animated:YES];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
//    UIBarButtonItem *composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(slctr:)];
//
//    NSArray *mA = [NSArray arrayWithArray:
//                   @[composeItem]];
//    [navController setToolbarItems:mA];
//    [navController pushViewController:negotiationVC animated:YES];
//    [self.controller presentViewController:negotiationVC animated:YES completion:nil];
