//
//  LUSCPhotosManager.m
//  LuscPhotos
//
//  Created by xy on 2018/9/21.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotosManager.h"
#import "LUSCPhotosViewController.h"
#import "LUSCPhotoGroupViewController.h"
#import "LUSCPhotoManage.h"
#import "UINavigationBar+LUSCNavigationBar.h"

@interface LUSCPhotosManager()

@property (nonatomic,weak) UIViewController<LUSCPhotosManagerDelegate>* controller;
@property (nonatomic,strong) NSMutableArray<LUSCPhotoModel*>* photos;

@end

@implementation LUSCPhotosManager

+(instancetype) sharedPhotosManager{
    static LUSCPhotosManager* manager = nil;
    static dispatch_once_t tokenManager;
    dispatch_once(&tokenManager, ^{
        manager = [[LUSCPhotosManager alloc] init];
        manager.MAXSelectedNumber = 10;
        manager.backImage = [UIImage imageNamed:@"luscBack"];
    });
    return manager;
}


//打开相册组
-(void) openAllPhotoGroupWithController:(UIViewController<LUSCPhotosManagerDelegate>*) controller selectedPhotos:(NSMutableArray<LUSCPhotoModel*>*  _Nullable ) photos{
    if (photos==nil) {
        if (self.photos == nil) {
            self.photos = [NSMutableArray array];
        }
    }else{
        self.photos = [NSMutableArray arrayWithArray:photos];
    }
    self.controller = controller;
    
    
    
//    LUSCPhotoGroupViewController* vc = [[LUSCPhotoGroupViewController alloc] init];
//    vc.photos = self.photos;
//    vc.controller = controller;
//    vc.MAXSelectedNumber = self.MAXSelectedNumber;
//    vc.backImage = self.backImage;
//    vc.sectionNumber = self.sectionNumber?self.sectionNumber:4;
//    vc.normalImage = self.normalImage;
//    vc.selectedImage = self.selectedImage;
//    [controller presentViewController:[self createNavWithController:vc] animated:YES completion:nil];
    
    [self popBox:self.controller type:1];
}

//打开所有相片
-(void) openMyPhotoStreamWithController:(UIViewController<LUSCPhotosManagerDelegate>*) controller selectedPhotos:(NSMutableArray<LUSCPhotoModel*>*  _Nullable ) photos{
    if (photos==nil) {
        if (self.photos == nil) {
            self.photos = [NSMutableArray array];
        }
    }else{
        self.photos = [NSMutableArray arrayWithArray:photos];
    }
    self.controller = controller;
    
    [self popBox:self.controller type:2];
    
    
}

-(LUSCPhotoGroupViewController*) createGroupVC{
    LUSCPhotoGroupViewController* vc = [[LUSCPhotoGroupViewController alloc] init];
    vc.photos = self.photos;
    vc.controller = self.controller;
    vc.MAXSelectedNumber = self.MAXSelectedNumber;
    vc.backImage = self.backImage;
    vc.sectionNumber = self.sectionNumber?self.sectionNumber:4;
    vc.normalImage = self.normalImage;
    vc.selectedImage = self.selectedImage;
    vc.isOriginal = NO;
    [self.controller presentViewController:[self createNavWithController:vc] animated:YES completion:nil];
    return vc;
}

-(LUSCPhotosViewController*) createPhotoVC:(LUSCPhotoGroupViewController*) vc{
    LUSCPhotosViewController* pvc = [[LUSCPhotosViewController alloc] init];
    pvc.choosePhotos = self.photos;
    pvc.photoTitle = @"相机胶卷";
    pvc.controller = self.controller;
    pvc.MAXSelectedNumber = self.MAXSelectedNumber;
    pvc.backImage = self.backImage;
    pvc.sectionNumber = self.sectionNumber?self.sectionNumber:4;
    pvc.normalImage = self.normalImage;
    pvc.selectedImage = self.selectedImage;
    pvc.isOriginal = NO;
    __weak typeof(self) weakSelf = self;
    pvc.returnIsOriginal = ^(BOOL isO) {
        weakSelf.isOriginal = isO;
        vc.isOriginal = isO;
    };
    [vc.navigationController pushViewController:pvc animated:NO];
    return pvc;
}

-(UINavigationController*) createNavWithController:(UIViewController*) controller{
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [nav.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];//加入空图片让导航栏背景全透明
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;//时间状态那栏调整模式
    nav.navigationController.navigationBar.translucent = YES;//是否导航栏半透明
    [nav.navigationBar setColor:[UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:0.55]];
    
    
//    //ViewController的方法
//    nav.automaticallyAdjustsScrollViewInsets = NO;//为YES时，它会找view里的scrollView，并设置scrollView的contentInset为{64, 0, 0, 0}。如果你不想让scrollView的内容自动调整，将这个属性设为NO（默认值YES）。IOS11后过期改用UIScrollView属性contentInsetAdjustmentBehavior
//    nav.edgesForExtendedLayout = UIRectEdgeAll;//这个属性是UIExtendedEdge类型，用来制定视图的哪条边需要扩展。比如UIRectEdgeTop，它把视图区域顶部扩展到statusBar（以前是navigationBar下面）；UIRectEdgeBottom是把区域底部扩展到屏幕下方边缘。默认值是UIRectEdgeAll。
//    nav.extendedLayoutIncludesOpaqueBars = YES;//如果你使用了不透明的导航栏，设置edgesForExtendedLayout的时候也请将extendedLayoutIncludesOpaqueBars的值设置为No（默认值是YES）。
    


    self.navigationCon = nav;
    return nav;
}

-(void) getLittleImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion{
    [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model completion:completion];
}

-(void) getOriginalImageWithAsset:(LUSCPhotoModel*) model completion:(void (^)(UIImage *))completion{
    [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:CGSizeMake(-1, -1) completion:completion];
}

-(void) getOriginalImageWithAsset:(LUSCPhotoModel*) model size:(CGSize) size completion:(void (^)(UIImage *))completion{
    [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:size completion:completion];
}

-(void) getOriginalImageDataWithAsset:(LUSCPhotoModel*) model completion:(void (^)(NSData *))completion{
    [[LUSCPhotoManage defaultPhotoManage] getImageDataWithAsset:model completion:completion];
}


- (BOOL)isCanUsePhotos {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
    return YES;
}


-(void) popBox:(UIViewController*) controller type:(NSInteger) type{//1 相册组  2 相机胶卷
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized){//用户之前已经授权
        LUSCPhotoGroupViewController* vc = [self createGroupVC];
        if (type==2) {
            [self createPhotoVC:vc];
        }
        return;
    }else if([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied){//用户之前已经拒绝授权
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"您之前拒绝了访问相册，请到手机隐私设置" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:sureAction];
        [controller presentViewController:alertC animated:YES completion:nil];
    }else{//弹窗授权时监听
        __weak typeof(self) weakself = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized){//允许
//                [weakself readSystemPhotos];//获取数据 刷新视图
                
                static void *mainQueueKey = "mainQueueKey";
                dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, &mainQueueKey, NULL);
                if (dispatch_get_specific(mainQueueKey)) { // do something in main queue
                    NSLog(@"%@",[NSThread isMainThread]?@"主":@"子");
                    LUSCPhotoGroupViewController* vc = [weakself createGroupVC];
                    if (type==2) {
                        [weakself createPhotoVC:vc];
                    }
                } else { // do something in other queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@",[NSThread isMainThread]?@"主":@"子");
                        LUSCPhotoGroupViewController* vc = [weakself createGroupVC];
                        if (type==2) {
                            [weakself createPhotoVC:vc];
                        }
                    });
                }
                
                
                
            }else{//拒绝
//                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}




@end
