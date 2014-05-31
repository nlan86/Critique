//
//  CritiqueViewController.h
//  Critique
//
//  Created by Nur on 7/21/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>

#import "ReviewScreenViewController.h"
#import "FilmSearchTextField.h"
#import "GoogleImageSearcher.h"
#import "TMDBImageSearcher.h"
#import "MoviesAPI.h"

@interface CritiqueViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, ReviewScreenViewDelegate>

@property UIImageView *currentBackgroundImageView;
@property (nonatomic, retain) MoviesAPI *currentMoviesAPI;
@property int currentPic;

@property (weak, nonatomic) IBOutlet UITextView *filmDescriptionText;
@property (weak, nonatomic) IBOutlet FilmSearchTextField *movieNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *critiqueLogoLabel;
@property (weak, nonatomic) IBOutlet UILabel *critiqueLogoLabelPlaceHolder;
@property (weak, nonatomic) IBOutlet UILabel *critiqueLogoMiddlePlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *critiqueLogoLabelBottomPlaceholder;
@property (weak, nonatomic) IBOutlet UITableView *filmResultsTable;
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@property (weak, nonatomic) IBOutlet UIImageView *logoGradientBGImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *movieDetailsCollectionView;


-(void)showMovieDetails: (MovieRecord *)movieRecord;
-(void)filmResultsDidLoad;

@end
