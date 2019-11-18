//
//  LUSCPhotosManager.h
//  LuscPhotos
//
//  Created by xy on 2018/9/21.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LUSCPhotoModel.h"
#import "LUSCPhotosManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotosManager : NSObject

//所有属性为一次性设置，如果想单独设置，需要使用前设置，用完后重置回原值

@property (nonatomic) NSInteger MAXSelectedNumber;//最大选择个数 默认10个

@property (nonatomic,strong) UINavigationController* navigationCon;//图片选择的nav

@property (nonatomic,strong) UIImage* backImage;


@property (nonatomic) NSInteger sectionNumber;//一行放几个图片
@property (nonatomic,strong,readonly) UIImage* normalImage;//无选择时的图片 暂时不开启
@property (nonatomic,strong,readonly) UIImage* selectedImage;//选择时的图片 暂时不开启

@property (nonatomic) BOOL isOriginal;//是否传原图

+(instancetype) sharedPhotosManager;

////判断是否可以使用相册
//- (BOOL)isCanUsePhotos;

//打开相册组
-(void) openAllPhotoGroupWithController:(UIViewController<LUSCPhotosManagerDelegate>*) controller selectedPhotos:( NSMutableArray<LUSCPhotoModel*>* _Nullable ) photos;
//打开所有相片
-(void) openMyPhotoStreamWithController:(UIViewController<LUSCPhotosManagerDelegate>*) controller selectedPhotos:(NSMutableArray<LUSCPhotoModel*>*  _Nullable ) photos;

//得到预览图
-(void) getLittleImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion;

//用LUSCPhotoModel得到原图
-(void) getOriginalImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion;

//用LUSCPhotoModel得到自定义大小图片
-(void) getOriginalImageWithAsset:(LUSCPhotoModel*) model size:(CGSize) size completion:(void (^)(UIImage *))completion;

//用LUSCPhotoModel得到原图Data
-(void) getOriginalImageDataWithAsset:(LUSCPhotoModel*) model completion:(void (^)(NSData *))completion;

@end

NS_ASSUME_NONNULL_END
