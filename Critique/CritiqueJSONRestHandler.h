//
//  CritiqueJSONRestHandler.h
//  Critique
//
//  Created by Nur Lan on 7/3/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CritiqueJSONRestHandler : NSObject
    - (NSData *) getDataObjFromURI:(NSString *)uri;
    + (NSString *) convertStringToURLEncoding: (NSString*)string;
    + (void)loadImageFromURLString:(NSString*)urlStr toImageView:(UIImageView*)imgView;
//safely retrieves a string value for a key from a dictionary. returns empty string if key doesn'y exist
+ (NSString*)safeJsonGetStringForKey: (NSString*)key fromObject:(id)obj;
+ (UIImage*)loadImageFromURL: (NSString*)urlStr;


@end
