//
//  GoogleImageSearcher.m
//  Critique
//
//  Created by Nur Lan on 7/2/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//


// USAGE:
// ----------------------
//    GoogleImageSearcher *myGoogleSearcher = [[GoogleImageSearcher alloc] init];
//    NSMutableArray *imgResults;
//    imgResults=[myGoogleSearcher GetImageURLS:self.movieNameTextField.text numberOfResults:SEARCH_RESULTS];
//    self.myArr = imgResults;
//    self.currentPic=0;
//    [CritiqueJSONRestHandler loadImageFromURLString:imgResults[0] toImageView:self.mainFilmImageView];
//API Sample: https://www.googleapis.com/customsearch/v1?key=%@&searchType=image&cx=%@&q=%@&num=%d&safe=medium&imgSize=large

#import "CritiqueMisc.h"
#import "GoogleImageSearcher.h"
#import "CritiqueJSONRestHandler.h"
#import "MoviesAPI.h"
#import "ImageSearchResult.h"


@implementation GoogleImageSearcher


//returns number of results de facto
- (NSInteger) getAppendImageResultsFromData:(NSData *)responseData toResultsArray:(NSMutableArray*)resultsArray numOfResults:(NSInteger)num {
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    NSDictionary *tempImageJSONResult, *tempImageDetailsJSON;
    
    NSArray* imageResults = [json objectForKey:GOOGLE_API_RESPONSE_ITEMS_FIELD];
    if (imageResults==nil) return 0;
        
    ImageSearchResult *tempImageSearchResult;
    NSString *tempImgURL, *tempThumbURL;
    
    NSInteger resultsDeFacto = MIN(num,[imageResults count]);
    
    for (int i=0; i<resultsDeFacto; i++) {
        tempImageJSONResult = [imageResults objectAtIndex:i];
        tempImageDetailsJSON = [tempImageJSONResult objectForKey:GOOGLE_API_RESPONSE_IMAGE_DETAILS_FIELD];
        
        tempImgURL = [CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_LINK_FIELD fromObject:tempImageJSONResult];
        tempThumbURL=[CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_THUMB_LINK_FIELD fromObject:tempImageDetailsJSON];
        tempImageSearchResult = [[ImageSearchResult alloc] init];
        tempImageSearchResult.imageURL = tempImgURL;
        tempImageSearchResult.thumbURL=tempThumbURL;
        tempImageSearchResult.thumbWidth=[[CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_THUMB_WIDTH_FIELD fromObject:tempImageDetailsJSON] integerValue];
        tempImageSearchResult.thumbHeight=[[CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_THUMB_HEIGHT_FIELD fromObject:tempImageDetailsJSON] integerValue];
        tempImageSearchResult.imageWidth=[[CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_WIDTH_FIELD fromObject:tempImageDetailsJSON] integerValue];
        tempImageSearchResult.imageHeight=[[CritiqueJSONRestHandler safeJsonGetStringForKey:GOOGLE_API_RESPONSE_IMAGE_HEIGHT_FIELD fromObject:tempImageDetailsJSON] integerValue];
        
        [resultsArray addObject:tempImageSearchResult];
    }
    
    return resultsDeFacto;
    
}

- (NSInteger) sendQuery: (NSString*)query numOfSuggestion:(NSInteger)num {

    
    //use fake results to not use google api
    if (GOOGLE_USE_DEMO) {
        
        NSArray *thumbs = [NSArray arrayWithObjects:
        @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7LAgLpVln0IYRDMCfPwnEZX7mPMUMLPudww0g5vSCvnw3OKwaZzJ2cB6z",
            @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpzh3HPA54Wb7TNgco59xYlDlSNc9JBMvHnnOeNjJEhZIt28CAoy3quIk",
            @"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQSDU2B8m0tumywowdbFkPbLvK5IYEUykVTSOTBnpO4APjnCLjMztHOvyM7",
               @"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTGJPfMXW75-_Tgy4THXKmDfWWtkTV_AmlC_uaQMge3UXJOTBZBlRMD2v4",nil];
        NSArray *bigs = [NSArray arrayWithObjects:@"http://2.bp.blogspot.com/-b2yg7pcXSas/Tn51T4WVKsI/AAAAAAAAAGI/yEECt7y6WZU/s320/titanic-movie.jpg", @"http://jr1990.files.wordpress.com/2010/10/titanic.jpg", @"http://www.thefilmpilgrim.com/wp-content/uploads/2012/02/Titanic-1997-Billy-Zane-Kate-Winslet.jpg", @"http://media.web.britannica.com/eb-media/53/93453-004-F91DDF75.jpg", nil];

        NSMutableArray *demoResults = [NSMutableArray array];
        for (int i=0; i<[bigs count] * 5; i++) {
            ImageSearchResult *res = [[ImageSearchResult alloc] init];
            res.thumbURL = [thumbs objectAtIndex: (i%4)];
            res.imageURL = [bigs objectAtIndex:(i%4)];
            [demoResults addObject:res];
        }
        
        currentImageResults = demoResults;
        [cachedQueries setObject:demoResults forKey:query];
        return [demoResults count];
        
    }
    
    if ([self queryExists:query]) { //if query is cached - return its cache
        currentImageResults=[cachedQueries objectForKey:query];
        return [currentImageResults count];
    }
    
    currentImageResults=[NSMutableArray arrayWithCapacity:num];
    
    NSString *safeSearchString = [CritiqueJSONRestHandler convertStringToURLEncoding:query];
    NSString *safeORQuery = [CritiqueJSONRestHandler convertStringToURLEncoding:GOOGLE_API_OR_QUERY_VALUE];
    
    CritiqueJSONRestHandler *googleJSONRestHAndler = [[CritiqueJSONRestHandler alloc] init];
    
    NSInteger neededPages = (num / GOOGLE_API_MAX_RESULTS_PER_PAGE);
    NSInteger currentStartIndex = 1;
    
    NSString *requestTemp=[NSString stringWithFormat:@"%@?%@&%@&%@&%@&%@&%@&%@&%@&%@&%@",
                           GOOGLE_API_BASE_URI, //Standalone
                           GOOGLE_API_SEARCH_KEY_FIELD,
                           GOOGLE_API_CX_FIELD_NAME,
                           GOOGLE_API_QUERY_FIELD_NAME,
                           GOOGLE_API_SEARCH_TYPE_FIELD,
                           GOOGLE_API_NUMBER_OF_RESULTS_FIELD,
                           GOOGLE_API_SAFESEARCH_FIELD,
                           GOOGLE_API_OR_QUERY_FIELD_NAME,
                           GOOGLE_API_EXCLUDE_QUERY_FIELD_NAME,
                           GOOGLE_API_PAGE_START_FIELD,
                           GOOGLE_API_SIZE_USE_FIELD ? GOOGLE_API_SIZE_FIELD_AND_VAL : @""]; //LAST FIELD IS STANDALONE
    //?base,key,cx,q,searchtype,num,safe,or,exclude,pageStart,?imgsize

    for (int pageResults=0, p=1; p<=neededPages; p++) {
        
        NSString *requestUrl=[NSString stringWithFormat:requestTemp,
                              GOOGLE_API_KEY,
                              GOOGLE_API_CX,
                              safeSearchString,
                              GOOGLE_API_SEARCH_TYPE_IMAGE,
                              GOOGLE_API_MAX_RESULTS_PER_PAGE,
                              GOOGLE_API_SAFESEARCH_MEDIUM,
                              safeORQuery,
                              GOOGLE_API_EXCLUDE_QUERY_VALUE,
                              currentStartIndex];

        NSLog(@"%@: Sending query:\n%@\n",GOOGLE_API_NAME,requestUrl);
        
        currentQueryJSONData=[googleJSONRestHAndler getDataObjFromURI:requestUrl];
        
        if (currentQueryJSONData==nil) return 0; //REST fetch failed, no results
        
        pageResults = [self getAppendImageResultsFromData:currentQueryJSONData toResultsArray:currentImageResults numOfResults:num];
        if (pageResults == 0) break;
        
        currentStartIndex += GOOGLE_API_MAX_RESULTS_PER_PAGE;
    }
    
    [cachedQueries setObject:currentImageResults forKey:query];
    return [currentImageResults count];
}



- (NSMutableArray*) getResultsArray {
    return currentImageResults;
}



-(BOOL) queryExists: (NSString*)query {
    if ([cachedQueries valueForKey:query]) {
        NSLog(@"%@: Query %@ cached!", GOOGLE_API_NAME, query);
        return YES;
    }
    return NO;
}


- (NSInteger) numOfResults {
    if (currentImageResults)
        return [currentImageResults count];
    return 0;
}




@end
