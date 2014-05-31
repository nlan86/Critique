//
//  ImageSearcher.m
//  Critique
//
//  Created by Nur Lan on 7/2/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "ImageSearcher.h"


@implementation ImageSearcher

-(id) init {
    self = [super init];
    if (self) {
        cachedQueries = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSInteger) sendQuery: (NSString*)query numOfSuggestion:(NSInteger)num {
    return 0;
}

- (void) resetQuery {
    currentQueryJSONData=nil;
    currentImageResults=nil;
}


-(ImageSearchResult*) getImageResults: (NSInteger)index {
    
    if (currentImageResults && [currentImageResults count]>index) {
        return [currentImageResults objectAtIndex:index];
    }
    
    return nil;
    
}

- (NSMutableArray*) getResultsArray {
    return currentImageResults;
}


-(BOOL) queryExists: (NSString*)query {
    if ([cachedQueries valueForKey:query]) {
        NSLog(@"IMAGE SEARCH: Query %@ cached!", query);
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
