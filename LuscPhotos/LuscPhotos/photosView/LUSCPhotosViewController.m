//
//  LUSCPhotosViewController.m
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotosViewController.h"
#import "LUSCPhotoManage.h"
#import "LUSCPhotoCollectionViewCell.h"
#import "UIImage+LUSCColorTransformation.h"
#import "LUSCPreviewImageViewController.h"


@interface LUSCPhotosViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LUSCPhotoCollectionViewCellDelegate>

@property (nonatomic,strong) UICollectionView* photoCollectionView;
@property (nonatomic,strong) NSMutableArray<LUSCPhotoModel*>* photos;
@property (nonatomic,strong) UIView* bottomButtonView;
@property (nonatomic,strong) UIButton* OKButton;
@property (nonatomic,strong) UIButton* lookButton;



@property (nonatomic,strong) UIView* isOriginalTouchView;//是否传原图的点击事件
@property (nonatomic,strong) UIView* isOriginalCircleView1;//伪同心圆
@property (nonatomic,strong) UIView* isOriginalCircleView2;//伪同心圆
@property (nonatomic,strong) UILabel* isOriginalLabel;//文字

@property (nonatomic) NSInteger littleImageIndex;
@property (nonatomic) NSInteger originalImageIndex;

@property (nonatomic) NSInteger bottomHeight;

@end

@implementation LUSCPhotosViewController


#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setSelf];
    
    [self createCollectionView];
    
    [self getAllPhotos];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.photoCollectionView reloadData];
    [self setOKButtonTitle];
}



-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.bottomHeight = self.view.safeAreaInsets.bottom;
    }
    [self createBottomButton];
}


#pragma mark - event

- (void) lookSelected{
    if (self.choosePhotos.count==0) {
        return;
    }
    LUSCPreviewImageViewController* vc = [[LUSCPreviewImageViewController alloc] init];
    vc.controller = self.controller;
    vc.choosePhotos = self.choosePhotos;
    vc.backImage = self.backImage;
    vc.currentDisplayIndex = 0;
    vc.source = PreviewImageSource_touchPreview;
    vc.isOriginal = self.isOriginal;
    vc.returnIsOriginal = ^(BOOL isO) {
        if (isO) {
            [self setOriginalYES];
        }else{
            [self setOriginalNO];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) returnPhotos{
//    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.choosePhotos];
    self.OKButton.userInteractionEnabled = NO;
    self.originalImageIndex = 0;
    self.littleImageIndex = 0;
    if (_isOriginal) {
        if ([self.controller respondsToSelector:@selector(returnChooseOriginalPhotos:)]){
            [self addOriginalImage];
        }else{
            [self.choosePhotos removeAllObjects];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else{
//        if ([self.controller respondsToSelector:@selector(returnChoosePhotos:)]) {
//            [self.controller returnChoosePhotos:array];
//        }
//        [self.choosePhotos removeAllObjects];
//        [self dismissViewControllerAnimated:YES completion:nil];
        if ([self.controller respondsToSelector:@selector(returnChoosePhotos:)]) {
            [self addSize800Image];
        }else{
            [self.choosePhotos removeAllObjects];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


- (void) addSize800Image{
    for (LUSCPhotoModel* model in self.choosePhotos) {
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
    for (LUSCPhotoModel* model in self.choosePhotos) {
        if (model.limitSizeImage == nil) {
            return;
        }
    }
    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.choosePhotos];
    [self.controller returnChoosePhotos:array];
    
    [self.choosePhotos removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) addOriginalImage{
    for (LUSCPhotoModel* model in self.choosePhotos) {
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
    for (LUSCPhotoModel* model in self.choosePhotos) {
        if (model.originalImage == nil) {
            return;
        }
    }
    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.choosePhotos];
    [self.controller returnChooseOriginalPhotos:array];
    
    [self.choosePhotos removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//- (void) addOriginalImage{
//    if (self.originalImageIndex == self.choosePhotos.count) {
//        NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.choosePhotos];
//        [self.controller returnChooseOriginalPhotos:array];
//
//        [self.choosePhotos removeAllObjects];
//        [self dismissViewControllerAnimated:YES completion:nil];
//        return;
//    }
//
//    LUSCPhotoModel* model = [self.choosePhotos objectAtIndex:self.originalImageIndex];
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



- (void) back{
    [self.choosePhotos removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) dismiss{
    [self.choosePhotos removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) touchOriginal{
    _isOriginal = !_isOriginal;
    if (_isOriginal) {
        [self setOriginalYES];
    }else{
        [self setOriginalNO];
    }
}

#pragma mark - LUSCPhotoCollectionViewCellDelegate

-(void)touchSelected:(UICollectionViewCell *) cell indexPath:(nonnull NSIndexPath *)indexPath{
    LUSCPhotoCollectionViewCell* lcell = (LUSCPhotoCollectionViewCell*) cell;
        
    LUSCPhotoModel* model = [self.photos objectAtIndex:indexPath.row];
    
    LUSCPhotoModel* selectedModel = nil;
    
    BOOL bl = NO;
    
    for (LUSCPhotoModel* sele in self.choosePhotos) {
        if ([sele.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            bl = YES;
            selectedModel = sele;
            break;
        }
    }
    
    if (bl) {
        [lcell setNotSelectedImage:self.normalImage];
        selectedModel.littleImage = nil;
        [self.choosePhotos removeObject:selectedModel];
        
        [self resetNumber];
    }else{
        if(self.choosePhotos.count==self.MAXSelectedNumber){
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多可以选择%ld个",self.MAXSelectedNumber] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
        }else{
            [lcell setSelectedImage:self.selectedImage];
            model.littleImage = [lcell getImage];
            [self.choosePhotos addObject:model];
            lcell.beSelectedNumber = self.choosePhotos.count;
        }
    }
    
    [self setMaskIsShow:(self.choosePhotos.count>=self.MAXSelectedNumber)];
    
    [self setOKButtonTitle];
}


#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"LUSCPhotoCollectionViewCell";
    LUSCPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.controller = self;
    cell.indexPath = indexPath;
    LUSCPhotoModel* model = [self.photos objectAtIndex:indexPath.row];
    cell.localIdentifier = model.asset.localIdentifier;
    cell.index = model.index;

    [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model completion:^(UIImage * _Nonnull image) {
//        [cell setImage:[self imageCompressFitSizeScale:image targetSize:cell.frame.size]];
        model.littleImage = image;
        [cell setImage:image];
    }];
    
    NSInteger index = 1;
    BOOL bl = NO;
    for (LUSCPhotoModel* sele in self.choosePhotos) {
        if ([sele.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            bl = YES;
            break;
        }
        index++;
    }
    
    if (bl) {
        [cell setSelectedImage:self.selectedImage];
        cell.beSelectedNumber = index;
    }else{
        [cell setNotSelectedImage:self.normalImage];
    }
    
    
    if (self.choosePhotos.count>=self.MAXSelectedNumber) {
        [cell showMask];
    }else{
        [cell hideMask];
    }
    
//    cell.backgroundColor = [UIColor colorWithRed:((10 * indexPath.row) / 255.0) green:((20 * indexPath.row)/255.0) blue:((30 * indexPath.row)/255.0) alpha:1.0f];
    
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.photoCollectionView.frame.size.width/self.sectionNumber-3, self.photoCollectionView.frame.size.width/self.sectionNumber-3);
}
//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//这个是两行cell之间的间距（上下行cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 3;
}

//两个cell之间的间距（同一行的cell的间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 3;
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LUSCPhotoCollectionViewCell * cell = (LUSCPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    LUSCPreviewImageViewController* vc = [[LUSCPreviewImageViewController alloc] init];
    vc.MAXSelectedNumber = self.MAXSelectedNumber;
    vc.controller = self.controller;
    vc.photos = self.photos;
    vc.choosePhotos = self.choosePhotos;
    vc.backImage = self.backImage;
    vc.currentDisplayIndex = cell.index;
    vc.source = PreviewImageSource_touchImage;
    vc.isOriginal = self.isOriginal;
    vc.returnIsOriginal = ^(BOOL isO) {
        if (isO) {
            [self setOriginalYES];
        }else{
            [self setOriginalNO];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - create

-(void) createCollectionView{
//    CGFloat statusHeight = [UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.frame.size.height;
    UICollectionViewFlowLayout * layout =[[UICollectionViewFlowLayout alloc] init];
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.photoCollectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.photoCollectionView];
    
    [self.photoCollectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    [self.photoCollectionView registerClass:[LUSCPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"LUSCPhotoCollectionViewCell"];
    
    [LUSCPhotoManage defaultPhotoManage].globalAttributes_ImageCompressSize = CGSizeMake(self.view.frame.size.width*2/self.sectionNumber, self.view.frame.size.width*2/self.sectionNumber);
}


- (void) createBottomButton{
    if (self.bottomButtonView!=nil) {
        return;
    }
    
    self.bottomButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-self.bottomHeight, self.view.frame.size.width, self.bottomHeight+50)];
    self.bottomButtonView.backgroundColor = UIColorFromHexadecimalAlphaLUSC(0xff2d2d2d);
    [self.view addSubview:self.bottomButtonView];
    
    self.photoCollectionView.frame = CGRectMake(self.photoCollectionView.frame.origin.x, self.photoCollectionView.frame.origin.y, self.photoCollectionView.frame.size.width, self.photoCollectionView.frame.size.height-self.bottomButtonView.frame.size.height);
    
    
    self.OKButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomButtonView.frame.size.width-20-65, 10, 65, 30)];
    [self setOKButtonTitle];
    [self.OKButton setBackgroundColor:[UIColor greenColor]];
    [self.OKButton addTarget:self action:@selector(returnPhotos) forControlEvents:(UIControlEventTouchUpInside)];
    self.OKButton.layer.cornerRadius = 6;
    self.OKButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomButtonView addSubview:self.OKButton];

    self.lookButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 65, 30)];
    [self.lookButton setTitle:@"预览" forState:UIControlStateNormal];
    [self.lookButton setTitle:@"预览" forState:UIControlStateHighlighted];
    [self.lookButton setTitle:@"预览" forState:UIControlStateDisabled];
    [self.lookButton setBackgroundColor:UIColorFromHexadecimalAlphaLUSC(0x00000000)];
    [self.lookButton addTarget:self action:@selector(lookSelected) forControlEvents:(UIControlEventTouchUpInside)];
    self.lookButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bottomButtonView addSubview:self.lookButton];
    
    
    _isOriginalTouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.bottomButtonView addSubview:_isOriginalTouchView];
    
    _isOriginalCircleView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];//伪同心圆
    _isOriginalCircleView1.backgroundColor = [UIColor clearColor];
    _isOriginalCircleView1.layer.cornerRadius = _isOriginalCircleView1.frame.size.width/2;
    _isOriginalCircleView1.layer.borderWidth = 2;
    _isOriginalCircleView1.layer.borderColor = UIColorFromHexadecimalAlphaLUSC(0xffffffff).CGColor;
    [_isOriginalTouchView addSubview:_isOriginalCircleView1];
    
    _isOriginalCircleView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];//伪同心圆
    _isOriginalCircleView2.backgroundColor = [UIColor greenColor];
    _isOriginalCircleView2.layer.cornerRadius = _isOriginalCircleView2.frame.size.width/2;
    _isOriginalCircleView2.center = CGPointMake(_isOriginalCircleView1.frame.size.width/2, _isOriginalCircleView1.frame.size.height/2);
    [_isOriginalCircleView1 addSubview:_isOriginalCircleView2];
    
    _isOriginalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _isOriginalLabel.font = [UIFont systemFontOfSize:14];
    _isOriginalLabel.text = @"原图";
    _isOriginalLabel.textColor = UIColorFromHexadecimalAlphaLUSC(0xffffffff);
    [_isOriginalLabel sizeToFit];
    [_isOriginalTouchView addSubview:_isOriginalLabel];
    
    _isOriginalTouchView.frame = CGRectMake(0, 0, _isOriginalLabel.frame.size.width+2+_isOriginalCircleView1.frame.size.width, 16);
    _isOriginalCircleView1.center = CGPointMake(_isOriginalCircleView1.frame.size.width/2, _isOriginalTouchView.frame.size.height/2);
    _isOriginalLabel.center = CGPointMake(_isOriginalTouchView.frame.size.width-_isOriginalLabel.frame.size.width/2, _isOriginalTouchView.frame.size.height/2);
    _isOriginalTouchView.center = CGPointMake(_bottomButtonView.frame.size.width/2, _lookButton.center.y);
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOriginal)];
    [_isOriginalTouchView addGestureRecognizer:tap];
    
    if (_isOriginal) {
        [self setOriginalYES];
    }else{
        [self setOriginalNO];
    }
    
    
     [self setOKButtonTitle];
}

#pragma mark - seter and geter
//选择原图
- (void) setOriginalYES{
    _isOriginal = YES;
    _isOriginalCircleView1.layer.borderColor = [UIColor greenColor].CGColor;
    _isOriginalCircleView2.hidden = NO;
    _isOriginalLabel.textColor = [UIColor greenColor];
    _returnIsOriginal(YES);
}
//没选择原图
- (void) setOriginalNO{
    _isOriginal = NO;
    _isOriginalCircleView1.layer.borderColor = UIColorFromHexadecimalAlphaLUSC(0xffffffff).CGColor;
    _isOriginalCircleView2.hidden = YES;
    _isOriginalLabel.textColor = UIColorFromHexadecimalAlphaLUSC(0xffffffff);
    _returnIsOriginal(NO);
}

- (void) setSelf{
    self.navigationItem.title = self.photoTitle==nil?self.groupModel.groupTitle:self.photoTitle;
    
    if (self.backImage) {
        self.backImage = [self.backImage imageWithColor:UIColorFromHexadecimalAlphaLUSC(0xffffffff)];
        UIButton* blackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
        [blackButton setImage:self.backImage forState:UIControlStateNormal];
        blackButton.tintColor = UIColorFromHexadecimalAlphaLUSC(0xffffffff);
        [blackButton setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [blackButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:blackButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    UIButton* returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    [returnButton setTitle:@"取消" forState:UIControlStateNormal];
    [returnButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [returnButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:returnButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void) setupOKButtonState{
    if (self.choosePhotos==nil||self.choosePhotos.count==0) {
        self.OKButton.userInteractionEnabled=NO;
    }else{
        self.OKButton.userInteractionEnabled=YES;
    }
}

- (void) setOKButtonTitle{
    
    NSInteger count = self.choosePhotos.count;
    NSString* countString = [NSString stringWithFormat:@"%ld",(long)count];
    
    [self.OKButton setTitle:[NSString stringWithFormat:@"完成%@%@%@",count==0?@"":@"(",count==0?@"":countString,count==0?@"":@")"] forState:UIControlStateNormal];
    [self.OKButton setTitle:[NSString stringWithFormat:@"完成%@%@%@",count==0?@"":@"(",count==0?@"":countString,count==0?@"":@")"] forState:UIControlStateHighlighted];
    [self.OKButton setTitle:[NSString stringWithFormat:@"完成%@%@%@",count==0?@"":@"(",count==0?@"":countString,count==0?@"":@")"] forState:UIControlStateDisabled];
    
    [self setupOKButtonState];
}


- (void) getAllPhotos{
    if (self.groupModel==nil) {
        self.photos = [[LUSCPhotoManage defaultPhotoManage] allPhotos];
    }else{
        self.photos = [[LUSCPhotoManage defaultPhotoManage] allPhotosWithGroup:self.groupModel];
    }
    [self.photoCollectionView reloadData];
}

- (void) setCollectionOffset{
    CGPoint offset = CGPointMake(0, self.photoCollectionView.contentSize.height - self.photoCollectionView.frame.size.height);
    if (self.photoCollectionView.contentSize.height>self.photoCollectionView.frame.size.height) {
        [self.photoCollectionView setContentOffset:offset animated:NO];
    }
    [self.photoCollectionView removeObserver:self forKeyPath:@"contentSize"];
}

- (void) setMaskIsShow:(BOOL) isShow{
    
    if (isShow) {
        for (id view in self.photoCollectionView.subviews) {
            if ([view isKindOfClass:[LUSCPhotoCollectionViewCell class]]) {
                LUSCPhotoCollectionViewCell* cell = view;
                [cell showMask];
            }
        }
    }else{
        for (id view in self.photoCollectionView.subviews) {
            if ([view isKindOfClass:[LUSCPhotoCollectionViewCell class]]) {
                LUSCPhotoCollectionViewCell* cell = view;
                [cell hideMask];
            }
        }
    }
    
}

- (void) resetNumber{
    for (id view in self.photoCollectionView.subviews) {
        if ([view isKindOfClass:[LUSCPhotoCollectionViewCell class]]) {
            LUSCPhotoCollectionViewCell* cell = view;
            if (!cell.isBeSelected) {
                continue;
            }
            NSInteger index = 1;
            BOOL bl = NO;
            for (LUSCPhotoModel* sele in self.choosePhotos) {
                if ([sele.asset.localIdentifier isEqualToString:cell.localIdentifier]) {
                    bl = YES;
                    break;
                }
                index++;
            }
            
            if (bl) {
                cell.beSelectedNumber = index;
            }
        }
    }
}

#pragma mark -

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    [self setCollectionOffset];
}


////指定宽度按比例缩放
//-(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
//
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = defineWidth;
//    CGFloat targetHeight = height / (width / targetWidth);
//    CGSize size = CGSizeMake(targetWidth, targetHeight);
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
//
//    if(CGSizeEqualToSize(imageSize, size) == NO){
//
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//
//        if(widthFactor > heightFactor){
//            scaleFactor = widthFactor;
//        }
//        else{
//            scaleFactor = heightFactor;
//        }
//        scaledWidth = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//
//        if(widthFactor > heightFactor){
//
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//
//        }else if(widthFactor < heightFactor){
//
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//
//    UIGraphicsBeginImageContext(size);
//
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//
//    [sourceImage drawInRect:thumbnailRect];
//
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    if(newImage == nil){
//
//        NSLog(@"scale image fail");
//    }
//    UIGraphicsEndImageContext();
//    return newImage;
//}


////按比例缩放,size 是你要把图显示到 多大区域
//- (UIImage *) imageCompressFitSizeScale:(UIImage *)sourceImage targetSize:(CGSize)size{
//    UIImage *newImage = nil;
//    CGSize imageSize = sourceImage.size;
//    CGFloat width = imageSize.width;
//    CGFloat height = imageSize.height;
//    CGFloat targetWidth = size.width;
//    CGFloat targetHeight = size.height;
//    CGFloat scaleFactor = 0.0;
//    CGFloat scaledWidth = targetWidth;
//    CGFloat scaledHeight = targetHeight;
//    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
//    
//    if(CGSizeEqualToSize(imageSize, size) == NO){
//        
//        CGFloat widthFactor = targetWidth / width;
//        CGFloat heightFactor = targetHeight / height;
//        
//        if(widthFactor > heightFactor){
//            scaleFactor = widthFactor;
//            
//        }
//        else{
//            
//            scaleFactor = heightFactor;
//        }
//        scaledWidth = width * scaleFactor;
//        scaledHeight = height * scaleFactor;
//        
//        if(widthFactor > heightFactor){
//            
//            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
//        }else if(widthFactor < heightFactor){
//            
//            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
//        }
//    }
//    
//    UIGraphicsBeginImageContext(size);
//    
//    CGRect thumbnailRect = CGRectZero;
//    thumbnailRect.origin = thumbnailPoint;
//    thumbnailRect.size.width = scaledWidth;
//    thumbnailRect.size.height = scaledHeight;
//    
//    [sourceImage drawInRect:thumbnailRect];
//    
//    newImage = UIGraphicsGetImageFromCurrentImageContext();
//    if(newImage == nil){
//        NSLog(@"scale image fail");
//    }
//    
//    UIGraphicsEndImageContext();
//    return newImage;
//}



#pragma mark -




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
