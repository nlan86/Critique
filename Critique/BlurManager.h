//
//  BlurManager.h
//  Critique
//
//  Created by Nur on 8/4/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlurManager : NSObject

- (UIImage*) blur:(UIImage*)theImage;
-(void)asyncBlurImageView:(UIImageView *)imgView imageTag:(NSString*)tag doUpdate:(BOOL)update;
-(void)asyncRevertBlurImageView: (UIImageView*)imgView toOriginal:(UIImage*)original;
-(void)asyncBlur:(UIImageView*)imgView thenPutInto:(UIImageView*)newImageView imageTag:(NSString*)tag;

- (void)fadeView: (UIView*)view toVisible:(BOOL)visible;

@end
