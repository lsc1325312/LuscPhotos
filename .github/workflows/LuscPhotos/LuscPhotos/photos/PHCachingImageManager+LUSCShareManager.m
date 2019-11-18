//
//  PHCachingImageManager+LUSCShareManager.m
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "PHCachingImageManager+LUSCShareManager.h"

@implementation PHCachingImageManager (LUSCShareManager)

+(instancetype)defaultManager{//解决imageManager父类在系统相册调用defaultManager再调caching的defaultManager后出现崩溃问题
    static PHCachingImageManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PHCachingImageManager alloc] init];
    });
    return manager;
}

@end
