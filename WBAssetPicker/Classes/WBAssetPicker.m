//
//  WBAssertPicker.m
//  WBAssertPicker
//
//  Created by 兵伍 on 2018/4/27.
//  Copyright © 2018年 兵伍. All rights reserved.
//

#import "WBAssetPicker.h"


@implementation WBAssetPicker

+ (NSInteger)getImageFromAsset:(PHAsset *)asset withSize:(CGSize)imageSize synchronous:(BOOL)isSynchronous completionBlock:(void (^) (UIImage *image, NSDictionary *info))completion {
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = isSynchronous;
    
    return [imageManager requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        if (completion) {
            completion(result, info);
        }
    }];

}


+ (NSInteger)getImageFromAsset:(PHAsset *)asset withWidth:(CGFloat)imageWidth completionBlock:(void (^) (UIImage *image, NSDictionary *info))completion {
    if ([asset isKindOfClass:[PHAsset class]]) {
        CGSize imageSize;
        CGFloat aspectRatio = asset.pixelWidth * 1.0 / asset.pixelHeight;
        CGFloat imageHeight = imageWidth / aspectRatio;
        imageSize = CGSizeMake(imageWidth, imageHeight);

        __block UIImage *image;
        // 修复获取图片时出现的瞬间内存过高问题
        // 下面两行代码，来自hsjcom，他的github是：https://github.com/hsjcom 表示感谢
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

        //option.synchronous = YES;
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        //option.resizeMode = PHImageRequestOptionsResizeModeNone;

        int32_t imageRequestID = [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:imageSize contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage *result, NSDictionary *info) {
            if (result) {
                image = result;
            }
            BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
            if (downloadFinined && result) {
                //result = [self fixOrientation:result];
                if (completion) completion(result,info);
            }
            // Download image from iCloud / 从iCloud下载图片
            if ([info objectForKey:PHImageResultIsInCloudKey]) {
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        if (progressHandler) {
//                            progressHandler(progress, error, stop, info);
//                        }
                    });
                };
                options.networkAccessAllowed = YES;
                options.resizeMode = PHImageRequestOptionsResizeModeFast;
                [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                    UIImage *resultImage = [UIImage imageWithData:imageData];
                    //resultImage = [self scaleImage:resultImage toSize:imageSize];
                    if (!resultImage) {
                        resultImage = image;
                    }
                    //resultImage = [self fixOrientation:resultImage];
                    if (completion) completion(resultImage,info);
                }];
            }
        }];
        return imageRequestID;
    }
    return 0;
}


+ (NSArray *)getPhotosFromUserLibrary {
    return [[self class] getAssetFromAlbum:PHAssetCollectionTypeSmartAlbum subType:PHAssetCollectionSubtypeSmartAlbumUserLibrary mediaType:PHAssetMediaTypeImage];
}

+ (NSArray *)getAssetFromAlbum:(PHAssetCollectionType)type subType:(PHAssetCollectionSubtype)subType mediaType:(PHAssetMediaType)mediaType {
    NSMutableArray *assetArray = [NSMutableArray array];
    
    // 列出智能相册
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subType options:nil];
    // 获取所有资源的集合，并按资源的创建时间排序
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", mediaType];
    
    // 这时 smartAlbums 中保存的应该是各个智能相册对应的 PHAssetCollection
    for (NSInteger i = 0; i < fetchResult.count; i++) {
        // 获取一个相册（PHAssetCollection）
        PHCollection *collection = fetchResult[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            NSLog(@"collectionName:%@", collection.localizedTitle);
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            // 从每一个智能相册中获取到的 PHFetchResult 中包含的才是真正的资源（PHAsset）
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
            if (assetCollection.estimatedAssetCount <= 0) continue;
            // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
            for (NSInteger i = 0; i < fetchResult.count; i++) {
                // 获取一个资源（PHAsset）
                PHAsset *asset = fetchResult[i];
                //NSLog(@"type:%zd", asset.mediaType);
                
                WBAsset *wbAsset = [[WBAsset alloc] init];
                wbAsset.asset = asset;
                [assetArray addObject:wbAsset];
            }
        } else {
            NSAssert(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    return assetArray;
}

@end
