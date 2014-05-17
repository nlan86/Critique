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
    
    NSString *formattedName = [self getFormattedName];
    NSString *formattedYear = [self getFormattedYear];

    BOOL isYear = [formattedYear isEqualToString:@""];
    
    NSLog((USE_ORIGINAL_LANGUAGE_TITLE && ![self.originalTitle isEqualToString:@""]) ? @"Yes" : @"NO");
    
    NSString *retStr=
    [NSString stringWithFormat:@"%@ %@%@%@",
     formattedName,
     isYear ? @"" : @"(", formattedYear,
     isYear ? @"" : @")"];
    
    NSLog(@"Formatted Movie Name and Year to: %@", retStr);
    
    return retStr;
    
}

- (NSString*) getFormattedYear {
    return self.movieYear;
}

- (NSString*) getFormattedName {
    
    NSString *retStr=
    [NSString stringWithFormat:@"%@",
     (USE_ORIGINAL_LANGUAGE_TITLE && ![self.originalTitle isEqualToString:@""]) ? self.originalTitle : self.movieTitle];
    
    if (USE_ORIGINAL_LANGUAGE_TITLE) {
        NSLog(@"Original title is: %@", self.originalTitle);
    }
    
    NSLog(@"Formatted Movie Name: %@", retStr);
    
    return retStr;
}


@end
