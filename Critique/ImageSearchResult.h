//
//  ImageSearchResult.h
//  Critique
//
//  Created by Nur on 7/21/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSearchResult : NSObject

@property NSString *imageURL;
@property NSString *thumbURL;
@property UIImage *imageThumb;
@property UIImage *imageBig;
@property NSInteger imageWidth;
@property NSInteger imageHeight;
@property NSInteger thumbWidth;
@property NSInteger thumbHeight;

@end
