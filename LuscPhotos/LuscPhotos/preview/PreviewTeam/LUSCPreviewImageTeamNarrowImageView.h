//
//  LUSCPreviewImageTeamNarrowImageView.h
//  LuscPhotos
//
//  Created by xy on 2018/9/29.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSCPhotoModel.h"

@protocol LUSCPreviewImageTeamNarrowImageViewDelegate <NSObject>

-(void) touchNarrowImageModel:(LUSCPhotoModel*) model imageView:(id) view;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPreviewImageTeamNarrowImageView : UIView

@property (nonatomic,weak) id<LUSCPreviewImageTeamNarrowImageViewDelegate> controller;
@property (nonatomic,strong) LUSCPhotoModel* model;

-(instancetype)initWithFrame:(CGRect)frame image:(LUSCPhotoModel*) model;
-(void) showSelected;
-(void) hideSelected;
-(void) showMask;
-(void) hideMask;

@end

NS_ASSUME_NONNULL_END
