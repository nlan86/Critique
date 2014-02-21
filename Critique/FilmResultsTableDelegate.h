//
//  FilmResultsTableDelegate.h
//  Critique
//
//  Created by Nur Lan on 7/10/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CritiqueViewController.h"
#import "MoviesAPI.h"

@interface FilmResultsTableDelegate : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) MoviesAPI *moviesSearchObject;
@property (nonatomic, retain) NSArray *movieResultsImageViews;
@property (nonatomic, weak) UITableView *movieResultsTableView;
@property (nonatomic, weak) CritiqueViewController *parent;

- (void)sendQueryThenLoadPosters: (NSString*)query;

@end
