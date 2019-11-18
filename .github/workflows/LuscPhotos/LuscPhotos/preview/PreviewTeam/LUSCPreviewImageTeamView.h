//
//  LUSCPreviewImageTeamView.h
//  LuscPhotos
//
//  Created by xy on 2018/9/29.
//  Copyright © 2018年 xy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LUSCPhotoModel.h"
#import "LUSCPreviewImageTeamNarrowImageView.h"

#define SPACE 8

typedef NS_ENUM(NSInteger,LUSCPreviewImageRemove) {
    LUSCPreviewImageRemove_remvoe, //点击图片进来的删除方法
    LUSCPreviewImageRemove_waitRemove //点击预览进来的删除方法
};

@protocol LUSCPreviewImageTeamViewDelegate <NSObject>

-(void) removeModel:(LUSCPhotoModel*) removeModel photos:(NSMutableArray*) array;
-(void) addModel:(LUSCPhotoModel*) addModel photos:(NSMutableArray*) array;

-(void) selectedModel:(LUSCPhotoModel*) model photosView:(LUSCPreviewImageTeamNarrowImageView*) view;

@end

NS_ASSUME_NONNULL_BEGIN

@interface LUSCPreviewImageTeamView : UIView

@property (nonatomic,weak) UIViewController<LUSCPreviewImageTeamViewDelegate>* controller;
@property (nonatomic,weak) NSMutableArray<LUSCPhotoModel*>* choosePhotos;
@property (nonatomic) LUSCPreviewImageRemove type;

- (instancetype) initWithFrame:(CGRect)frame choosePhoto:(NSMutableArray<LUSCPhotoModel*>*) array removeType:(LUSCPreviewImageRemove) type;
- (void) addPhotoRefresh:(LUSCPhotoModel*) model addType:(LUSCPreviewImageRemove) type;
- (void) setSelected:(LUSCPhotoModel*) selectedModel;
- (void) removePhoto:(LUSCPhotoModel*) removePhoto removeType:(LUSCPreviewImageRemove) type;

//清空所有选择
-(void) clearAllSelected;

@end

NS_ASSUME_NONNULL_END
