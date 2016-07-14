//
//  POQActieTVC.h
//  Poq 
//
//  Created by Jeroen Dunselman on 08/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <UIKit/UIKit.h>

//
//@protocol POQActieTVCDelegate <NSObject>
//@required
//- (BOOL) didSelectUnlocalized; //
//- (BOOL) needsLocaReg;
//- (void) didSelectInviteBuurt;
//- (void) didSelectUnregistered;
////- (void) showMapForLocation:(PFGeoPoint *)locaPoint withDistance:(int) distance;
////-(void)showConvoVCForRequest:(POQRequest *)rqst;
//-(void)refreshBuurt;
//@end

@interface POQActieTVC : UITableViewController
//{
//    id <POQActieTVCDelegate> delegate;
//}
@property (nonatomic) NSMutableArray *acties;

@end
