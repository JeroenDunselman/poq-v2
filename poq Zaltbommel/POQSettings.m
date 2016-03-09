//
//  POQSettings.m
//  poq Zaltbommel
//
//  Created by Jeroen Dunselman on 07/03/16.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

#import "POQSettings.h"

@implementation POQSettings
@dynamic urenAanbodGeldig, urenVraagGeldig, kilometersOmroepBereik, aantalOmroepenMaxPerDag, typeOmschrijvingSet;

+ (NSString *)parseClassName
{
    return @"POQSettings";
}
@end
