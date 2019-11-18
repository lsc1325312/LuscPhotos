//
//  LUSCPhotoManage.m
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

//PHAsset 用户照片库中一个单独的资源，简单而言就是单张图片的元数据吧
//PHAsset 组合而成PHAssetCollection(PHCollection)一个单独的资源集合(PHAssetCollection)可以是照片库中相簿中一个相册或者照片中一个时刻，或者是一个特殊的“智能相册”。这种智能相册包括所有的视频集合，最近添加的项目，用户收藏，所有连拍照片等
//PHCollectionList 则是包含PHCollection的PHCollection。因为它本身就是PHCollection，所以集合列表可以包含其他集合列表，它们允许复杂的集合继承。例子：年度->精选->时刻
//PHFetchResult 某个系列（PHAssetCollection）或者是相册（PHAsset）的的返回结果，一个集合类型，PHAsset或者PHAssetCollection的类方法均可以获取到
//PHImageManager 处理图片加载，加载图片过程有缓存处理
//PHCachingImageManager(PHImageManager的抽象) 处理图像的整个加载过程的缓存要加载大量资源的缩略图时可以使用该类的startCachingImage...预先将图像加载到内存中 ，使用时注意size要一致
//PHImageRequestOptions设置加载图片方式的参数()
//PHFetchOptions集合资源的配置方式（按一定的(例如时间)顺序对资源进行排列、隐藏/显示某一个部分的资源集合）


#import "LUSCPhotoManage.h"
#import "LUSCPhotos.h"
#import "LUSCPhotoGroup.h"
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@implementation LUSCPhotoManage

+(instancetype) defaultPhotoManage{
    static LUSCPhotoManage* manager = nil;
//    static dispatch_once_t tokenOnce;
//    dispatch_once(&tokenOnce, ^{
        @synchronized (manager) {
            if (manager == nil) {
                manager = [[self alloc]init];
                manager.globalAttributes_ImageCompressSize = CGSizeMake(([UIScreen mainScreen].applicationFrame.size.width)/4, ([UIScreen mainScreen].applicationFrame.size.width)/4);
                manager.globalAttributes_ImageRequestOptionsResizeMode = PHImageRequestOptionsResizeModeFast;
            }
        }
//    });
    return manager;
}


/*
 1、 首次加载APP时出现的问题：仅会获取相应的权限 而不会响应方法
 */
//每次访问相册都会调用这个handler  检查改app的授权情况
//PHPhotoLibrary
-(void) photoPowerWithVisitController:(id<LUSCPhotoManageDelegate>) controller{
//    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
//    if (status == PHAuthorizationStatusRestricted ||
//        status == PHAuthorizationStatusDenied) {
//        // 这里便是无访问权限
//        //可以弹出个提示框，叫用户去设置打开相册权限
//    }  else {
//        //这里就是用权限
//    }
//
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        BOOL bl = NO;
        if (status == PHAuthorizationStatusAuthorized) {
            //code
            bl = YES;
        }
        static void *mainQueueKey = "mainQueueKey";
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, &mainQueueKey, NULL);
        if (dispatch_get_specific(mainQueueKey)) { // do something in main queue
            if ([controller respondsToSelector:@selector(respondPowerIsOpen:)]) {
                [controller respondPowerIsOpen:bl];
            }
        } else { // do something in other queue
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([controller respondsToSelector:@selector(respondPowerIsOpen:)]) {
                    [controller respondPowerIsOpen:bl];
                }
            });
        }
    }];
}


-(NSArray<LUSCPhotoGroupModel*>*) allGroup{
    return [[LUSCPhotoGroup defaultPhotoGroup] getAllPhotoList];
}

-(NSMutableArray<LUSCPhotoModel*>*) allPhotos{
    return [[LUSCPhotos sharedPhoto] getAllAssetInPhotoAblumWithAscending:YES];
}

-(NSMutableArray<LUSCPhotoModel*>*) allPhotosWithGroup:(LUSCPhotoGroupModel*) groupModel{
    
    return [[LUSCPhotos sharedPhoto] getAssetsInAssetCollection:groupModel.assetCollection ascending:YES];
}

-(void) getImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion{
    [self getImageWithAsset:model size:self.globalAttributes_ImageCompressSize completion:completion];
}
-(void) getImageWithAsset:(LUSCPhotoModel*) model size:(CGSize) size completion:(void (^)(UIImage *))completion{
    [[LUSCPhotos sharedPhoto] getImageByAsset:model.asset makeSize:size makeResizeMode:self.globalAttributes_ImageRequestOptionsResizeMode completion:^(UIImage * _Nonnull image) {
        static void *mainQueueKey = "mainQueueKey";
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, &mainQueueKey, NULL);
        if (dispatch_get_specific(mainQueueKey)) { // do something in main queue
            completion(image);
        } else { // do something in other queue
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }
    }];
}

-(void) getImageDataWithAsset:(LUSCPhotoModel*) model completion:(void (^)(NSData *))completion{
    [[LUSCPhotos sharedPhoto] getImageDataByAsset:model.asset makeResizeMode:self.globalAttributes_ImageRequestOptionsResizeMode completion:^(NSData * _Nonnull image) {
        static void *mainQueueKey = "mainQueueKey";
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, &mainQueueKey, NULL);
        if (dispatch_get_specific(mainQueueKey)) { // do something in main queue
            completion(image);
        } else { // do something in other queue
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(image);
            });
        }
    }];
}

@end
