//
//  WBAssertPickerController.h
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/4/27.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBAssetPickerController : UIViewController
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, copy) void (^imagePreviewCallback)(UIImage *image, NSDictionary *info);
@property (nonatomic, copy) void (^messageCallback)(NSString *msg);
@property (nonatomic, copy) void (^completionCallback)(NSArray *images);

- (instancetype)initWithCount:(NSInteger) count;

+ (void)setAssetPickerCellSelectedIcon:(UIImage *)icon;
+ (void)setAssetPickerTintColor:(UIColor *)color;
@end
