//
//  CritiqueMisc.h
//  Critique
//
//  Created by Nur Lan on 7/14/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieRecord.h"

#define COLLECTION_VIEW_MAX_IMAGE_LOADS 4

#define DEFAULT_SPACING_PX 20
#define MOVIE_THUMBNAIL_SIZE 135
#define MOVIE_PICS_RESULTS_LOAD_THUMB NO

#define GOOGLE_USE_DEMO NO
#define USE_ORIGINAL_LANGUAGE_TITLE YES

#define BACKGROUND_PIC_MARGIN 0
#define CRITIQUE_API_REQUEST_NAME_SEARCH_RESULTS 10
#define CRITIQUE_API_IMAGE_SEARCH_RESULTS 10 //30 d'habitude
#define CRITIQUE_DEFAULT_API TMDB_MoviesAPI

#define IMAGE_SEARCH_USING_TMDB YES

#define CRITIQUE_LOOG_QUESTION @"What did you watch?"

#define SEGUE_IDENTIFIER_MAIN_TO_REVIEW @"ShowReview"
#define SEGUE_IDENTIFIER_SHOW_IMAGE @"ShowMovieImage"
#define CRITIQUE_MOVIE_RESULT_LABEL_SEPARATOR @"::"
#define CRITIQUE_MOVIE_RESULT_LABEL_STRUCTURE @"%@ %@ %@" //name_separator_?year

#define IMAGES_COLLECTION_VIEW_ITEMS_TO_FILL_BLANK 6

#define GRAPHICS_TRANSPARENT_BG_WHITE [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.15f]
#define GRAPHICS_BLUR_RADIUS 15.0f
#define GRAPHICS_BLUR_DURATION 0.3f
#define GRAPHICS_DISSOLVE_DURATION 0.3f
#define GRAPHICS_FADE_TO_TRANSPARANT_DURATION 0.3f
#define GRAPHICS_BG_SWITCH_INTERVAL 5.0f
#define GRAPHICS_BG_ANIMATION_OFFSET 15

#define PLIST_BG_IMAGE_IMAGENAME_FIELD @"Image"

@interface CritiqueMisc : NSObject

@end
