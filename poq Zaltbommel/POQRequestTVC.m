//
//  POQRequestTVC.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 06/11/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "Parse/Parse.h"
#import "POQRequestTVC.h"
#import "POQRequestCell.h"
#import "POQRequestVC.h"
#import "POQInviteFBFriendsVC.h"
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "Mixpanel.h"
@interface POQRequestTVC ()

@end

@implementation POQRequestTVC
@synthesize delegate;
//userpermissionForGPS
//CLLocationManager *locationManagerTVC;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    UIViewController* viewController = [self.viewControllers objectAtIndex:0];
//    viewController.tabBarItem.image = [UIImage imageNamed:@"chat.png"];
    
//  set to clear color
//    [self.view setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.0]];
    return self;
}

- (void *) reloadLocalizedData {
    [self reloadPOQData];//[self.tableView reloadData];
    return nil;
}

- (void)reloadPOQData
{
    [[self delegate] refreshBuurt];
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"POQRequestCell" bundle:nil] forCellReuseIdentifier:@"POQRequestCell"];

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadPOQData)
                  forControlEvents:UIControlEventValueChanged];
    
    //trying to fix moving lbel after select
    // enable automatic row heights in your UITableViewController subclass
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 30.0; // set to whatever your "average" cell height is
//    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
//    locationManagerTVC = [[CLLocationManager alloc] init];
//    [locationManagerTVC setDelegate:self];
//    self.rqsts = [[[POQRequestStore sharedStore] getRqsts] copy];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"\nHee joh! TVCdidChangeAuthorizationStatus");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
//    [SVProgressHUD show];
//#pragma mark - door buurtvw willappear laten afhandelen
//    self.rqsts = [[[POQRequestStore sharedStore] getRqsts] copy];
//    [self.tableView reloadData];
////    [self setEditing:NO animated:YES];
//    [SVProgressHUD dismiss];
        [self setEditing:NO animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    // Detemine if it's in editing mode
//    if (self.tableView.editing)
//    {
//        return UITableViewCellEditingStyleDelete;
//    }
    
    return UITableViewCellEditingStyleNone;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.rqsts.count == 0 || [[self delegate] needsLocaReg] || [[self delegate] needsFBReg])
    {
        return 1;
    }
    else
    {
        return [self.rqsts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    POQRequestCell *myCell = [tableView dequeueReusableCellWithIdentifier:@"POQRequestCell" ];
    UIImage *theImg = nil;
    myCell.vwImg.image = nil;
    [myCell.vwImg setContentMode:UIViewContentModeScaleAspectFit];
    if (myCell == nil) {
        myCell = [[POQRequestCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"POQRequestCell" ];
    }
    myCell.userInteractionEnabled = true;
    if (!
        ([[self delegate] needsLocaReg] ||
         [[self delegate] needsFBReg])
        ) {

        if (self.rqsts.count == 0)
        {
//            myCell.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.5];
            myCell.lblTitle.text = @"Geen actuele oproepen in de buurt.";
            myCell.lblSubtitle.text = @"Nodig je vrienden uit voor een leuke buurt.";
            theImg = [UIImage imageNamed:@"perm invite.png"];
        } else {
            POQRequest *rqst = [self.rqsts objectAtIndex:indexPath.row];
            //[[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
            
            NSString *requestType = @"";
            if (rqst.requestSupplyOrDemand) {
                requestType = @"Vraag";
                
            } else {
                requestType = @"Aanbod";
            }
            theImg = [UIImage imageNamed:requestType];
            myCell.lblTypeRequest.text = requestType;
            
            //            init view
            myCell.vwImg.layer.borderWidth = 0.0f;
            myCell.vwImg.layer.borderColor = [UIColor blackColor].CGColor;
            myCell.vwImg.layer.cornerRadius = 0;
            //                myCell.vwImg.frame.size.width / 2;
            myCell.vwImg.clipsToBounds = NO;
            myCell.vwImg.contentMode = UIViewContentModeScaleAspectFit;
            
            NSString *txtCancelled = @"";
            if (rqst.requestCancelled) {
//                myCell.userInteractionEnabled = false;
                txtCancelled = @"Vervuld: ";
                theImg = [UIImage imageNamed:@"CancelledRequest"];
            } else if ([self imgAvatarForUserId:rqst.requestUserId] && rqst.requestAvatarLocation   ) {
                theImg = [self imgAvatarForUserId:rqst.requestUserId];
                myCell.vwImg.layer.borderWidth = 1.0f;
                myCell.vwImg.contentMode = UIViewContentModeScaleAspectFill;
                myCell.vwImg.layer.cornerRadius = myCell.vwImg.frame.size.width / 2;
                myCell.vwImg.clipsToBounds = YES;
            }
            
            NSString *txt = rqst.requestTitle;
            txt = [txt stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[txt substringToIndex:1] uppercaseString]];
            
            NSString *cellText = [[NSString alloc] initWithFormat:@"%@%@",
                                  txtCancelled, txt ];
            myCell.lblTitle.text = cellText;
            
            //lblSubtitle DetailText
            NSString *txtDtl = nil;
            if ([rqst requestIsOwnRequest]) {
                txtDtl = [[NSString alloc] initWithFormat:@"Mijn verzoek van %@",
                          rqst.textTime];
            } else {
#pragma mark - issue: niet consequent zetten van bgclr van hergebruikte cel
//                [myCell setBackgroundColor: [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:0.5]]; //??.backgr
                txtDtl = [[NSMutableString alloc] initWithFormat:@"%@ %@", rqst.textFullName, rqst.textDistanceRequestToCurrentLocation];
            }
//            myCell.detailTextLabel.text = txtDtl;
            myCell.lblSubtitle.text = txtDtl;
        }
    } else {
#pragma mark - todo ook needsFBReg
        if ([[self delegate] needsLocaReg]) {
            theImg = [UIImage imageNamed:@"perm locatie.png"];
            myCell.lblTitle.text = @"Maak Je Locatie Bekend";
            myCell.lblSubtitle.text = @"Oproepen tonen voor jouw buurt.";
            myCell.lblTypeRequest.text = @"";
        } else if ([[self delegate] needsFBReg]) {
            theImg = [UIImage imageNamed:@"perm facebook.png"];
            myCell.lblTitle.text = @"Log in via Facebook";
            myCell.lblSubtitle.text = @"Oproepen tonen voor gebruiker.";
            myCell.lblTypeRequest.text = @"";
        }
    }
    myCell.vwImg.image = theImg;
    return myCell;
}

-(UIImage *) imgAvatarForUserId:userId {
    NSMutableDictionary *theDict = [[POQRequestStore sharedStore] avatars];
    //    NSObject *avatar = theDict[self.pathAvatar] ;
    if (!theDict[userId]){ //() {r
#pragma mark - todo add userId to theDict
        return nil; //[self imgForType];
    } else {
        if([theDict[userId] isKindOfClass:[NSString class]]){
            return nil; //[self imgForType];
        } else {
            return theDict[userId];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //komp zelfde neer
    if ([[self delegate] needsLocaReg]) {
#pragma mark - todo toon vwUitleg
        [[self delegate] didSelectUnlocalized];
        return;
    } else if ([[self delegate] needsFBReg]){
        [[self delegate] didSelectUnregistered];
        return;
    }
    
    NSString *titleAlert = @"";
    UIAlertAction* ok = nil;
    //    NSString *messageAlert = @""; //rqst.textFirstMessage;
    UIAlertController * alert = nil;
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Annuleren"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    if (self.rqsts.count == 0) {
#pragma mark -  geen actuele oproepen 
        [[self delegate] didSelectInviteBuurt];
        
        [mixpanel track:@"Buurt geen actuele oproepen didSelectInvite"];
        
        return;
//        [[self delegate] requestPermissionWithTypes:[NSMutableArray arrayWithObjects:@"Invite", nil]];
//        return;
//        titleAlert = @"Facebook vrienden uitnodigen?";
//        alert =   [UIAlertController
//                   alertControllerWithTitle:titleAlert
//                   message:@"Er zijn geen actuele oproepen in de buurt.\nHelp mee aan de organische groei van poq door Facebook vrienden uit te nodigen."
//                   preferredStyle:UIAlertControllerStyleAlert];
//        ok = [UIAlertAction
//              actionWithTitle:@"Buurtgenoten Uitnodigen"
//              style:UIAlertActionStyleDefault
//              handler:^(UIAlertAction * action)
//              {
//                  [alert dismissViewControllerAnimated:YES completion:nil];
//                  [self showInviteFBVC];
//              }];
//        [alert addAction:cancel];
        
    } else { //data available
        POQRequest *rqst = [self.rqsts objectAtIndex:indexPath.row];
//        [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
        [[self delegate] showMapForLocation:rqst.requestLocation withDistance:500];
        //If own request: no convo
        
        if ([rqst requestIsOwnRequest] && !rqst.requestCancelled) {
            titleAlert = @"Wil je deze oproep annuleren?"; //was: Bedankt voor deze oproep!
            NSString *alertText = [NSMutableString stringWithFormat:@"[%@] %@", rqst.textTime,
                                   rqst.requestTitle];
            alert =   [UIAlertController
                       alertControllerWithTitle:titleAlert
                       message:alertText
                       preferredStyle:UIAlertControllerStyleAlert];
            ok = [UIAlertAction
                  actionWithTitle:@"Ja, Annuleren."
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
#pragma mark - todo optie cancel ondersteunen
                      rqst.requestCancelled = true;
                      [rqst saveInBackground];
                      [alert dismissViewControllerAnimated:YES completion:nil];
                      [mixpanel track:@"Ja, Verzoek annuleren"];
                      
                      return;
                  }];
            cancel = [UIAlertAction
                      actionWithTitle:@"Nee, Laten Bestaan."
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [mixpanel track:@"Nee, Verzoek Laten Bestaan"];
                          
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }];
            [alert addAction:cancel];
        } else { //user taps someones request
#pragma mark - todo check: als requestCancelled “bedankt, maar bedankt”, reloadData
            //            anders initConvo
            //has request been cancelled since loading?
            
            //testing query
            //            POQRequest *updatedRequest = [[POQRequestStore sharedStore]
            //                                          getRequestWithUserId:rqst.requestUserId
            //                                          createdAt:rqst.createdAt];
            //
            if (![rqst requestValidStatus]) {
                titleAlert = @"Bedankt voor je reactie!";
                alert =   [UIAlertController
                           alertControllerWithTitle:titleAlert
                           message:@"Dit verzoek is inmiddels vervuld."
                           preferredStyle:UIAlertControllerStyleAlert];
                ok = [UIAlertAction
                      actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [mixpanel track:@"Dit verzoek is inmiddels vervuld."];
                          
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }];
            } else {
                //Confirm chat
                titleAlert = @"Gesprek beginnen?";
                alert =   [UIAlertController
                           alertControllerWithTitle:titleAlert
                           message:rqst.textFirstMessage
                           preferredStyle:UIAlertControllerStyleAlert];
                ok = [UIAlertAction
                      actionWithTitle:@"Bericht Versturen"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [mixpanel track:@"Gesprek beginnen?:Bericht Versturen"];
                          [alert dismissViewControllerAnimated:YES completion:nil];
                          [[[self delegate] delegate] showConvoVCForRequest:rqst];
                      }];
                
                cancel = [UIAlertAction
                          actionWithTitle:@"Annuleren"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [mixpanel track:@"Gesprek beginnen?:Annuleren"];
                              [alert dismissViewControllerAnimated:YES completion:nil];
                          }];
                [alert addAction:cancel];
            }
            
        }
    }
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
    return 48;
}

//depr -> appdelegate
- (void)showConvoVCForRequest:(POQRequest *)rqst{
//    POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
    
    ConversationViewController *convoVC = [[ConversationViewController alloc]initWithLayerClient:self.layerClient];
    // Pass the selected object to the new view controller.
    LYRConversation *returnConversation = [rqst requestConversationWithLYRClient:self.layerClient];
    NSError *error = nil;
    NSString *convoTitle = [NSString stringWithFormat:@"%@, %@", rqst.requestLocationTitle, rqst.requestTitle];;
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: rqst.textFirstMessage];
    NSArray *mA = @[part];
    // Configure the push notification text to be the same as the message text
//    LYRMessage *message = [layerClient newMessageWithParts:@[part] options:@{LYRMessagePushNotificationAlertMessageKey: messageText} error:nil];
    LYRPushNotificationConfiguration *defaultConfiguration = [LYRPushNotificationConfiguration new];
    defaultConfiguration.alert = rqst.textFirstMessage;
    defaultConfiguration.sound = @"layerbell.caf"; //pushSound;

    NSDictionary *options = @{ LYRMessageOptionsPushNotificationConfigurationKey: defaultConfiguration };
    
    LYRMessage *msgOpenNegotiation = [self.layerClient newMessageWithParts:mA
                                                        options:options
                                                        error:&error];
    NSDictionary *metadata = @{@"title" : convoTitle,
                               @"theme" : @{
                                       @"background_color" : @"335333",
                                       @"text_color" : @"F8F8EC",
                                       @"link_color" : @"21AAE1"},
                               @"created_at" : @"Dec, 01, 2014",
                               @"img_url" : @"/path/to/img/url"};
    [returnConversation setValuesForMetadataKeyPathsWithDictionary:metadata merge:YES];
    [returnConversation sendMessage:msgOpenNegotiation error:&error];
    
    convoVC.conversation = returnConversation;
    convoVC.displaysAddressBar = YES;
    
    // Push the view controller.
    [self.navigationController pushViewController:convoVC animated:YES];
}

- (void)showInviteFBVC{
    POQInviteFBFriendsVC *inviteVC = nil;
//    [SVProgressHUD dismiss];
//?    if (!inviteVC) {
        inviteVC = [[POQInviteFBFriendsVC alloc] initWithNibName:@"POQInviteFBFriendsVC" bundle:nil];
        inviteVC.view.frame = self.view.frame;
//    }
    [self.navigationController pushViewController:inviteVC animated:YES];
}

//- (void)presentPoqrequestVC
//{
//    POQRequestVC *rqstVC = nil;
//    [SVProgressHUD dismiss];
//    if (!rqstVC) {
//        rqstVC = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
//        rqstVC.layerUserId = self.layerClient.authenticatedUserID;
//        rqstVC.view.frame = self.view.frame;
//    }
//    [self.navigationController pushViewController:rqstVC animated:YES];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
