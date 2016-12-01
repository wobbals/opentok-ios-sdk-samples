//
//  OTSubscriberMOS.m
//  1.Hello-World
//
//  Created by Charley Robinson on 11/23/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import "OTSubscriberMOS.h"
struct otk_subscriber;
@interface OTSubscriberKit ()
@property(readonly) struct otk_subscriber* otkitSubscriber;
- (NSInteger)videoSSRC;
- (NSString*)statForKey:(NSString*)key lastUpdated:(struct timeval*)lastUpdated;
- (NSArray*)statsKeys;
@end
void otk_subscriber_dump_stats(struct otk_subscriber *subscriber);
void otk_subscriber_gather_stats(struct otk_subscriber *subscriber);

@implementation OTSubscriberMOS {
    __weak OTSubscriberKit* _subscriber;
    NSTimer* _timer;
    
    NSInteger _lastBytesReceived;
    struct timeval _statsLastUpdated;
}

-(instancetype)initWithSubscriber:(OTSubscriberKit*)subscriber
{
    self = [super init];
    if (self) {
        _subscriber = subscriber;
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
    NSInteger ssrc = [_subscriber videoSSRC];
    NSArray* keys = [_subscriber statsKeys];
    for (NSString* key in keys) {
        NSLog(@"%@: %@", key, [_subscriber statForKey:key lastUpdated:nil]);
    }
    struct timeval lastUpdated;
    NSString* bytesReceivedStr =
    [_subscriber statForKey:[NSString stringWithFormat:@"ssrc.%ld.bytesReceived", ssrc]
             lastUpdated:&lastUpdated];
    NSString* frameWidthStr =
    [_subscriber statForKey:[NSString stringWithFormat:@"ssrc.%ld.googFrameWidthReceived", ssrc]
             lastUpdated:nil];
    NSString* frameHeightStr =
    [_subscriber statForKey:[NSString stringWithFormat:@"ssrc.%ld.googFrameHeightReceived", ssrc]
             lastUpdated:nil];
    NSString* frameRateStr =
    [_subscriber statForKey:[NSString stringWithFormat:@"ssrc.%ld.googFrameRateReceived", ssrc]
             lastUpdated:nil];
    NSInteger bytesReceived = [bytesReceivedStr integerValue];
    NSInteger frameWidth = [frameWidthStr integerValue];
    NSInteger frameHeight = [frameHeightStr integerValue];
    NSInteger frameRate = [frameRateStr integerValue];
    
    if (lastUpdated.tv_sec != _statsLastUpdated.tv_sec) {
        NSInteger frameSize = frameWidth * frameHeight;
        NSTimeInterval interval =
        (lastUpdated.tv_sec + ((1.0 / USEC_PER_SEC) * lastUpdated.tv_usec)) -
        (_statsLastUpdated.tv_sec + ((1.0 / USEC_PER_SEC) * _statsLastUpdated.tv_usec));
        
        [self calculateStatsWithFrameSize:frameSize
                                frameRate:frameRate
                                 interval:interval
                                byteCount:(bytesReceived - _lastBytesReceived)];
        //NSLog(@"video bps: %ld", bitsPerSecond);
        
        _statsLastUpdated = lastUpdated;
        _lastBytesReceived = bytesReceived;
    }
    
    // force gather stats
    //otk_subscriber_gather_stats(_subscriber.otkitSubscriber);
    //otk_subscriber_dump_stats(_subscriber.otkitSubscriber);
}

#define MIN_SCORE 1
#define MAX_SCORE 5
#define MIN_SCORE_BPP 0.01953125
#define MAX_SCORE_BPP 0.104166667

- (void)calculateStatsWithFrameSize:(NSInteger)frameSize
                          frameRate:(NSInteger)frameRate
                           interval:(double)interval
                          byteCount:(NSInteger)byteCount
{
    double bitsReceived = 8 * byteCount;
    NSInteger framesReceived = frameRate * interval;
    NSInteger pixelsReceived = framesReceived * frameSize;
    double bitsPerPixel = bitsReceived / pixelsReceived;
    double m = ((MAX_SCORE_BPP - MIN_SCORE_BPP) / (MAX_SCORE - MIN_SCORE));
    double b = (m * MIN_SCORE) - MIN_SCORE_BPP;
    double score = (bitsPerPixel - b) / m;
    // don't pass scoring boundaries
    score = MIN(MAX_SCORE, score);
    score = MAX(MIN_SCORE, score);
    
    NSLog(@"bpp: %f score: %f", bitsPerPixel, score);
}

@end
