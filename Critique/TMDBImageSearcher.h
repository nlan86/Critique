//
//  TMDBImageSearcher.h
//  Critique
//
//  Created by Nur on 5/31/14.
//  Copyright (c) 2014 Nur. All rights reserved.
//

#import "ImageSearcher.h"
#import "TMDB_MoviesAPI.h"


/* 
 TMDB Image Queries Usage:
 
 - Get movie info:
     GET /3/movie/{id}?api_key=######

 - Get movie images:
    /3/movie/{id}/images?api_key=######

 - /images/ response structure:
    
 
 */

@interface TMDBImageSearcher : ImageSearcher

@end
