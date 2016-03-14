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
#import "POQSettings.h"
#import "POQPermissionVC.h"

@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize poqLYRQueryController;
FirstInstallVC *lockVC;
POQInviteFBFriendsVC *inviteVC;
POQSettingsVC *settingsVC;
POQPermissionVC *permissionVC;
POQBuurtVC *tabWall;
MyConversationListViewController *tabChat;
POQSettings *poqSettings;
UIViewController *redVC;

UIView *vwTopBar;
UIView *vwBanner;
CGPoint anchorTopLeft;
CGFloat hBtn;
float hTopBar;
UIButton *btnInviteFBFriends;
UIButton *btnSettings;
UIImageView *logo;

NSMutableArray *neededRegs;
NSUInteger indexPermissionPage;
CLLocationManager *locationManager;
UIViewController *opaq;

-(void) showMapForLocation:(PFGeoPoint *)locaPoint{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

-(void) poqLocationVCDidLocalize:(BOOL)success
{
    NSLog(@"POQRequestVC.didLocalize: Process completed");
    
    //    if (isRequesting) {
    //        [self saveRequest];
    //        isRequesting = false;
    //    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
#pragma mark - todo trigger reloaddata only through this method, not on viewload
    [tabWall localizationStatusChanged];
}

-(BOOL) needsInvitePgShown {
    return ![[[PFUser currentUser] objectForKey:@"FBInvitesSent"] isEqualToString:@"true"];
}

-(BOOL) needsLocaReg {
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        return false;
    }
    return true;
}

-(BOOL) needsFBReg {
    if (![PFUser currentUser]) {
        return true;
    }
    //    [SVProgressHUD dismiss];
    return false;
}

-(BOOL) needsNotifReg
{
    //always NO in simu
    //http://stackoverflow.com/questions/28242332/isregisteredforremotenotifications-always-returns-no
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        NSLog(@"needsNotifReg true");
    } else {
        NSLog(@"needsNotifReg false");
    }
    return ![[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
}

- (void) requestPermissionWithTypes:(NSMutableArray *)regTypes
{
    if (permissionVC == nil) {
        neededRegs = regTypes;
        indexPermissionPage = 0;
        //will trigger view for next type through poqPermissionVCDidDecide.success
        [self showPermissionPage];
    } else {
        //depr by self.opaq
        //emulate modality
        NSLog(@"\npermissionVC != nil");
    }
}

- (void) showPermissionPage
{
    if (indexPermissionPage == [neededRegs count]) {
        //terminate chained showing of permissionVC
        permissionVC = nil;
        [opaq.view removeFromSuperview];
        [opaq removeFromParentViewController];
        opaq = nil;
        [tabWall localizationStatusChanged];
        return;
    }
    
    NSString *theReg = [neededRegs objectAtIndex:indexPermissionPage];
    NSLog(@"REG: %@", theReg);
    NSLog(@"needsFBReg is - %d",[self needsFBReg] ? YES:NO);
    NSLog(@"needsLocaReg is - %d",[self needsLocaReg ] ? YES:NO);
    NSLog(@"needsNotifReg is - %d",[self needsNotifReg] ? YES:NO);
    
    //go next if already granted..
    if (
        ([theReg isEqualToString:@"FB" ] && ![self needsFBReg]) ||
        ([theReg isEqualToString:@"Loca" ] && ![self needsLocaReg ])||
        ([theReg isEqualToString:@"Invite" ] && ![self needsInvitePgShown])||
        ([theReg isEqualToString:@"Notif" ] && ![self needsNotifReg])
        
//        ||
//        (//..or not yet granted, when user has been cancelling the fb signup pg
//            self.needsFBReg &&
//            ([theReg isEqualToString:@"Invite" ] || [theReg isEqualToString:@"Notif" ])
//         )
        )
    {
        indexPermissionPage ++;
        NSLog(@"\nBUMPING PERMPG FOR ALREADY GRANTED");
        
        [self showPermissionPage]; //recursive
        return;
    }
    NSLog(@"pType:\n%@", [neededRegs objectAtIndex:indexPermissionPage]);
    NSLog(@"showPermissionPage called");
    //    POQPermissionVC *
    
    permissionVC = [[POQPermissionVC alloc] initWithNibName:@"POQPermissionVC" bundle:nil];
    permissionVC.permissionPage = theReg;
    [permissionVC setPermissionPage:theReg];
    NSLog(@"askingPermission:\n%@", theReg);
    [self.window.rootViewController addChildViewController:permissionVC];
   
    float vwH = 400;
    float vwW = 280;
    float x = CGRectGetMidX(self.window.rootViewController.view.bounds) - (vwW/2);
    float y = CGRectGetMidY(self.window.rootViewController.view.bounds) - (vwH/2);
    CGRect rect = CGRectMake(x, y, vwW, vwH); //10;50//CGRectMake(10, -32, 280, 400);
    [[permissionVC view] setFrame: rect];
    [permissionVC setDelegate:self];
    
    //obscure bg
    if (opaq == nil) {
        opaq = [[UIViewController alloc] init] ;
        [opaq.view setBounds:self.window.rootViewController.view.bounds];
        [opaq.view setBackgroundColor:   [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.5]];
        [self.window.rootViewController.view addSubview:opaq.view];
    }
    //show permission
    [self.window.rootViewController.view addSubview:permissionVC.view];
}

-(void) poqPermissionVCDidDecide:(BOOL)success withVC:(POQPermissionVC *)theVC{
    if (success) {
        NSLog(@"succes.poqPermissionVCDidDecide");
        if ([theVC.permissionPage isEqualToString:@"Loca"]) {
            //1 localisatie -> POQBuurtVC.RequestTVC.data
            if ([self needsLocaReg]) {
                [locationManager requestWhenInUseAuthorization];
                //uitgezet, nu in show
//                [tabWall localizationStatusChanged];
            } else {
#pragma mark - todo URL poqapp.nl howto change settings
                //previously set authstatus = never, show
                NSURL *url = [ [ NSURL alloc ] initWithString: @"http://poqapp.nl/#!faq/kj830" ];
                //    http://www.poqapp.nl/#!uitleg/cctor
                [[UIApplication sharedApplication] openURL:url];
            }
        } else if ([theVC.permissionPage isEqualToString:@"FB"]){
            //2 FB (in combi met loca) -> postPOQRequestPrivilege
            FirstInstallVC *loginVC = [[FirstInstallVC alloc] init];
            [loginVC setDelegate:self];
            loginVC.layerClient = self.layerClient;
            [loginVC attemptSignup];
//            
//            [loginVC attemptSignupWithBlock:^(NSError *error) {
////                if (!error) {
//                    NSLog(@"[tabWall.localizationStatusChanged];");
//                    [tabWall localizationStatusChanged];
////                }
//            }];
        } else if ([theVC.permissionPage isEqualToString:@"Invite"]){
            //3 inviteFB
            [self showInviteFBFriendsPage:nil];
        } else if ([theVC.permissionPage isEqualToString:@"Notif"]){
            //4 notificatie
            //define actions for notif, triggers registerForRemoteNotifications(toestemming usert)
            [self registerForRequestNotification];
            //[[UIApplication sharedApplication] registerForRemoteNotifications] ;
        }
        indexPermissionPage ++;
        
    } else {        //go to subsequent permissionPage, if any
        if (![theVC.permissionPage isEqualToString:@"Invite"]) {
            //user is in a no mood. stop the chain.
            indexPermissionPage = [neededRegs count];
        } else {//force ask for notif
           indexPermissionPage ++;
        }
        NSLog(@"fail.poqPermissionVCDidDecide");
    }
    //next permissionPage or finishes chain and destroys permissionVC
    [self showPermissionPage];
//    [opaq.view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
//    [opaq performSelectorOnMainThread:@selector(removeFromParentViewController) withObject:nil waitUntilDone:NO];
//
//    [opaq.view removeFromSuperview];
//    [opaq removeFromParentViewController];
    [theVC.view removeFromSuperview];
    [theVC removeFromParentViewController];
    
//    opaq = nil;
}

-(void)poqFirstInstallVCDidSignup{
    NSLog(@"\npoqFirstInstallVCDidSignup");
//    [opaq.view performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
//    [opaq performSelectorOnMainThread:@selector(removeFromParentViewController) withObject:nil waitUntilDone:NO];
    [tabWall localizationStatusChanged];
    [self requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"Notif", @"Invite", nil]];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//register with analytics service
    [AppAnalytics initWithAppKey:@"B9HIi5LANIRcQ1V91PhmqpNzfp5EIsdx" options:@{DebugLog : @(NO)}];
    
//register model to Parse
    [POQRequest registerSubclass]; //    [PFUser registerSubclass];
    [POQSettings registerSubclass];
   
    //init PFUser if previously registered
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [self initParseWithLaunchOptions:launchOptions];
    [self initLYRClient];
//we're keeping the badge count low
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self getPOQSettings];
//    [self createPOQSettings];//rename meters kilometers
    //v1:storyboard  [self showHomeVC];
//v2:tabbar, programmatically
    [self setupHomeVC];
    
#pragma mark - testing move to permissionVC
//**get poq registration statuses

    //FB
    if ([PFUser currentUser]) {
        FirstInstallVC *loginVC = [[FirstInstallVC alloc] init];
        [loginVC setDelegate:self];
        loginVC.layerClient = self.layerClient;
        NSLog(@"%@", [PFUser currentUser].username);
        [loginVC loginLayer];
        [self setLYRQueryControllerForUnread];
    }
    
    //toestemming usert, notiftypes
    if (![self needsNotifReg]) {
        [self registerForRequestNotification];
    }
//else WAIT until user wants something
    if (self.needsFBReg || self.needsLocaReg || self.needsNotifReg) {
        //**dus dit niet hier, maar triggeren via VC acties
//        [self showPermissionVC];
    }

    //depr
//    lockVC = [[FirstInstallVC alloc] initWithNibName:@"FirstInstall" bundle:nil];
//    lockVC.layerClient = self.layerClient;
//    if (![PFUser currentUser] ){
//        [self showSignupPage];
//        
//    } else {
//        [lockVC loginLayer];
//    }
    
    //try FB/layer login
    //waardes ophalen waar
//    self.needsFBReg = [PFUser currentUser];
//    self.needsLocaReg = true; //zie locavw status
//    self.needsNotifReg = true; //
//**
    
    NSLog(@"usert zijn createdAt:%@", [PFUser currentUser].createdAt);
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
//    [self POQLocationManager]
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    return YES;
}

-(void) createPOQSettings {
    POQSettings *create = [[POQSettings alloc] init];
    create.urenAanbodGeldig = @"24";
    create.urenVraagGeldig = @"2";
    create.aantalOmroepenMaxPerDag = @"1000";
    create.kilometersOmroepBereik = @"5";
    create.typeOmschrijvingSet = @"default";
    [create saveInBackground];
}

-(POQSettings *) theSettings{
    return poqSettings;
}

-(void) getPOQSettings {
    NSString *typeUser = nil;
    if ([[PFUser currentUser] objectForKey:@"PoqUserType"]) {
        typeUser = [[PFUser currentUser] objectForKey:@"PoqUserType"];
    } else {
        typeUser = @"default";
    }
    poqSettings = [[POQRequestStore sharedStore] getSettingsWithUserType:typeUser];
    
//    if ([PFUser currentUser]) {
//        NSLog(@"objectForKey:PoqUserType: %@", [[PFUser currentUser] objectForKey:@"PoqUserType"]);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

-(void) makeTopViewObjects{
    anchorTopLeft = CGPointMake(0.0, 20.0);
    hBtn = 40.0;
    
    float l = CGRectGetMidX(self.window.rootViewController.view.bounds)/3;
    float c = CGRectGetMidX(self.window.rootViewController.view.bounds);
    float r = 2*l + c;
    //btns
    UIImage *btnImgInviteFB = [UIImage imageNamed:@"btn invite"];
    UIImage *btnImgSettings = [UIImage imageNamed:@"btn settings"];
    
    CGRect myImageS = CGRectMake(c - (hBtn), 8, 2*hBtn, 2*hBtn);
    logo = [[UIImageView alloc] initWithFrame:myImageS];
    [logo setImage:[UIImage imageNamed:@"poqapp-logo.png"]];
    logo.contentMode = UIViewContentModeScaleToFill;
    
    btnInviteFBFriends = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btnInviteFBFriends addTarget:self
                           action:@selector(showInviteFBFriendsPage:)
                 forControlEvents:UIControlEventTouchUpInside];
    [btnSettings addTarget:self
                    action:@selector(showSettingsPage:)
          forControlEvents:UIControlEventTouchUpInside];
    
    btnInviteFBFriends.frame = CGRectMake(l - (hBtn/2), 8 + anchorTopLeft.y,
                                          hBtn, hBtn);
    btnSettings.frame = CGRectMake(r - (hBtn/2), 8 + anchorTopLeft.y,
                                   hBtn, hBtn);
    [btnInviteFBFriends setBackgroundImage:btnImgInviteFB forState:UIControlStateNormal];
    [btnSettings setBackgroundImage:btnImgSettings forState:UIControlStateNormal];
}

-(void) makeTabs{
    POQRequestVC *tabShout = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
    [tabShout setDelegate:self];
    tabShout.title = @"Verzoek";
    
#pragma mark - waarom apart authenticatedUserID?
    [tabShout setValue:self.layerClient.authenticatedUserID forKey:@"layerUserId"];
    tabShout.layerClient = self.layerClient;
    
    tabChat = [MyConversationListViewController  conversationListViewControllerWithLayerClient:self.layerClient];
    UIView *TabVw = [[UIView alloc]initWithFrame:CGRectMake(0,0,
                                                            self.window.bounds.size.width - 3*hTopBar,
                                                            self.window.bounds.size.height - hTopBar)];
    tabChat.view.bounds = TabVw.frame;
    [tabChat.searchController setDisplaysSearchBarInNavigationBar:false];
//    UINavigationController *navChat = [[UINavigationController alloc] initWithRootViewController:tabChat];

    //in tabcyhat kan je dit wel zetten
//    navChat.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
//                                        initWithTitle:@"Terug" style: UIBarButtonItemStylePlain
//                                        target:self action:@selector(htsfltsMyView)];

    /*self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
     initWithTitle:@"Terug" style: UIBarButtonItemStylePlain
     target:self action:@selector(dismissMyView)];
     }
     
     - (void)htsfltsMyView {
     //    [self removeFromParentViewController];
     [self dismissViewControllerAnimated:YES completion:nil];
     //    [self.navigationController dismissViewControllerAnimated:self completion:nil];
     }*/

    tabWall = [[POQBuurtVC alloc] initWithNibName:@"POQBuurtVC" bundle:nil] ;
    tabWall.layerClient = self.layerClient;
    tabWall.hasFullUserPrivilege = NO; //depr getMissingPermissionsWithVC:tabWall
    tabWall.delegate = self;
    tabWall.title = @"Buurt";
    self.tabBarController = [[TabBarController alloc] init];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithWhite:0.92 alpha:0.75]];
    //     [UIColor colorWithRed:0.229 green:0.229 blue:0.229 alpha:0.3]];
    
    self.tabBarController.viewControllers = [NSArray arrayWithObjects: tabWall, tabChat, tabShout, nil];
}

-(void) setupHomeVC {
    hTopBar = 72;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self makeTabs];
    self.window.rootViewController = self.tabBarController;
    [self.tabBarController setDelegate:self];
    
    [self makeTopViewObjects];
    
    vwTopBar = [[UIView alloc]initWithFrame:CGRectMake(0,0,
                    self.window.bounds.size.width, hTopBar)];

    [vwTopBar addSubview:btnInviteFBFriends];
    [vwTopBar addSubview:btnSettings];
//    [TopBarVw addSubview:logo];
    UIColor *clrTopBar = [UIColor colorWithWhite:0.5 alpha:0.6];
    vwTopBar.backgroundColor = clrTopBar;
    [self.window.rootViewController.view addSubview:vwTopBar];
    
#pragma mark - todo Wat doet dit ?
    [self.window makeKeyAndVisible];
#pragma mark - todo use navcon
}
    //quick fix top control pos to navbar in both orientations
    //    self.navigationController.navigationBar.translucent = NO;
    
    //add navcon
    //    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    //    [self setNavBar];
    //    [self.tabBarController.view addSubview:self.navigationController.view];

    //    float vwH = 400;
    //    float vwW = 280;
    ////    float x = CGRectGetMidX(self.window.rootViewController.view.bounds) - (vwW/2);
    //    float y = CGRectGetMidY(self.window.rootViewController.view.bounds) - (vwH/2);
    

//  //
//    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
//    UINavigationController *navigationController=[[UINavigationController alloc] initWithRootViewController:detailViewController];
//    self.window.rootViewController =nil;
//    self.window.rootViewController = navigationController;
//    [self.window makeKeyAndVisible];
//    //
    
    
//    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    
//    [self setNavBar];
//    self.window.rootViewController =nil;
//    self.window.rootViewController = self.navigationController;
    
    
//    [self.window.rootViewController.view addSubview:self.navigationController.view];
    

//    self.navigationController.navigationItem.titleView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"user anno.png"]];
//    
//    [self.tabBarController didMoveToParentViewController:self.window.rootViewController];
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.window.rootViewController];
//    [navController setDelegate:self];
//    navController.delegate = self;
//    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"Klaar" style:UIBarButtonItemStylePlain target:self action:@selector(dismissMyView)];
//    [[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 0.0f) forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationItem.leftBarButtonItem = btn;
//    [self.navigationController setNeedsStatusBarAppearanceUpdate];
    
//    navController.navigationItem.leftBarButtonItem = btn;
//    //    [[UIBarButtonItem alloc]
////                                                                  initWithTitle:@"Klaar" style: UIBarButtonItemStylePlain
////                                                                target:self action:@selector(dismissMyView)];
//    [navController setTitle:@"flatsi flo"];
//    [self setNavigationController:navController];
//    [navController setNeedsStatusBarAppearanceUpdate];
//    [self.window addSubview:navController.view];
//    [navController setNeedsStatusBarAppearanceUpdate];
    
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController.title isEqualToString:@"Gesprekken"]) {
        [self requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"FB", @"Loca", @"Notif", nil]];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        self.tabBarController.tabBar.items[1].badgeValue = nil;
        [vwTopBar setHidden:true];
    } else {
        [vwTopBar setHidden:false];
    }
    
//    NSLog(@"controller class: %@", NSStringFromClass([viewController class]));
//    NSLog(@"controller title: %@", viewController.title);
    
//    if (viewController == tabBarController.moreNavigationController)
//    {
//        tabBarController.moreNavigationController.delegate = self;
//    }
}

-(void) dismissMyView {
    [inviteVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNavBar { //depr
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
    [self requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"Loca", @"FB", @"Invite", @"Notif", nil]];
}

- (void) showInviteBuurt
{
    [self showInviteFBFriendsPage:nil];
}

- (void) showInviteFBFriendsPage:(id)sender {
    NSLog(@"showInviteFBFriendsPage: called");
    if ([self needsFBReg]) {
        [self requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"FB", @"Loca", @"Notif", nil]];
//        return; show anyway
    }
    POQInviteFBFriendsVC *settingsVC = [[POQInviteFBFriendsVC alloc] initWithNibName:@"POQInviteFBFriendsVC" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
}

#pragma mark - LYRQuery show badgecount unread in tabbar item
-(void)setLYRQueryControllerForUnread{
    //set up query delegate for unread msgs
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"isUnread"  predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    query.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"receivedAt" ascending:NO] ];
    NSError *error;
    poqLYRQueryController = [self.layerClient queryControllerWithQuery:query error:&error];
    [poqLYRQueryController execute:&error];
    poqLYRQueryController.delegate = self;
}

- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController
{
    if (queryController.count > 0) {
//        if (self.tabBarController.selectedIndex != 1) {
            [UIApplication sharedApplication].applicationIconBadgeNumber++;
            self.tabBarController.tabBar.items[1].badgeValue = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber];
//        } else {
//            if (![tabChat.view isFirstResponder]) {
//                redVC = [[UIViewController alloc]  init];
//                redVC.view.backgroundColor = [UIColor redColor];
//                redVC.view.frame = CGRectMake(100, 100, 100, 100);
//                [self.window.rootViewController addChildViewController:redVC];
//                [self.window.rootViewController.view addSubview:redVC.view];
//                [NSTimer scheduledTimerWithTimeInterval:2.0
//                                                 target:self
//                                               selector:@selector(unloadVw)
//                                               userInfo:nil
//                                                repeats:NO];
//            }
            
//        }
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        self.tabBarController.tabBar.items[1].badgeValue = nil;
    }
}

-(void)unloadVw {
//    [redVC removeFromParentViewController];
    [redVC.view setHidden:true];
}
//- (void)presentConversationListViewController
//{
//    if (self.tabBarController.selectedIndex != 1) {
//        //todo alleen als newmsg in niet-actieve convo
//        self.tabBarController.selectedIndex = 1;
//    }
//}
//        [self presentConversationListViewController];
//                if ([UIApplication sharedApplication].applicationState !=UIApplicationStateActive) {
//    depr: voortstrompelend inzicht: layer stuurt ons voortaan een push op nieuwe msgs, zelf een notif maken hoefde toen niet meer
        //            LYRMessage *theMsg = [queryController objectAtIndexPath:0];
        //            LYRActor *fromUser = theMsg.sender;
        //            NSLog(@"from user %@", fromUser.name);
        //            LYRMessagePart *messagePart = theMsg.parts[0];
        //            NSString *msg = [[NSString alloc ] initWithFormat:@"%@", [[NSString alloc] initWithData:messagePart.data encoding:NSUTF8StringEncoding]];
        //            NSString *notif = [[NSString alloc] initWithFormat:@"%@: \n%@", @"poq bericht", msg ];
        //            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        //            NSDate *currentTime = [NSDate date];
        //            localNotification.fireDate = currentTime;
        //            localNotification.alertBody = notif; //@"Nieuw bericht poq";
        //            localNotification.alertAction = @"Toon bericht";
        //            localNotification.timeZone = [NSTimeZone defaultTimeZone];
        //            localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        //            localNotification.soundName = UILocalNotificationDefaultSoundName;//@"default";
        //            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//                }

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
    } else {
        [self showBanner];
    }
}

- (void)showBanner{
    //        aVC = [[UIViewController alloc]  init];
    UILabel *theLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 30, 30, 30)];
    theLabel.backgroundColor = [UIColor clearColor];
    theLabel.textColor = [UIColor whiteColor];
    NSString *txtBadge = [NSString stringWithFormat:@"%ld", (long)[UIApplication sharedApplication].applicationIconBadgeNumber ];
    //        if ([txtBadge isEqualToString:@"0"]) {
    //            return;
    //        }
    theLabel.text = txtBadge;
    [vwBanner addSubview:theLabel];
    [vwBanner setHidden:false];
    //        aVC.view.backgroundColor = [UIColor redColor];
    //        aVC.view.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 64);
    //        [self addChildViewController:aVC];
    //        [self.view addSubview:aVC.view];
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(unloadVwBanner)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)unloadVwBanner {
    //    [redVC removeFromParentViewController];
    [vwBanner setHidden:true];
    //    [aVC removeFromParentViewController];
    //    aVC = nil;
}

-(void) showRequestAVwithUserInfo:(NSDictionary *)userInfo {
    
    if (![[[PFUser currentUser] objectForKey:@"UserIsBanned"] isEqualToString:@"true"]) {
        return;
    }
    
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
    [self showConvoVCForRequest:rqst];
}

-(void)showConvoVCForRequest:(POQRequest *)rqst{
//    send initial default msg to rqsting user
    LYRConversation *rqstConvo = [rqst requestConversationWithLYRClient:self.layerClient];
    NSError *error = nil;
    NSString *convoTitle = rqst.requestLocationTitle; //];//[NSString stringWithFormat:@"%@ \n'%@'", msgInitChat, alertText];
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: rqst.textFirstMessage];
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

//    ->tab Gesprekken
//     self.tabBarController.selectedIndex = 1;
    
//  [self presentConversationListViewController];
//    ConversationViewController *negotiationVC = [ConversationViewController conversationViewControllerWithLayerClient:self.layerClient ];
//    negotiationVC.conversation = rqstConvo;
//    
//    [self.controller.navigationController pushViewController:negotiationVC animated:YES];
}

#pragma mark - Registration poq app
-(void) initParseWithLaunchOptions:(NSDictionary *)launchOptions{
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
}

-(void) initLYRClient{
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
//
//-(void) attemptedUnregisteredActionWithVC:(UIViewController *)poqVC {
//    //self: btnInvite
//    //buurt: FB+loca = permissionPost, push
//    //
//}
//
//-(void) attemptedUnlocalizedCellTapWithVC:(UIViewController *)buurtVC {
//    //label Maak loca bekend
//    //geen FB, geen notifs
//}
//
//-(void) attemptedUnregisteredCellTapWithVC:(UIViewController *)buurtVC {
//    //ziet oproepen, maar needsFBRegistration
//}
//
//-(void) attemptedUnregisteredPostWithVC:(UIViewController *)permissionVC {
//    //attempt registration FB, loca, notifs
//}
//
//-(BOOL)permission2Post {
//    //FB+loca = permission2Post,
//    return NO;
//}
//
//-(void) posterNeedsNotifRegistration
//{
//    //attempt registration notifs (others are set)
//}
//
//-(void)showPermissionVC //depr
//{
//    neededRegs = [[NSMutableArray alloc] init];
//    if (self.needsLocaReg) {
//        [neededRegs addObject:@"Loca"];
//    }
//    if (self.needsFBReg) {
//        [neededRegs addObject:@"FB"];
//        [neededRegs addObject:@"Invite"];
//    }
//    if (self.needsNotifReg) {
//        [neededRegs addObject:@"Notif"];
//    }
//    [self requestPermissionWithTypes:neededRegs];
//}


//    [permissionVC didMoveToParentViewController:self];
//    permissionVC.view.frame = self.parentViewController.view.frame;
//    [[permissionVC view] setFrame:[[self.parentViewController view] bounds]];[[UIScreen mainScreen] bounds]
//    NSLog(@"%f", self.view.frame.origin.x);

//    permissionVC.view.center = CGPointMake(self.window.rootViewController.view.bounds.size.width  / 2,
//                                     self.window.rootViewController.view.bounds.size.height / 2);
//    [[permissionVC view] centerXAnchor];
//    [[permissionVC view] centerYAnchor];
//    [permissionVC.view setFrame:({
//        CGRect frame = permissionVC.view.frame;
//
//        frame.origin.x = (self.window.rootViewController.view.bounds.size.width - frame.size.width) / 2.0;
//        frame.origin.y = (self.window.rootViewController.view.bounds.size.height - frame.size.height) / 2.0;
//
//        CGRectIntegral(frame);
//    })];
//    permissionVC.view.center = CGPointMake(CGRectGetMidX(self.window.rootViewController.view.bounds),
//                                        CGRectGetMidY(self.window.rootViewController.view.bounds));

//    CGPoint *myPointExactly = CGPointMake();
//-(void) showHomeVC { //depr
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    self.controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"PoqHome"];
//    // Make it use our layerclient
//    self.controller.layerClient = self.layerClient;
//    //    self.window.rootViewController = self.controller;
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:self.controller];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//}