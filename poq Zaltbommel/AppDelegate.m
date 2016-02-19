//
//  AppDelegate.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import <Atlas/Atlas.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ParseFacebookUtilsV4/PFFacebookUtils.h"
#import "ViewController.h"
#import "FirstInstallVC.h"
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "AppAnalytics/Appanalytics.h"
#import "MyConversationListViewController.h"
#import "TabBarController.h"
#import "POQInviteFBFriendsVC.h"
#import "POQSettingsVC.h"
#import "POQRequestVC.h"
#import "POQRequestTVC.h"
#import "POQBuurtVC.h"
#import "POQRequest.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
FirstInstallVC *lockVC;
POQInviteFBFriendsVC *inviteVC;
POQSettingsVC *settingsVC;
CGPoint anchorTopLeft;
CGFloat btnHeight;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AppAnalytics initWithAppKey:@"B9HIi5LANIRcQ1V91PhmqpNzfp5EIsdx" options:@{DebugLog : @(NO)}];
    
    [POQRequest registerSubclass];
//    [PFUser registerSubclass];
    
    [self registerForRequestNotification];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
#pragma mark - testing move to permissionVC
    //staat uit, verschijnt toch -> via LockVC..?
//    [application registerForRemoteNotifications]; //toestemming usert,
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // Enable Parse local data store for user persistence
    [Parse enableLocalDatastore];
    
    // Parse App Id //
    //- PROD: "Layer-Parse-iOS-Example"
//    static NSString *const ParseAppIDString = @"Ueur5UeqNJQYZLWbMiTEMcJyfBFu6pbYC7GbnFNo";
//    static NSString *const ParseClientKeyString = @"J3UF3j2gXCz4SjxPAhtgJlEqL8yUL4oKhgwGZBqm";
    
    //- PROTO: "Poq prototype"
    static NSString *const ParseAppIDString = @"aDSX5yujtJKe07zROLckUhT2wZGQP3VtNMGLN9Za";
    static NSString *const ParseClientKeyString = @"GLLObtqmewxvYYZW54kPuiROjOgKv58B2v7oIQcN";
    
    [Parse setApplicationId:ParseAppIDString
                  clientKey:ParseClientKeyString];
    PFACL *defaultACL = [PFACL ACL];
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
//  zie ook applicationDidBecomeActive:
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Layer App Id
    //- dev
    //LayerAppIDString = @"layer:///apps/staging/9f3d165a-9a86-11e5-86c7-02c404003dc4";
    //- jeroduns@gmail.com
    static NSString *const LayerAppIDString = @"layer:///apps/staging/0e7b0b8c-5def-11e5-b579-4fd01f000f3c";
    //- poqapp@gmail.com
//    static NSString *const LayerAppIDString = @"layer:///apps/production/0e7b1078-5def-11e5-8f32-4fd01f000f3c";

    //     Initializes a LYRClient object
    NSURL *appID = [NSURL URLWithString:LayerAppIDString];
    self.layerClient = [LYRClient clientWithAppID:appID];
    self.layerClient.autodownloadMIMETypes = [NSSet setWithObjects:ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation, nil];
    //    self.layerClient.delegate = self;
    
    //quick fix top control pos to navbar in both orientations
    //    self.navigationController.navigationBar.translucent = NO;
    
    //v1:storyboard  [self showHomeVC];
    //v2:tabbar, programmatically
    [self setupHomeVC];
    lockVC = [[FirstInstallVC alloc] initWithNibName:@"FirstInstall" bundle:nil];
    lockVC.layerClient = self.layerClient;
    if (![PFUser currentUser] ){
        [self showSignupPage];
    } else {
        [lockVC loginLayer];
    }
    NSLog(@"usert zijn createdAt:%@", [PFUser currentUser].createdAt);
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

-(void) setupHomeVC {
    POQRequestVC *tabShout = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
#pragma mark - waarom apart authenticatedUserID?
    [tabShout setValue:self.layerClient.authenticatedUserID forKey:@"layerUserId"];
    tabShout.layerClient = self.layerClient;
    
    MyConversationListViewController *tabChat = [MyConversationListViewController  conversationListViewControllerWithLayerClient:self.layerClient];
    
    POQBuurtVC *tabWall = [[POQBuurtVC alloc] initWithNibName:@"POQBuurtVC" bundle:nil] ;
    tabWall.layerClient = self.layerClient;
    
    self.tabBarController = [[TabBarController alloc] init];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:0.229 green:0.229 blue:0.229 alpha:1.0]];

    self.tabBarController.viewControllers = [NSArray arrayWithObjects:tabShout, tabChat, tabWall, nil];
//    self.window.rootViewController = self.tabBarController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UIViewController *rootVC = [[UIViewController alloc] init];
    self.window.rootViewController = rootVC;
    
    anchorTopLeft = CGPointMake(8.0, 30.0);
    btnHeight = 40.0;
    
    //btnLeft
    UIImage *btnImgInviteFB = [UIImage imageNamed:@"btn invite"];
    UIButton *btnInviteFBFriends = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnInviteFBFriends addTarget:self
               action:@selector(showInviteFBFriendsPage:)
     forControlEvents:UIControlEventTouchUpInside];
    //[btnInviteFBFriends setTitle:@"Invite" forState:UIControlStateNormal];
    btnInviteFBFriends.frame = CGRectMake(self.window.frame.size.width/4 - (btnImgInviteFB.size.width/2), anchorTopLeft.y, btnImgInviteFB.size.width, btnImgInviteFB.size.height);
    //scale
    [btnInviteFBFriends sizeToFit];
    [btnInviteFBFriends center];
    [btnInviteFBFriends setBackgroundImage:btnImgInviteFB forState:UIControlStateNormal];
    [self.window.rootViewController.view addSubview:btnInviteFBFriends];
    
    //btnRight
    UIImage *btnImgSettings = [UIImage imageNamed:@"btn settings"];
    UIButton *btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSettings addTarget:self
                    action:@selector(showSettingsPage:)
          forControlEvents:UIControlEventTouchUpInside];
    //    [btnSettings setTitle:@"Settings" forState:UIControlStateNormal];
    btnSettings.frame = CGRectMake(3*(self.window.frame.size.width/4), anchorTopLeft.y, btnImgSettings.size.width, btnImgSettings.size.height);
    [btnSettings sizeToFit];
    [btnSettings center];
    [btnSettings setBackgroundImage:btnImgSettings forState:UIControlStateNormal];
    [self.window.rootViewController.view addSubview:btnSettings];
   
    UIView *mySubview = [[UIView alloc]initWithFrame:CGRectMake(0, btnHeight + anchorTopLeft.y, self.window.frame.size.width, self.window.frame.size.height - (btnHeight + anchorTopLeft.y))];
    mySubview.backgroundColor = [UIColor brownColor];
    self.tabBarController.view.frame = mySubview.frame;
    [self.window.rootViewController addChildViewController:self.tabBarController];
    [self.window.rootViewController.view addSubview:self.tabBarController.view];
#pragma mark - todo use navcon
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
//    self.navigationController.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"user anno.png"]];
    
    [self.tabBarController didMoveToParentViewController:self.window.rootViewController];
//    [self setNavBar];
    
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Klaar" style:UIBarButtonItemStylePlain target:self action:@selector(dismissMyView)];
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    
//    navController.navigationItem.leftBarButtonItem = btn;
//    //    [[UIBarButtonItem alloc]
////                                                                  initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
////                                                                target:self action:@selector(dismissMyView)];
   #pragma mark - todo Wat doet dit ?
    [self.window makeKeyAndVisible];
//    [navController setTitle:@"flatsi flo"];
//    [self setNavigationController:navController];
//    [navController setNeedsStatusBarAppearanceUpdate];
//    [self.window addSubview:navController.view];
//    [navController setNeedsStatusBarAppearanceUpdate];
    
//    [self.window.rootViewController.view addSubview:self.navigationController.view];
}
-(void) dismissMyView {
    [inviteVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNavBar {
//    UIImageView *vwPoqLogo = [[UIImageView alloc]
//    initWithFrame:CGRectMake(  self.window.frame.size.width/2 - (40),
//                             anchorTopLeft.y, 80.0, 1.6*btnHeight)];
//    [vwPoqLogo setImage:[UIImage imageNamed: @"poqapp-logo.png"]];
//    [vwPoqLogo setContentMode:UIViewContentModeScaleAspectFit];
//    vwPoqLogo.backgroundColor = [UIColor whiteColor];
//    [self.window.rootViewController.view addSubview:vwPoqLogo];

    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    CGRect myImageS = CGRectMake(0, 0, 38, 38);
    UIImageView *logo = [[UIImageView alloc] initWithFrame:myImageS];
    [logo setImage:[UIImage imageNamed:@"poqapp-logo.png"]];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationController.navigationItem.titleView = logo;
    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
                                             target:self action:@selector(dismissMyView)];
    
    
}
- (void)showSignupPage {
    NSLog(@"showSignupPage: called");
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:lockVC];
    [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
}

- (void)showSettingsPage:(id)sender {
    NSLog(@"showSettingsPage: called");
    POQSettingsVC *settingsVC = [[POQSettingsVC alloc] initWithNibName:@"POQSettingsVC" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
}

- (void)showInviteFBFriendsPage:(id)sender {
    NSLog(@"showInviteFBFriendsPage: called");
    POQInviteFBFriendsVC *settingsVC = [[POQInviteFBFriendsVC alloc] initWithNibName:@"POQInviteFBFriendsVC" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
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
   
    //deze regel resulteert in een registerForRemoteNotifications
    //dus de UIUserNotificationSettings kunnen pas tzt worden gezet
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
    NSString *convoTitle = [rqst textFirstMessage];//[NSString stringWithFormat:@"%@ \n'%@'", msgInitChat, alertText];
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: convoTitle];
    NSArray *mA = @[part];
    LYRMessage *msgOpenNegotiation = [self.layerClient newMessageWithParts:mA
                                                           options:nil //todo test
                                                             error:&error];
    
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
    
}


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
//    [FBSDKAppEvents activateApp];
}
//moet aan voor appevents
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                          openURL:url
//                                                sourceApplication:sourceApplication
//                                                       annotation:annotation];
//}


//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    [[FBSDKApplicationDelegate sharedInstance] application:application
//                             didFinishLaunchingWithOptions:launchOptions];
//    return YES;
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
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

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

//    //todo weghalen
//    //    // handle push at app launch, pre refact
//    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (localNotif &&
//        application.applicationState != UIApplicationStateBackground) {
//        [self showRequestAVwithUserInfo:(NSDictionary *)localNotif];
//    }

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
