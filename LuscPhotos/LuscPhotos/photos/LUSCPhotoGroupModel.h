//
//  LUSCPhotoGroupModel.h
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotoGroupModel : NSObject

@property (nonatomic,strong) NSString* groupTitle; // 相册名字

@property (nonatomic,strong) NSString* englishGroupTitle;//英文名字

@property (nonatomic) NSInteger photosNumber; //相册图片个数

@property(nonatomic,strong)PHAsset * firstAsset; //该相册的第一张图片

@property(nonatomic,strong)PHAssetCollection * assetCollection;//同过该属性可以取得该相册的所有照片

@end

NS_ASSUME_NONNULL_END
