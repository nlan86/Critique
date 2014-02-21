//
//  MoviesAPI.h
//  Critique
//
//  Created by Nur Lan on 7/6/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieRecord.h"

#define MOVIESAPI_RESULTS_DICTIONARY_ID @"id"
#define MOVIESAPI_RESULTS_DICTIONARY_TITLE @"title"
#define MOVIESAPI_RESULTS_DICTIONARY_YEAR @"year"
#define MOVIESAPI_RESULTS_DICTIONARY_POSTER_FULL_URL @"poster"


@interface MoviesAPI : NSObject

@property NSInteger currentSelectedSearchResult;
@property NSString *currentMovieSearchName;
@property NSInteger currentNumberOfResults; //
@property NSMutableArray *currentQueryMovieRecordResultsArray; //an array of MovieRecords
@property (nonatomic, strong) NSMutableDictionary *cachedQueries; //a dictionary of results arrays


- (void)resetResults;

- (MovieRecord*) getMovieRecord: (NSInteger)index;

- (NSInteger) sendQuery: (NSString*)query numOfSuggestion:(NSInteger)num;

- (NSString*) getMovieNameSuggestion: (NSInteger)index;

- (NSString*) getMoviePoster: (NSInteger)index;

-(NSString*)getMovieID:(NSInteger)index;

-(NSString*) getMovieYear:(NSInteger)index;

-(BOOL) queryExists: (NSString*)query;

@end
