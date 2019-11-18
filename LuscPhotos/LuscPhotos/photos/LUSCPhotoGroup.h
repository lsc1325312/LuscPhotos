//
//  LUSCPhotoGroup.h
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LUSCPhotoGroupModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPhotoGroup : NSObject

+(instancetype)defaultPhotoGroup;

-(NSArray<LUSCPhotoGroupModel *> *)getAllPhotoList;

@end

NS_ASSUME_NONNULL_END
