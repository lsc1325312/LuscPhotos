//
//  LUSCPhotoGroup.m
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotoGroup.h"

@interface LUSCPhotoGroup ()

@end

@implementation LUSCPhotoGroup

+(instancetype)defaultPhotoGroup{
    static LUSCPhotoGroup * manager = nil;
    @synchronized(manager) {
        if (manager == nil) {
            manager = [[self alloc]init];
        }
    }
    return manager;
}

- (NSString *)transformAblumTitle:(NSString *)title{
    if ([title isEqualToString:@"Slo-mo"]) {
        return @"慢动作";
    } else if ([title isEqualToString:@"Recently Added"]) {
        return @"最近添加";
    } else if ([title isEqualToString:@"Favorites"]) {
        return @"最爱";
    } else if ([title isEqualToString:@"Recently Deleted"]) {
        return @"最近删除";
    } else if ([title isEqualToString:@"Videos"]) {
        return @"视频";
    } else if ([title isEqualToString:@"All Photos"]) {
        return @"所有照片";
    } else if ([title isEqualToString:@"Selfies"]) {
        return @"自拍";
    } else if ([title isEqualToString:@"Screenshots"]) {
        return @"屏幕快照";
    } else if ([title isEqualToString:@"Camera Roll"]) {
        return @"相机胶卷";
    }else if ([title isEqualToString:@"My Photo Stream"]){
        return @"我的照片流";
    }else if ([title isEqualToString:@"Panoramas"]){
        return @"全景图";
    }else if ([title isEqualToString:@"Live Photos"]){
        return @"Live Photos";//短动画
    }else if ([title isEqualToString:@"Animated"]){
        return @"Animated";
    }
    return nil;
}

- (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending{//排序根据创建时间
    PHFetchOptions *option = [[PHFetchOptions alloc] init]; //相片格式
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
    
}

-(NSArray<LUSCPhotoGroupModel *> *)getAllPhotoList{
    
    __weak typeof(self) weakSelf = self;
    
    NSMutableArray<LUSCPhotoGroupModel *> * photoList = [NSMutableArray array];
    //获取有的系统相册
    PHFetchResult * smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!([collection.localizedTitle isEqualToString:@"Recently Deleted"] || [collection.localizedTitle isEqualToString:@"Videos"])) {
            PHFetchResult * result = [weakSelf fetchAssetsInAssetCollection:collection ascending:NO];
            if (result.count > 0) {
                LUSCPhotoGroupModel * list = [[LUSCPhotoGroupModel alloc] init];
                list.groupTitle = [weakSelf transformAblumTitle:collection.localizedTitle];
                list.englishGroupTitle = collection.localizedTitle;
                if (list.groupTitle==nil) {
                    list.groupTitle = collection.localizedTitle;
                }
                list.photosNumber = result.count;
                list.firstAsset = result.firstObject;
                list.assetCollection = collection;
                [photoList addObject:list];
            }
        }
    }];
    //用户创建的相册
    PHFetchResult * userAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        PHFetchResult *result = [weakSelf fetchAssetsInAssetCollection:collection ascending:NO];
        if (result.count > 0) {
            LUSCPhotoGroupModel * list = [[LUSCPhotoGroupModel alloc]init];
            list.groupTitle = [weakSelf transformAblumTitle:collection.localizedTitle];
            list.englishGroupTitle = collection.localizedTitle;
            if (list.groupTitle == nil) {
                list.groupTitle = collection.localizedTitle;
            }
            list.photosNumber = result.count;
            list.firstAsset = result.firstObject;
            list.assetCollection = collection;
            [photoList addObject:list];
        }
    }];
    return photoList;
}

@end
