//
//  RottenAPI.h
//  Critique
//
//  Created by Nur Lan on 7/3/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoviesAPI.h"

@interface RottenAPI : MoviesAPI

@property NSString *currentMovieSearchName;
@property NSMutableArray *currentQueryMovieRecordResultsArray;

@end
