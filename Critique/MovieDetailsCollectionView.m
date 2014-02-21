//
//  MovieDetailsCollectionView.m
//  Critique
//
//  Created by Nur on 8/4/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import "MBSpinningCircle.h"
#import "ReviewScreenViewController.h"
#import "CritiqueMisc.h"
#import "CritiqueJSONRestHandler.h"
#import "GoogleImageCell.h"
#import "MovieDetailsCollectionView.h"


@implementation MovieDetailsCollectionView

- (id)init
{
    self = [super init];
    if (self) {
        
        //init thumbnail loading queue
        self.movieThumbsQueue = [[NSOperationQueue alloc] init];
        [self.movieThumbsQueue setMaxConcurrentOperationCount:COLLECTION_VIEW_MAX_IMAGE_LOADS];        
        
    }
    return self;
}

-(void)initNewQueryWithMovieRecord: (MovieRecord*)newMovieRecord {

    self.selectedMovieRecord = newMovieRecord;
    self.movieThumbsCurrentlyDownloading = nil; //de-alloc current download list
    NSString *searchTitle = [NSString stringWithFormat:@"%@ %@",newMovieRecord.movieTitle,newMovieRecord.originalTitle]; 
    
//    self.movieThumbsCurrentlyDownloading = [nsar; //cancel previous downloads
    
    NSString *query = [NSString stringWithFormat:@"\"%@\" %@",self.selectedMovieRecord.movieTitle, self.selectedMovieRecord.movieYear]; //title_year_'film'_'-poster'
    
    //set image download queue
    __weak MovieDetailsCollectionView *weakSelf = self;
    
    //reset thumbs
    [self.imageSearcher resetQuery];
    //        [self.imagesCollection reloadData];
    
    
    //init query & dispatch it in thumbnail queue
    NSBlockOperation *imageSearchQueryBlock = [NSBlockOperation blockOperationWithBlock:^{
        [self.imageSearcher sendQuery:query numOfSuggestion:CRITIQUE_API_IMAGE_SEARCH_RESULTS];
    }];
    
    [imageSearchQueryBlock setCompletionBlock:^{
        weakSelf.selectedMovieRecord.imageSearchResults = [weakSelf.imageSearcher getResultsArray]; //put image search results into movie record
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.parentCollectionView reloadData]; //reload collection w/ results
        }); 
        
    }];
    [self.movieThumbsQueue addOperation:imageSearchQueryBlock];

}

#pragma mark - UICollectionView Datasource

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX([self.imageSearcher numOfResults],
               IMAGES_COLLECTION_VIEW_ITEMS_TO_FILL_BLANK);
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    GoogleImageCell *cell = (GoogleImageCell*)[cv dequeueReusableCellWithReuseIdentifier:@"GoogleCell"
                                                                            forIndexPath:indexPath];
    if (!cell) {
        cell = [[GoogleImageCell alloc] init];
        cell.imageView.image = nil;
    }
    
    cell.cellTag = indexPath.row;

    [self putSpinnerInCell:cell inImgView:cell.imageView];
    [cell.loadSpinner startAnimating];
    
    ImageSearchResult *curImgResult = [self.imageSearcher getImageResults:indexPath.row];
    
    //no image loaded yet for image result
    if (!curImgResult.imageThumb) {
        
        //if download did already start - nothing to do yet
        if ([self.movieThumbsCurrentlyDownloading objectForKey:indexPath])
        {
            NSLog(@"Results number %d: already downloading, waiting...\n",indexPath.row);
            cell.imageView.image = nil;
            cell.imageView.backgroundColor = GRAPHICS_TRANSPARENT_BG_WHITE;
            return cell;
        }
        
        cell.imageView.image = nil;
        cell.imageView.backgroundColor = GRAPHICS_TRANSPARENT_BG_WHITE;
        
        //create thumbnail downloader
        NSBlockOperation *thumbLoadBlock = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage *loadedThumb;
                                
                //either load real thumbnail or full-size as thumbnail
                loadedThumb=[CritiqueJSONRestHandler loadImageFromURL:
                             MOVIE_PICS_RESULTS_LOAD_THUMB ?
                             curImgResult.thumbURL : curImgResult.imageURL];
            
            if (loadedThumb) { //make sure download went ok, then load img into UI
                
                [self.movieThumbsCurrentlyDownloading removeObjectForKey:indexPath]; //download finished, remove from list. we do not remove error downloads to avoid retries
                
                curImgResult.imageThumb = loadedThumb;
                if (!MOVIE_PICS_RESULTS_LOAD_THUMB)
                    curImgResult.imageBig = loadedThumb;
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    //  set thumb via main queue if cell is still same cell
                    if (cell.cellTag == indexPath.row) {
                            if(cell.loadSpinner)
                                [cell.loadSpinner stopAnimating];
                        [cell.imageView setImage:loadedThumb];
                    }
                });
            }
            
        }];
        
        //add to download list
        [self.movieThumbsCurrentlyDownloading setObject:indexPath forKey:indexPath];
        //start download
        [self.movieThumbsQueue addOperation:thumbLoadBlock];
        
    }
    //image already did load and cached
    else {
        UIImage *loadedThumb=curImgResult.imageThumb;
        
        if (cell.cellTag == indexPath.row) {
            [cell.imageView setImage:loadedThumb];
            if (cell.loadCircle) {
                [cell.loadCircle setHidden:YES];
            }

            if (cell.loadSpinner)
                [cell.loadSpinner stopAnimating];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected item %d in Collection", indexPath.row);
    self.currentSelectedCollectionViewImage = indexPath.row;
    
    [self.parentView performSegueWithIdentifier:SEGUE_IDENTIFIER_MAIN_TO_REVIEW sender:self.parentView];
    
    if (0) {
        // Create & present browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        browser.wantsFullScreenLayout = YES;
        browser.displayActionButton = YES;
        [browser setInitialPageIndex:self.currentSelectedCollectionViewImage];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self.parentView presentViewController:nc animated:YES completion:nil];
        
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    //    [self performSegueWithIdentifier:SEGUE_IDENTIFIER_SHOW_IMAGE sender:self];
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(MOVIE_THUMBNAIL_SIZE, MOVIE_THUMBNAIL_SIZE);
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self.selectedMovieRecord.imageSearchResults count];
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (index >= [self.selectedMovieRecord.imageSearchResults count])
        return nil;
    
    MWPhoto *mwPhoto=nil;
    
    ImageSearchResult *imgSrchResultAtIndex =(ImageSearchResult*)[self.selectedMovieRecord.imageSearchResults objectAtIndex:index];
    if (!imgSrchResultAtIndex) return nil;
    
    mwPhoto.caption = self.selectedMovieRecord.movieTitle;
    
    if (imgSrchResultAtIndex.imageBig)
        mwPhoto = [MWPhoto photoWithImage:imgSrchResultAtIndex.imageBig];
    else if (imgSrchResultAtIndex.imageURL)
        mwPhoto = [MWPhoto photoWithURL:[NSURL URLWithString:
                                         imgSrchResultAtIndex.imageURL]];
    
    return mwPhoto;
    
}

#pragma mark - MISC



-(void)putSpinnerInCell: (GoogleImageCell*)cell inImgView:(UIImageView*)imgV {
    
    if (cell.loadSpinner) return;
    
        UIActivityIndicatorView *loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loadSpinner.hidesWhenStopped = YES;
        loadSpinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        [loadSpinner setCenter:imgV.center];
        [imgV addSubview:loadSpinner];
        cell.loadSpinner=loadSpinner;
}


- (void)putCircleInCell: (UICollectionViewCell*)cell {
    MBSpinningCircle *activityIndicator = [MBSpinningCircle circleWithSize:NSSpinningCircleSizeLarge color:[UIColor whiteColor]];
    CGRect circleRect = cell.frame;
    circleRect.origin = cell.frame.origin;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.frame = circleRect;
    activityIndicator.circleSize = NSSpinningCircleSizeLarge;
    activityIndicator.hasGlow = NO;
    activityIndicator.isAnimating = YES;
    activityIndicator.color = [UIColor whiteColor];
    activityIndicator.speed = 0.55;
    [cell addSubview:activityIndicator];
}

- (void)putCircleInImgView: (UIImageView*)imgV {
    MBSpinningCircle *activityIndicator = [MBSpinningCircle circleWithSize:NSSpinningCircleSizeLarge color:[UIColor whiteColor]];
    CGRect circleRect = imgV.frame;
    circleRect.origin = imgV.frame.origin;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.frame = circleRect;
    activityIndicator.circleSize = NSSpinningCircleSizeSmall;
    activityIndicator.hasGlow = NO;
    activityIndicator.isAnimating = YES;
    activityIndicator.color = [UIColor whiteColor];
    activityIndicator.speed = 0.55;
    [imgV addSubview:activityIndicator];
}

@end
