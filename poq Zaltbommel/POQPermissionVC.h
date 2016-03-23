//
//  POQPermissionVC.h
//  POQPermission
//
//  Created by Jeroen Dunselman on 17/02/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol POQPermissionVCDelegate <NSObject>
@required
- (void) poqPermissionVCDidDecide: (BOOL)success withVC:(UIViewController *)permissionVC;
@end

@interface POQPermissionVC : UIViewController
{
    id <POQPermissionVCDelegate> delegate;
}
@property BOOL hasLocationManagerEnabled;
@property (retain) id delegate;

@property (weak, nonatomic) IBOutlet UITextView *txtPermission;
@property (weak, nonatomic) IBOutlet UIImageView *vwTypeLogo;
@property (weak, nonatomic) IBOutlet UIButton *btnAccept;
@property (weak, nonatomic) NSString *permissionPage;
- (IBAction)btnAccept:(id)sender;
- (IBAction)btnDecline:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *vwFB;
@property (weak, nonatomic) IBOutlet UIButton *btnDecline;

@end



