//
//  FilmResultsTableDelegate.m
//  Critique
//
//  Created by Nur Lan on 7/10/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//
#import "MBProgressHUD.h"
#import "CritiqueMisc.h"
#import "FilmResultsTableDelegate.h"
#import "ImageDownloader.h"
#import "MovieRecord.h"
#import "MoviesAPI.h"
#import "FilmReultsTableCell.h"
#import "CritiqueJSONRestHandler.h"

#define MOVIE_RESULTS_TABLE_MOVIE_RESULT_CELL @"FilmResultCell"
#define MOVIE_RESULTS_TABLE_MOVIE_PLACEHOLDER_CELL @"PlaceHolderCell"
#define DEFAULT_PLACEHOLDER_POSTER @"image_leaf_right_medium.png"

#define TABLEVIEW_SECTION 1
#define TABLE_NUM_OF_ROWS_FILL 1

@interface FilmResultsTableDelegate() <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, strong) NSOperationQueue *moviePostersQueue;

@end

@implementation FilmResultsTableDelegate

@synthesize moviesSearchObject;
@synthesize movieResultsImageViews;

- (id)init {
    self=[super init];
    if (self) {
        self.moviePostersQueue = [[NSOperationQueue alloc] init];
        [self.moviePostersQueue setMaxConcurrentOperationCount:COLLECTION_VIEW_MAX_IMAGE_LOADS];
    }
    
    return self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if there's no data yet, return enough rows to fill the screen
    
    NSUInteger count = MAX([self.moviesSearchObject currentNumberOfResults],TABLE_NUM_OF_ROWS_FILL);
    
    return count;

}

- (void)sendQueryThenLoadPosters: (NSString*)query {
    
    //show hud progress
    __weak CritiqueViewController* weakParent = self.parent;
    [MBProgressHUD showHUDAddedTo:(UIView*)weakParent.view animated:YES];
    
    NSBlockOperation *queryBlock = [NSBlockOperation blockOperationWithBlock:^{
        int results;
        
        results=[weakParent.currentMoviesAPI sendQuery:query numOfSuggestion: CRITIQUE_API_REQUEST_NAME_SEARCH_RESULTS];
        NSLog(@"Results after query: %d or %d", results, weakParent.currentMoviesAPI.currentNumberOfResults);
        
        //logging print of all movies gathered
        for (int i=0; i<results; i++) {
            NSLog(@"#%d || Movie ID: %@ || Name: %@ || Year: %@ || Poster: %@\n\n", i,
                  [weakParent.currentMoviesAPI getMovieID:i],
                  [weakParent.currentMoviesAPI getMovieNameSuggestion:i],
                  [weakParent.currentMoviesAPI getMovieYear:i],
                  [weakParent.currentMoviesAPI getMoviePoster:i]);
        }
        
    }];
    
    [queryBlock setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:(UIView*)weakParent.view animated:YES];
            [weakParent filmResultsDidLoad];
        });
    }];
    
    [self.moviePostersQueue addOperation:queryBlock];
    
}
                
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numOfResults = [moviesSearchObject currentNumberOfResults];
    
    static NSString *CellIdentifier = MOVIE_RESULTS_TABLE_MOVIE_RESULT_CELL;
    static NSString *CellPlaceHolder = MOVIE_RESULTS_TABLE_MOVIE_PLACEHOLDER_CELL;

    if (numOfResults == 0 && indexPath.row == 0) //no results for sent query
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellPlaceHolder];
            cell.textLabel.text = @"No results :(";
            return cell;
        }
    if (numOfResults == -1 && indexPath.row == 0) //no query sent yet
        {
                                    NSLog(@"RESULTS= %d = -1\n",numOfResults);
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellPlaceHolder];
            cell.textLabel.text = @"Loading...";
            return cell;
        }
    
    FilmReultsTableCell *retCell = (FilmReultsTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [retCell.starLabel setHidden:YES];
    
    retCell.cellTag = indexPath.row;
    
    if (retCell!=nil) {
        retCell.moviePosterImage.image=nil; //clear previous cell image
    }
    
    if (numOfResults > 0)
	{

        MovieRecord *movieRecord = [moviesSearchObject getMovieRecord:indexPath.row];
        NSString *movieLabel = [movieRecord getFormattedNameAndYear];
		retCell.movieTitleLabel.text = movieLabel;
        retCell.moviePosterImage.backgroundColor = GRAPHICS_TRANSPARENT_BG_WHITE;
                
        if (!movieRecord.moviePosterImage) {

        //put spinner until we see what's up with img
        [self putSpinnerInCell:retCell];
        [retCell.loadSpinner startAnimating];
            
        NSBlockOperation *posterLoadBlock = [NSBlockOperation blockOperationWithBlock:^{
                
            UIImage *loadedPoster;
            
            //only download if movie has poster url
            if (![movieRecord.moviePosterURLString isEqualToString:@""])
            {
                //download image
                loadedPoster=[CritiqueJSONRestHandler loadImageFromURL:
                             movieRecord.moviePosterURLString];
            }
            else loadedPoster=nil;
            
            movieRecord.moviePosterImage=loadedPoster;

            //poster download/cache ok, update ui
            if (loadedPoster) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                        if (retCell.cellTag == indexPath.row) //verify still same cell
                        {
                            if (retCell.loadSpinner) [retCell.loadSpinner stopAnimating];
                            retCell.moviePosterImage.backgroundColor = [UIColor clearColor];
                            [retCell.moviePosterImage setContentMode:UIViewContentModeScaleAspectFit];
                            retCell.moviePosterImage.image = loadedPoster;
                        }
                    
                });
            }
            else { //no poster or error loading it
                dispatch_async(dispatch_get_main_queue(), ^{
                    retCell.moviePosterImage.backgroundColor = GRAPHICS_TRANSPARENT_BG_WHITE;
                    if (retCell.loadSpinner) [retCell.loadSpinner stopAnimating];

                });
            }
            
    }];
            [self.moviePostersQueue addOperation:posterLoadBlock];

        }
            else //poster already cached, just put it
            {
                retCell.moviePosterImage.backgroundColor = [UIColor clearColor];
                [retCell.moviePosterImage setContentMode:UIViewContentModeScaleAspectFit];
                [retCell.moviePosterImage setImage:movieRecord.moviePosterImage];
            }

    }
    return retCell;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.moviesSearchObject.currentNumberOfResults <= 0) //nothing to select
        return;
    ;
    self.moviesSearchObject.currentSelectedSearchResult = indexPath.row;
    MovieRecord *selectedMovieRecord = [self.parent.currentMoviesAPI getMovieRecord:indexPath.row];

    [self.parent showMovieDetails:selectedMovieRecord];
    
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
//    if (!decelerate)
//	{
//        [self loadImagesForOnscreenRows];
//    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    [self loadImagesForOnscreenRows];
}

#pragma Mark - MISC

-(void)putSpinnerInCell: (FilmReultsTableCell*)cell {
    
    if (!cell.loadSpinner) {
        
        UIActivityIndicatorView *loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadSpinner.hidesWhenStopped = YES;
        loadSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [loadSpinner setCenter:cell.moviePosterImage.center];
        [cell addSubview:loadSpinner];
        cell.loadSpinner = loadSpinner;
        
    }
}

@end
