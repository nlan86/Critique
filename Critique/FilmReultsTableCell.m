//
//  FilmReultsTableCell.m
//  Critique
//
//  Created by Nur Lan on 7/11/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//
#import "CritiqueMisc.h"
#import "FilmReultsTableCell.h"


@implementation FilmReultsTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellTag=-1;
    }
    
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
