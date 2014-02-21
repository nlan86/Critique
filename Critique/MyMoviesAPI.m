//
//  MyMoviesAPI.m
//  Critique
//
//  Created by Nur Lan on 7/6/13.
//  Copyright (c) 2013 Lan. All rights reserved.

#import "MyMoviesAPI.h"
#import "MovieRecord.h"
#import "CritiqueJSONRestHandler.h"

#define API_LOG_NAME @"MyMovies API"
#define BASE_URI @"http://imdbapi.org/"
#define SEARCH_BY_TITLE_URI @"q=%@"
#define SEARCH_BY_ID_URI @"id=%@"
#define SEARCH_RESULTS_LIMIT_URI @"limit=%d"
#define SEARCH_RESULTS_DATA_TYPE_URI @"type=json"

#define JSON_TITLE_FIELD @"title"
#define JSON_ID_FIELD @"imdb_id"
#define JSON_POSTER_FIELD @"poster"
#define JSON_POSTER_COVER_FIELD @"cover"
#define JSON_ERROR_FIELD @"error"
#define JSON_YEAR_FIELD @"year"

@implementation MyMoviesAPI

{
    NSData *currentMovieDataObject;
    NSString *currentEncodedQuery, *URIformattedString, *finalAPIQueryURI;

}

@synthesize currentMovieSearchName;
@synthesize currentQueryMovieRecordResultsArray; 

- (id)init {
    self=[super init];
    if (self) {
        self.cachedQueries = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSInteger)sendQuery:(NSString *)query numOfSuggestion:(NSInteger)requestedResultsNum {
    
        if ([self queryExists:query])  {
            currentQueryMovieRecordResultsArray = [self.cachedQueries objectForKey:query];
            return [currentQueryMovieRecordResultsArray count];
        }
        
        CritiqueJSONRestHandler *myMoviesJsonHandler = [[CritiqueJSONRestHandler alloc] init];
        currentEncodedQuery=[CritiqueJSONRestHandler convertStringToURLEncoding:query];
        URIformattedString = [NSString stringWithFormat:@"%@?%@&%@&%@",BASE_URI,SEARCH_BY_TITLE_URI,SEARCH_RESULTS_LIMIT_URI,SEARCH_RESULTS_DATA_TYPE_URI];
    
        finalAPIQueryURI = [NSString stringWithFormat:URIformattedString, currentEncodedQuery,requestedResultsNum ]; //query, results_limit
    
        NSLog(@"%@: Send to API URI: %@\n",API_LOG_NAME,finalAPIQueryURI);
        currentMovieDataObject=[myMoviesJsonHandler getDataObjFromURI:finalAPIQueryURI];
    
        //error getting json from uri
        if (currentMovieDataObject == nil) {
            NSLog(@"%@: Error GETting data object, http error\n",API_LOG_NAME);
            [self resetResults];
            return 0;
        }
    
        NSError* error;
        NSArray* json = [NSJSONSerialization JSONObjectWithData:currentMovieDataObject options:kNilOptions error:&error]; //myMovies returns JSON Array
    
    NSInteger numOfResults = [json count];
    NSString *isError=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_ERROR_FIELD fromObject:json];
    if (isError!=nil && ![isError isEqualToString:@""]) { //API Returned error
        NSLog(@"%@\n",isError);
        [self resetResults];
        return 0; 
    }
    
        NSLog(@"%@: Num of results for movie %@: %d\n",API_LOG_NAME,query,numOfResults);
        
    if (numOfResults==0) {
        [self resetResults];
        return 0;
    }
    
        NSString *tempMovieName, *tempMovieID, *tempMoviePosterURL, *tempMovieYear;
        NSDictionary *tempMovieResult;
        NSMutableArray *tempFinalSuggestionArray = [[NSMutableArray alloc] initWithCapacity:numOfResults];
        NSMutableArray *tempNoPosterSuggestionArray = [[NSMutableArray alloc] init];

    
        int i=0;
        for (; i<MIN(numOfResults,requestedResultsNum); i++) {            
            NSLog(@"i=%d\n",i);
            tempMovieResult=[json objectAtIndex:i];
            tempMovieName=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_TITLE_FIELD fromObject:tempMovieResult];
            if ([tempMovieName isEqualToString:@""]) continue; 
            tempMovieID=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_ID_FIELD fromObject:tempMovieResult];
            tempMoviePosterURL=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_POSTER_COVER_FIELD fromObject:
                                [tempMovieResult objectForKey:JSON_POSTER_FIELD]];
            tempMovieYear=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_YEAR_FIELD fromObject:tempMovieResult];
            
            MovieRecord *newMovieRecord = [[MovieRecord alloc] init];
            newMovieRecord.movieID=tempMovieID;
            newMovieRecord.movieTitle=tempMovieName;
            newMovieRecord.movieYear=tempMovieYear;
            newMovieRecord.moviePosterURLString=tempMoviePosterURL;

            if ([newMovieRecord.moviePosterURLString isEqualToString:@""])
                [tempNoPosterSuggestionArray addObject:newMovieRecord];
            else
                [tempFinalSuggestionArray addObject:newMovieRecord];
            
        }
    
        [tempFinalSuggestionArray addObjectsFromArray:tempNoPosterSuggestionArray]; //merge with-poster with no-poster
        self.currentQueryMovieRecordResultsArray = nil; //release previous results
        self.currentQueryMovieRecordResultsArray = tempFinalSuggestionArray;
        self.currentNumberOfResults = i;

        [self.cachedQueries setValue:self.currentQueryMovieRecordResultsArray forKey:query];     //cache results

        return i;

}

@end
