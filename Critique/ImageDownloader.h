//
//  ImageDownloader.h
//  Critique
//
//  Created by Nur Lan on 7/11/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "ImageDownloadItem.h"
#import "MovieRecord.h"
#import <Foundation/Foundation.h>

@interface ImageDownloader : NSObject

//@property (nonatomic,strong) MovieRecord *movieRecord;

@property (nonatomic, strong) ImageDownloadItem *imageDownloadItem;
@property (nonatomic, copy) void (^completionHandler)(void);

-(void)startDownload;
-(void)cancelDownload;

@end
