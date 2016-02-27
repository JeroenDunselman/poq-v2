//
//  FirstInstallVC.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 28/10/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import <Parse/Parse.h>
#import "POQLocationVC.h"
//typedef void(^POQSignupBlock)(NSError *error);
@protocol FirstInstallVCDelegate <NSObject>
@required
- (void) poqFirstInstallVCDidSignup;
@end

@interface FirstInstallVC : UIViewController{
    id <FirstInstallVCDelegate> delegate;
}
//<POQLocationVCDelegate>
//-(void) attemptSignupWithBlock:(POQSignupBlock)block;

@property (retain) id delegate;
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) void *loginLayer;
@property (weak, nonatomic) IBOutlet UIView *vwLoca;
@property (nonatomic) void *attemptSignup;
@end
