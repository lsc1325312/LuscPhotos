//
//  LUSCPhotoGroupTableViewCell.m
//  LuscPhotos
//
//  Created by xy on 2018/9/20.
//  Copyright © 2018年 xy. All rights reserved.
//

#import "LUSCPhotoGroupTableViewCell.h"

@interface LUSCPhotoGroupTableViewCell ()

@property (nonatomic,strong) UIImageView* titleImageView;
@property (nonatomic,strong) UILabel* titleLabel;
@property (nonatomic,strong) UIImageView* nextImageView;

@end


@implementation LUSCPhotoGroupTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createImageView];
        [self createNext];
        [self createLabel];
    }
    return self;
}

-(void) createImageView{
    self.titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 34, 34)];
    [self.contentView addSubview:self.titleImageView];
}

-(void) createLabel{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 13, [UIScreen mainScreen].applicationFrame.size.width-60-self.nextImageView.frame.size.width-5, 18)];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.titleLabel];
}

-(void) createNext{
    self.nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.contentView addSubview:self.nextImageView];
}


-(void) setTitleName:(NSString*) string{
    self.titleLabel.text = string;
}

-(void) setTitleImage:(UIImage *) image{
    self.titleImageView.image = image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
