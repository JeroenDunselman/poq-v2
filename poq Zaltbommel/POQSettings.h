//
//  POQSettings.h
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 07/03/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import <Parse/Parse.h>

@interface POQSettings : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *urenAanbodGeldig;
@property (nonatomic, retain) NSString *urenVraagGeldig;
@property (nonatomic, retain) NSString *kilometersOmroepBereik;
@property (nonatomic, retain) NSString *aantalOmroepenMaxPerDag;
@property (nonatomic, retain) NSString *typeOmschrijvingSet;
// class methods
+ (NSString *)parseClassName;
@end
