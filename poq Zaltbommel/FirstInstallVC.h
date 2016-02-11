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
@interface FirstInstallVC : UIViewController<POQLocationVCDelegate>
@property (nonatomic) LYRClient *layerClient;
@property (nonatomic) void *loginLayer;
@property (weak, nonatomic) IBOutlet UIView *vwLoca;
@end
