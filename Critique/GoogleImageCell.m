//
//  GoogleImageCell.m
//  Critique
//
//  Created by Nur on 7/20/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "GoogleImageCell.h"

@implementation GoogleImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.frame  = CGRectMake(self.contentView.frame.origin.x+1, self.contentView.frame.origin.y+1, self.contentView.frame.size.width-2, self.contentView.frame.size.height-2);
        //        self.imageView.frame  = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds=YES;
        [self addSubview:self.imageView];
        [self sendSubviewToBack:self.imageView];
        self.cellTag = -1;
    }
    return self;
}

@end
