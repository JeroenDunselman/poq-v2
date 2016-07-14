//
//  POQPromoTVCell.h
//  Poq 
//
//  Created by Jeroen Dunselman on 27/06/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POQPromoTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIWebView *txtHTML;
@property (weak, nonatomic) IBOutlet UIImageView *imgPromo;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoHeader;

@end
//- (IBAction)btnSelectPromo:(id)sender;