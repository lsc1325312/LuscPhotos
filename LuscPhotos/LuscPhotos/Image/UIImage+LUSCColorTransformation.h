//
//  UIImage+LUSCColorTransformation.h
//  LuscPhotos
//
//  Created by xy on 2018/9/27.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (LUSCColorTransformation)
//用颜色得到一张同色图片 大小与自身image相同
- (UIImage *)imageWithColor:(UIColor *)color;
//得到一个渐变色图
- (UIImage *)imageWithCradualChangeStartColor:(UIColor*)startColor endColor:(UIColor*) endColor imageSize:(CGSize) imageSize;

//改变单色图片的颜色
-(UIImage*)imageChangeColor:(UIColor*)color;

//图片尺寸压缩
- (UIImage *)imageCompressSizeWithSize:(CGSize) size;
//图片质量压缩
-(UIImage *)imageCompressQualityWithByte:(NSInteger) qualityByte;
//图片旋转
- (UIImage *)imageWithRotation:(UIImageOrientation)orientation;
//图片矫正
- (UIImage *)imageWithRightOrientation;

@end

NS_ASSUME_NONNULL_END
