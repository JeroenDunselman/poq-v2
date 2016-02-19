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

@interface POQRequestTVC ()

@end

@implementation POQRequestTVC
@synthesize userpermissionForGPS;

- (void) reloadLocalizedData {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"POQRequestCell" bundle:nil] forCellReuseIdentifier:@"POQRequestCell"];

    //trying to fix moving lbel after select
    // enable automatic row heights in your UITableViewController subclass
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 30.0; // set to whatever your "average" cell height is
//    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.rqsts = [[[POQRequestStore sharedStore] getRqsts] copy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [SVProgressHUD show];
    self.rqsts = [[[POQRequestStore sharedStore] getRqsts] copy];
    [self.tableView reloadData];
//    [self setEditing:NO animated:YES];
    [SVProgressHUD dismiss];
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
    if (self.rqsts.count == 0 || !userpermissionForGPS)
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
    if (myCell == nil) {
        myCell = [[POQRequestCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"POQRequestCell" ];
    }

    if (userpermissionForGPS) {

        if (self.rqsts.count == 0)
        {
            myCell.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
            myCell.lblTitle.text = @"Geen actuele oproepen in de buurt.";
            //prev: @"Kies 'Oproep' om zelf een oproep te plaatsen.";
            myCell.lblSubtitle.text = @"Nodig je vrienden uit voor een leuke buurt.";
            myCell.vwImg.image = [UIImage imageNamed:@"btn invite.png"];
        } else {
            POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
            //lblTitle
            //"[Vervuld: ]<Item>"
            NSString *txtCancelled = @"";
            if (rqst.requestCancelled) {
                myCell.userInteractionEnabled = false;
                txtCancelled = @"Vervuld:";
            }
            NSString *cellText = [[NSString alloc] initWithFormat:@"%@ %@",
                                  txtCancelled, rqst.requestTitle ];
            myCell.lblTitle.text = cellText;
            
            //lblSubtitle DetailText
            NSString *txtDtl = nil;
            //If own request:
            if ([rqst.requestUserId isEqualToString:[PFUser currentUser].objectId]) {
                txtDtl = [[NSString alloc] initWithFormat:@"Mijn verzoek van %@",
                          rqst.textTime];
            } else {
#pragma mark - todo make it work on POQcell
                [myCell setBackgroundColor: [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0]]; //??.backgr
                txtDtl = [[NSMutableString alloc] initWithFormat:@"%@ %@", rqst.textFirstName, rqst.textDistanceRequestToCurrentLocation];
            }
//            myCell.detailTextLabel.text = txtDtl;
            myCell.lblSubtitle.text = txtDtl;
            if (rqst.requestSupplyOrDemand) {
                myCell.vwImg.image = [UIImage imageNamed:@"question.png"];
            } else {
                myCell.vwImg.image = [UIImage imageNamed:@"exclamation.png"];
            }
        }
    } else {
        myCell.vwImg.image = [UIImage imageNamed:@"home anno.png"];
//        myCell.textLabel.text = @"Maak Je Lokatie Bekend";
//        myCell.detailTextLabel.text = @"Oproepen tonen voor lokatie.";
        myCell.lblTitle.text = @"Maak Je Lokatie Bekend";
        myCell.lblSubtitle.text = @"Oproepen tonen voor lokatie.";
    }
    return myCell;
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
- (void)showConvoVCForRequest:(POQRequest *)rqst{
//    POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
    
    ConversationViewController *convoVC = [[ConversationViewController alloc]initWithLayerClient:self.layerClient];
    // Pass the selected object to the new view controller.
    LYRConversation *returnConversation = [rqst requestConversationWithLYRClient:self.layerClient];
    NSError *error = nil;
    NSString *convoTitle = rqst.textFirstMessage;
    LYRMessagePart *part = [LYRMessagePart messagePartWithText: convoTitle];
    NSArray *mA = @[part];
    LYRMessage *msgOpenNegotiation = [self.layerClient newMessageWithParts:mA
                                                                   options:nil
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!userpermissionForGPS) {
#pragma mark - todo toon vwUitleg
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
    
    if (self.rqsts.count == 0) {
#pragma mark - todo bij geen actuele oproepen toon incell “FB vrienden uitnodigen?”

        titleAlert = @"Facebook vrienden uitnodigen?";
        alert =   [UIAlertController
                   alertControllerWithTitle:titleAlert
                   message:@"Er zijn geen actuele oproepen in de buurt.\nHelp mee aan de organische groei van poq door Facebook vrienden uit te nodigen."
                   preferredStyle:UIAlertControllerStyleAlert];
        ok = [UIAlertAction
              actionWithTitle:@"Buurtgenoten Uitnodigen"
              style:UIAlertActionStyleDefault
              handler:^(UIAlertAction * action)
              {
                  [alert dismissViewControllerAnimated:YES completion:nil];
                  [self showInviteFBVC];
              }];
        [alert addAction:cancel];

    } else { //data available
        POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
        //If own request: no convo
        if ([rqst.requestUserId isEqualToString:[PFUser currentUser].objectId]) {
            titleAlert = @"Wil je deze oproep annuleren?"; //was: Bedankt voor deze oproep!
            NSString *alertText = [NSMutableString stringWithFormat:@"[%@] %@", rqst.textTime,
                                         rqst.requestTitle];
            alert =   [UIAlertController
                       alertControllerWithTitle:titleAlert
                       message:alertText
                       preferredStyle:UIAlertControllerStyleAlert];
            ok = [UIAlertAction
                  actionWithTitle:@"Ja, oproep annuleren."
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
#pragma mark - todo optie cancel ondersteunen
                      rqst.requestCancelled = true;
                      [rqst saveInBackground];
                      [alert dismissViewControllerAnimated:YES completion:nil];
                      return;
                  }];
            cancel = [UIAlertAction
                      actionWithTitle:@"Nee, oproep laten bestaan."
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
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
                          [alert dismissViewControllerAnimated:YES completion:nil];
                          [self showConvoVCForRequest:rqst];
                      }];
            } else {
            //Confirm chat
                titleAlert = @"Reageren?";
                alert =   [UIAlertController
                           alertControllerWithTitle:titleAlert
                           message:rqst.textFirstMessage
                           preferredStyle:UIAlertControllerStyleAlert];
                ok = [UIAlertAction
                      actionWithTitle:@"Bevestigen"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                          [self showConvoVCForRequest:rqst];
                      }];
                
                [alert addAction:cancel];
            }
            
        }
    }
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showInviteFBVC{
    POQInviteFBFriendsVC *inviteVC = nil;
    [SVProgressHUD dismiss];
    if (!inviteVC) {
        inviteVC = [[POQInviteFBFriendsVC alloc] initWithNibName:@"POQInviteFBFriendsVC" bundle:nil];
        inviteVC.view.frame = self.view.frame;
    }
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
