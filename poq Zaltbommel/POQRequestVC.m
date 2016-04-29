//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQRequestVC.h"
#import "Parse/Parse.h"
#import "POQRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "Mixpanel.h"
@implementation POQRequestVC
@synthesize layerUserId, delegate, scrollView;
static NSString *initPrice;
POQLocationVC *locaVC;
POQRequest *rqst;
BOOL isRequesting;

//protocol POQLocationVC
- (BOOL) needsLocaReg{
    return [[self delegate] needsLocaReg];
}

-(void) alertRequestNotPushed {

    //Explain cancel
    NSString *titleAlert = @"Verzoek niet gepost.";
    NSString *messageAlert = @"Geef een artikel en een prijs.";
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:titleAlert
                                   message:messageAlert
                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = nil;
    ok = [UIAlertAction
          actionWithTitle:@"OK"
          style:UIAlertActionStyleDefault
          handler:^(UIAlertAction * action)
          {
              [alert dismissViewControllerAnimated:YES completion:nil];
          }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertRequestNotPushedAppNeedsPermission
{
    //Explain cancel
    NSString *titleAlert = @"Verzoek niet gepost.";
    NSString *messageAlert = nil;
    if (![self needsLocaReg]) {
        messageAlert = @"Om te kunnen posten moet je eerst inloggen via Facebook.";
    } else if (![[self delegate] needsFBReg]) {
        messageAlert = @"Om te kunnen posten heeft Poq je locatie nodig.";
    } else {
        messageAlert = @"Om te kunnen posten heeft Poq je locatie nodig en moet je inloggen via Facebook.";
    }
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:titleAlert
                                   message:messageAlert
                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = nil;
    ok = [UIAlertAction
          actionWithTitle:@"OK"
          style:UIAlertActionStyleDefault
          handler:^(UIAlertAction * action)
          {
              [alert dismissViewControllerAnimated:YES completion:nil];
          }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

//protocol POQLocationVC
- (void)requestPermissionWithTypes:(NSMutableArray *)Types{
//    [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"Loca", nil]];
    [[self delegate] requestPermissionWithTypes:Types];
//
}

- (IBAction)postRequest:(id)sender {
    //check permissions
    if ([[self delegate] needsFBReg] || [[self delegate] needsLocaReg]) {
        [self dismissKeyboard];
        [self alertRequestNotPushedAppNeedsPermission];
        [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects: @"FB", @"Loca", nil]];
        return;
        //RegNotif may wait until after post
    }
    
    //Check required Item, Price
    if (self.textItemRequested.text.length == 0) {
        [self alertRequestNotPushed];
        return;
    }
    if ([self.textPrice.text isEqualToString:initPrice]) {
        [self alertRequestNotPushed];
        return;
    }
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    //Bevestigen push: toon voorbeeldtekst push
    //vraag aanbod
    NSString *controllerTitle = @"";
    NSString *rqstDescSupplyOrDemand = @""; ;
    if (self.scSupplyDemand.selectedSegmentIndex == 0) {
        rqstDescSupplyOrDemand = @"zoekt naar" ;
        controllerTitle = [NSString stringWithFormat:@"%@ %@ \n%@ voor %@", [[PFUser currentUser] username], rqstDescSupplyOrDemand, self.textItemRequested.text, self.textPrice.text];
    } else {
        controllerTitle = [NSString stringWithFormat:@"%@ biedt %@ aan \n voor %@", [[PFUser currentUser] username], self.textItemRequested.text, self.textPrice.text];
    }
    
    NSString *titleAlert = @"Doorgaan?";
    NSString *messageAlert = controllerTitle;
    UIAlertController * alert =   [UIAlertController
                                   alertControllerWithTitle:titleAlert
                                   message:messageAlert
                                   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = nil;
    ok = [UIAlertAction
          actionWithTitle:@"Bevestigen"
          style:UIAlertActionStyleDefault
          handler:^(UIAlertAction * action)
          {
              [alert dismissViewControllerAnimated:YES completion:nil];
              // post
              
              rqst = [POQRequest object];
              rqst.requestTitle = self.textItemRequested.text;
              rqst.requestPriceDeliveryLocationUser = self.textPrice.text;
              
              //firstname from full
              NSString *fullNameFB  =  [PFUser currentUser].username;
              //split it to maybe get firstname from it
              NSArray *listDescUser = [fullNameFB componentsSeparatedByString:@" "];
              //    return fullNameFB;
              rqst.requestLocationTitle = [listDescUser objectAtIndex:0];//[PFUser currentUser].username;
              
              if (self.scSupplyDemand.selectedSegmentIndex == 0) {
                  rqst.requestSupplyOrDemand = YES;
                  [mixpanel track:@"Oproep bevestigd.Vraag"];
              } else {
                  rqst.requestSupplyOrDemand = NO;
                  [mixpanel track:@"Oproep bevestigd.Aanbod"];
              }
              rqst.requestUserId = [PFUser currentUser].objectId ;//echt niet self.layerUserId;
              rqst.requestCancelled = false;
              isRequesting = true;
              
#if TARGET_IPHONE_SIMULATOR
              [locaVC startLocalizing];//just calling for test, no DidLocalize expected
              [self saveRequest];
              
              
              
              isRequesting = false;
#else
              [locaVC startLocalizing];
#endif
              
#pragma mark Aanzetten, kan uit voor test push
                  self.textPrice.text = initPrice;
                  self.textItemRequested.text = @"";
                  [self.navigationController popViewControllerAnimated:YES];
          }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Annuleren"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if (self.scSupplyDemand.selectedSegmentIndex == 0) {
                                     [mixpanel track:@"Oproep geannuleerd.Vraag"];
                                 } else {
                                     [mixpanel track:@"Oproep geannuleerd.Aanbod"];
                                 }
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) poqLocationVCDidLocalize:(BOOL)success
{
    NSLog(@"POQRequestVC.didLocalize: Process completed");
    if (isRequesting) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Lokatie gevonden tabVerzoek "];
        [self saveRequest];
        isRequesting = false;
    }
}


- (void) saveRequest
{
    //depr, permissions checked already in postrequest
//    if (locaVC.hasLocationManagerEnabled) {
        [self saveLocation];
//    } else {
//#if TARGET_IPHONE_SIMULATOR
////        NSLog(@"Hello, FB testuser harry ebola!");
//    [self saveLocation];
//#else
//#pragma mark - alertView Request Not Saved
//#endif
//    }
    
    if (![[[PFUser currentUser] objectForKey:@"UserIsBanned"] isEqualToString:@"true"]) {
        
        //determine validity with setting.uren<>Geldig
        NSDate *now = [NSDate date];
        POQSettings *settings = [[self delegate] theSettings];
        NSString *strHrsValid;
        if (rqst.requestSupplyOrDemand) {
            strHrsValid = settings.urenVraagGeldig;
        } else {
            strHrsValid = settings.urenAanbodGeldig;
        }
        int numHrs = [strHrsValid intValue];
        NSDateComponents *hrs = [NSDateComponents new];
        [hrs setHour:numHrs];
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDate *validUntil = [cal dateByAddingComponents:hrs toDate:now options:0];
        rqst.requestExpiration = validUntil;
        
        //set avatar use
        if (![[[PFUser currentUser] objectForKey:@"useAvatar"] isEqualToString:@"false"]){
            rqst.requestAvatarLocation = [[PFUser currentUser] objectForKey: @"profilePictureURL"];
        }
        
        [rqst saveInBackground];
    }
    
    //communicate permissions, promote invite
    if ([[self delegate] needsNotifReg]) {
        [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects:
                                                     @"Invite", @"Notif", nil]];
    } else {
//        if (![[PFUser currentUser] objectForKey:@"seenInviteFBPage"]) {
            [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects:
                                                         @"Invite", nil]];
//        }
    }
    self.tabBarController.selectedIndex = 0;
}

-(void) saveLocation
{
    PFGeoPoint *location = [[PFUser currentUser] objectForKey:@"location"];
    rqst.requestLocation = location; //locaVC.currentPoint;
//    rqst.requestRadius = [[PFUser currentUser] objectForKey:@"sliderUit"];
    NSString *rds =[[[self delegate] theSettings] objectForKey:@"kilometersOmroepBereik"];
    rqst.requestRadius = rds;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField.keyboardType != UIKeyboardTypeNumbersAndPunctuation){
//        int anchorProduct = self.textPrice.heightAnchor - 30;
//        
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y + 100) animated:YES];
//    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.keyboardType != UIKeyboardTypeNumbersAndPunctuation) {
        [self.textPrice becomeFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentOffset.y + 100) animated:YES];
    }
//    else {
//       [self.scrollView setContentOffset:CGPointMake(0, (self.scrollView.contentOffset.y + 100)) animated:YES];
//    }
    
    [textField resignFirstResponder];
    return YES;
}

-(void)dismissKeyboard {
    [self.textItemRequested resignFirstResponder];
    [self.textPrice resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    
    [self.scrollView setDelegate:self];
//    [self.scrollView setDirectionalLockEnabled:YES];
//    self.scrollView.contentSize = CGSizeMake(300, 1000);
//    self.scrollView set
//    self.vwSymbol.hidden = true;
//    self.vwOtherSymbol.hidden = !self.vwSymbol.hidden;
    
    isRequesting = false;
    rqst = [[POQRequest alloc] init];
    
    //show location tool
    locaVC = [[POQLocationVC alloc] init];
    
    [locaVC setDelegate:self];//self delegate
//    [locaVC setDelegate:[self delegate]];
    [locaVC setDescTab:@"Buurt"];
    //todo use io descTab
    [locaVC setTitle:@"Buurt"];
    
    [self addChildViewController:locaVC];
    [self.vwLoca addSubview:locaVC.view];
    [locaVC didMoveToParentViewController:self];
    //compare initial price with textPrice.text to detect it is entered
    initPrice = [NSString stringWithFormat:@"%@", self.textPrice.text];
    self.textPrice.delegate = self;
    self.textPrice.returnKeyType = UIReturnKeyDone;
    
    self.textItemRequested.delegate = self;
    self.textItemRequested.returnKeyType = UIReturnKeyNext;
    self.textItemRequested.placeholder = @"Welk levensmiddel zoek je?";
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:17], NSFontAttributeName,
                                nil];

    [self.scSupplyDemand setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    [self.scSupplyDemand setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    self.btnPost.layer.cornerRadius = 10; // this value vary as per your desire
    self.btnPost.clipsToBounds = YES;
    self.vwPost.layer.cornerRadius = 10;
    self.vwPost.clipsToBounds = YES;
}

- (void) showMapForLocation:(PFGeoPoint *)locaPoint {
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)scSupplyDemandChange:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.textItemRequested.placeholder = @"bijv. M&M's pinda";
        self.lblProdukt.text = @"Welk levensmiddel zoek je?";
        self.lblHdrPrice.text = @"Je budget";
    } else {
        self.textItemRequested.placeholder = @"bijv. zelfgemaakte appeltaart";
        self.lblProdukt.text = @"Wat heb je in de aanbieding?";
        self.lblHdrPrice.text = @"Je prijs";
    }
    
//    self.vwSymbol.hidden = !self.vwSymbol.hidden;
//    self.vwOtherSymbol.hidden = !self.vwSymbol.hidden;
    
//    if (!locaVC.hasLocationManagerEnabled) {
//        [self showPermissionView];
//        return;
//    }
////    [self.textItemRequested becomeFirstResponder];
}
@end

//    if (![self permission2Post]) {
//        [[self delegate] attemptedUnregisteredPostWithVC:self];
//        return;
//    }

//    if ([self hasFullUserPrivilege]) {
//        [[self delegate] attemptedUnregisteredPostWithVC:self];
//    }

//    if (!locaVC.hasLocationManagerEnabled) {
//
//
//        return;
//    }
//- (void)showPermissionView{
//    NSLog(@"showPermissionPage called");
////    POQPermissionVC *
//    permissionVC = [[POQPermissionVC alloc] initWithNibName:@"POQPermissionVC" bundle:nil];
//    permissionVC.modalPresentationStyle = UIModalPresentationNone;
//    [self addChildViewController:permissionVC];
////    [permissionVC didMoveToParentViewController:self];
//    //    permissionVC.view.frame = self.parentViewController.view.frame;
//    //    [[permissionVC view] setFrame:[[self.parentViewController view] bounds]];[[UIScreen mainScreen] bounds]
//    NSLog(@"%f", self.view.frame.origin.x);
//    CGRect rect = CGRectMake(10, -32, 280, 400);
//    [[permissionVC view] setFrame: rect];
//
//    [permissionVC setDelegate:self];
//    [self.view addSubview:permissionVC.view];
//
//    //
////    ChildViewController *child = [[ChildViewController alloc] initWithNibName:nil bundle:nil];
////    [self presentModalViewController:permissionVC animated:YES];
//}//-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
////    UIViewController* viewController = [self.viewControllers objectAtIndex:0];
////    viewController.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
////[self.view setBackgroundColor:   [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.5]];
//    return self;
//}
//-(void) poqPermissionVCDidDecide:(BOOL)success withVC:(UIViewController *)permissionVC{
//    if (success) {
//        NSLog(@"succes.poqPermissionVCDidDecide");
//        //toestemming usert,
//        [[UIApplication sharedApplication] registerForRemoteNotifications] ;
//    } else {
//        NSLog(@"fail.poqPermissionVCDidDecide");
//    }
////    [apermissionVC dismissViewControllerAnimated:NO completion:nil];
////    UIViewController *vc = [self.childViewControllers lastObject];
//    [permissionVC.view removeFromSuperview];
//    [permissionVC removeFromParentViewController];
//}