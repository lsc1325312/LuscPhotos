//
//  LUSCPreviewImageTeamView.m
//  LuscPhotos
//
//  Created by xy on 2018/9/29.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPreviewImageTeamView.h"
#import "LUSCPreviewImageTeamNarrowImageView.h"

@interface LUSCPreviewImageTeamView()<LUSCPreviewImageTeamNarrowImageViewDelegate>

@property (nonatomic,strong) UIScrollView* scrollView;
@property (nonatomic,strong) NSMutableArray<LUSCPreviewImageTeamNarrowImageView*>* imagesViewArray;

@property (nonatomic) NSInteger currentSelectedIndex;

@end

@implementation LUSCPreviewImageTeamView

- (instancetype) initWithFrame:(CGRect)frame choosePhoto:(NSMutableArray<LUSCPhotoModel*>*) array removeType:(LUSCPreviewImageRemove) type{
    if (self = [super initWithFrame:frame]) {
        self.currentSelectedIndex = -1;
        self.choosePhotos = array;
        self.type = type;
        self.backgroundColor = [UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:0.55];
        [self setSelfHidden];
        
        [self createTeamView];
        [self setImageAndScrollContentSize];
        [self createLine];
    }
    return self;
}

- (void) createLine{
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(SPACE, self.frame.size.height-1, self.frame.size.width-SPACE*2, 1)];
    line.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
    [self addSubview:line];
}

- (void) createTeamView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    self.imagesViewArray = [NSMutableArray array];
}

- (LUSCPreviewImageTeamNarrowImageView*) createPreviewImage:(LUSCPhotoModel*) model{
    LUSCPreviewImageTeamNarrowImageView* view = [[LUSCPreviewImageTeamNarrowImageView alloc] initWithFrame:CGRectMake(SPACE, SPACE, self.frame.size.height-SPACE*2, self.frame.size.height-SPACE*2) image:model];
    view.controller = self;
    [self.scrollView addSubview:view];
    [self.imagesViewArray addObject:view];
    return view;
}

#pragma mark - remove

- (void) removePreviewImage:(LUSCPreviewImageTeamNarrowImageView*) view{
    if (self.type == LUSCPreviewImageRemove_waitRemove) {
        [view showMask];
    }else{
        [self removeAnimation:view];
    }
}

- (void) removeAnimation:(LUSCPreviewImageTeamNarrowImageView*) view{
    NSInteger index = -1;
    for (NSInteger i=0; i<self.imagesViewArray.count; i++) {
        if ([self.imagesViewArray objectAtIndex:i]==view) {
            index = i;
            break;
        }
    }
    
    LUSCPreviewImageTeamNarrowImageView* nextView = nil;
    if (index+1<self.imagesViewArray.count) {
        nextView = [self.imagesViewArray objectAtIndex:index+1];
    }
    
    CGFloat w = nextView.center.x-view.center.x;
    
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha=0;
        for (NSInteger i=index+1; i<self.imagesViewArray.count; i++) {
            LUSCPreviewImageTeamNarrowImageView* v= [self.imagesViewArray objectAtIndex:i];
            v.center = CGPointMake(v.center.x-w, v.center.y);
        }
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
        [self.imagesViewArray removeObject:view];
        [self.choosePhotos removeObject:view.model];
    }];
}


#pragma mark - event

- (void) addPhotoRefresh:(LUSCPhotoModel*) model addType:(LUSCPreviewImageRemove) type{
    self.hidden=NO;
    
    if (type == LUSCPreviewImageRemove_waitRemove) {
        [self addWaitRemoveRefresh:model];
    }else if(type == LUSCPreviewImageRemove_remvoe){
        LUSCPreviewImageTeamNarrowImageView* image = [self createPreviewImage:model];
        [self.imagesViewArray addObject:image];
        
        [self addPhotoRefresh];
    }
}

- (void) addWaitRemoveRefresh:(LUSCPhotoModel*) model{
    LUSCPreviewImageTeamNarrowImageView* view = nil;
    for (LUSCPreviewImageTeamNarrowImageView* image in self.imagesViewArray) {
        if ([image.model.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            view = image;
            [image hideMask];
        }
    }
}

- (void) addPhotoRefresh{

    for (LUSCPreviewImageTeamNarrowImageView* image in self.imagesViewArray) {
        [image removeFromSuperview];
    }
    [self.imagesViewArray removeAllObjects];
    
    [self setImageAndScrollContentSize];
    
}

- (void) setSelected:(LUSCPhotoModel*) selectedModel{
    [self clearAllSelected];
    NSInteger index = 0;
    for (LUSCPreviewImageTeamNarrowImageView* v in self.imagesViewArray) {
        if ([v.model.asset.localIdentifier isEqualToString:selectedModel.asset.localIdentifier]) {
            [v showSelected];
            self.currentSelectedIndex = index;
            [self refreshScrollOffset];
            return;
        }
        index++;
    }
    self.currentSelectedIndex = -1;
}
- (void) removePhoto:(LUSCPhotoModel*) removePhoto removeType:(LUSCPreviewImageRemove) type{
    
    if (type == LUSCPreviewImageRemove_waitRemove) {
        
        [self removeWaitRemoveRefresh:removePhoto];
        
    }else if(type == LUSCPreviewImageRemove_remvoe){
        for (LUSCPreviewImageTeamNarrowImageView* image in self.imagesViewArray) {
            if ([image.model.asset.localIdentifier isEqualToString:removePhoto.asset.localIdentifier]) {
                [self removeAnimation:image];
            }
        }
    }
    
    [self setSelfHidden];
}

- (void) removeWaitRemoveRefresh:(LUSCPhotoModel*) model{
    LUSCPreviewImageTeamNarrowImageView* view = nil;
    for (LUSCPreviewImageTeamNarrowImageView* image in self.imagesViewArray) {
        if ([image.model.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            view = image;
            [image showMask];
        }
    }
}

#pragma mark - LUSCPreviewImageTeamNarrowImageViewDelegate

-(void) touchNarrowImageModel:(LUSCPhotoModel*) model imageView:(id)view{
    NSInteger index = -1;
    
    for (int i=0;i<self.choosePhotos.count;i++) {
        LUSCPhotoModel* ml = [self.choosePhotos objectAtIndex:i];
        if (ml==model) {
            index = i;
            break;
        }
    }
    
    if (index==-1) {
        return;
    }
    
    self.currentSelectedIndex = index;
    [self clearAllSelected];
    [view showSelected];
    [self refreshScrollOffset];
    if ([self.controller respondsToSelector:@selector(selectedModel:photosView:)]) {
        [self.controller selectedModel:model photosView:view];
    }
}

#pragma mark - set and get

-(void) clearAllSelected{
    for (LUSCPreviewImageTeamNarrowImageView* v in self.imagesViewArray) {
        [v hideSelected];
    }
}
//刷新选择图像位置
-(void) refreshScrollOffset{
    if (self.currentSelectedIndex==-1) {
        return;
    }
    if (self.scrollView.contentSize.width<self.scrollView.frame.size.width) {
        return;
    }
    
    LUSCPreviewImageTeamNarrowImageView* view = [self.imagesViewArray objectAtIndex:self.currentSelectedIndex];
    CGPoint point = view.center;
    
    CGPoint offset = self.scrollView.contentOffset;
    
    offset = CGPointMake(point.x - self.scrollView.frame.size.width/2, offset.y);
    
    
    if (offset.x<0) {
        offset = CGPointMake(0, offset.y);
    }
    if (offset.x>self.scrollView.contentSize.width-self.scrollView.frame.size.width) {
        offset = CGPointMake(self.scrollView.contentSize.width-self.scrollView.frame.size.width, offset.y);
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.contentOffset = offset;
    }];
}

-(void) setImageAndScrollContentSize{
    
    CGFloat x = SPACE;
    
    for (NSInteger i=0; i<self.choosePhotos.count; i++) {
        LUSCPhotoModel* model = [self.choosePhotos objectAtIndex:i];
        
        LUSCPreviewImageTeamNarrowImageView* view = [self createPreviewImage:model];
        
        view.center = CGPointMake(x + view.frame.size.width/2, SPACE+view.frame.size.height/2);
        
        x+=view.frame.size.width+SPACE;
    }
    
    self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.size.height);
}

-(void) setSelfHidden{
    if (self.choosePhotos.count==0) {
        self.hidden=YES;
    }else{
        self.hidden=NO;
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
