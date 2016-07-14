//
//  POQActie.h
//  Poq 
//
//  Created by Jeroen Dunselman on 05/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
//typedef void(^POQImageBlock)(UIImage *image);

@interface POQActie : PFObject <PFSubclassing> //, MKAnnotation>

//@property (nonatomic, retain) PFFile *promoImg;
@property (nonatomic, retain) NSString *actiePromoID;
@property (nonatomic, retain) NSString *actieAmbaID;
@property (nonatomic, retain) NSString *actieClaimantID;
@property (nonatomic, retain) NSString *actieTijdslot;
//@property (nonatomic) int actieTestTeller;

/*@property (nonatomic) double promoDistance;
 @property (nonatomic, retain) NSDate *promoExpiration;
 @property (nonatomic) BOOL promoValidStatus;
 @property (nonatomic) BOOL promoCancelled; //initial status
 @property (nonatomic, retain) PFGeoPoint *promoLocation;
 @property (nonatomic, retain) NSString *promoRadius;
 @property (nonatomic, retain) NSString *promoUserId;
 @property (nonatomic, retain) NSString *promoLocationTitle;
 @property (nonatomic, retain) NSString *promoAvatarLocation;
 @property (nonatomic, retain) NSString *promoPriceDeliveryLocationUser;
 @property (nonatomic) BOOL promoSupplyOrDemand;*/

+ (NSString *)parseClassName;
//- (UIImage *)actiePromoImage;

@end
