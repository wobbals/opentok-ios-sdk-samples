//
//  OTCXProvider.m
//  1.Hello-World
//
//  Created by Charley Robinson on 12/29/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import "OTCXProvider.h"
#import "OTDefaultAudioDevice.h"
#import <OpenTok/OpenTok.h>

@implementation OTCXProvider {
    CXProvider* _provider;

    NSUUID* _currentCallID;
    IncomingCallBlock _incomingCallBlock;

    CXAction* _pendingAction;
    BOOL _outgoing;
}

@synthesize delegate;

+ (instancetype)sharedInstance {
    static OTCXProvider* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[OTCXProvider alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CXProviderConfiguration *config =
        [[CXProviderConfiguration alloc] initWithLocalizedName:@"OTCXProvider"];
        config.ringtoneSound = @"Ringtone.caf";
        UIImage* iconMask = [UIImage imageNamed:@"IconMask"];
        if (iconMask) {
            config.iconTemplateImageData = UIImagePNGRepresentation(iconMask);
        }

        //config.maximumCallGroups = 1;
        config.maximumCallsPerCallGroup = 1;
        config.supportedHandleTypes =
        [NSSet setWithArray:@[[NSNumber numberWithInt:CXHandleTypePhoneNumber],
                              [NSNumber numberWithInt:CXHandleTypeGeneric]]];
        config.supportsVideo = true;

        _provider = [[CXProvider alloc] initWithConfiguration:config];
        [_provider setDelegate:self queue:nil];
    }
    return self;
}


#pragma mark - Call Control

- (void)triggerIncomingCallFromConnection:(OTConnection*)connection
                              resultBlock:(IncomingCallBlock)block
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    // HACK: before we trigger the call, force the audio session alive
    // https://forums.developer.apple.com/thread/64544
    [[OTDefaultAudioDevice sharedInstance] setupAudioSession];

    _incomingCallBlock = block;
    _currentCallID = [NSUUID UUID];
    CXCallUpdate* update = [[CXCallUpdate alloc] init];
    update.remoteHandle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric
                                                   value:connection.data ? connection.data : @"Unknown: OpenTok"];
    update.hasVideo = YES;
    [_provider reportNewIncomingCallWithUUID:_currentCallID
                                      update:update
                                  completion:^(NSError * _Nullable error) {
                                      if (error) {
                                          NSLog(@"reportIncomingCall error: %@", error);
                                      }
                                  }];

    _outgoing = NO;
}

- (void)triggerOutgoingCallToConnection:(OTConnection*)connection {
    NSLog(@"%@", NSStringFromSelector(_cmd));

    // HACK: before we trigger the call, force the audio session alive
    // https://forums.developer.apple.com/thread/64544
    [[OTDefaultAudioDevice sharedInstance] setupAudioSession];

    _currentCallID = [NSUUID UUID];
    [_provider reportOutgoingCallWithUUID:_currentCallID
                  startedConnectingAtDate:[NSDate date]];

    _outgoing = YES;
}

// this should work for both incoming and outgoing calls, but we haven't tried
// handling multiple calls.
- (void)triggerCallConnected {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [_pendingAction fulfill];
    _pendingAction = nil;

    if (_outgoing) {
        [_provider reportOutgoingCallWithUUID:_currentCallID
                              connectedAtDate:[NSDate date]];
    }
}

- (void)triggerCallTerminatedRemotely {
    [_provider reportCallWithUUID:_currentCallID
                      endedAtDate:[NSDate date]
                           reason:CXCallEndedReasonRemoteEnded];
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), provider);
}

- (void)providerDidBegin:(CXProvider *)provider
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), provider);

}

- (BOOL)provider:(CXProvider *)provider
executeTransaction:(CXTransaction *)transaction
{
    NSLog(@"%@ %@ %@", NSStringFromSelector(_cmd), provider, transaction);
    return NO;
}

- (void)provider:(CXProvider *)provider
performStartCallAction:(CXStartCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)provider:(CXProvider *)provider
performAnswerCallAction:(CXAnswerCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if (_incomingCallBlock) {
        _incomingCallBlock(YES);
        // wait to fulfill this action once subscribed
        _pendingAction = action;
        // ... or immediately fulfill the action and hope for the best
        // [action fulfill];
    } else {
        NSLog(@"no callback for this call");
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider
performEndCallAction:(CXEndCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [action fulfill];
    if ([delegate respondsToSelector:@selector(notifyCallTerminated)]) {
        [delegate notifyCallTerminated];
    }
}

- (void)provider:(CXProvider *)provider
performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)provider:(CXProvider *)provider
performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)provider:(CXProvider *)provider
performSetGroupCallAction:(CXSetGroupCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)provider:(CXProvider *)provider
performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));

}

- (void)provider:(CXProvider *)provider
timedOutPerformingAction:(CXAction *)action
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)provider:(CXProvider *)provider
didActivateAudioSession:(AVAudioSession *)audioSession
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)provider:(CXProvider *)provider
didDeactivateAudioSession:(AVAudioSession *)audioSession
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
