//
//  WBViewController.m
//  WBAssetPicker
//
//  Created by PeterJames4719 on 07/02/2019.
//  Copyright (c) 2019 PeterJames4719. All rights reserved.
//

#import "WBViewController.h"
#import <WBAssetPickerController.h>
@interface WBViewController ()

@end

@implementation WBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    NSInteger lineCount = 4;
    CGFloat gap = 4;
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - ((lineCount + 1) * gap))/lineCount;
    itemWidth = floorf(itemWidth);
    
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = 4;
    layout.minimumInteritemSpacing = 4;
    layout.sectionInset = UIEdgeInsetsMake(gap, gap, gap, gap);
    
    
    WBAssetPickerController *picker = [[WBAssetPickerController alloc] initWithCount:0];
    picker.layout = layout;
    picker.messageCallback = ^(NSString *msg) {
        NSLog(@"message:%@", msg);
    };
    picker.imagePreviewCallback = ^(UIImage *image, NSDictionary *info) {
        NSLog(@"image:%@, info:%@", image, info);
    };
    picker.completionCallback = ^(NSArray *images) {
        NSLog(@"images:%@", images);
    };
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:picker];
    
    [self presentViewController:navi animated:YES completion:^{
        
    }];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
