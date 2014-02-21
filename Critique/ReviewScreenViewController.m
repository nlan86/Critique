//
//  ReviewScreenViewController.m
//  Critique
//
//  Created by Nur on 8/10/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import "ReviewScreenViewController.h"

@interface ReviewScreenViewController ()

@end

@implementation ReviewScreenViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bigImgView.image = self.imgSearchResult.imageBig;
    self.movieTitleLabel.text = [self.movieRecord getFormattedNameAndYear];
    
    //add tap recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [tap setCancelsTouchesInView:NO];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) viewTapped {
    [self.delegate dismissReviewScreenView];
}

@end
