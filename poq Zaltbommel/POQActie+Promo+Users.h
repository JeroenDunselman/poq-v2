//
//  POQActie+Promo+Users.h
//  Poq 
//
//  Created by Jeroen Dunselman on 13/07/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "POQActie.h"
#import "POQPromo.h"
#import "Parse/Parse.h"

@interface POQActie_Promo_Users : NSObject
@property (nonatomic, retain) POQActie *actie;
@property (nonatomic, retain) POQPromo *promo;
@property (nonatomic, retain) PFUser *amba;
@property (nonatomic, retain) PFUser *claimant;
@end
