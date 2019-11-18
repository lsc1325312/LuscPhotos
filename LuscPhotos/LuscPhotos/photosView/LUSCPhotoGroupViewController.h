//
//  LUSCPhotoGroupViewController.h
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSCPhotosManagerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotoGroupViewController : UIViewController

@property (nonatomic,weak) UIViewController<LUSCPhotosManagerDelegate>* controller;

@property (nonatomic) NSInteger MAXSelectedNumber;//最大选择个数

@property (nonatomic,weak) NSMutableArray* photos;

@property (nonatomic,strong) UIImage* backImage;

@property (nonatomic) NSInteger sectionNumber;//一行放几个图片
@property (nonatomic,strong) UIImage* normalImage;
@property (nonatomic,strong) UIImage* selectedImage;

@property (nonatomic) BOOL isOriginal;//是否传原图

@end

NS_ASSUME_NONNULL_END
