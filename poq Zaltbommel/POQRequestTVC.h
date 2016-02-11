//
//  POQRequestTVC.h
//  Poq Requester
//
//  Created by Jeroen Dunselman on 06/11/15.
//  Copyright © 2015 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerKit/LayerKit.h>
#import "POQRequestStore.h"
#import "POQLocationVC.h"
@interface POQRequestTVC : UITableViewController 
@property (nonatomic) NSMutableArray *rqsts;
@property (nonatomic) LYRClient *layerClient;
- (void) reloadLocalizedData;
@end
