//
//  UTIHeaderView.m
//  Paldaruo
//
//  Created by Apiau on 11/09/2014.
//  Copyright (c) 2014 Uned Technolegau Iaith. All rights reserved.
//

#import "UTIHeaderView.h"

@implementation UTIHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppIcon76x76" ofType:@"png"]]];
        CGRect iconFrame = icon.frame;
        iconFrame.origin = CGPointMake(44, 44);
        icon.frame = iconFrame;
        [self addSubview:icon];
        
        UILabel *appName = [[UILabel alloc] init];
        appName.text = @"Paldaruo";
        appName.font = [UIFont fontWithName:@"Helvetica" size:40];
        [appName sizeToFit];
        CGRect appNameRect = appName.frame;
        appNameRect.origin = CGPointMake(140, 44);
        appName.frame = appNameRect;
        [self addSubview:appName];
        
        UILabel *subheader = [[UILabel alloc] init];
        subheader.text = NSLocalizedString(@"Torfoli Corpws Adnabod Lleferydd Cymraeg", @"Subheader for the Paldaruo header");
        subheader.font = [UIFont fontWithName:@"Helvetica" size:30];
        [subheader sizeToFit];
        CGRect subheaderFrame = subheader.frame;
        subheaderFrame.origin = CGPointMake(140, 92);
        subheader.frame = subheaderFrame;
        [self addSubview:subheader];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
