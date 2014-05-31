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
 
 - Get movie general properties:
     GET /3/movie/{id}?api_key=######

 - Get movie images:
    /3/movie/{id}/images?api_key=######

 - /images/ response structure:
         {
         "id": 550,
         "backdrops": [
         {
         "file_path": "/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg",
         "width": 1280,
         "height": 720,
         "iso_639_1": null,
         "aspect_ratio": 1.78,
         "vote_average": 6.6470588235294121,
         "vote_count": 17
         },

 
 */

@interface TMDBImageSearcher : ImageSearcher

@end
