//
//  MovieRecord.h
//  Critique
//
//  Created by Nur Lan on 7/11/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MovieRecord : NSObject

@property (nonatomic,strong) NSString *movieTitle;
@property (nonatomic, strong) NSString *originalTitle;
@property (nonatomic, strong) NSString *movieID;
@property (nonatomic,strong) NSString *movieYear;
@property (nonatomic,strong) NSString *moviePosterURLString;
@property (nonatomic,strong) UIImage *moviePosterImage;
@property (nonatomic, strong) NSMutableArray *imageSearchResults;


- (NSString*) getFormattedNameAndYear;
- (NSString*) getFormattedName;
- (NSString*) getFormattedYear;


@end
