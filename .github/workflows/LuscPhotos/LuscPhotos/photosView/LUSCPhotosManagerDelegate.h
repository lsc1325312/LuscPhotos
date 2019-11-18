//
//  LUSCPhotosManagerDelegate.h
//  LuscPhotos
//
//  Created by xy on 2018/9/21.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUSCPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol LUSCPhotosManagerDelegate <NSObject>

@optional
-(void) returnChoosePhotos:(NSMutableArray<LUSCPhotoModel*>*) photos;//LUSCPhotoModel 中 originalImage 不带原图  与returnChooseOriginalPhotos是相同数组
-(void) returnChooseOriginalPhotos:(NSMutableArray<LUSCPhotoModel*>*) photos;//LUSCPhotoModel 中 originalImage 带原图 与returnChoosePhotos是相同数组

@end

NS_ASSUME_NONNULL_END
