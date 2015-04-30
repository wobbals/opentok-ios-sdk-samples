//
//  TBThumbnailGenerator.m
//  ThumbNailer
//
//  Created by Charley Robinson on 4/30/15.
//  Copyright (c) 2015 TokBox, Inc. All rights reserved.
//

#import "TBThumbnailGenerator.h"
#import <UIKit/UIKit.h>

@implementation TBThumbnailGenerator

// This won't actually work for our default GLKView renderer.
+ (UIImage*)createThumbnailWithView:(UIView*)view {
    UIImage* result = nil;
    
    CGSize size = [view bounds].size;
    UIGraphicsBeginImageContext(size);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize destinationSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContext(destinationSize);
    [newImage drawInRect:CGRectMake(0,0,
                                    destinationSize.width,
                                    destinationSize.height)];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}

// images will never be wider or higher than this value
#define MAX_PIXEL_EDGE 50.f

+ (UIImage*)createThumbnailWithImage:(UIImage*)image {
    CGSize originalSize = image.size;
    CGFloat scale = 1.0;
    if (originalSize.width > originalSize.height) {
        scale = MAX_PIXEL_EDGE / originalSize.width;
    } else {
        scale = MAX_PIXEL_EDGE / originalSize.height;
    }
    CIImage* ciImage = [CIImage imageWithCGImage:image.CGImage];
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    ciImage = [ciImage imageByApplyingTransform:transform];
    CGImageRef cgImage = [TBThumbnailGenerator ciImageToCGImage:ciImage];
    UIImage* result = [UIImage imageWithCGImage:cgImage];
    return result;
    
//    UIImage* result = nil;
//    
//    // Why does this not work?
//    CGSize destinationSize = CGSizeMake(20, 20);
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.f);
//    [image drawInRect:CGRectMake(0,0,destinationSize.width,
//                                destinationSize.height)];
//    result = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return result;
}

+ (CGImageRef)ciImageToCGImage:(CIImage*)ciImage {
    CIContext* myContext = [CIContext contextWithOptions:nil];
    return [myContext createCGImage:ciImage fromRect:[ciImage extent]];
}

@end
