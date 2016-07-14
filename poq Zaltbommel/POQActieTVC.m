//
//  POQActieTVC.m
//  Poq 
//
//  Created by Jeroen Dunselman on 08/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQActieTVC.h"
#import "POQActie.h"
#import "POQActie+Promo+Users.h"
#import "POQMsg.h"
#import "Parse/Parse.h"
#import "POQActieTVCell.h"
#import "POQRequestStore.h"
@interface POQActieTVC ()

@end

@implementation POQActieTVC
//@synthesize acties;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"POQActieTVCell" bundle:nil] forCellReuseIdentifier:@"POQActieTVCell"];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [self.acties count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    POQActie_Promo_Users *theActie = [self.acties objectAtIndex:indexPath.row];
    // currentuser can claim this activated promo if..
    if (![theActie.actie.actieAmbaID isEqualToString:[PFUser currentUser].objectId])//..not the amba
    {
        if ([theActie.actie.actieClaimantID isEqualToString:@""])//..and not already claimed
        {
            if ([[POQRequestStore sharedStore] currentUserHasClaimedPromo:theActie.actie.actiePromoID])
            //..and not of promo that currentuser has previously claimed in another POQActie
            {
                NSString *titleAlert = @"Helaas";
                NSString *messageAlert = @"Je hebt dit product al ontvangen.";
                UIAlertController * alert =   [UIAlertController
                                               alertControllerWithTitle:titleAlert
                                               message:messageAlert
                                               preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* ok = nil;
                ok = [UIAlertAction
                      actionWithTitle:@"Jammer"
                      style:UIAlertActionStyleDefault
                      handler:^(UIAlertAction * action)
                      {
                          [alert dismissViewControllerAnimated:YES completion:nil];
                      }];
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                if (![[POQRequestStore sharedStore] currentUserHasPromoted:theActie.actie.actiePromoID]) {
//                    currentUser can claim this POQActie
                    NSString *titleAlert = @"Ophalen?";
                    NSString *messageAlert = [[NSMutableString alloc] initWithFormat:@"Wil je de %@ ophalen? %@ zijn adres is <straat + huisnr>. Je kunt om <tijdstip> het product komen ophalen.", theActie.promo.promoHTML, theActie.amba.username];
                    //                theActie.amba.useradres;
                    //                theActie.actie.usertijdstip;
                    UIAlertController * alert =   [UIAlertController
                                                   alertControllerWithTitle:titleAlert
                                                   message:messageAlert
                                                   preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = nil;
                    ok = [UIAlertAction
                          actionWithTitle:@"Ja, leuk!"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              //currentUser claims activated promo
                              theActie.actie.actieClaimantID = [PFUser currentUser].objectId;
                              theActie.claimant = [PFUser currentUser];
                              [theActie.actie saveInBackground];
                              [self createMsgClaimedActie:theActie];
                              [alert dismissViewControllerAnimated:YES completion:nil];
                          }];
                    [alert addAction:ok];
                    
                    UIAlertAction* cancel = nil;
                    cancel = [UIAlertAction
                              actionWithTitle:@"Oeps, toch niet"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                              }];
                    [alert addAction:cancel];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
#pragma mark - bespreken: verboden te claimen als je voor deze promo al amba was
                    NSString *titleAlert = @"Helaas";
                    NSString *messageAlert = @"Je hebt dit product al gepromoot.";
                    UIAlertController * alert =   [UIAlertController
                                                   alertControllerWithTitle:titleAlert
                                                   message:messageAlert
                                                   preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* ok = nil;
                    ok = [UIAlertAction
                          actionWithTitle:@"Jammer"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action)
                          {
                              [alert dismissViewControllerAnimated:YES completion:nil];
                          }];
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
        } else {
            NSLog(@"Product is geclaimd door %@:", theActie.actie.actieClaimantID);
        }
    } else {
        NSLog(@"Ik promoot dit product");
    }
}

- (void)createMsgClaimedActie:(POQActie_Promo_Users *) theActie {
    POQMsg *theMsg = [[POQMsg alloc] init];
    theMsg.msgFrom = [PFUser currentUser].objectId; //theActie.claimant.username;
    theMsg.msgTo = theActie.actie.actieAmbaID;
//    theMsg.msgTxt = @"hatsiflatsiflo";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
    
    POQActieTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POQActieTVCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell =  [[POQActieTVCell alloc] init];
    }
    //init
    cell.backgroundColor = [UIColor whiteColor];
    cell.lblActieAmbaDesc.text = @"";
    cell.lblActieClaimantDesc.text = @"";
    
    // Configure the cell...
    POQActie_Promo_Users *theAction = [self.acties objectAtIndex:indexPath.row];
    NSString *lblText = [[NSMutableString alloc] initWithFormat:@"%@, %@",
                         theAction.promo.promoProduct,
                         theAction.actie.actiePromoID];
    cell.lblPromoHeader.text = lblText;//myAction.actie.actiePromoID;
    cell.imgPromo.image = theAction.promo.promoImage; // img;
    
    NSLog(@"mijn id:%@", [PFUser currentUser].objectId);
    if ([theAction.actie.actieAmbaID isEqualToString:[PFUser currentUser].objectId]) {
        cell.lblActieAmbaDesc.text = @"Mijn Promo Actie";
        if (![theAction.actie.actieClaimantID isEqualToString:@""]) {
            cell.backgroundColor = [UIColor greenColor];
            lblText = [[NSMutableString alloc] initWithFormat:@"%@, %@",
                       theAction.actie.actieClaimantID,
                       theAction.claimant.username];
        } else {
            cell.backgroundColor = [UIColor orangeColor];
            lblText = @"Nog niet geclaimd";
        }
    } else {
        lblText = [[NSMutableString alloc] initWithFormat:@"%@, %@",
                   theAction.actie.actieAmbaID,
                   theAction.amba.username];
        cell.lblActieAmbaDesc.text = lblText;
        
        if (![theAction.actie.actieClaimantID isEqualToString:@""]) {
            if (![theAction.actie.actieClaimantID isEqualToString:[PFUser currentUser].objectId]) {
                cell.backgroundColor = [UIColor yellowColor];
                lblText = [[NSMutableString alloc] initWithFormat:@"%@, %@",
                       theAction.actie.actieClaimantID,
                       theAction.claimant.username];
            } else {
                cell.backgroundColor = [UIColor greenColor];
                lblText = @"Mijn claim";
            }
                
        } else {
            lblText = @"Claim deze promo!";
        }
       
    }
    cell.lblActieClaimantDesc.text = lblText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 86;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
//[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];

//myAction.actie.actieAmbaID;
//    // Configure the cell...
//    POQActie *myAction = [self.acties objectAtIndex:indexPath.row];
//    cell.lblPromoHeader.text = myAction.actiePromoID;
//    cell.lblActieClaimantDesc.text = myAction.actieClaimantID;
////    UIImage *img = myAction.actiePromoImage;
//    NSLog(@"cell.imgPromo.image");
//    cell.imgPromo.image = myAction.actiePromoImage; // img;
//    if ([myAction.actieAmbaID isEqualToString:[PFUser currentUser].objectId]) {
//        cell.lblActieAmbaDesc.text = @"Mijn Promo Actie";
//
////        ;lblActieAmbaDesc;lblPromoHeader;
//
////        NSLog(@"myAction.actieClaimantID: %@", myAction.actieClaimantID);
////        if ([myAction.actieClaimantID isEqualToString:@""]) {
//        if (myAction.actieClaimantID) {
//            cell.backgroundColor = [UIColor greenColor];
//        } else {
//            cell.backgroundColor = [UIColor orangeColor];
//        }
//    } else {
//        if (myAction.actieClaimantID) {
//            cell.backgroundColor = [UIColor yellowColor];
//        }
//        cell.lblActieAmbaDesc.text = myAction.actieAmbaID;
//    }

