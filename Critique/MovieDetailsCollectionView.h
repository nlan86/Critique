//
//  MovieDetailsCollectionView.h
//  Critique
//
//  Created by Nur on 8/4/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//
#import "GoogleImageCell.h"
#import "MWPhotoBrowser.h"
#import "MWPhoto.h"
#import "MovieRecord.h"
#import "ImageSearcher.h"
#import <UIKit/UIKit.h>

@interface MovieDetailsCollectionView : NSObject  <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate>

@property (nonatomic, assign) NSInteger currentSelectedCollectionViewImage;
@property (nonatomic, strong) NSOperationQueue *movieThumbsQueue;
@property (nonatomic, strong) NSMutableDictionary *movieThumbsCurrentlyDownloading;

@property (nonatomic, weak) UIViewController *parentView;
@property (nonatomic, weak) UICollectionView *parentCollectionView;
@property (nonatomic, strong) MovieRecord *selectedMovieRecord;
@property (nonatomic, strong) ImageSearcher *imageSearcher;

-(void)initNewQueryWithMovieRecord: (MovieRecord*)newMovieRecord;

@end
