//
//  LUSCPreviewImageViewController.h
//  LuscPhotos
//
//  Created by xy on 2018/9/27.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSCPhotoModel.h"


typedef NS_ENUM(NSInteger,PreviewImageSource) {
    PreviewImageSource_touchPreview,//点击预览进入
    PreviewImageSource_touchImage//点击图片进入
};

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPreviewImageViewController : UIViewController

@property (nonatomic) NSInteger MAXSelectedNumber;//最大选择个数

@property (nonatomic,weak) id controller;

@property (nonatomic,weak) NSMutableArray<LUSCPhotoModel*>* photos;
@property (nonatomic,weak) NSMutableArray<LUSCPhotoModel*>* choosePhotos;

@property (nonatomic,strong) UIImage* backImage;

@property (nonatomic) NSInteger currentDisplayIndex;//只用于点击选择与第一回进入时，显示图片定位用

@property (nonatomic) PreviewImageSource source;

@property (nonatomic,strong) UIImage* normalImage;
@property (nonatomic,strong) UIImage* selectedImage;

@property (nonatomic) BOOL isOriginal;//是否传原图
@property (nonatomic) void(^returnIsOriginal)(BOOL isO);//反回上一级数据


@end

NS_ASSUME_NONNULL_END
