//
//  LUSCPreviewImageViewController.m
//  LuscPhotos
//
//  Created by xy on 2018/9/27.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPreviewImageViewController.h"
#import "UIImage+LUSCColorTransformation.h"
#import "LUSCPreviewImageView.h"
#import "LUSCPreviewImageTeamView.h"
#import "LUSCPhotosManager.h"
#import "LUSCPhotoManage.h"

#define LUSCPreviewNON -1
#define UIColorFromHexadecimalAlphaLUSCPreview(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0]
#define mainColorPreview UIColorFromHexadecimalAlphaLUSCPreview(0xff48C1a4)

@interface LUSCPreviewImageViewController ()<UIScrollViewDelegate,LUSCPreviewImageTeamViewDelegate>

@property (nonatomic) NSInteger MAXScrollNum;
@property (nonatomic,strong) UIScrollView* previewScroll;

@property (nonatomic,strong) UIView* bottomButtonView;
@property (nonatomic) CGFloat bottomHeight;
@property (nonatomic,strong) UIImageView* viewInreturnButton;
@property (nonatomic) CGPoint viewInreturnButtonCenter;
@property (nonatomic) CGRect viewInreturnButtonFrame;
@property (nonatomic,strong) UILabel* viewInreturnLabel;
@property (nonatomic,strong) UIButton* OKButton;

@property (nonatomic) CGSize scrollOffsetSize;

@property (nonatomic,strong) NSMutableArray<LUSCPreviewImageView*>* imagesView;//正面显示的图像
@property (nonatomic,strong) NSMutableArray<LUSCPreviewImageView*>* waitImagesView;//等待显示的图像

@property (nonatomic,strong) LUSCPreviewImageTeamView* selectedTeamView;

@property (nonatomic) CGSize collisionArea;


@property (nonatomic,weak) NSMutableArray<LUSCPhotoModel*>* previewPhotos;
@property (nonatomic,strong) NSMutableArray<LUSCPhotoModel*>* waitRemovePhotos;


@property (nonatomic) CGFloat tempOffSet;

@property (nonatomic) NSInteger viewIndex;

@property (nonatomic) BOOL isInit;

@property (nonatomic) NSInteger notResetImageIndex;

@property (nonatomic) NSInteger littleImageIndex;
@property (nonatomic) NSInteger originalImageIndex;


@property (nonatomic,strong) UIView* isOriginalTouchView;//是否传原图的点击事件
@property (nonatomic,strong) UIView* isOriginalCircleView1;//伪同心圆
@property (nonatomic,strong) UIView* isOriginalCircleView2;//伪同心圆
@property (nonatomic,strong) UILabel* isOriginalLabel;//文字

@end

@implementation LUSCPreviewImageViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavAndSelf];
    [self createScroll];
    
    [self createBaseView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        self.bottomHeight = self.view.safeAreaInsets.bottom;
    }
    [self createBottomButton];
    [self createSelectedTeamView];
}


#pragma mark - event

- (void) touchOriginal{
    _isOriginal = !_isOriginal;
    if (_isOriginal) {
        [self setOriginalYES];
    }else{
        [self setOriginalNO];
    }
}

-(void) back{
    if (self.source == PreviewImageSource_touchPreview) {
        if (self.waitRemovePhotos.count!=0) {
            for (LUSCPhotoModel* model in self.waitRemovePhotos) {
                [self.choosePhotos removeObject:model];
            }
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) choose{
    NSInteger index = (self.previewScroll.contentOffset.x+self.scrollOffsetSize.width)/self.previewScroll.frame.size.width;
    LUSCPhotoModel* model = [self.previewPhotos objectAtIndex:index];
    NSInteger chooseIndex = [self indexWithSelectedImage:model];
    if (self.source == PreviewImageSource_touchPreview) {
        LUSCPhotoModel* mModel = nil;
        for (LUSCPhotoModel* cmodel in self.waitRemovePhotos) {
            if (cmodel==model) {
                mModel = cmodel;
                break;
            }
        }
        if (mModel==nil) {
            [self closeTouchSelectedButton:chooseIndex];
            [self.waitRemovePhotos addObject:model];
            [self.selectedTeamView removePhoto:model removeType:LUSCPreviewImageRemove_waitRemove];
        }else{
            [self openTouchSelectedButton:[self getAddPreviewModelIndex:model]];
            [self.waitRemovePhotos removeObject:model];
            [self.selectedTeamView addPhotoRefresh:model addType:LUSCPreviewImageRemove_waitRemove];
        }
        
        
    }else if (self.source == PreviewImageSource_touchImage) {
        if (chooseIndex == LUSCPreviewNON) {
            
            if (self.choosePhotos.count>=self.MAXSelectedNumber) {
                
                NSLog(@"选择的超个数了");
                
                return;
            }
            
            [self.choosePhotos addObject:model];
            [self openTouchSelectedButton:self.choosePhotos.count];
            [self.selectedTeamView addPhotoRefresh:model addType:LUSCPreviewImageRemove_remvoe];
        }else{
            [self closeTouchSelectedButton:chooseIndex];
            [self removeChoosePhotoModelWithModel:model];
            [self.selectedTeamView removePhoto:model removeType:LUSCPreviewImageRemove_remvoe];
        }
        
    }
    
    [self setOKButtonNum:self.choosePhotos.count removeNum:self.waitRemovePhotos.count];
//    if (chooseIndex == LUSCPreviewNON) {
//        if (self.source == PreviewImageSource_touchPreview) {
//            [self openTouchSelectedButton:self.choosePhotos.count];
//            [self.selectedTeamView addPhotoRefresh:model addType:LUSCPreviewImageRemove_waitRemove];
//        }else if (self.source == PreviewImageSource_touchImage) {
//            [self.choosePhotos addObject:model];
//            [self openTouchSelectedButton:self.choosePhotos.count];
//            [self.selectedTeamView addPhotoRefresh:model addType:LUSCPreviewImageRemove_remvoe];
//        }
//    }else{
//        [self closeTouchSelectedButton:chooseIndex];
////        [self removeChoosePhotoModelWithModel:model];
//        if (self.source == PreviewImageSource_touchPreview) {
//            [self.selectedTeamView removePhoto:model removeType:(LUSCPreviewImageRemove_waitRemove)];
//        }else if (self.source == PreviewImageSource_touchImage) {
//            [self.selectedTeamView removePhoto:model removeType:(LUSCPreviewImageRemove_remvoe)];
//        }
//    }
}

- (void) returnPhotos{
    if (self.source == PreviewImageSource_touchPreview) {
        if (self.waitRemovePhotos.count!=0) {
            for (LUSCPhotoModel* model in self.waitRemovePhotos) {
                [self.choosePhotos removeObject:model];
            }
        }
    }
    
//    NSMutableArray<LUSCPhotoModel*>* array = [NSMutableArray arrayWithArray:self.choosePhotos];
//    self.OKButton.userInteractionEnabled = NO;
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

- (void) touchImage{
//    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:NO];
    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    self.bottomButtonView.hidden = !self.bottomButtonView.hidden;
    if (self.selectedTeamView.choosePhotos.count!=0) {
        self.selectedTeamView.hidden = !self.selectedTeamView.hidden;
    }
    
    for (LUSCPreviewImageView* imageView in self.imagesView) {
        [imageView setHiddenStatus:self.navigationController.navigationBarHidden];
    }
    
}

#pragma mark - LUSCPreviewImageTeamViewDelegate

-(void) removeModel:(LUSCPhotoModel*) removeModel photos:(NSMutableArray*) array{
    
}
-(void) addModel:(LUSCPhotoModel *)addModel photos:(NSMutableArray*) array{
    
}

-(void) selectedModel:(LUSCPhotoModel*) model photosView:(LUSCPreviewImageTeamNarrowImageView*) view{
    self.currentDisplayIndex = [self indexWithModel:model];
    
    NSInteger index = self.currentDisplayIndex-1;
    
    for (LUSCPreviewImageView* v in self.imagesView) {
        v.frame = CGRectMake(index*self.previewScroll.frame.size.width+self.scrollOffsetSize.width, self.scrollOffsetSize.height, v.frame.size.width, v.frame.size.height);
        LUSCPhotoModel* m = nil;
        if (index>=0&&index<self.previewPhotos.count) {
            m = [self.previewPhotos objectAtIndex:index];
        }
        [self setViewInfoWithInfoIndex:index displayView:v];
        [self selectedCurrentDisplayImage:m];
        index++;
    }
    self.isInit=NO;
    self.previewScroll.contentOffset = CGPointMake(self.currentDisplayIndex*self.previewScroll.frame.size.width, 0);
    NSInteger cindex = [self getIndexInChoosePhotos:model];
    if (cindex!=LUSCPreviewNON) {
        [self openTouchSelectedButton:cindex];
    }
}

#pragma mark - UIScrollViewDelegate
//节点判断 如果手不放开无法得到index
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat index = scrollView.contentOffset.x/scrollView.frame.size.width;
//    NSInteger indexInt = index;
//    if ((index - indexInt)>0) {
//        return;
//    }
//    if (index!=self.currentDisplayIndex) {
//        self.currentDisplayIndex = index;
//    }
//}
//碰撞判断
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.isInit) {
        self.isInit=YES;
        return;
    }
    [self collisionDetectionScroll:scrollView];
}


-(void) collisionDetectionScroll:(UIScrollView *)scrollView{
//    if (self.previewPhotos.count<4) {
//        return;
//    }
    CGPoint center = [self getCollisionCenterWithScroll:scrollView];
    
    //计算白碰撞区域
    CGRect collisionRect = CGRectMake(center.x-self.collisionArea.width/2, center.y-self.collisionArea.height/2,self.collisionArea.width, self.collisionArea.height);
    
    //得到滑动方向; 负数是右滑 屏左动; 正数是左滑 屏右动;
    CGFloat tempCur = scrollView.contentOffset.x;
    CGFloat temp = tempCur - self.tempOffSet;
    self.tempOffSet = tempCur;
    
//    [self viewPositionTransformation:scrollView];
    
    //三个View的碰撞检测与View的位置变化
    [self setMultiplexingPosition:collisionRect detectionDirection:(temp>0?1:-1)];
    
    [self setDisplaySelectedButton:scrollView];
    
    [self resetImage:scrollView];
}


#pragma mark - create

-(void) createSelectedTeamView{
    if (self.selectedTeamView) {
        return;
    }
    LUSCPreviewImageRemove type = LUSCPreviewImageRemove_waitRemove;
    if (self.source == PreviewImageSource_touchImage) {
        type = LUSCPreviewImageRemove_remvoe;
    }
    self.selectedTeamView = [[LUSCPreviewImageTeamView alloc] initWithFrame:CGRectMake(0, self.bottomButtonView.frame.origin.y-80, self.view.frame.size.width, 80) choosePhoto:self.choosePhotos removeType:type];
    self.selectedTeamView.controller = self;
    self.selectedTeamView.choosePhotos = self.choosePhotos;
    [self.view addSubview:self.selectedTeamView];
    
    [self setSelectedTeamBox:self.currentDisplayIndex];
}


- (void) createBaseView{
    self.imagesView = [NSMutableArray array];
    self.waitImagesView = [NSMutableArray array];
    NSInteger index = self.currentDisplayIndex - 1;
    //加载显示图层
    for (NSInteger i = 0; i<3; i++) {
        LUSCPhotoModel* model = nil;
        if (index+i<0||index+i>=self.previewPhotos.count) {
            model = nil;
        }else{
            model = [self.previewPhotos objectAtIndex:index+i];
        }
        
        LUSCPreviewImageView* view = [[LUSCPreviewImageView alloc] initWithFrame:CGRectMake((index+i)*self.previewScroll.frame.size.width, 0, self.previewScroll.frame.size.width, self.previewScroll.frame.size.height)];
//        view.backgroundColor = [UIColor colorWithRed:10/255.0 green:(i*40)/255.0 blue:(255-50*i)/255.0 alpha:1];
        
        [self setDisplayImageWithModel:model inView:view];
        [self.previewScroll addSubview:view];
        
        view.frame = CGRectInset(view.frame, self.scrollOffsetSize.width, self.scrollOffsetSize.height);
        
        [self.imagesView addObject:view];
    }
    //加载等待图层
    for (NSInteger i = 0; i<2; i++) {
        LUSCPreviewImageView* view = [[LUSCPreviewImageView alloc] initWithFrame:CGRectMake((index+i)*self.previewScroll.frame.size.width, 0, self.previewScroll.frame.size.width, self.previewScroll.frame.size.height)];
//        view.backgroundColor = [UIColor colorWithRed:200/255.0 green:(i*40)/255.0 blue:(255-50*i)/255.0 alpha:1];
        [self.previewScroll addSubview:view];
        view.frame = CGRectInset(view.frame, self.scrollOffsetSize.width, self.scrollOffsetSize.height);
        view.hidden = YES;
        [self.waitImagesView addObject:view];
    }
    
    
    self.previewScroll.contentOffset = CGPointMake(self.currentDisplayIndex*self.previewScroll.frame.size.width, 0);
    NSInteger cindex = self.previewScroll.contentOffset.x/self.previewScroll.frame.size.width;
    [self selectedCurrentDisplayImage:[self.previewPhotos objectAtIndex:cindex]];
    
    //第一回加载图像的位置
}

- (void) createScroll{
    self.MAXScrollNum = self.previewPhotos.count;
    
    self.previewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(-self.scrollOffsetSize.width, 0, self.view.frame.size.width+self.scrollOffsetSize.width*2, self.view.frame.size.height)];
    self.previewScroll.delegate = self;
    self.previewScroll.backgroundColor = [UIColor clearColor];
    self.previewScroll.pagingEnabled = YES;
    self.previewScroll.showsVerticalScrollIndicator=YES;
    self.previewScroll.showsHorizontalScrollIndicator=YES;
    [self.view addSubview:self.previewScroll];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImage)];
    [self.previewScroll addGestureRecognizer:tap];
    
    self.previewScroll.contentSize = CGSizeMake(self.MAXScrollNum*self.previewScroll.frame.size.width, self.previewScroll.frame.size.height);
    
    self.collisionArea = CGSizeMake(self.previewScroll.frame.size.width*3, self.view.frame.size.height);
    
    self.tempOffSet = self.currentDisplayIndex*self.previewScroll.frame.size.width;
}

- (void) createBottomButton{
    if (self.bottomButtonView!=nil) {
        return;
    }
    
    self.bottomButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-self.bottomHeight, self.view.frame.size.width, self.bottomHeight+50)];
    self.bottomButtonView.backgroundColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:0.55];
    [self.view addSubview:self.bottomButtonView];
    
    self.OKButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bottomButtonView.frame.size.width-20-65, 10, 65, 30)];
    [self.OKButton setBackgroundColor:[UIColor colorWithRed:(0x48/255.0) green:(0xC1/255.0) blue:(0xA4/255.0) alpha:1]];
    [self.OKButton addTarget:self action:@selector(returnPhotos) forControlEvents:(UIControlEventTouchUpInside)];
    self.OKButton.layer.cornerRadius = 6;
    self.OKButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomButtonView addSubview:self.OKButton];
    
    
    _isOriginalTouchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.bottomButtonView addSubview:_isOriginalTouchView];
    
    _isOriginalCircleView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];//伪同心圆
    _isOriginalCircleView1.backgroundColor = [UIColor clearColor];
    _isOriginalCircleView1.layer.cornerRadius = _isOriginalCircleView1.frame.size.width/2;
    _isOriginalCircleView1.layer.borderWidth = 2;
    _isOriginalCircleView1.layer.borderColor = [UIColor whiteColor].CGColor;
    [_isOriginalTouchView addSubview:_isOriginalCircleView1];
    
    _isOriginalCircleView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];//伪同心圆
    _isOriginalCircleView2.backgroundColor = [UIColor greenColor];
    _isOriginalCircleView2.layer.cornerRadius = _isOriginalCircleView2.frame.size.width/2;
    _isOriginalCircleView2.center = CGPointMake(_isOriginalCircleView1.frame.size.width/2, _isOriginalCircleView1.frame.size.height/2);
    [_isOriginalCircleView1 addSubview:_isOriginalCircleView2];
    
    _isOriginalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _isOriginalLabel.font = [UIFont systemFontOfSize:14];
    _isOriginalLabel.text = @"原图";
    _isOriginalLabel.textColor = [UIColor whiteColor];
    [_isOriginalLabel sizeToFit];
    [_isOriginalTouchView addSubview:_isOriginalLabel];
    
    _isOriginalTouchView.frame = CGRectMake(0, 0, _isOriginalLabel.frame.size.width+2+_isOriginalCircleView1.frame.size.width, 16);
    _isOriginalCircleView1.center = CGPointMake(_isOriginalCircleView1.frame.size.width/2, _isOriginalTouchView.frame.size.height/2);
    _isOriginalLabel.center = CGPointMake(_isOriginalTouchView.frame.size.width-_isOriginalLabel.frame.size.width/2, _isOriginalTouchView.frame.size.height/2);
    _isOriginalTouchView.center = CGPointMake(_bottomButtonView.frame.size.width/2, _OKButton.center.y);
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOriginal)];
    [_isOriginalTouchView addGestureRecognizer:tap];
    
    if (_isOriginal) {
        [self setOriginalYES];
    }else{
        [self setOriginalNO];
    }
    
    [self setOKButtonNum:self.choosePhotos.count removeNum:self.waitRemovePhotos.count];
}

#pragma mark - set and get

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
    _isOriginalCircleView1.layer.borderColor = [UIColor whiteColor].CGColor;
    _isOriginalCircleView2.hidden = YES;
    _isOriginalLabel.textColor = [UIColor whiteColor];
    _returnIsOriginal(NO);
}

//设置self的相关信息与nav的相关信息
- (void) setNavAndSelf{
    self.edgesForExtendedLayout = UIRectEdgeAll;//显示类型 是否从顶点计算
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
    
    self.navigationController.navigationBar.translucent = YES;
    
    
    self.waitRemovePhotos = [NSMutableArray array];
    if (self.backImage) {
        self.backImage = [self.backImage imageWithColor:[UIColor whiteColor]];
        UIButton* blackButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
        [blackButton setImage:self.backImage forState:UIControlStateNormal];
        blackButton.tintColor =[UIColor whiteColor];
        [blackButton setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [blackButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithCustomView:blackButton];
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    UIButton* returnButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44)];
    [returnButton addTarget:self action:@selector(choose) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithCustomView:returnButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    CGFloat w =20;
    
    self.viewInreturnButton = [[UIImageView alloc] initWithFrame:CGRectMake((returnButton.frame.size.width-w)/2+5, (returnButton.frame.size.height-w)/2+3, w, w)];
    self.viewInreturnButtonCenter = self.viewInreturnButton.center;
    self.viewInreturnButtonFrame = self.viewInreturnButton.frame;
    self.viewInreturnButton.layer.cornerRadius=self.viewInreturnButton.frame.size.width/2;
    self.viewInreturnButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewInreturnButton.layer.borderWidth = 1;
    [returnButton addSubview:self.viewInreturnButton];
    
    self.viewInreturnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.viewInreturnButton.frame.size.width, self.viewInreturnButton.frame.size.height)];
    self.viewInreturnLabel.font = [UIFont systemFontOfSize:13];
    self.viewInreturnLabel.textAlignment = NSTextAlignmentCenter;
    self.viewInreturnLabel.textColor = [UIColor whiteColor];
    [self.viewInreturnButton addSubview:self.viewInreturnLabel];
    
    self.view.backgroundColor = [UIColor blackColor];
    
//    self.edgesForExtendedLayout = UIRectEdgeAll;//显示类型 是否从顶点计算
//    self.automaticallyAdjustsScrollViewInsets = NO;//当第一个视图是scrollview时是否跟具NavBar调整scrollview的大小
    
    self.scrollOffsetSize = CGSizeMake(5, 0);
    
    switch (self.source) {
        case PreviewImageSource_touchImage:{
            self.previewPhotos = self.photos;
            break;}
        case PreviewImageSource_touchPreview:{
            self.previewPhotos = self.choosePhotos;
            break;}
    }
}
//计算碰撞区域中心点
- (CGPoint) getCollisionCenterWithScroll:(UIScrollView*) scrollView{
    CGPoint center = CGPointMake(scrollView.frame.size.width/2+scrollView.contentOffset.x, scrollView.frame.size.height/2+scrollView.contentOffset.y);
    return center;
}
//view复用机制 direction 负数是右滑 屏左动; 正数是左滑 屏右动;
- (void) setMultiplexingPosition:(CGRect) collisionRect detectionDirection:(NSInteger) direction{
    LUSCPreviewImageView* waitView = nil;
    for (LUSCPreviewImageView* view in self.imagesView){
        //手往右滑动 屏往左前进
        BOOL isCollision = YES;
        CGFloat nextDisplayX = view.frame.origin.x;
        if (direction<0) {
            isCollision = CGRectContainsPoint(collisionRect,CGPointMake(view.frame.origin.x+view.frame.size.width, 0));
            nextDisplayX = view.frame.origin.x-3*self.previewScroll.frame.size.width;
        }else if(direction>0){//手往左滑动 屏往右前进
            isCollision = CGRectContainsPoint(collisionRect,view.frame.origin);
            nextDisplayX = view.frame.origin.x+3*self.previewScroll.frame.size.width;
        }
        
        if (!isCollision) {
            view.hidden = YES;
            [self.waitImagesView addObject:view];
            waitView = [self.waitImagesView objectAtIndex:0];
            waitView.displayImage = nil;
            [self.waitImagesView removeObject:waitView];
            waitView.hidden=NO;
            waitView.frame = CGRectMake(nextDisplayX, 0, waitView.frame.size.width, waitView.frame.size.height);
        }
    }
    if (waitView!=nil) {
        for (LUSCPreviewImageView* view in self.waitImagesView) {
            [self.imagesView removeObject:view];
        }
        CGFloat cindex = waitView.frame.origin.x/self.previewScroll.frame.size.width;
        NSInteger index = cindex;
        if (cindex<0) {
            index = -1;
        }
        [self.imagesView addObject:waitView];
        [self setViewInfoWithInfoIndex:index displayView:waitView];
    }
}

//图像信息加载
- (void) setViewInfoWithInfoIndex:(NSInteger) index displayView:(LUSCPreviewImageView*) view{
    if (index<0||index>=self.previewPhotos.count) {
        view.displayImage = nil;
        return;
    }
    LUSCPhotoModel* model = nil;
    
    if (index>=self.previewPhotos.count||index<0) {
        model = nil;
    }else{
        model = [self.previewPhotos objectAtIndex:index];
    }
    
    [self setDisplayImageWithModel:model inView:view];
    //滑动加载后一页图像的位置
}

- (void) setDisplaySelectedButton:(UIScrollView*) scrollView{
    if (scrollView.contentOffset.x<0) {
        return;
    }
    if (scrollView.contentOffset.x+scrollView.frame.size.width>scrollView.contentSize.width) {
        return;
    }
    CGFloat scr = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSInteger index = scr;
    if (scr-index!=0) {
        return;
    }
    
    LUSCPhotoModel* model = [self.previewPhotos objectAtIndex:index];
    
    [self selectedCurrentDisplayImage:model];
    [self setSelectedTeamBox:index];
}

- (void) setOKButtonNum:(NSInteger) count removeNum:(NSInteger) removeCount{
    
    if ((count-removeCount)==0) {
        [self.OKButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.OKButton setTitle:@"完成" forState:UIControlStateHighlighted];
        [self.OKButton setTitle:@"完成" forState:UIControlStateDisabled];
    }else{
        NSString* string = [NSString stringWithFormat:@"完成(%d)",(int)(count-removeCount)];
        [self.OKButton setTitle:string forState:UIControlStateNormal];
        [self.OKButton setTitle:string forState:UIControlStateHighlighted];
        [self.OKButton setTitle:string forState:UIControlStateDisabled];
    }
    
    
    if (count==0) {
        self.OKButton.userInteractionEnabled = NO;
    }else{
        self.OKButton.userInteractionEnabled = YES;
    }
    
}

- (void) setDisplayImageWithModel:(LUSCPhotoModel*) model inView:(LUSCPreviewImageView*) view{
    if (model==nil) {
        view.displayImage = nil;
        return;
    }
    if (model.originalImage == nil) {
        if (model.littleImage == nil) {
            [[LUSCPhotosManager sharedPhotosManager] getOriginalImageWithAsset:model completion:^(UIImage * _Nonnull image) {
                view.displayImage = image;
            }];
        }else{
            view.displayImage = model.littleImage;
            [[LUSCPhotosManager sharedPhotosManager] getOriginalImageWithAsset:model completion:^(UIImage * _Nonnull image) {
                view.displayImage = image;
            }];
        }
    }else{
        view.displayImage = model.originalImage;
    }
}

-(void) resetImage:(UIScrollView*) scrollView{
    CGFloat ci = scrollView.contentOffset.x/scrollView.frame.size.width;
    NSInteger ni = ci;
    if (ci-ni!=0) {
        return;
    }
    if (self.notResetImageIndex==ni) {
        return;
    }
    self.notResetImageIndex = ni;
    
    for (NSInteger i=0;i<self.imagesView.count;i++) {
        LUSCPreviewImageView* v = [self.imagesView objectAtIndex:i];
        [v resetImage];
    }
    
}

//得到当前显示model 不要在scroll滑动时使用，会不准
-(LUSCPhotoModel*) getCurrentModel{
    NSInteger index = self.previewScroll.contentOffset.x/self.previewScroll.frame.size.width;
    return [self.previewPhotos objectAtIndex:index];
}

-(void) setSelectedTeamBox:(NSInteger) selectedIndex{
    if (selectedIndex<0||selectedIndex>=self.previewPhotos.count) {
        return;
    }
    [self.selectedTeamView setSelected:[self.previewPhotos objectAtIndex:selectedIndex]];
}

-(void)setCurrentDisplayIndex:(NSInteger)currentDisplayIndex{
    _currentDisplayIndex = currentDisplayIndex;
    _notResetImageIndex = currentDisplayIndex;
}

-(NSInteger) getPreviewModelIndex:(LUSCPhotoModel*) model{
    if (self.source == PreviewImageSource_touchPreview) {
        NSInteger index = 0;
        for (NSInteger i=0; i<self.choosePhotos.count; i++) {
            LUSCPhotoModel* cModel = [self.choosePhotos objectAtIndex:i];
            if (model==cModel) {
                for (LUSCPhotoModel* wModel in self.waitRemovePhotos) {
                    if (wModel==model) {
                        return LUSCPreviewNON;
                    }
                }
                return i-index;
            }else{
                for (LUSCPhotoModel* wModel in self.waitRemovePhotos) {
                    if (wModel==cModel) {
                        index++;
                    }
                }
            }
        }
    }
    return LUSCPreviewNON;
}

-(NSInteger) getIndexInChoosePhotos:(LUSCPhotoModel*) model{
    
    for (int i=0; i<self.choosePhotos.count; i++) {
        LUSCPhotoModel* m = [self.choosePhotos objectAtIndex:i];
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            return i+1;
        }
    }
    return LUSCPreviewNON;
}

-(NSInteger) getAddPreviewModelIndex:(LUSCPhotoModel*) model{
    if (self.source == PreviewImageSource_touchPreview) {
        NSInteger index = 0;
        for (NSInteger i=0; i<self.choosePhotos.count; i++) {
            LUSCPhotoModel* cModel = [self.choosePhotos objectAtIndex:i];
            if (model==cModel) {
                return i-index+1;
            }else{
                for (LUSCPhotoModel* wModel in self.waitRemovePhotos) {
                    if (wModel==cModel) {
                        index++;
                    }
                }
            }
        }
    }
    return LUSCPreviewNON;
}

-(NSInteger) indexWithModel:(LUSCPhotoModel* _Nonnull) model{
    NSInteger index = LUSCPreviewNON;
    for (int i=0; i<self.previewPhotos.count; i++) {
        LUSCPhotoModel* m = [self.previewPhotos objectAtIndex:i];
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            index = i;
            break;
        }
    }
    return index;
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
        CGFloat w = model.asset.pixelWidth;
        CGFloat h = model.asset.pixelHeight;
        CGSize size = CGSizeMake(w, h);
        __weak typeof(self) weakSelf=self;
        [[LUSCPhotoManage defaultPhotoManage] getImageWithAsset:model size:size completion:^(UIImage * _Nonnull image) {
//            if (size.width-10<=image.size.width&&size.width+10>=image.size.width&&size.height-10<=image.size.height&&size.height+10>=image.size.height) {
//                model.originalImage = image;
//                [weakSelf returnOriginalSizeImage];
//            }
            if (model.originalImageIndex==0) {
                model.littleImage = image;
                model.originalImageIndex++;
                NSLog(@"0");
            }else{
                if (model.littleImage.size.width<image.size.width&&model.littleImage.size.height<image.size.height) {
                    model.originalImage = image;
                    model.originalImageIndex++;
                    [self returnOriginalSizeImage];
                    NSLog(@"1");
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
//
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

#pragma mark - animation
//删除选择数组中的model
-(BOOL) removeChoosePhotoModelWithModel:(LUSCPhotoModel*) model{
    for (NSInteger i = 0;i<self.choosePhotos.count;i++){
        LUSCPhotoModel* selectedImage = [self.choosePhotos objectAtIndex:i];
        if ([model.asset.localIdentifier isEqualToString:selectedImage.asset.localIdentifier]) {
            [self.choosePhotos removeObject:selectedImage];
            return YES;
        }
    }
    return NO;
}

//返回选中图片的索引如果没有返回LUSCPreviewNON
-(NSInteger) indexWithSelectedImage:(LUSCPhotoModel*) model{
    
    for (NSInteger i = 0;i<self.choosePhotos.count;i++){
        LUSCPhotoModel* selectedImage = [self.choosePhotos objectAtIndex:i];
        if ([model.asset.localIdentifier isEqualToString:selectedImage.asset.localIdentifier]) {
            return i;
        }
    }
    return LUSCPreviewNON;
}
//设置选择按钮
-(void) selectedCurrentDisplayImage:(LUSCPhotoModel*) model{
    if (model==nil) {
        return;
    }
    NSInteger index = [self indexWithSelectedImage:model];
    if (self.source == PreviewImageSource_touchPreview) {
        index = [self getPreviewModelIndex:model];
    }
    if (index != LUSCPreviewNON) {
        self.viewInreturnButton.backgroundColor = mainColorPreview;
        self.viewInreturnLabel.hidden=NO;
        
        self.viewInreturnLabel.text = [NSString stringWithFormat:@"%d",(int)index+1];
        
        self.viewInreturnButton.layer.cornerRadius=self.viewInreturnButton.frame.size.width/2;
        self.viewInreturnButton.layer.borderColor = [UIColor clearColor].CGColor;
        self.viewInreturnButton.layer.borderWidth = 0;
    }else{
        self.viewInreturnButton.layer.cornerRadius=self.viewInreturnButton.frame.size.width/2;
        self.viewInreturnButton.layer.borderColor = [UIColor grayColor].CGColor;
        self.viewInreturnButton.layer.borderWidth = 1;
        
        self.viewInreturnButton.backgroundColor = [UIColor clearColor];
        self.viewInreturnLabel.hidden=YES;
    }
}

-(void) openTouchSelectedButton:(NSInteger) index{
    self.viewInreturnButton.backgroundColor = mainColorPreview;
    self.viewInreturnLabel.hidden=NO;
    self.viewInreturnLabel.text = [NSString stringWithFormat:@"%d",(int)index];
    
    self.viewInreturnButton.layer.cornerRadius=self.viewInreturnButton.frame.size.width/2;
    self.viewInreturnButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.viewInreturnButton.layer.borderWidth = 0;
    
    [self selected1];
}

-(void) closeTouchSelectedButton:(NSInteger) index{
    self.viewInreturnButton.layer.cornerRadius=self.viewInreturnButton.frame.size.width/2;
    self.viewInreturnButton.layer.borderColor = [UIColor grayColor].CGColor;
    self.viewInreturnButton.layer.borderWidth = 1;
    
    self.viewInreturnButton.backgroundColor = [UIColor clearColor];
    self.viewInreturnLabel.hidden=YES;
}

-(void) selected1{
    self.viewInreturnButton.frame = CGRectMake(0, 0, self.viewInreturnButtonFrame.size.width+4, self.viewInreturnButtonFrame.size.height+4);
    self.viewInreturnButton.center = self.viewInreturnButtonCenter;
    self.viewInreturnButton.layer.cornerRadius = self.viewInreturnButtonFrame.size.width/2;
    self.viewInreturnLabel.center = CGPointMake(self.viewInreturnButton.frame.size.width/2, self.viewInreturnButton.frame.size.height/2);
    
    [self performSelector:@selector(selected2) withObject:nil afterDelay:0.08];
}
-(void) selected2{
    self.viewInreturnButton.frame = CGRectMake(0, 0, self.viewInreturnButtonFrame.size.width-2, self.viewInreturnButtonFrame.size.height-2);
    self.viewInreturnButton.center = self.viewInreturnButtonCenter;
    self.viewInreturnButton.layer.cornerRadius = self.viewInreturnButtonFrame.size.width/2;
    self.viewInreturnLabel.center = CGPointMake(self.viewInreturnButton.frame.size.width/2, self.viewInreturnButton.frame.size.height/2);
    [self performSelector:@selector(selected3) withObject:nil afterDelay:0.08];
}
-(void) selected3{
    self.viewInreturnButton.frame = CGRectMake(0, 0, self.viewInreturnButtonFrame.size.width+2, self.viewInreturnButtonFrame.size.height+2);
    self.viewInreturnButton.center = self.viewInreturnButtonCenter;
    self.viewInreturnButton.layer.cornerRadius = self.viewInreturnButtonFrame.size.width/2;
    self.viewInreturnLabel.center = CGPointMake(self.viewInreturnButton.frame.size.width/2, self.viewInreturnButton.frame.size.height/2);
    [self performSelector:@selector(selected4) withObject:nil afterDelay:0.04];
}
-(void) selected4{
    self.viewInreturnButton.frame = CGRectMake(0, 0, self.viewInreturnButtonFrame.size.width-1, self.viewInreturnButtonFrame.size.height-1);
    self.viewInreturnButton.center = self.viewInreturnButtonCenter;
    self.viewInreturnButton.layer.cornerRadius = self.viewInreturnButtonFrame.size.width/2;
    self.viewInreturnLabel.center = CGPointMake(self.viewInreturnButton.frame.size.width/2, self.viewInreturnButton.frame.size.height/2);
    [self performSelector:@selector(selected5) withObject:nil afterDelay:0.04];
}
-(void) selected5{
    self.viewInreturnButton.frame = CGRectMake(0, 0, self.viewInreturnButtonFrame.size.width, self.viewInreturnButtonFrame.size.height);
    self.viewInreturnButton.center = self.viewInreturnButtonCenter;
    self.viewInreturnButton.layer.cornerRadius = self.viewInreturnButtonFrame.size.width/2;
    self.viewInreturnLabel.center = CGPointMake(self.viewInreturnButton.frame.size.width/2, self.viewInreturnButton.frame.size.height/2);
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
