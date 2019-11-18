//
//  LUSCPreviewImageTeamNarrowImageView.m
//  LuscPhotos
//
//  Created by xy on 2018/9/29.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPreviewImageTeamNarrowImageView.h"
#import "LUSCPhotosManager.h"

@interface LUSCPreviewImageTeamNarrowImageView()

@property (nonatomic,strong) UIImageView* imageView;

@property (nonatomic,strong) UIView* maskView;

@property (nonatomic) BOOL isShow;

@end

@implementation LUSCPreviewImageTeamNarrowImageView


-(instancetype)initWithFrame:(CGRect)frame image:(LUSCPhotoModel*) model{
    if (self = [super initWithFrame:frame]) {
        self.model = model;
        self.imageView = [[UIImageView alloc] initWithImage:model.littleImage];
        if (model.littleImage==nil) {
            __weak typeof(self) weakSelf=self;
            [[LUSCPhotosManager sharedPhotosManager] getLittleImageWithAsset:model completion:^(UIImage * _Nonnull image) {
                model.littleImage = image;
                weakSelf.imageView.image = image;
            }];
        }
        CGFloat ratio = [self ratio];
        self.imageView.frame = CGRectMake(0, 0, model.littleImage.size.width*ratio, model.littleImage.size.height*ratio);
        self.imageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self addSubview:self.imageView];
        
        self.clipsToBounds = YES;

        
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.maskView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.55];
        [self addSubview:self.maskView];
        
        self.maskView.hidden = YES;
        
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchSelf)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void) setModel:(LUSCPhotoModel *)model{
    _model = model;
    self.imageView.image = model.littleImage;
    CGFloat ratio = [self ratio];
    self.imageView.frame = CGRectMake(0, 0, model.littleImage.size.width*ratio, model.littleImage.size.height*ratio);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

-(void) showSelected{
    self.layer.borderColor = [UIColor colorWithRed:(0x48/225.0) green:(0xC1/255.0) blue:(0xA4/255.0) alpha:1].CGColor;
    self.layer.borderWidth = 2;
    self.isShow = YES;
}

-(void) hideSelected{
    self.layer.borderColor = [UIColor clearColor].CGColor;
    self.layer.borderWidth = 0;
    self.isShow=NO;
}

-(void) showMask{
    self.maskView.hidden=NO;
}

-(void) hideMask{
    self.maskView.hidden=YES;
}

-(CGFloat) ratio{
    if (self.imageView.image==nil) {
        return 1;
    }
    CGFloat ratio = self.frame.size.width/self.imageView.image.size.width;
    if (self.imageView.image.size.height*ratio<self.frame.size.height) {
        ratio = self.frame.size.height/self.imageView.image.size.height;
    }
    return ratio;
}

-(void) touchSelf{
    if (!self.isShow) {
        [self showSelected];
    }else{
        [self hideSelected];
    }
    
    if ([self.controller respondsToSelector:@selector(touchNarrowImageModel:imageView:)]) {
        [self.controller touchNarrowImageModel:self.model imageView:self];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
