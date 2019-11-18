//
//  LUSCPhotoGroupViewController.m
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotoGroupViewController.h"
#import "LUSCPhotoManage.h"
#import "LUSCPhotoGroupTableViewCell.h"
#import "LUSCPhotosViewController.h"


@interface LUSCPhotoGroupViewController () <LUSCPhotoManageDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic)NSInteger littleImageIndex;
@property (nonatomic)NSInteger originalImageIndex;

@property (nonatomic,strong) UIView* tabBar;

@property (nonatomic,strong) UITableView* groupTableView;

@property (nonatomic,strong) NSArray<LUSCPhotoGroupModel*>* groups;

@end

@implementation LUSCPhotoGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"所有相册";
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:(UIBarButtonItemStylePlain) target:self action:@selector(returnPhotos)];
    self.navigationItem.rightBarButtonItem = item;
    
    UIButton* returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    [returnButton setTitle:@"取消" forState:UIControlStateNormal];
    [returnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:returnButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    

//    UIFontDescriptorTextStyleAttribute
//    [self addBar];
    
    [[LUSCPhotoManage defaultPhotoManage] photoPowerWithVisitController:self];
    [self createTableView];
    
    [self getGroups];
    
}

#pragma mark - event

-(void)respondPowerIsOpen:(BOOL)isOpen{
    if (!isOpen) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self getGroups];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LUSCPhotoGroupTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LUSCPhotoGroupTableViewCell"];
    if (cell==nil) {
        cell = [[LUSCPhotoGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LUSCPhotoGroupTableViewCell"];
    }
    LUSCPhotoGroupModel* model = [self.groups objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setTitleName:model.groupTitle];
    
    LUSCPhotoModel* photomodel = [[LUSCPhotoModel alloc] init];
    photomodel.asset = model.firstAsset;
    [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:photomodel completion:^(UIImage * _Nonnull image) {
        [cell setTitleImage:image];
    }];
    
//    [cell setTitleImage:nil];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LUSCPhotoGroupModel* model = [self.groups objectAtIndex:indexPath.row];
    LUSCPhotosViewController* vc = [[LUSCPhotosViewController alloc] init];
    vc.groupModel = model;
    vc.controller = self.controller;
    vc.MAXSelectedNumber = self.MAXSelectedNumber;
    vc.backImage = self.backImage;
    vc.choosePhotos = self.photos;
    vc.sectionNumber = self.sectionNumber;
    vc.normalImage = self.normalImage;
    vc.selectedImage = self.selectedImage;
    vc.isOriginal = self.isOriginal;
    __weak typeof(self) weakSelf = self;
    vc.returnIsOriginal = ^(BOOL isO) {
        weakSelf.isOriginal = isO;
    };
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - create

-(void) createTableView{
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height+44;
    self.groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, statusHeight, self.view.frame.size.width, self.view.frame.size.height-statusHeight) style:UITableViewStylePlain];
    self.groupTableView.delegate = self;
    self.groupTableView.dataSource = self;
    self.groupTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.groupTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.groupTableView];
}


#pragma mark - seter and geter

- (void) getGroups{
    NSArray<LUSCPhotoGroupModel*>* array = [[LUSCPhotoManage defaultPhotoManage] allGroup];
    self.groups = array;
    [self.groupTableView reloadData];
}


#pragma mark -


- (void) addBar{
    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height+44;
    self.tabBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, statusHeight)];
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tabBar];
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBar.frame.size.height-1, self.tabBar.frame.size.width, 1)];
    line.backgroundColor = [UIColor grayColor];
    [self.tabBar addSubview:line];
    
    UIView* back = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBar.frame.size.height-44, 44, 44)];
    back.backgroundColor = [UIColor blueColor];
    [self.tabBar addSubview:back];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back)];
    [back addGestureRecognizer:tap];
}

- (void) back{
    [self.photos removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) returnPhotos{
//    if ([self.controller respondsToSelector:@selector(returnChoosePhotos:)]) {
//        [self.controller returnChoosePhotos:self.photos];
//    }
//    if ([self.controller respondsToSelector:@selector(returnChooseOriginalPhotos:)]){
//        [self addOriginalImage];
//    }else{
//        [self back];
//    }
    self.originalImageIndex = 0;
    self.littleImageIndex = 0;
    if (_isOriginal) {
        if ([self.controller respondsToSelector:@selector(returnChooseOriginalPhotos:)]){
            [self addOriginalImage];
        }else{
            [self back];
        }
    }else{
        if ([self.controller respondsToSelector:@selector(returnChoosePhotos:)]) {
//            [self.controller returnChoosePhotos:self.photos];
            [self addSize800Image];
        }else{
            [self back];
        }
    }
}

- (void) addSize800Image{
    for (LUSCPhotoModel* model in self.photos) {
        model.limitSizeImageIndex = 0;
        CGFloat w = model.asset.pixelWidth/2;
        CGFloat h = model.asset.pixelHeight/2;
        CGSize size = CGSizeMake(w, h);
        if (w<800&&h<800) {//得到图片一半大小的图片,如果都小于800就得到原图
            size = CGSizeMake(w, h);
        }
        __weak typeof(self) weakSelf=self;
        [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:size completion:^(UIImage * _Nonnull image) {
            //            if (size.width-10<=image.size.width&&size.width+10>=image.size.width&&size.height-10<=image.size.height&&size.height+10>=image.size.height) {
            //                model.limitSizeImage = image;
            //                [weakSelf returnLimitSizeImage];
            //            }
            if (model.limitSizeImageIndex==0) {
                model.littleImage = image;
                model.limitSizeImageIndex++;
            }else{
                if (model.littleImage.size.width<image.size.width&&model.littleImage.size.height<image.size.height) {
                    model.limitSizeImage = image;
                    model.limitSizeImageIndex++;
                    [self returnLimitSizeImage];
                }else{
                    model.limitSizeImage = model.littleImage;
                    model.limitSizeImageIndex++;
                    [self returnLimitSizeImage];
                }
            }
            
        }];
    }
}
-(void) returnLimitSizeImage{
    for (LUSCPhotoModel* model in self.photos) {
        if (model.limitSizeImage == nil) {
            return;
        }
    }
    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.photos];
    [self.controller returnChoosePhotos:array];
    
    [self back];
}
- (void) addOriginalImage{
    for (LUSCPhotoModel* model in self.photos) {
        model.originalImageIndex = 0;
        CGFloat w = model.asset.pixelWidth;
        CGFloat h = model.asset.pixelHeight;
        CGSize size = CGSizeMake(w, h);
        __weak typeof(self) weakSelf=self;
        [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:size completion:^(UIImage * _Nonnull image) {
            if (model.originalImageIndex==0) {
                model.littleImage = image;
                model.originalImageIndex++;
            }else{
                if (model.littleImage.size.width<image.size.width&&model.littleImage.size.height<image.size.height) {
                    model.originalImage = image;
                    model.originalImageIndex++;
                    [self returnOriginalSizeImage];
                }else{
                    model.originalImage = model.littleImage;
                    model.originalImageIndex++;
                    [self returnOriginalSizeImage];
                }
            }
        }];
    }
}
-(void) returnOriginalSizeImage{
    for (LUSCPhotoModel* model in self.photos) {
        if (model.originalImage == nil) {
            return;
        }
    }
    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.photos];
    [self.controller returnChooseOriginalPhotos:array];
    
    [self back];
}



//- (void) addSize800Image{
//    for (LUSCPhotoModel* model in self.photos) {
//        CGFloat w = model.asset.pixelWidth/2;
//        CGFloat h = model.asset.pixelHeight/2;
//        CGSize size = CGSizeMake(w, h);
//        if (w<800&&h<800) {//得到图片一半大小的图片,如果都小于800就得到原图
//            size = CGSizeMake(w, h);
//        }
//        WeakSelf
//        [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:size completion:^(UIImage * _Nonnull image) {
//            if (size.width-10<=image.size.width&&size.width+10>=image.size.width&&size.height-10<=image.size.height&&size.height+10>=image.size.height) {
//                model.limitSizeImage = image;
//                [weakSelf returnLimitSizeImage];
//            }
//        }];
//    }
//}
//-(void) returnLimitSizeImage{
//    for (LUSCPhotoModel* model in self.photos) {
//        if (model.limitSizeImage == nil) {
//            return;
//        }
//    }
//    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.photos];
//    [self.controller returnChoosePhotos:array];
//    [self back];
//}
//
//
//- (void) addOriginalImage{
//    if (self.originalImageIndex == self.photos.count) {
//        NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.photos];
//        [self.controller returnChooseOriginalPhotos:array];
//        [self back];
//        return;
//    }
//
//    LUSCPhotoModel* model = [self.photos objectAtIndex:self.originalImageIndex];
//
//    if (model.originalImage!=nil) {
//        self.originalImageIndex++;
//        [self addOriginalImage];
//    }else{
//        __weak typeof(self) weakSelf = self;
//        [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:CGSizeMake(-1, -1) completion:^(UIImage * _Nonnull image) {
//            model.originalImage = image;
//            weakSelf.originalImageIndex++;
//            [weakSelf addOriginalImage];
//        }];
//    }
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
