//
//  PFUser+Participant.h
//  Layer-Parse-iOS-Example
//
//  Created by Abir Majumdar on 3/1/15.
//  Copyright (c) 2015 Layer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "PFUser+ATLParticipant.h"
#import "POQRequestStore.h"
@implementation PFUser (ATLParticipant)

- (NSURL *) avatarImageURL{
#pragma mark - todo if useAvatar
    
    BOOL useAvatar = (![[self objectForKey:@"useAvatar"] isEqualToString: @"false"]);
    NSString *theURL = @"";
    if (useAvatar) {
        theURL = [self objectForKey:@"profilePictureURL"];
    }
    return [NSURL URLWithString:theURL];
//    return nil;
}

- (NSString *)firstName
{
      //self.username;
    NSString *name  = self.username;
    //split it to maybe get firstname from it
    NSArray *listDescUser = [name componentsSeparatedByString:@" "];
    return [listDescUser objectAtIndex:0];
}

- (NSString *)lastName
{
    //space used as initial
    return @" "; //return @"Test";
}

- (NSString *)fullName
{
    //fullname shows up in convo
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

- (NSString *)participantIdentifier
{
    return self.objectId;
}

- (UIImage *)avatarImage
{
//   return [[POQRequestStore sharedStore] avatars][self.objectId];
    return nil;
}

- (NSString *)avatarInitials
{// shows up in convo
    return [[NSString stringWithFormat:@"%@%@", [self.firstName substringToIndex:1], [self.lastName substringToIndex:1]] uppercaseString];
}

@end
