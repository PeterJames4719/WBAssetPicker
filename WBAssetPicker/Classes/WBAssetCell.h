//
//  WBAssetCell.h
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/5/3.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WBAsset.h"

@interface WBAssetCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIButton *selectBtn;
@property (nonatomic, copy) void (^selectionBlock) (BOOL isSelected);

- (void)setupWithModel:(id)model;

+ (void)setSelectedIcon:(UIImage *)icon;
@end
