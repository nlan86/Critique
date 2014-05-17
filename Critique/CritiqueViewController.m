//
//  CritiqueViewController.m
//  Critique
//
//  Created by Nur on 7/21/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "ReviewScreenViewController.h"
#import "GoogleImageCell.h"
#import "MovieDetailsCollectionView.h"
#import "MWPhotoBrowser.h"
#import "MBProgressHUD.h"
#import "BlurManager.h"
#import "CritiqueMisc.h"
#import "CritiqueViewController.h"
#import "CritiqueJSONRestHandler.h"
#import "RottenAPI.h"
#import "MyMoviesAPI.h"
#import "TMDB_MoviesAPI.h"
#import "FilmResultsTableDelegate.h"

@interface CritiqueViewController () {
    FilmResultsTableDelegate *mainResultsTableDel;
    GoogleImageSearcher *googleImageSearcher;
    BOOL resultsDisplayed, curretlyBlurred, currentlyEditing, displayLastPosters, displayLastImages;
    CGFloat screenWidth, screenHeight;
    CGPoint lastLogoCenter;
    NSArray *bgPicsArray;
    NSInteger currentBGImage;
    NSTimer *bgSwitchTimer;
    BlurManager *blurManager;
    MovieDetailsCollectionView *movieDetailsCollectionViewHandler;
    MovieRecord *currentFilmDescriptionMovieRecord;

}

@end

@implementation CritiqueViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
  
    //get screen size
    CGRect screenRect = [self.view bounds]; //[[UIScreen mainScreen] bounds];
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    
    //init collection view
    [self.movieDetailsCollectionView registerClass:[GoogleImageCell class] forCellWithReuseIdentifier:@"GoogleCell"];

    [self.movieDetailsCollectionView setHidden:YES];
    movieDetailsCollectionViewHandler = [[MovieDetailsCollectionView alloc] init];
    self.movieDetailsCollectionView.delegate=movieDetailsCollectionViewHandler;
    self.movieDetailsCollectionView.dataSource=movieDetailsCollectionViewHandler;
    movieDetailsCollectionViewHandler.parentCollectionView = self.movieDetailsCollectionView;
    movieDetailsCollectionViewHandler.parentView = self;

    //init image searcher
    googleImageSearcher = [[GoogleImageSearcher alloc] init];
    movieDetailsCollectionViewHandler.imageSearcher = googleImageSearcher;
    
    //init bg switch timer
    bgSwitchTimer = [NSTimer scheduledTimerWithTimeInterval:GRAPHICS_BG_SWITCH_INTERVAL target:self selector:@selector(switchBGImage) userInfo:nil repeats:YES];
    
    //init state booleans
    resultsDisplayed=currentlyEditing=curretlyBlurred=displayLastImages=displayLastPosters=NO;
    
    //init blur manager
    blurManager = [[BlurManager alloc] init];
    
    //init bg pics list from plist
    NSString *plistBGPics = [[NSBundle mainBundle] pathForResource:@"bgImages" ofType:@"plist"];
    bgPicsArray = [NSArray arrayWithContentsOfFile:plistBGPics];

    //init bg image
    NSString *firstBGImgName = [[bgPicsArray objectAtIndex:currentBGImage]objectForKey:PLIST_BG_IMAGE_IMAGENAME_FIELD];
    CGRect bgImageRect = CGRectMake(-GRAPHICS_BG_ANIMATION_OFFSET, -GRAPHICS_BG_ANIMATION_OFFSET, screenWidth+(GRAPHICS_BG_ANIMATION_OFFSET*2), screenHeight+(GRAPHICS_BG_ANIMATION_OFFSET*2));
    [self.bgImgView setFrame:bgImageRect];
    UIImage *firstBGImg = [UIImage imageNamed:firstBGImgName];
    [self.bgImgView setImage:firstBGImg];
    
    //start animating bg image
    [self animateBG];
    
    //prepare blurred image for first bg
    [blurManager asyncBlurImageView:self.bgImgView imageTag: firstBGImgName doUpdate:NO];
    
    //get description for first bg pic
    [self putBGPicDescription: currentBGImage];
    
    [self.filmDescriptionText setFrame:CGRectMake(0,screenHeight-self.filmDescriptionText.bounds.size.height, screenWidth, self.filmDescriptionText.bounds.size.height)];
    
    //add tap recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    //set gesture recognizer for description
    UITapGestureRecognizer *descriptionTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(filmDescriptionWasTapped)];
    descriptionTap.cancelsTouchesInView=NO;
    [self.filmDescriptionText addGestureRecognizer:descriptionTap];
    
    //init swipe recognizer to switch bg image
    UISwipeGestureRecognizer *bgSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchBGImage)];
    bgSwipe.cancelsTouchesInView=NO;
    [self.bgImgView addGestureRecognizer:bgSwipe];
    
   //position bottom bg gradient
    [self.logoGradientBGImageView setFrame:CGRectMake(0,screenHeight-self.logoGradientBGImageView.bounds.size.height + DEFAULT_SPACING_PX, screenWidth, self.logoGradientBGImageView.bounds.size.height)];

    //position main table
    [self.filmResultsTable setHidden:YES];
    [self.filmResultsTable setFrame:CGRectMake(
                                               self.critiqueLogoLabelPlaceHolder.frame.origin.x,
                                               self.critiqueLogoLabelPlaceHolder.frame.origin.y + self.critiqueLogoLabel.bounds.size.height + self.movieNameTextField.bounds.size.height,
                                               self.critiqueLogoLabelPlaceHolder.bounds.size.width,
                                               screenHeight -                                                self.critiqueLogoLabelPlaceHolder.frame.origin.y - self.critiqueLogoLabel.bounds.size.height - self.movieNameTextField.bounds.size.height - 0)];
    //position images collection view
    [self.movieDetailsCollectionView setFrame:self.filmResultsTable.frame];
    
    //init main table
    resultsDisplayed=NO;
    mainResultsTableDel = [[FilmResultsTableDelegate alloc] init];
    mainResultsTableDel.parent = self;
    self.filmResultsTable.delegate =mainResultsTableDel;
    self.filmResultsTable.dataSource = mainResultsTableDel;
    mainResultsTableDel.movieResultsTableView = self.filmResultsTable;
    [self.filmResultsTable reloadData];

    //init logo text
    [self.critiqueLogoLabel setText:CRITIQUE_LOOG_QUESTION];

    //hide placeholders
    [self.critiqueLogoLabelPlaceHolder setHidden:YES];
    lastLogoCenter = self.critiqueLogoLabel.center;
    
    //init default movie search api
    self.currentMoviesAPI = [[CRITIQUE_DEFAULT_API alloc] init]; //use default api
    if (self.currentMoviesAPI == nil) {
        //TODO HANDLE API ERROR
    }
    mainResultsTableDel.moviesSearchObject=self.currentMoviesAPI;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:SEGUE_IDENTIFIER_MAIN_TO_REVIEW])
	{
        NSLog(@"Segue: %@\n",SEGUE_IDENTIFIER_MAIN_TO_REVIEW);
        ReviewScreenViewController *reviewScreen = (ReviewScreenViewController*)segue.destinationViewController;
        ImageSearchResult *selectedImageResult = [movieDetailsCollectionViewHandler.imageSearcher getImageResults:movieDetailsCollectionViewHandler.currentSelectedCollectionViewImage];
        MovieRecord *selectedMovieRecord = movieDetailsCollectionViewHandler.selectedMovieRecord;
        reviewScreen.movieRecord = selectedMovieRecord;
        reviewScreen.imgSearchResult = selectedImageResult;
        reviewScreen.delegate = self;
	}
}


#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.movieNameTextField) {
        currentlyEditing=YES;
        [self.critiqueLogoLabel setText:CRITIQUE_LOOG_QUESTION];
        [self manageViewsEndUpBlurred:YES postersHidden:YES imagesHidden:YES];
        [self animateFieldsToLast:NO toMiddle:YES toBottom:NO toTop:NO];

    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.movieNameTextField) {
        [self performFilmLookup];
    }
    return YES;
}

- (void)manageViewsEndUpBlurred: (BOOL)blur postersHidden:(BOOL)hidePosters imagesHidden:(BOOL)hideImages {
    
    [blurManager fadeView:self.movieDetailsCollectionView toVisible:!hideImages];
    [blurManager fadeView:self.filmResultsTable toVisible:!hidePosters];
    
    if (blur && !curretlyBlurred) {
        [blurManager asyncBlurImageView:self.bgImgView imageTag:[[bgPicsArray objectAtIndex:currentBGImage] objectForKey:PLIST_BG_IMAGE_IMAGENAME_FIELD] doUpdate:YES];
        curretlyBlurred=YES;
    }
    if (!blur && curretlyBlurred) {
        [blurManager asyncRevertBlurImageView:self.bgImgView toOriginal:[UIImage imageNamed:[[bgPicsArray objectAtIndex:currentBGImage]objectForKey:PLIST_BG_IMAGE_IMAGENAME_FIELD]]];
        curretlyBlurred=NO;
    }

}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark UIGestureReocognizerDelegate

//prevent text clear button from allowing gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of gestures in unwanted elements
    if ([touch.view isMemberOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}


#pragma mark MISC

- (void)performFilmLookup {
    [self.movieNameTextField resignFirstResponder]; //first get rid of keyboard
    currentlyEditing=NO;
    
    if ([self.movieNameTextField.text isEqualToString:@""]) {
        [self manageViewsEndUpBlurred:resultsDisplayed postersHidden:!displayLastPosters imagesHidden:!displayLastImages];
        [self animateFieldsToLast:YES toMiddle:NO toBottom:NO toTop:NO];
        
        return;
    }
    
    resultsDisplayed=YES;
    [self manageViewsEndUpBlurred:YES postersHidden:YES imagesHidden:YES];
    
    [mainResultsTableDel sendQueryThenLoadPosters:self.movieNameTextField.text];
    
}

-(void)filmResultsDidLoad {
    resultsDisplayed=YES;
    displayLastPosters=YES;
    displayLastImages=NO;
    
    [self.filmDescriptionText setHidden:YES];
    [self.filmResultsTable scrollRectToVisible:CGRectMake(0, 0, 1, 1)  animated:NO]; //scroll to top of table after update
    [self.filmResultsTable reloadData]; //reload data & redraw table
    [self manageViewsEndUpBlurred:YES postersHidden:NO imagesHidden:YES];
    [self animateFieldsToLast:NO toMiddle:NO toBottom:NO toTop:YES];
    
}

- (void)dismissKeyboard {
    if ([self.movieNameTextField isFirstResponder]) {
        [self.movieNameTextField resignFirstResponder];
        currentlyEditing=NO;
        
        [self manageViewsEndUpBlurred:resultsDisplayed postersHidden:!displayLastPosters imagesHidden:!displayLastImages];
        [self animateFieldsToLast:YES toMiddle:NO toBottom:NO toTop:NO];

    }
}

+ (CGAffineTransform)calculateYTransformOriginalCenter: (CGPoint)originalCenter toNewCenter:(CGPoint)new {
    
    CGFloat deltaY = (new.y - originalCenter.y);
//    deltaY = deltaY * ((originalCenter.y > new.y) ?
//                       -1 : 1);
    
    CGAffineTransform retTransform = CGAffineTransformMakeTranslation(0.0f, deltaY);
    return retTransform;
    
}

-(void)animateFieldsToLast: (BOOL)returnToLast toMiddle:(BOOL)toMiddle toBottom:(BOOL)toBottom toTop:(BOOL)toTop {

    CGPoint newCenter;
    CGAffineTransform animationTrans;

    if (returnToLast) {
        newCenter=lastLogoCenter;
    }

    if (toMiddle) {
        newCenter=self.critiqueLogoMiddlePlaceholder.center;
     
        }
    else if (toBottom) {
        newCenter=self.critiqueLogoLabelBottomPlaceholder.center;
            }
    else if (toTop) {
        newCenter=self.critiqueLogoLabelPlaceHolder.center;
       }
    lastLogoCenter=self.critiqueLogoLabel.center;
    animationTrans=
    [CritiqueViewController calculateYTransformOriginalCenter:self.critiqueLogoLabel.center toNewCenter:newCenter];

    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.movieNameTextField setCenter:CGPointApplyAffineTransform(self.movieNameTextField.center, animationTrans)];
        [self.critiqueLogoLabel setCenter:CGPointApplyAffineTransform(self.critiqueLogoLabel.center, animationTrans)];
        
    } completion:nil];
    
}

//bg "drifting" animation
-(void)animateBG {
    CGPoint cent=self.bgImgView.center;
    
    cent.x+=GRAPHICS_BG_ANIMATION_OFFSET;
    CGAffineTransform scale=CGAffineTransformMakeScale(1.05f, 1.05f);
    CGRect newFrame = CGRectApplyAffineTransform(self.bgImgView.frame, scale);
    
    [UIView animateWithDuration:GRAPHICS_BG_SWITCH_INTERVAL delay:0.0f options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
        [self.bgImgView setCenter:cent]; //move
        [self.bgImgView setFrame:newFrame]; //and scale
        
    } completion:nil];

}

-(void)switchBGImage {
    
    if (currentlyEditing || curretlyBlurred) return;

    BOOL moveForward = YES; //for future support of bg navigating
    currentBGImage = ( (moveForward ?
                        ++currentBGImage : --currentBGImage)
                      % [bgPicsArray count]) ;
    
    UIImageView *newImgView = [[UIImageView alloc] init];
    newImgView.image = [UIImage imageNamed:[[bgPicsArray objectAtIndex:currentBGImage] objectForKey:PLIST_BG_IMAGE_IMAGENAME_FIELD]];
    
    if (curretlyBlurred) {
        [blurManager asyncBlur:newImgView thenPutInto:self.bgImgView imageTag:[[bgPicsArray objectAtIndex:currentBGImage] objectForKey:PLIST_BG_IMAGE_IMAGENAME_FIELD]];
    }
    else {
        [self dissolveFrom:self.bgImgView to:newImgView];
    }
    [self putBGPicDescription:currentBGImage];

}

-(void) putBGPicDescription: (NSInteger)index {
    NSString *name, *year, *dir;
    NSDictionary *mov = [bgPicsArray objectAtIndex:index];
    MovieRecord *movRecord = [[MovieRecord alloc] init];
    name=[mov objectForKey:@"Title"];
    year=[mov objectForKey:@"Year"];
    dir=[mov objectForKey:@"Director"];
    movRecord.movieTitle=name;
    movRecord.movieYear=year;
    NSString *txt = [NSString stringWithFormat:@"%@, %@. %@", name, dir, year];
    currentFilmDescriptionMovieRecord = movRecord;
    [self.filmDescriptionText setText:txt];
}

- (void)filmDescriptionWasTapped {
    [self showMovieDetails:currentFilmDescriptionMovieRecord];
}

-(void)dissolveFrom: (UIImageView*)first to:(UIImageView*)second {
    [UIView transitionWithView:self.view duration:GRAPHICS_BLUR_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.bgImgView.image = second.image;
    } completion:nil];
}




-(void)showMovieDetails: (MovieRecord *)movieRecord {

//    [self.movieNameTextField setText:[movieRecord movieTitle]];
    [self.critiqueLogoLabel setText:[movieRecord getFormattedNameAndYear]]; //set logo to be movie name
    
    
    [movieDetailsCollectionViewHandler initNewQueryWithMovieRecord:movieRecord];
    [self.movieDetailsCollectionView reloadData];
    [self.movieDetailsCollectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1)  animated:NO];
    [self.movieDetailsCollectionView setHidden:NO];
    
    [self manageViewsEndUpBlurred:YES postersHidden:YES imagesHidden:NO];
    [self animateFieldsToLast:NO toMiddle:NO toBottom:NO toTop:YES];
    displayLastImages=YES;
    displayLastPosters=NO;
    
}

#pragma mark - ReviewScreenViewDelegate

-(void)dismissReviewScreenView {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
