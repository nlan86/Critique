//
//  TMDB_MoviesAPI.m
//  Critique
//
//  Created by Nur Lan on 7/10/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "TMDB_MoviesAPI.h"
#import "MovieRecord.h"
#import "CritiqueJSONRestHandler.h"

#define API_LOG_NAME @"TMDB API"
#define TMDB_API_KEY @"e611fac67fa1ba432db6a4d62bd7672d"
#define TMDB_API_POSTER_SIZE @"w184" //w92, w154, w184, w342, w500, original
#define TMDB_API_BACKDROP_SIZE @"w780" //w300, w780, w1280, original
#define TMDB_BASE_URI_SEARCH_MOVIE @"http://api.themoviedb.org/3/search/movie"
#define TMDB_BASE_URI_CONFIGURATION @"http://api.themoviedb.org/3/configuration"
#define TMDB_API_QUERY_FIELD @"query=%@"
#define TMDB_API_API_KEY_FIELD @"api_key=%@"
#define TMDB_API_PAGE_FIELD @"page=%@"
#define TMDB_API_QUERY_FIELD @"query=%@"

#define JSON_CONFIG_IMAGES_FIELD @"images"
#define JSON_CONFIG_IMAGES_BASEURL_FIELD @"base_url"

#define JSON_TOTAL_RESULTS_NUM_FIELD @"total_results"
#define JSON_RESULTS_FIELD @"results"

#define JSON_RESULT_ADULT_FIELD @"adult"
#define JSON_RESULT_TITLE_FIELD @"title"
#define JSON_RESULT_ORIGINAL_TITLE @"original_title"
#define JSON_RESULT_ID @"id"
#define JSON_RESULT_POSTER_PATH @"poster_path"
#define JSON_RESULT_BACKDROP_PATH @"backdrop_path"
#define JSON_RESULT_POPULARITY @"popularity"
#define JSON_RESULT_RELEASE_DATE @"release_date"


@implementation TMDB_MoviesAPI

{
    NSData *currentMovieDataObject;
    CritiqueJSONRestHandler *myMoviesJsonHandler;
    NSString *currentEncodedQuery, *URIformattedString, *finalAPIQueryURI;
    NSString *imagesBaseUrl;
}

@synthesize currentMovieSearchName;
@synthesize currentQueryMovieRecordResultsArray;

-(id)init {
    self = [super init];
    if (self) {
        
        self.cachedQueries = [NSMutableDictionary dictionary];
        
        NSString *configURIString = [NSString stringWithFormat:@"%@?%@",TMDB_BASE_URI_CONFIGURATION,TMDB_API_API_KEY_FIELD]; //BASE Config,api_key
        NSString *finalConfigURIString = [NSString stringWithFormat:configURIString,TMDB_API_KEY]; //config query
        
        NSLog(@"%@: Send to API URI: \n%@\n",API_LOG_NAME,finalConfigURIString);
        CritiqueJSONRestHandler *tempJsonHandler= [[CritiqueJSONRestHandler alloc] init];
        NSData *configData=[tempJsonHandler getDataObjFromURI:finalConfigURIString];
        if (configData == nil) {
            NSLog(@"%@: Error GETting config data object, http error\n",API_LOG_NAME);
            imagesBaseUrl=@"";
            return nil;
        }
        
        NSError* error;
        NSDictionary *jsonConf = [NSJSONSerialization JSONObjectWithData:configData options:kNilOptions error:&error]; //TMDB Returns JSON Dictionary
        
        NSDictionary *imagesConf = [jsonConf objectForKey:JSON_CONFIG_IMAGES_FIELD];
        if (imagesConf==nil) { //error with getting config
            imagesBaseUrl=@"";
        }
        NSString *tempBaseUrlStr = [CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_CONFIG_IMAGES_BASEURL_FIELD fromObject:imagesConf];

        imagesBaseUrl=tempBaseUrlStr;
        
    }
    
    return self;
}

-(NSInteger)sendQuery:(NSString *)query numOfSuggestion:(NSInteger)requestedResultsNum {
    
    if ([self queryExists:query])  {
        currentQueryMovieRecordResultsArray = [self.cachedQueries objectForKey:query];
        return [currentQueryMovieRecordResultsArray count];
    }
    
    myMoviesJsonHandler = [[CritiqueJSONRestHandler alloc] init];
    currentEncodedQuery=[CritiqueJSONRestHandler convertStringToURLEncoding:query];
    URIformattedString = [NSString stringWithFormat:@"%@?%@&%@",TMDB_BASE_URI_SEARCH_MOVIE,TMDB_API_QUERY_FIELD,TMDB_API_API_KEY_FIELD]; //BASE,query,api_key
    
    finalAPIQueryURI = [NSString stringWithFormat:URIformattedString, currentEncodedQuery,TMDB_API_KEY]; //query
    
    NSLog(@"%@: Send to API URI: %@\n",API_LOG_NAME,finalAPIQueryURI);
    currentMovieDataObject=[myMoviesJsonHandler getDataObjFromURI:finalAPIQueryURI];
    if (currentMovieDataObject == nil) {
        NSLog(@"%@: Error GETting data object, http error\n",API_LOG_NAME);
        return 0;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:currentMovieDataObject options:kNilOptions error:&error]; //TMDB Returns JSON Dictionary
    
    NSArray *resultsArray = [json objectForKey:JSON_RESULTS_FIELD];
    NSInteger numOfResults = [[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_TOTAL_RESULTS_NUM_FIELD fromObject:json] integerValue];

    NSLog(@"%@: Num of results for movie %@: %d\n",API_LOG_NAME,query,numOfResults);
    
    //if error getting results from JSON or no results
    if (resultsArray == nil || [resultsArray count] ==0 || numOfResults==0)
    {
        [self resetResults];
        return self.currentNumberOfResults=0;
    }
    
    NSString *tempMovieName, *tempOriginalTitle, *tempMovieID, *tempMoviePosterURL, *tempMovieYear;
    NSDictionary *tempMovieResult;
    NSMutableArray *tempFinalSuggestionArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempNoPosterSuggestionArray = [[NSMutableArray alloc] init];

    
    //extract results
    int i=0;
    for (; i<MIN(numOfResults,requestedResultsNum); i++) {
        tempMovieResult=[resultsArray objectAtIndex:i];
        tempMovieName=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_RESULT_TITLE_FIELD fromObject:tempMovieResult];
        tempOriginalTitle = [CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_RESULT_ORIGINAL_TITLE fromObject:tempMovieResult];
        tempMovieID=[CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_RESULT_ID fromObject:tempMovieResult];
        tempMoviePosterURL=[self convertTMDBImageURLToFullPath:
            [CritiqueJSONRestHandler safeJsonGetStringForKey:JSON_RESULT_POSTER_PATH fromObject:tempMovieResult]];
        tempMovieYear=[self convertTMDBDateToYear:
            [CritiqueJSONRestHandler safeJsonGetStringForKey:
                 JSON_RESULT_RELEASE_DATE fromObject:tempMovieResult]];
        
        MovieRecord *newMovieRecord = [[MovieRecord alloc] init];
        newMovieRecord.movieID = tempMovieID;
        newMovieRecord.originalTitle = tempOriginalTitle;
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

- (NSString*)convertTMDBDateToYear: (NSString*)date {
    NSString *retStr=@"";
    if (date !=(NSString*)[NSNull null] && [date length]>=4) {
        retStr=[date substringToIndex:4];
    }
    return retStr;
}

- (NSString*)convertTMDBImageURLToFullPath: (NSString*)relativePath {
    if (![relativePath compare:@""]) return @"";
    
    NSString *retStr = [NSString stringWithFormat:@"%@%@%@",
                        imagesBaseUrl,
                        TMDB_API_POSTER_SIZE,
                        relativePath];
    
    return retStr;
}


@end
