//
//  TBThumbnailGenerator.h
//  ThumbNailer
//
//  Created by Charley Robinson on 4/30/15.
//  Copyright (c) 2015 TokBox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TBThumbnailGenerator : NSObject

+ (UIImage*)createThumbnailWithView:(UIView*)view;
+ (UIImage*)createThumbnailWithImage:(UIImage*)image;

@end
