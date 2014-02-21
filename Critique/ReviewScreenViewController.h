//
//  ReviewScreenViewController.h
//  Critique
//
//  Created by Nur on 8/10/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import "MovieRecord.h"
#import "ImageSearchResult.h"
#import <UIKit/UIKit.h>


@protocol ReviewScreenViewDelegate <NSObject>

- (void)dismissReviewScreenView;

@end

@interface ReviewScreenViewController : UIViewController <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bigImgView;
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *starsLabel;

@property (strong, nonatomic) MovieRecord *movieRecord;
@property (strong, nonatomic) ImageSearchResult *imgSearchResult;

@property (weak, nonatomic) id <ReviewScreenViewDelegate> delegate;

@end

