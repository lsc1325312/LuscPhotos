//
//  LUSCPhotoManage.h
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PHCachingImageManager+LUSCShareManager.h"
#import "LUSCPhotoModel.h"
#import "LUSCPhotoGroupModel.h"
#import "LUSCPhotoManageDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotoManage : NSObject

@property (nonatomic) CGSize globalAttributes_ImageCompressSize;//压缩大小  default: 屏宽-25/4
@property (nonatomic) PHImageRequestOptionsResizeMode globalAttributes_ImageRequestOptionsResizeMode;//defaule : PHImageRequestOptionsResizeModeExact


+(instancetype) defaultPhotoManage;

-(void) photoPowerWithVisitController:(id<LUSCPhotoManageDelegate>) controller;
-(NSMutableArray<LUSCPhotoGroupModel*>*) allGroup;
-(NSMutableArray<LUSCPhotoModel*>*) allPhotos;
-(NSMutableArray<LUSCPhotoModel*>*) allPhotosWithGroup:(LUSCPhotoGroupModel*) groupModel;
-(void) getImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion;
-(void) getImageWithAsset:(LUSCPhotoModel*) model size:(CGSize) size completion:(void (^)(UIImage *))completion;
-(void) getImageDataWithAsset:(LUSCPhotoModel*) model completion:(void (^)(NSData *))completion;
@end

NS_ASSUME_NONNULL_END
