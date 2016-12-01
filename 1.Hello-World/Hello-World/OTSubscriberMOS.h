//
//  OTSubscriberMOS.h
//  1.Hello-World
//
//  Created by Charley Robinson on 11/23/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenTok/OpenTok.h>

@interface OTSubscriberMOS : NSObject

-(instancetype)initWithSubscriber:(OTSubscriberKit*)subscriber;

- (void)stop;

@end
