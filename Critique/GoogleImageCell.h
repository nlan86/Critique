//
//  GoogleImageCell.h
//  Critique
//
//  Created by Nur on 7/20/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "MBSpinningCircle.h"
#import <UIKit/UIKit.h>

@interface GoogleImageCell : UICollectionViewCell

@property (nonatomic, strong) MBSpinningCircle *loadCircle;
@property (nonatomic, strong) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *loadSpinner;
@property (nonatomic, assign) NSInteger cellTag;

@end
