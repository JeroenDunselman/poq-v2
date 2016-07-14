//
//  POQActieTVCell.h
//  Poq 
//
//  Created by Jeroen Dunselman on 12/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POQActieTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgPromo;
@property (weak, nonatomic) IBOutlet UILabel *lblPromoHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblActieAmbaDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblActieClaimantDesc;

@end
