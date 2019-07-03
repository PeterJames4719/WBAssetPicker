//
//  WBAssetCell.m
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/5/3.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import "WBAssetCell.h"
#import "WBAssetPicker.h"

static UIImage *_wbAssetCellSelectedIcon;

@implementation WBAssetCell

+ (void)setSelectedIcon:(UIImage *)icon {
    _wbAssetCellSelectedIcon = icon;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.selectBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectBtn.layer.borderWidth = 1;
    self.selectBtn.layer.cornerRadius = 12;
    self.selectBtn.clipsToBounds = YES;
    
    if ([_wbAssetCellSelectedIcon isKindOfClass:[UIImage class]]) {
        [self.selectBtn setImage:_wbAssetCellSelectedIcon forState:UIControlStateSelected];
    } else {
        UIImage *img = [UIImage imageNamed:@"wb_ap_selected"];
        [self.selectBtn setImage:img forState:UIControlStateSelected];
    }
}

- (void)dealloc {
    //NSLog(@"%s", __func__);
}

- (void)setupWithModel:(id)model {
    WBAsset *wbAsset = (WBAsset *)model;
    if (![wbAsset isKindOfClass:[WBAsset class]]) {
        return;
    }
    
    PHAsset *asset = wbAsset.asset;
    if ([asset isKindOfClass:[PHAsset class]]) {
        [WBAssetPicker getImageFromAsset:asset withWidth:160 completionBlock:^(UIImage *image, NSDictionary *info) {
            self.imgView.image = image;
        }];
        
        self.selectBtn.selected = wbAsset.isSelected;
    }
}

- (IBAction)selectBtnClicked:(UIButton *)sender {
    if (self.selectionBlock) {
        self.selectionBlock(sender.isSelected);
    }
}

@end
