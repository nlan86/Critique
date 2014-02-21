//
//  BlurManager.m
//  Critique
//
//  Created by Nur on 8/4/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import "CritiqueMisc.h"
#import "BlurManager.h"

@interface BlurManager () {
    NSMutableDictionary *cachedBlurs; //key:TAG value: blurred UIImage
    NSOperationQueue *opQueue;
}

@end

@implementation BlurManager

-(id) init {
    
    self = [super init];
    
    opQueue = [[NSOperationQueue alloc] init];
    opQueue.maxConcurrentOperationCount = 1;
    cachedBlurs = [NSMutableDictionary dictionary];
    
    return self;

}

-(void)asyncBlurImageView:(UIImageView *)imgView imageTag:(NSString*)tag doUpdate:(BOOL)update {
    
    if (update && [cachedBlurs objectForKey:tag]) {
        [self dissolve:imgView secondImage:[cachedBlurs objectForKey:tag]];
        return;
   }
    
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        UIImage *blurredImg;
        blurredImg=[self blur:imgView.image];
        [cachedBlurs setObject:blurredImg forKey:tag];
        if (update) {
            [self dissolve:imgView secondImage:blurredImg];
        }
    }];
    
    [opQueue addOperation:blockOp];
}


- (UIImage*) blur:(UIImage*)theImage
{
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:GRAPHICS_BLUR_RADIUS] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
}

-(void)asyncBlur:(UIImageView*)imgView thenPutInto:(UIImageView*)newImageView imageTag:(NSString*)tag {
    
    if ([cachedBlurs objectForKey:tag]) {
        [self dissolve:newImageView secondImage:[cachedBlurs objectForKey:tag]];
        return;
    }
        NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
            UIImage *blurredImg;
            blurredImg=[self blur:imgView.image];
            [cachedBlurs setObject:blurredImg forKey:tag];
            [self dissolve:newImageView secondImage:blurredImg];
        }];
    
    [opQueue addOperation:blockOp];
        
    
}


-(void)asyncRevertBlurImageView: (UIImageView*)imgView toOriginal:(UIImage*)original {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:imgView duration:GRAPHICS_BLUR_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            imgView.image=original;
        } completion:nil];
    });

}

- (void)fadeView: (UIView*)view toVisible:(BOOL)visible {

    if (view.hidden==!visible) return; //no need to fade since already in same mode
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:view duration:GRAPHICS_FADE_TO_TRANSPARANT_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [view setHidden:!visible];
        } completion:nil];
    });
}

-(void) dissolve: (UIImageView*)imgView secondImage:(UIImage*)newImg {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:imgView duration:GRAPHICS_DISSOLVE_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            imgView.image = newImg;
        } completion:nil];
    });
}



@end
