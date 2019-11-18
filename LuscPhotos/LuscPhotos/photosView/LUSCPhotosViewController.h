//
//  LUSCPhotosViewController.h
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSCPhotoGroupModel.h"
#import "LUSCPhotoModel.h"
#import "LUSCPhotosManagerDelegate.h"

// RGB颜色转换（16进制->10进制）(0x00000000--0xFFFFFFFF)
#define UIColorFromHexadecimalAlphaLUSC(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]

//#define mainColor UIColorFromHexadecimalAlphaLUSC(0xff48C1a4)

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotosViewController : UIViewController

@property (nonatomic,weak) UIViewController<LUSCPhotosManagerDelegate>* controller;

@property (nonatomic,strong) LUSCPhotoGroupModel* groupModel;

@property (nonatomic,weak) NSMutableArray<LUSCPhotoModel*>* choosePhotos;

@property (nonatomic,strong) NSString* photoTitle;

@property (nonatomic) NSInteger MAXSelectedNumber;//最大选择个数

@property (nonatomic,strong) UIImage* backImage;

@property (nonatomic) NSInteger sectionNumber;//一行放几个图片
@property (nonatomic,strong) UIImage* normalImage;
@property (nonatomic,strong) UIImage* selectedImage;

@property (nonatomic) BOOL isOriginal;//是否传原图
@property (nonatomic) void(^returnIsOriginal)(BOOL isO);//反回上一级数据

@end

NS_ASSUME_NONNULL_END
