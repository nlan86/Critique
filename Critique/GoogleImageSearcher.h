//
//  GoogleImageSearcher.h
//  Critique
//
//  Created by Nur Lan on 7/2/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageSearcher.h"



#define GOOGLE_API_NAME @"GOOGLE_IMAGES_API"

#define GOOGLE_API_BASE_URI @"https://www.googleapis.com/customsearch/v1"
#define GOOGLE_API_KEY @"AIzaSyDTF6CbW2GSZs-mvYFa95Zdg5oGegLokdE"
#define GOOGLE_API_CX @"018413626396609586264:jzopvgz2rk8"

#define GOOGLE_API_MAX_RESULTS_PER_PAGE 10

#define GOOGLE_API_SEARCH_KEY_FIELD @"key=%@"
#define GOOGLE_API_SEARCH_TYPE_FIELD @"searchType=%@"
#define GOOGLE_API_SEARCH_TYPE_IMAGE @"image"
#define GOOGLE_API_CX_FIELD_NAME @"cx=%@"
#define GOOGLE_API_QUERY_FIELD_NAME @"q=%@"
#define GOOGLE_API_AND_QUERY_FIELD_NAME @"hq=%@"

#define GOOGLE_API_OR_QUERY_FIELD_NAME @"orTerms=%@"
#define GOOGLE_API_OR_QUERY_VALUE @"film" //stills? poster?

#define GOOGLE_API_EXCLUDE_QUERY_FIELD_NAME @"excludeTerms=%@"
#define GOOGLE_API_EXCLUDE_QUERY_VALUE @"poster"

#define GOOGLE_API_NUMBER_OF_RESULTS_FIELD @"num=%d"
#define GOOGLE_API_PAGE_START_FIELD @"start=%d"

#define GOOGLE_API_SAFESEARCH_FIELD @"safe=%@"
#define GOOGLE_API_SAFESEARCH_MEDIUM @"off" //off | medium | high

#define GOOGLE_API_SIZE_USE_FIELD NO
#define GOOGLE_API_SIZE_FIELD_AND_VAL @"imgSize=xlarge" 
    //sizes: TINY:   icon
    //       MEDIUM: small|medium|large|xlarge
    //       LARGE:  xxlarge
    //       XLARGE: huge

#define GOOGLE_API_RESPONSE_QUERIES_FIELD @"queries"
#define GOOGLE_API_RESPONSE_QUERIES_NEXTPAGE_FIELD @"nextPage"
#define GOOGLE_API_RESPONSE_QUERIES_NEXTPAGE_STARTINDEX_FIELD @"startIndex"

#define GOOGLE_API_RESPONSE_ITEMS_FIELD @"items"
#define GOOGLE_API_RESPONSE_IMAGE_DETAILS_FIELD @"image"
#define GOOGLE_API_RESPONSE_IMAGE_LINK_FIELD @"link"
#define GOOGLE_API_RESPONSE_IMAGE_THUMB_LINK_FIELD @"thumbnailLink"
#define GOOGLE_API_RESPONSE_IMAGE_WIDTH_FIELD @"width"
#define GOOGLE_API_RESPONSE_IMAGE_HEIGHT_FIELD @"height"
#define GOOGLE_API_RESPONSE_IMAGE_THUMB_WIDTH_FIELD @"thumbnailWidth"
#define GOOGLE_API_RESPONSE_IMAGE_THUMB_HEIGHT_FIELD @"thumbnailHeight"


@interface GoogleImageSearcher : ImageSearcher


@end
