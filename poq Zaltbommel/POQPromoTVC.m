//
//  PoqPromoTVC.m
//  Poq 
//
//  Created by Jeroen Dunselman on 27/06/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQPromoTVC.h"
#import "POQPromoTVCell.h"
#import "POQRequestStore.h"

@interface POQPromoTVC ()

@end

@implementation POQPromoTVC
@synthesize delegate;
NSArray *arrPromos;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"POQPromoTVCell" bundle:nil] forCellReuseIdentifier:@"POQPromoTVCell"];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    arrPromos = [[POQRequestStore sharedStore] getPromos];
//    POQPromo *aPromo = [arrPromos objectAtIndex:0];
    //NSString *txt = [aPromo promoHTML];
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
    return [arrPromos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 147;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* -controle of gekozen promo valid is voor currentuser, niet als AdvertisedByCurrentUser*/
    POQPromo *thePromo = [arrPromos objectAtIndex:indexPath.row];
    if (![thePromo AdvertisedByCurrentUser])
    {
        /*         -alertview "wil je <product> delen met je buren?> "-->"annuleren"en "ja leuk  */
        NSString *titleAlert = @"Delen?";
        NSString *messageAlert = @"wil je <product> delen met je buren?";
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
                  /*-eventVw "Leuk dat je meedoet! Wanneer ben je thuis?" <selecteer hele dag of tijdsinterval>
                   -postcode + ophaal tijdstip + actie + adres + username worden op backend bij de oproep geplaatst
                   -toestemming notifs	"<b>Wil je weten als een buur reageert?</b> <break> Wij sturen je een bericht als iemand interesse heeft in je <product>	actieproduct naam ophalen, als nog niet is gezegd, elke keer oproepen bij delen*/
                  POQActie *myAction = [[POQActie alloc] init];
                  myAction.actieAmbaID = [PFUser currentUser].objectId;
                  myAction.actiePromoID = thePromo.objectId;
                  myAction.actieClaimantID = @"";
                  [myAction saveInBackground];
                  [alert dismissViewControllerAnimated:YES completion:nil];
              }];
        [alert addAction:ok];
        
        UIAlertAction* cancel = nil;
        cancel = [UIAlertAction
              actionWithTitle:@"Annuleren"
              style:UIAlertActionStyleDefault
              handler:^(UIAlertAction * action)
              {
                  [alert dismissViewControllerAnimated:YES completion:nil];
              }];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self showAlertVwAlreadyAdvertisingPromo];
//        NSLog(@"AdvertisedByCurrentUser");
    }
}

-(void)showAlertVwAlreadyAdvertisingPromo
{
    NSString *titleAlert = @"showAlertVwAlreadyAdvertisingPromo";
    NSString *messageAlert = @"showAlertVwAlreadyAdvertisingPromo.messageAlert";
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POQPromoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POQPromoTVCell" forIndexPath:indexPath];
    POQPromo *thePromo = [arrPromos objectAtIndex:indexPath.row];
//    cell.textLabel.text = thePromo.promoHTML;
    [cell.txtHTML loadHTMLString:thePromo.promoHTML baseURL:nil];
    UIImage *anImg = [thePromo promoImage];
    [cell.imgPromo setImage:anImg];
    cell.lblPromoHeader.text = thePromo.promoProduct;
//    thePromo.promoStockLevel
    
    // Configure the cell...
//    if (indexPath.row == 0) {
//        cell.textLabel.text = @"Een promo.";
//        cell.imageView.image = [UIImage imageNamed:@"Screen Shot 2016-06-27 at 15.43.21.png"];
//
//    } else {
//        cell.textLabel.text = @"Nog een promo.";
//        cell.imageView.image = [UIImage imageNamed:@"Screen Shot 2016-06-27 at 15.43.11.png"];
//
//    }
   
    return cell;
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
