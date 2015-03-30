//
//  TBLogStreamer.h
//  Hello-World
//
//  Created by Charley Robinson on 3/27/15.
//  Copyright (c) 2015 TokBox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBLogStreamer : NSObject

+ (instancetype)sharedInstance;

- (void)compressMessage:(NSString*)message;

@end
