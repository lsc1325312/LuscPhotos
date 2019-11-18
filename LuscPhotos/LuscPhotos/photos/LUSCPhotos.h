//
//  LUSCPhotos.h
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUSCPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotos : NSObject
+(instancetype) sharedPhoto;

//获取asset相对应的照片 size宽高同时为-1时 返回原图
-(void)getImageByAsset:(PHAsset *)asset makeSize:(CGSize)size makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion;
//取到所有的asset资源
- (NSMutableArray<LUSCPhotoModel *> *)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;
//获得指定相册的所有照片
- (NSMutableArray<LUSCPhotoModel *> *)getAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;
//获取asset相对应的照片 size宽高同时为-1时 返回原图
-(void)getImageDataByAsset:(PHAsset *)asset makeResizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(NSData *))completion;
@end

NS_ASSUME_NONNULL_END
