//
//  MovieRecord.m
//  Critique
//
//  Created by Nur Lan on 7/11/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "MovieRecord.h"
#import "CritiqueMisc.h"



@implementation MovieRecord

-(NSString *)getFormattedNameAndYear {
    
    BOOL isYear = [self.movieYear isEqualToString:@""];
    
    NSString *retStr=
    [NSString stringWithFormat:@"%@ %@%@%@",
     (USE_ORIGINAL_LANGUAGE_TITLE && ![self.originalTitle isEqualToString:@""]) ? self.originalTitle : self.movieTitle,
     isYear ? @"" : @"(",
     self.movieYear,
     isYear ? @"" : @")"];
    
    
    if (USE_ORIGINAL_LANGUAGE_TITLE) {
        NSLog(@"Original title is: %@", self.originalTitle);
    }
    
    return retStr;
    
    
    
}


@end
