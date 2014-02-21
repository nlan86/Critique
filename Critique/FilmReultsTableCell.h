//
//  FilmReultsTableCell.h
//  Critique
//
//  Created by Nur Lan on 7/11/13.
//  Copyright (c) 2013 Lan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FilmReultsTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *moviePosterImage;
@property (assign, nonatomic) NSInteger cellTag;
@property (weak, nonatomic) IBOutlet UILabel *starLabel;
@property (strong, nonatomic) UIActivityIndicatorView *loadSpinner;

@end
