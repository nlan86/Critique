//
//  ImageSearcher.h
//  Critique
//
//  Created by Nur Lan on 7/2/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//


#import "ImageSearchResult.h"
#import <Foundation/Foundation.h>


@interface ImageSearcher : NSObject

{
    @protected NSMutableDictionary *cachedQueries; //cached results
    @protected NSMutableArray *currentImageResults; //image results
    @protected NSData* currentQueryJSONData;
}

- (NSInteger) sendQuery: (NSString*)query numOfSuggestion:(NSInteger)num;
- (NSInteger) numOfResults;
-(ImageSearchResult*) getImageResults: (NSInteger)index;
- (NSMutableArray*) getResultsArray;
- (void) resetQuery;
-(BOOL) queryExists: (NSString*)query;

@end
