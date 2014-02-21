//
//  RottenAPI.m
//  Critique
//
//  Created by Nur Lan on 7/3/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "RottenAPI.h"
#import "CritiqueJSONRestHandler.h"
#import "MovieRecord.h"
#import "ImageSearcher.h"

#define API_LOG_NAME @"Rotten API"
#define API_KEY @"fbujpmnzbyeb3fae7jwshfkk"
#define API_URI_TEMP @"http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=%@&q=%@&page_limit=%d" //api_key, query, num_results
#define JSON_ID_FIELD @"id"
#define JSON_TITLE_FIELD @"title"
#define JSON_YEAR_FIELD @"year"
#define JSON_POSTER_FATHER_FIELD @"posters"
#define JSON_POSTER_INSTANCE @"profile" //original, detailed, profile, thumbnail


@implementation RottenAPI

@synthesize currentMovieSearchName;
@synthesize currentQueryMovieRecordResultsArray; 

- (id)init {
    self=[super init];
    return self;
}

//Returns: number of suggestions in practice
- (NSInteger)sendQuery:(NSString *)query numOfSuggestion:(NSInteger)requestedResultsNum {
    
    if ([self queryExists:query])  {
        currentQueryMovieRecordResultsArray = [self.cachedQueries objectForKey:query];
        return [currentQueryMovieRecordResultsArray count];
    }
    
    CritiqueJSONRestHandler *rottenJsonHandler = [[CritiqueJSONRestHandler alloc] init];
    NSString *encodedQuery=[CritiqueJSONRestHandler convertStringToURLEncoding:query];
    
    NSString *rottenURI = [NSString stringWithFormat:API_URI_TEMP,API_KEY,encodedQuery,requestedResultsNum];
    NSLog(@"%@: Send to API URI: %@\n",API_LOG_NAME,rottenURI);
    NSData *rottenDataObject =[rottenJsonHandler getDataObjFromURI:rottenURI];
    
    //error getting json. return 0 and reset
    if (rottenDataObject == nil) {
        [self resetResults];
        return 0;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:rottenDataObject options:kNilOptions error:&error];
    
    NSInteger numOfResults = [[json valueForKey:@"total"] integerValue];
    
    NSLog(@"%@: Num of results for movie %@: %d\n",API_LOG_NAME,query,numOfResults);
    
    //no results. return 0 and reset
    if (numOfResults==0) {
        [self resetResults];
        return 0;
    }
    
    NSArray *moviesArray = [json objectForKey:@"movies"];
        
    NSString *tempMovieName, *tempMovieID, *tempMoviePosterURL, *tempMovieYear;
    
    NSDictionary *tempMovieResult;
    NSMutableArray *tempFinalSuggestionArray = [[NSMutableArray alloc] initWithCapacity:numOfResults];
    NSMutableArray *tempNoPosterSuggestionArray = [[NSMutableArray alloc] init];

    int i=0;
    for (; i<MIN(numOfResults,requestedResultsNum); i++) {
        
        tempMovieResult=[moviesArray objectAtIndex:i];
        tempMovieName = [CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_TITLE_FIELD fromObject:tempMovieResult];
        tempMoviePosterURL=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_POSTER_INSTANCE fromObject:[tempMovieResult objectForKey:JSON_POSTER_FATHER_FIELD]]; //"original" for hi-res poster
        tempMovieID=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_ID_FIELD fromObject:tempMovieResult];
        tempMovieYear=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_YEAR_FIELD fromObject:tempMovieResult];
        
        MovieRecord *newMovieRecord = [[MovieRecord alloc] init];
        newMovieRecord.movieID = tempMovieID;
        newMovieRecord.movieTitle=tempMovieName;
        newMovieRecord.movieYear=tempMovieYear;
        newMovieRecord.moviePosterURLString=tempMoviePosterURL;
        
        if ([newMovieRecord.moviePosterURLString isEqualToString:@""])
            [tempNoPosterSuggestionArray addObject:newMovieRecord];
        else
            [tempFinalSuggestionArray addObject:newMovieRecord];
    }
    
    [tempFinalSuggestionArray addObjectsFromArray:tempNoPosterSuggestionArray]; //merge with-poster with no-poster
    
    self.currentQueryMovieRecordResultsArray = tempFinalSuggestionArray;
    self.currentNumberOfResults = i;
    
    [self.cachedQueries setValue:self.currentQueryMovieRecordResultsArray forKey:query];     //cache results

    return i;
}


@end
