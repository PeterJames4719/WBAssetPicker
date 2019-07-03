//
//  WBAsset.h
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/5/3.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface WBAsset : NSObject
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) BOOL isSelected;
@end
