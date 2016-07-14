//
//  POQPromo.h
//  Poq 
//
//  Created by Jeroen Dunselman on 04/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
typedef void(^POQImageBlock)(UIImage *image);

@interface POQPromo : PFObject <PFSubclassing> //, MKAnnotation>

@property (nonatomic, retain) PFFile *promoImg;
@property (nonatomic, retain) NSString *promoHTML;
@property (nonatomic, retain) NSString *promoProduct;
@property (nonatomic) NSInteger *promoStockLevel;
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
- (UIImage *)promoImage;
- (BOOL) AdvertisedByCurrentUser;
@end
