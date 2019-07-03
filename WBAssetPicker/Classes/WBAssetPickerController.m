//
//  WBAssetPickerController.m
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/4/27.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import "WBAssetPickerController.h"
#import "WBAssetPicker.h"
#import "WBAssetCell.h"
#import "WBAssetPicker.h"

static const NSInteger TotalImgCount = 9;
static UIColor *_wbAssetPickerTintColor;

@interface WBAssetPickerController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomBar;
@property (atomic,assign) NSInteger selectedCount;
@property (nonatomic, strong) UIColor *tintColor;
@end

@implementation WBAssetPickerController

#pragma mark - UI Custom

+ (void)setAssetPickerCellSelectedIcon:(UIImage *)icon {
    [WBAssetCell setSelectedIcon:icon];
}

+ (void)setAssetPickerTintColor:(UIColor *)color {
    _wbAssetPickerTintColor = color;
}

#pragma mark - Life Cycle

- (instancetype)initWithCount:(NSInteger) count {
    self = [super init];
    if(self){
        if (![_wbAssetPickerTintColor isKindOfClass:[UIColor class]]) {
            _wbAssetPickerTintColor = [UIColor colorWithRed:1.0 green:102/255.0 blue:50/255.0 alpha:1];
        }
        self.tintColor = _wbAssetPickerTintColor;
        self.selectedCount = count;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:[self cancelBtn]];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                self.dataArray = [WBAssetPicker getPhotosFromUserLibrary];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAuthorizationAlert];
                });
            }
        }];
    } else {
        self.dataArray = [WBAssetPicker getPhotosFromUserLibrary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}

- (void)showAuthorizationAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"打开设置，允许访问相册" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
    CGRect tmp = self.bottomBar.frame;
    tmp.origin.y = self.view.bounds.size.height - tmp.size.height;
    self.bottomBar.frame = tmp;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

#pragma mark - Event

- (void)sureBtnClicked:(UIButton *)btn {
    if (self.selectedArray.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.completionCallback) {
        self.completionCallback(self.selectedArray);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelBtnClicked:(UIButton *)btn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WBAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WBAssetCell" forIndexPath:indexPath];
    WBAsset *asset = self.dataArray[indexPath.item];

    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.selectionBlock = ^(BOOL isSelected) {
        if (isSelected) {
            weakCell.selectBtn.selected = NO;
            asset.isSelected = NO;
            [weakSelf.selectedArray removeObject:asset];
        } else {
            if (weakSelf.selectedArray.count < (TotalImgCount - weakSelf.selectedCount)) {
                asset.isSelected = YES;
                weakCell.selectBtn.selected = YES;
                [weakSelf.selectedArray addObject:asset];
            } else {
                NSString* str = [NSString stringWithFormat:@"最多只能选择%ld张图片", TotalImgCount];
                if (self.messageCallback) {
                    self.messageCallback(str);
                }
            }
        }
    };
    
    [cell setupWithModel:asset];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!self.imagePreviewCallback) {
        return;
    }
    WBAsset *asset = self.dataArray[indexPath.item];
    CGSize size = CGSizeMake(asset.asset.pixelWidth, asset.asset.pixelHeight);
    if (size.width * size.height <= 0) {
        CGFloat imgWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat imgHeight = imgWidth / (1.0 * asset.asset.pixelWidth / asset.asset.pixelHeight);
        size = CGSizeMake(imgWidth, imgHeight);
    }
    
    [WBAssetPicker getImageFromAsset:asset.asset withSize:size synchronous:YES completionBlock:^(UIImage *image, NSDictionary *info) {
        self.imagePreviewCallback(image, info);
    }];
}

#pragma mark - Getter and Setter

- (NSMutableArray *)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    return _selectedArray;
}

- (UIButton *)cancelBtn {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 0, 30, 44);
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.tintColor = [UIColor colorWithWhite:34/255.0 alpha:1];
    [button addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)bottomBar {
    if (!_bottomBar) {
        CGFloat width = self.view.bounds.size.width;
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
        bar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view addSubview:bar];
        
        UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
        [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sureBtn addTarget:self action:@selector(sureBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        sureBtn.frame = CGRectMake(width - 80, 10, 70, 30);
        sureBtn.backgroundColor = self.tintColor;
        [bar addSubview:sureBtn];
        
        _bottomBar = bar;
    }
    return _bottomBar;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:self.layout];
        [collectionView registerNib:[UINib nibWithNibName:@"WBAssetCell" bundle:nil] forCellWithReuseIdentifier:@"WBAssetCell"];
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

@end
