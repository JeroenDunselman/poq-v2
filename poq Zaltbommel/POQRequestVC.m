//
//  Created by Jeroen Dunselman on 02/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQRequestVC.h"
#import "Parse/Parse.h"
#import "POQRequest.h"
@implementation POQRequestVC

#pragma mark -
#pragma mark UIViewController
static NSString *initPrice;


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

- (IBAction)postRequest:(id)sender {
    //Check required Item, Price
    if (self.textItemRequested.text.length == 0) {
        [self alertRequestNotPushed];
        return;
    }
    if ([self.textPrice.text isEqualToString:initPrice]) {
        [self alertRequestNotPushed];
        return;
    }
    
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
              POQRequest *rqst = [[POQRequest alloc] init];
              rqst = [POQRequest object];
              rqst.requestTitle = self.textItemRequested.text;
              rqst.requestPriceDeliveryLocationUser = self.textPrice.text;
              rqst.requestLocationTitle = [PFUser currentUser].username;
              if (self.scSupplyDemand.selectedSegmentIndex == 0) {
                  rqst.requestSupplyOrDemand = YES;
              } else {
                  rqst.requestSupplyOrDemand = NO;
              }
              rqst.requestUserId = self.userId;
              [rqst saveInBackground];
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
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.keyboardType != UIKeyboardTypeNumbersAndPunctuation) {
        [self.textPrice becomeFirstResponder];
    }
    
    [textField resignFirstResponder];
    return YES;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        self.textItemRequested.placeholder = @"Welk levensmiddel zoek je?";
    } else {
        self.textItemRequested.placeholder = @"Welk levensmiddel bied je aan?";
    }
    [self.textItemRequested becomeFirstResponder];
}
@end
