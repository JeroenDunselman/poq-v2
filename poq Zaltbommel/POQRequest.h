//
//  Spot.h
//  StarStruck
//
//  Created by Jeroen Dunselman on 28/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
//#import <Layer/Layerkit.h>
#import <LayerKit/LayerKit.h>
//#import <Atlas/Atlas.h>

//#import <Parse/PFObject+Subclass.h> moved to .m
//#import <MapKit/MapKit.h>

typedef void(^POQCompletionBlock)(BOOL succeeded, NSError *error);
typedef void(^POQImageBlock)(UIImage *image);

@interface POQRequest : PFObject <PFSubclassing> //, MKAnnotation>
@property (nonatomic, retain) PFGeoPoint *requestLocation;
@property (nonatomic, retain) NSString *requestRadius;
@property (nonatomic, retain) NSString *requestUserId;
@property (nonatomic, retain) NSString *requestTitle;
@property (nonatomic, retain) NSString *requestLocationTitle;
@property (nonatomic, retain) NSString *requestPriceDeliveryLocationUser;
//@property (nonatomic, retain) NSString *requestPriceDeliveryLocationAngel;
@property (nonatomic) BOOL requestSupplyOrDemand;
//@property (nonatomic, retain) NSNumber *priceFetch;
//@property (nonatomic, retain) NSNumber *priceBring;
//@property (nonatomic) BOOL requestDeliveryLocationUser;
//@property (nonatomic) BOOL requestDeliveryLocationAngel;
//@property (nonatomic, strong) UIImage *requestImg;
//@property (nonatomic, copy) NSString *fotoID;
//@property (nonatomic, retain) NSDate *requestDate;
//@property (nonatomic, retain) NSString *requestItem;
//@property (nonatomic, retain) NSString *requestComment;
//@property (nonatomic, retain) NSString *requestUser;
//@property (nonatomic, retain) NSNumber *testingNumber;
//@property (nonatomic, retain) CLLocation *spotLocation;
//@property (nonatomic, assign) CLLocationCoordinate2D requestLocation;
// de longitude/latitude coordinaat waar de tag geplaatst is (foto, tekst, anders)
//@property (nonatomic) PFGeoPoint *location;
//@property (nonatomic) CLLocation *coreLocation;
//@property (nonatomic, readonly) CLLocationCoordinate2D coordinate; // nodig voor MKAnnotation

// class methods
+ (NSString *)parseClassName;
- (LYRConversation *) requestConversationWithLYRClient:LYRClient;
- (NSString *)textFirstMessage;
// [TAATag object] is the standaard ini tialiser!
//+ (instancetype) randomTag;

// instance methods
//- (void) postTagWithBlock:(POQCompletionBlock)block;
//
//- (void) postTag;
//- (PFFile*) saveFotoWithBlock:(POQCompletionBlock)block;
//- (void) fotoWithBlock:(POQImageBlock)block;        // async versie


@end
