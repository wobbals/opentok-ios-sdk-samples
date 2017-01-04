//
//  OTCXProvider.h
//  1.Hello-World
//
//  Created by Charley Robinson on 12/29/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CallKit;
@import OpenTok;

typedef void (^IncomingCallBlock)(BOOL callAccepted);

@protocol OTCXProviderDelegate <NSObject>

-(void)notifyCallTerminated;

@end

@interface OTCXProvider : NSObject <CXProviderDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, weak) id<OTCXProviderDelegate> delegate;

- (void)triggerOutgoingCallToConnection:(OTConnection*)connection;
- (void)triggerIncomingCallFromConnection:(OTConnection*)connection
                              resultBlock:(IncomingCallBlock)block;
- (void)triggerCallConnected;
- (void)triggerCallTerminatedRemotely;

@end
