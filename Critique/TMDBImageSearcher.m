//
//  TMDBImageSearcher.m
//  Critique
//
//  Created by Nur on 5/31/14.
//  Copyright (c) 2014 Nur. All rights reserved.
//

#import "TMDBImageSearcher.h"
#import "CritiqueJSONRestHandler.h"

@interface TMDBImageSearcher() {

    CritiqueJSONRestHandler *resultsJsonHandler;
    NSData *currentTMDBImagesDataObject;
    NSInteger numOfResults;
}

@end


@implementation TMDBImageSearcher

- (NSInteger) sendQuery:(NSString *)query numOfSuggestion:(NSInteger)num {
    
    if ([self queryExists:query]) { //if query is cached - return its cache
        currentImageResults=[cachedQueries objectForKey:query];
        return [currentImageResults count];
    }
    

    
    NSString *safeSearchString = [CritiqueJSONRestHandler convertStringToURLEncoding:query];
    
    CritiqueJSONRestHandler *TmdbImageJSONRestHAndler = [[CritiqueJSONRestHandler alloc] init];
    
    NSString *URIformattedString = [NSString stringWithFormat:@"%@/%@/%@?%@",TMDB_BASE_URI_MOVIE_QUERY,safeSearchString,TMDB_API_URI_IMAGES_PATH, TMDB_API_API_KEY_FIELD]; //BASE,id,api_key=
    
    NSString *finalAPIQueryURI = [NSString stringWithFormat:URIformattedString, TMDB_API_KEY]; //query
    
    currentTMDBImagesDataObject=[TmdbImageJSONRestHAndler getDataObjFromURI:finalAPIQueryURI];
    
    NSLog(@"TMDB Images: Send to API URI: %@\n",finalAPIQueryURI);
    currentTMDBImagesDataObject=[TmdbImageJSONRestHAndler getDataObjFromURI:finalAPIQueryURI];
    if (currentTMDBImagesDataObject == nil) {
        NSLog(@"%@: Error GETting data object, http error\n",@"TMDB Images");
        return 0;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:currentTMDBImagesDataObject options:kNilOptions error:&error]; //TMDB Returns JSON Dictionary
    
    NSArray *resultsArray = [json objectForKey:IMAGES_JSON_BACKDROPS_ARRAY_FIELD];

    //if error getting results from JSON or no results
    if (resultsArray == nil || [resultsArray count] ==0)
    {
        return 0;
    }
    
    currentImageResults=[NSMutableArray arrayWithCapacity:[resultsArray count]];
    ImageSearchResult *tempImageSearchResult;
    NSString *tempImgURL;
    NSDictionary *tempImageResultJson;
    
    for (int i=0; i<MIN(num,[resultsArray count]); i++) {
        
        tempImageResultJson = [resultsArray objectAtIndex:i];
        tempImgURL = [CritiqueJSONRestHandler safeJsonGetStringForKey:IMAGES_JSON_BACKDROP_RELATIVE_PATH_FIELD fromObject:tempImageResultJson];
        tempImageSearchResult = [[ImageSearchResult alloc] init];
        tempImageSearchResult.imageURL = [NSString stringWithFormat:@"http://image.tmdb.org/t/p/%@%@",TMDB_API_BACKDROP_SIZE, tempImgURL]; //TODO FIX TO SUPPORT CONFIGURATION!!
        NSLog(@"TMDB Image Search: Adding image at offset %d", i);
        [currentImageResults addObject:tempImageSearchResult];
        
    }
    
    [cachedQueries setObject:currentImageResults forKey:query];
    return [currentImageResults count];

}

@end
