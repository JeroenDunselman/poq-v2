
//  Created by Jeroen Dunselman on 28/05/15.
//  Copyright (c) 2015 Jeroen Dunselman. All rights reserved.
//

#import "POQRequest.h"
#import <Parse/PFObject+Subclass.h> //moved from .h

@implementation POQRequest

@dynamic requestLocationTitle, requestTitle,  requestPriceDeliveryLocationUser, requestSupplyOrDemand, requestUserId, requestLocation, requestRadius;

#pragma getters and setters

+ (NSString *)parseClassName
{
    return @"POQRequest";
}

- (NSString *)textFirstMessage {
//    NSLog(@"prijs: %@", self.requestPriceDeliveryLocationUser);
    if (self.requestSupplyOrDemand) {
        /*vraag = Hoi <oproeper>! <naam reageerder> heeft <naam product> voor <prijs>voor je. Hier kun je met elkaar overleggen. */
        NSString *msg = [[NSString alloc] initWithFormat:@"Hoi %@! %@ heeft %@ voor %@ voor je. \nHier kun je met elkaar overleggen.",
                         self.requestLocationTitle,
                         [PFUser currentUser].username,
                         self.requestTitle,
                         self.requestPriceDeliveryLocationUser];
        return msg;
    } else {
        /*aanbod = Hoi <oproeper>! <naam reageerder> heeft interesse in je <naam product> voor <prijs>. Hier kun je met elkaar overleggen. */
        NSString *msg = [[NSString alloc] initWithFormat:@"Hoi %@! %@ heeft interesse in je %@ voor %@. \nHier kun je met elkaar overleggen.",
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

