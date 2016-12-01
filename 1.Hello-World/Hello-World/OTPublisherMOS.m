//
//  OTPublisherMOS.m
//  1.Hello-World
//
//  Created by Charley Robinson on 11/23/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import "OTPublisherMOS.h"
@interface OTPublisherKit ()
- (NSInteger)videoSSRC;
- (NSInteger)audioSSRC;
- (NSString*)statForKey:(NSString*)key lastUpdated:(struct timeval*)lastUpdated;
- (NSArray*)statsKeys;
@end

@implementation OTPublisherMOS {
    __weak OTPublisherKit* _publisher;
    NSTimer* _timer;
    
}

-(instancetype)initWithPublisher:(OTPublisherKit*)publisher
{
    self = [super init];
    if (self) {
        _publisher = publisher;
        _timer =
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                        repeats:YES
                                          block:^(NSTimer * _Nonnull timer)
         {
             [self executePeriodic];
         }];
        
    }
    return self;
}

- (void)stop {
    [_timer invalidate];
}

- (void)executePeriodic
{
    NSArray* keys = [_publisher statsKeys];
    for (NSString* key in keys) {
        NSLog(@"%@: %@", key, [_publisher statForKey:key lastUpdated:nil]);
    }
}

@end
