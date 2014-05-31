//
//  TMDB_MoviesAPI.h
//  Critique
//
//  Created by Nur Lan on 7/10/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "MoviesAPI.h"

#define API_LOG_NAME @"TMDB API"
#define TMDB_API_KEY @"e611fac67fa1ba432db6a4d62bd7672d"
#define TMDB_API_POSTER_SIZE @"w184" //w92, w154, w184, w342, w500, original
#define TMDB_API_BACKDROP_SIZE @"w780" //w300, w780, w1280, original
#define TMDB_BASE_URI_SEARCH_MOVIE @"http://api.themoviedb.org/3/search/movie"

#define TMDB_BASE_URI_MOVIE_QUERY @"http://api.themoviedb.org/3/movie"

#define TMDB_BASE_URI_CONFIGURATION @"http://api.themoviedb.org/3/configuration"
#define TMDB_API_QUERY_FIELD @"query=%@"
#define TMDB_API_API_KEY_FIELD @"api_key=%@"
#define TMDB_API_PAGE_FIELD @"page=%@"
#define TMDB_API_QUERY_FIELD @"query=%@"


#define JSON_CONFIG_IMAGES_FIELD @"images"
#define JSON_CONFIG_IMAGES_BASEURL_FIELD @"base_url"

#define JSON_TOTAL_RESULTS_NUM_FIELD @"total_results"
#define JSON_RESULTS_FIELD @"results"   

#define IMAGES_JSON_BACKDROP_RELATIVE_PATH_FIELD @"file_path"
#define IMAGES_JSON_BACKDROPS_ARRAY_FIELD @"backdrops"
#define TMDB_API_URI_IMAGES_PATH @"images"

#define JSON_RESULT_ADULT_FIELD @"adult"
#define JSON_RESULT_TITLE_FIELD @"title"
#define JSON_RESULT_ORIGINAL_TITLE @"original_title"
#define JSON_RESULT_ID @"id"
#define JSON_RESULT_POSTER_PATH @"poster_path"
#define JSON_RESULT_BACKDROP_PATH @"backdrop_path"
#define JSON_RESULT_POPULARITY @"popularity"
#define JSON_RESULT_RELEASE_DATE @"release_date"


@interface TMDB_MoviesAPI : MoviesAPI

@end
