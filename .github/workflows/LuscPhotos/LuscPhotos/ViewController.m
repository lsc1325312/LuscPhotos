//
//  ViewController.m
//  LuscPhotos
//
//  Created by xy on 2018/9/19.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "ViewController.h"
#import "LUSCPhotosManager.h"
#import "LUSCPhotosManagerDelegate.h"


@interface ViewController ()<LUSCPhotosManagerDelegate>

@property (nonatomic,strong) NSMutableArray<LUSCPhotoModel*>* photos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    for (LUSCPhotoGroupModel* model in array) {
//        NSLog(@"title = %@",model.groupTitle);
//    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%@",[NSThread isMainThread]?@"主":@"子");
//    [LUSCPhotosManager sharedPhotosManager].sectionNumber = 4;
//    [LUSCPhotosManager sharedPhotosManager].titleColor = [UIColor blueColor];
//    [LUSCPhotosManager sharedPhotosManager].selectedImage = [UIImage imageNamed:@"login_goux"];
//    [LUSCPhotosManager sharedPhotosManager].backImage = [UIImage imageNamed:@"luscBack"];
    [LUSCPhotosManager sharedPhotosManager].MAXSelectedNumber = 6;
    [[LUSCPhotosManager sharedPhotosManager] openMyPhotoStreamWithController:self selectedPhotos:self.photos];
}

-(void)returnChoosePhotos:(NSMutableArray *)photos{
    _photos = photos;
}

-(void)returnChooseOriginalPhotos:(NSMutableArray<LUSCPhotoModel *> *)photos{
    _photos = photos;
}

//是否打开相册访问权限
- (void) respondPowerIsOpen:(BOOL)isOpen{
    
    NSLog(@"%d",isOpen);
    
}


@end
