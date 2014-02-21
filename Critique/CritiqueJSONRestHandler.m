//
//  CritiqueJSONRestHandler.m
//  Critique
//
//  Created by Nur Lan on 7/3/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import "CritiqueJSONRestHandler.h"

@implementation CritiqueJSONRestHandler

- (NSData *) getDataObjFromURI:(NSString *)uri {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:uri]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", uri, [responseCode statusCode]);
        return nil;
    }
    
    return oResponseData;
}

+ (UIImage*)loadImageFromURL: (NSString*)urlStr {
    UIImage *retImg;
    NSURL *imgUrl = [NSURL URLWithString:urlStr];
    if (imgUrl)
    {
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        if (imgData) {
                retImg = [[UIImage alloc] initWithData:imgData];
        }
    }
    return retImg;

}

+ (NSString *) convertStringToURLEncoding: (NSString*)string {
    const unsigned char * charStr = (const unsigned char*)[string UTF8String];
    int stringLen = strlen((const char*)charStr);
    NSMutableString *retStr = [NSMutableString string];
    
    for (int i=0; i<stringLen; i++) {
        if (charStr[i]==' ')
            [retStr appendString:@"+" ];
        else if (charStr[i] == '.' || charStr[i] == '-' || charStr[i] == '_' || charStr[i] == '~' ||
                 (charStr[i] >= 'a' && charStr[i] <= 'z') ||
                 (charStr[i] >= 'A' && charStr[i] <= 'Z') ||
                 (charStr[i] >= '0' && charStr[i] <= '9')) {
            [retStr appendFormat:@"%c", charStr[i]];
            
        } else {
            [retStr appendFormat:@"%%%02X", charStr[i]];
        }
        
    }
    NSLog(@"Safe-converted %@ to %@\n",string,retStr);
    return retStr;
}

//safely retrieves a string value for a key from a dictionary. returns empty string if key doesn'y exist
+ (NSString*)safeJsonGetStringForKey: (NSString*)key fromObject:(id)obj {
    
    if (!obj) return @"";
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSString *tempStr;
        NSString *retStr;
        
        tempStr=[obj objectForKey:key];
        if (tempStr==(NSString*)[NSNull null] || tempStr==nil)
            retStr=@""; //check for null collection value
        else retStr=[NSString stringWithFormat:@"%@",tempStr];
        
        return retStr;
        
    }
    return @"";
}

@end
