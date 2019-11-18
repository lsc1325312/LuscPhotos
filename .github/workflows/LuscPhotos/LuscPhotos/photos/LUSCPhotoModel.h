//
//  LUSCPhotoModel.h
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotoModel : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) UIImageOrientation orientation;
@property (nonatomic,strong,nullable) UIImage* littleImage;
@property (nonatomic,strong,nullable) UIImage* limitSizeImage;
@property (nonatomic) NSInteger limitSizeImageIndex;
@property (nonatomic,strong,nullable) UIImage* originalImage;
@property (nonatomic) NSInteger originalImageIndex;
@property (nonatomic,strong) NSData* imageData;
@property (nonatomic,strong) NSDictionary* info;
@property (nonatomic,strong) PHAsset* asset;

@property (nonatomic) BOOL isPreviewRemove;//预览预删除转用

@end

NS_ASSUME_NONNULL_END
