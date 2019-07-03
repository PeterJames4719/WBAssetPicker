//
//  WBAssertPicker.h
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/4/27.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBAsset.h"

@interface WBAssetPicker : NSObject
+ (NSInteger)getImageFromAsset:(PHAsset *)asset withSize:(CGSize)imageSize synchronous:(BOOL)isSynchronous completionBlock:(void (^) (UIImage *image, NSDictionary *info))completion;

+ (NSInteger)getImageFromAsset:(PHAsset *)asset withWidth:(CGFloat)imageWidth completionBlock:(void (^) (UIImage *image, NSDictionary *info))completion;

+ (NSArray *)getPhotosFromUserLibrary;

@end
