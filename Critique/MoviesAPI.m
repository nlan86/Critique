//
//  MoviesAPI.m
//  Critique
//
//  Created by Nur Lan on 7/6/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "MovieRecord.h"
#import "MoviesAPI.h"


@implementation MoviesAPI
@synthesize currentNumberOfResults;

-(id) init {
    self = [super init];
    if (self) {
        self.currentSelectedSearchResult = -1; //-1 for none selected
        self.currentNumberOfResults = -1; //-1 for no query yet. 0 for no results
    }
    return self;
}

- (NSInteger) sendQuery: (NSString*)query numOfSuggestion:(NSInteger)num
{ return currentNumberOfResults;}

- (NSString*) getMovieNameSuggestion: (NSInteger)index {
    return [(MovieRecord*)[self.currentQueryMovieRecordResultsArray objectAtIndex:index] movieTitle];
}

- (NSString*) getMoviePoster: (NSInteger)index {
    return [(MovieRecord*)[self.currentQueryMovieRecordResultsArray objectAtIndex:index] moviePosterURLString];
}

-(NSString*)getMovieID:(NSInteger)index {
        return [(MovieRecord*)[self.currentQueryMovieRecordResultsArray objectAtIndex:index] movieID];

}

-(NSString*)getMovieYear:(NSInteger)index{
        return [(MovieRecord*)[self.currentQueryMovieRecordResultsArray objectAtIndex:index] movieYear];
}


- (MovieRecord*) getMovieRecord: (NSInteger)index {
    if (self.currentQueryMovieRecordResultsArray != nil && [self.currentQueryMovieRecordResultsArray count] > 0)
        return [self.currentQueryMovieRecordResultsArray objectAtIndex:index];
    else return nil;
}


//resets results after unsuccessful search
- (void)resetResults {
    self.currentQueryMovieRecordResultsArray=nil;
    self.currentSelectedSearchResult=-1;
    self.currentNumberOfResults = 0;
}

-(BOOL) queryExists: (NSString*)query {
    if ([self.cachedQueries valueForKey:query]) {
        return YES;
    }
    return NO;
}


@end
