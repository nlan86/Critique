//
//  FilmSearchTextField.m
//  Critique
//
//  Created by Nur on 8/8/13.
//  Copyright (c) 2013 Nur. All rights reserved.
//

#import "FilmSearchTextField.h"

@implementation FilmSearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//make sure clear button doesn't push text/placeholder
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return bounds;
}
//make sure clear button doesn't push text/placeholder
- (CGRect)textRectForBounds:(CGRect)bounds {
    return bounds;
}
//make sure clear button doesn't push text/placeholder
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return bounds;
}

-(void)drawPlaceholderInRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByClipping alignment:self.textAlignment];
}


- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect tmp = [super rightViewRectForBounds:bounds];
    return tmp;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
