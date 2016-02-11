//
//  POQRequestTVC.m
//  Poq Requester
//
//  Created by Jeroen Dunselman on 06/11/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQRequestTVC.h"
#import "POQRequestCell.h"
#import "POQRequestVC.h"
#import "ConversationViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface POQRequestTVC ()

@end

@implementation POQRequestTVC

- (void) reloadLocalizedData {
    [self.tableView reloadData];
}
//**

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UINib *nib = [UINib nibWithNibName:@"POQRequestCell" bundle:nil];
//    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
//    
    [self.tableView registerNib:[UINib nibWithNibName:@"POQRequestCell" bundle:nil] forCellReuseIdentifier:@"POQRequestCell"];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    if (self.rqsts.count == 0)
    {
        return 1;
    }
    else
    {
        return [self.rqsts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POQRequestCell *myCell = [[POQRequestCell alloc] init];
    myCell = [tableView dequeueReusableCellWithIdentifier:@"POQRequestCell" forIndexPath:indexPath];
    if (self.rqsts.count == 0)
    {
        myCell.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.00 alpha:1.0];
        myCell.textLabel.text = @"Geen actuele oproepen.";
        myCell.detailTextLabel.text = @"Kies 'Plaats Oproep' in hoofdmenu.";
    } else {
        myCell.backgroundColor = [UIColor whiteColor];
        //    myCell.titleLabel = @"";
        POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
        NSString *sOrD = @"Gevraagd: ";
        if (!rqst.requestSupplyOrDemand) {
            sOrD = @"Aangeboden: ";}
//        PFObject *object = ... // A PFObject
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"HH:mm"] ; //@"yyy-MM-dd"];
        NSString *sTime = [df stringFromDate:rqst.createdAt];
//        NSDate *tStamp = rqst.createdAt;
        NSMutableString *cellText = [NSMutableString stringWithFormat:@"[%@] %@ %@", sTime,
                                     sOrD,
                                     rqst.requestTitle];
        myCell.textLabel.text = cellText;
        //    NSMutableString *cellTextDetail = [NSMutableString stringWithFormat:@"Zelf halen: %@", rqst.requestPriceDeliveryLocationUser];
        myCell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"voor %@", rqst.requestPriceDeliveryLocationUser ]; //cellTextDetail;
#pragma mark todo        -buurtcel title: item; subtitle: afstand/voornaam
//        *nieuw
        myCell.textLabel.text = rqst.requestTitle;
//        voornaam substring op space
        myCell.detailTextLabel.text = @"Afstand/Voornaam";
        //* einde nieuw
        if (rqst.requestSupplyOrDemand) {
            myCell.imageView.image = [UIImage imageNamed:@"vraag.png"];
        } else {
            myCell.imageView.image = [UIImage imageNamed:@"aanbod.png"];
        }    //rqst.requestLocationTitle;
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
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath  {
//    return 100;
//}
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
        titleAlert = @"Oproep doen?";
        alert =   [UIAlertController
                   alertControllerWithTitle:titleAlert
                   message:@"BUURT: Als er vandaag oproepen zijn gedaan in de buurt, dan vind je ze hier.\n\nWil je nu zelf een oproep doen?"
                   preferredStyle:UIAlertControllerStyleAlert];
        ok = [UIAlertAction
              actionWithTitle:@"Oproep Doen"
              style:UIAlertActionStyleDefault
              handler:^(UIAlertAction * action)
              {
                  [alert dismissViewControllerAnimated:YES completion:nil];
                  [self presentPoqrequestVC];
              }];
        
        [alert addAction:cancel];
//        [alert addAction:ok];
//        return;
    } else {
        POQRequest *rqst = [[[POQRequestStore sharedStore] rqsts]objectAtIndex:indexPath.row];
        //   messageAlert = rqst.textFirstMessage;
        //    [UIAlertController
        //                                   alertControllerWithTitle:titleAlert
        //                                   message:messageAlert
        //                                   preferredStyle:UIAlertControllerStyleAlert];
        
        if ([rqst.requestUserId isEqualToString:self.layerClient.authenticatedUserID]) {
            //If own request: no convo
            titleAlert = @"Dit is je eigen oproep.";
            alert =   [UIAlertController
                       alertControllerWithTitle:titleAlert
                       message:rqst.requestTitle
                       preferredStyle:UIAlertControllerStyleAlert];
            ok = [UIAlertAction
                  actionWithTitle:@"OK"
                  style:UIAlertActionStyleDefault
                  handler:^(UIAlertAction * action)
                  {
                      [alert dismissViewControllerAnimated:YES completion:nil];
                      return;
                  }];
//            [alert addAction:ok];
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
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)presentPoqrequestVC
{
    POQRequestVC *rqstVC = nil;
    [SVProgressHUD dismiss];
    if (!rqstVC) {
        rqstVC = [[POQRequestVC alloc] initWithNibName:@"POQRequestVC" bundle:nil];
        rqstVC.userId = self.layerClient.authenticatedUserID;
        rqstVC.view.frame = self.view.frame;
    }
    [self.navigationController pushViewController:rqstVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
