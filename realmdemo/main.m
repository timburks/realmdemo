//
//  main.m
//  realmdemo
//
//  Created by Tim Burks on 9/13/14.
//  Copyright (c) 2014 Radtastical. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Place : RLMObject
@property NSString *name;
@property float latitude;
@property float longitude;
@property NSString *UUID;
@end

@implementation Place
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        {
            NSLog(@"delete any preexisting objects");
            [realm beginWriteTransaction];
            [realm deleteObjects:[Place allObjects]];
            [realm commitWriteTransaction];
        }
        
        Place *store;
        {
            NSLog(@"add a single place record");
            store = [[Place alloc] init];
            store.name    = @"Palo Alto Apple Store";
            store.latitude = 37.446289;
            store.longitude = -122.160652;
            store.UUID = [[NSUUID new] description];
            [realm beginWriteTransaction];
            [realm addObject:store];
            [realm commitWriteTransaction];
        }
        
        {
            NSLog(@"add lots of random places");
            [realm beginWriteTransaction];
            for (int i = 0; i < 100000; i++) {
                Place *place = [[Place alloc] init];
                place.name    = [NSString stringWithFormat:@"place %d", i];
                place.latitude = store.latitude + (rand() % 1000) / 100.0 - 5.0;
                place.longitude = store.longitude + (rand() % 1000) / 100.0 - 5.0;
                place.UUID = [[NSUUID new] description];
                [realm addObject:place];
            }
            [realm commitWriteTransaction];
        }
        
        {
            NSLog(@"query for all places");
            RLMArray *places = [Place allObjects];
            NSLog(@"found %d places", (int) [places count]);
        }
        
        {
            NSLog(@"query for an identified place");
            NSPredicate *pred = [NSPredicate predicateWithFormat:
                                 @"UUID == %@",
                                 store.UUID];
            RLMArray *places = [Place objectsWithPredicate:pred];
            NSLog(@"found %d identified place", (int) [places count]);
        }
        
        {
            NSLog(@"query for nearby places");
            CGFloat delta = 0.05;
            NSPredicate *pred = [NSPredicate predicateWithFormat:
                                 @"latitude > %@ AND latitude < %@ AND longitude > %@ AND longitude < %@",
                                 @(store.latitude - delta),
                                 @(store.latitude + delta),
                                 @(store.longitude - delta),
                                 @(store.longitude + delta)];
            RLMArray *places = [Place objectsWithPredicate:pred];
            NSLog(@"found %d nearby places", (int) [places count]);
        }
        
    }
    return 0;
}
