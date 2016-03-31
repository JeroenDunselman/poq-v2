//
//  POQRequestCell.h
//  
//
//  Created by Jeroen Dunselman on 06/11/15.
//
//

#import <UIKit/UIKit.h>

@interface POQRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *vwImg;

@property (weak, nonatomic) IBOutlet UILabel *lblTypeRequest;
@end
