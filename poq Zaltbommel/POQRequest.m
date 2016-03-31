
//  Created by Jeroen Dunselman on 28/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQRequest.h"
#import "POQRequestStore.h"
#import <Parse/PFObject+Subclass.h> //moved from .h

@implementation POQRequest

@dynamic requestLocationTitle, requestTitle,  requestPriceDeliveryLocationUser, requestSupplyOrDemand, requestUserId, requestLocation, requestRadius,
    requestCancelled, requestValidStatus, requestExpiration, requestAvatarLocation, requestDistance, requestImgAvatar;

double distance;

#pragma getters and setters

+ (NSString *)parseClassName
{
    return @"POQRequest";
}

- (BOOL) requestIsOwnRequest{
    return [self.requestUserId isEqualToString:[PFUser currentUser].objectId];
}

- (NSString *)requestAnnoType{
    //                currentusers own rqst
    if (self.requestIsOwnRequest){
        return @"home";
    } else if (self.requestCancelled) {
        return @"poqRqstCancelled";
    } else if ([self requestSupplyOrDemand]) {
        return @"poqRqstDemand";
    } else {
        return @"poqRqstSupply";
    }
//home; poquser; poqRqstSupply; poqRqstDemand; poqRqstCancelled
//    return @"hatseflats";
}

- (UIImage *)requestImgAvatar {
    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.requestUserId]];
    UIImage *avatar = [[UIImage alloc] initWithContentsOfFile:filePath];
    return avatar;
}

- (BOOL) requestValidStatus {
    //    Am I still a valid request?
    POQRequest *updatedRequest = [[POQRequestStore sharedStore]
                                  getRequestWithUserId:self.requestUserId
                                  createdAt:self.createdAt];
    if (updatedRequest) {
        return !updatedRequest.requestCancelled;
    } else {
        return true;
    }
}

//- (NSString *) textDistanceToLocation: (PFGeoPoint *) location {
//    return @"4.9km";
//}
-(double)requestDistance{
    if (!distance) {
        distance = [self distanceFromCurrentPOQUser ];
    }
    return distance;
}

- (double)distanceFromCurrentPOQUser {
    PFGeoPoint *ptCurrent = [[PFUser currentUser] objectForKey:@"location"];
    PFGeoPoint *ptRqst = self.requestLocation;
    double distanceDouble  = [ptCurrent distanceInKilometersTo:ptRqst];
    return distanceDouble;
}

- (NSString *)textDistanceRequestToCurrentLocation {
    NSString *result = [[NSString alloc] initWithFormat:@"[%.1f km]",[self distanceFromCurrentPOQUser ]];
//    NSLog(@"Distance in kilometers: %@",result);
    return result;
}

- (NSString *) textFullName{// FirstName {
    //requestLocationTitle stores the FB fullname
    NSString *fullNameFB  =  [self requestLocationTitle];
    //split it to maybe get firstname from it
    NSArray *listDescUser = [fullNameFB componentsSeparatedByString:@" "];
//    return fullNameFB;
    return [listDescUser objectAtIndex:0];
}
    
- (NSString *) textTime{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"] ; //@"yyy-MM-dd"];
    return [df stringFromDate:self.createdAt];
}

- (NSString *) textFirstMessage {
//    NSLog(@"prijs: %@", self.requestPriceDeliveryLocationUser);
    if (self.requestSupplyOrDemand) {
        /*vraag = Hoi <oproeper>! <naam reageerder> heeft <naam product> voor <prijs>voor je. Hier kun je met elkaar overleggen. */
        NSString *msg = [[NSString alloc] initWithFormat:@"'Hoi %@! %@ heeft %@ voor %@ voor je.'",
                         self.requestLocationTitle,
                         [PFUser currentUser].username,
                         self.requestTitle,
                         self.requestPriceDeliveryLocationUser];
        return msg;
    } else {
        /*aanbod = Hoi <oproeper>! <naam reageerder> heeft interesse in je <naam product> voor <prijs>. Hier kun je met elkaar overleggen. */
        NSString *msg = [[NSString alloc] initWithFormat:@"'Hoi %@! %@ heeft interesse in je %@ voor %@.'",
                         self.requestLocationTitle,
                         [PFUser currentUser].username,
                         self.requestTitle,
                         self.requestPriceDeliveryLocationUser];
        return msg;
    }
}

-(LYRConversation *) requestConversationWithLYRClient:(LYRClient *)layerClient{
    LYRConversation *returnConversation = nil;
    // Fetch conversation between
//    1:authenticated user,
//    2:supplied requester-user
//    3:admin
    NSMutableArray *userSet = [[NSMutableArray alloc] init];
    [userSet addObject:layerClient.authenticatedUserID];
    NSError *error;
    //add admin if not authenticatedUser
    NSString *adminId = @"";
    adminId = [PFCloud callFunction:@"getPoqChatBotId" withParameters:nil error:&error];
    if (!error) {
        if (![layerClient.authenticatedUserID isEqualToString: adminId] &&
            ![adminId isEqualToString:@""]) {
            [userSet addObject:adminId];
        }
    }
    if (self.requestUserId) {
        [userSet addObject:self.requestUserId];
    }
    NSSet *participants = [userSet copy];
    
    //Query for existing convo
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" predicateOperator:LYRPredicateOperatorIsEqualTo value:participants];
    error = nil;
    NSOrderedSet *conversations = [layerClient executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu conversations with participants %@", conversations.count, participants);
        if (conversations.count > 0) {
            returnConversation = [conversations objectAtIndex:0];
        } else {
            // Creates and returns a new conversation object
            BOOL deliveryReceiptsEnabled = true; //participants.count <= 5;
            NSDictionary *options = @{LYRConversationOptionsDeliveryReceiptsEnabledKey: @(deliveryReceiptsEnabled)};
            
            returnConversation = [layerClient newConversationWithParticipants:[NSSet setWithArray:userSet] options:options error:&error];
        }
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
    return returnConversation;
}

@end

