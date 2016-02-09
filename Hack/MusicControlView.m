//
//  NewReleaseView.m
//  Hack
//
//  Created by Megan Gebhard on 2/9/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "MusicControlView.h"
@interface MusicControlView ()

@property UIButton *nextButton;
@property UIButton *previousButton;
@property UIButton *playButton;

@end


@implementation MusicControlView
- (instancetype) initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame])) {
        return nil;
    }
    

    // Audio Control buttons
    self.previousButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 80, frame.size.height * 2/3, 40, 40)];
    //    self.previousButton.backgroundColor = [UIColor redColor];
    [self.previousButton addTarget:self action:@selector(rewind:) forControlEvents:UIControlEventTouchDown];
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2 - 20, frame.size.height * 2/3, 40, 40)];
    //    self.playButton.backgroundColor = [UIColor blackColor];
    [self.playButton addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchDown];
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2 + 40, frame.size.height * 2/3, 40, 40)];
    //    self.nextButton.backgroundColor = [UIColor redColor];
    [self.nextButton addTarget:self action:@selector(fastForward:) forControlEvents:UIControlEventTouchDown];
    [self.nextButton setImage:[UIImage imageNamed:@"next"] forState:0];
    [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:0];
    [self.previousButton setImage:[UIImage imageNamed:@"previous"] forState:0];

    [self addSubview:self.previousButton];
    [self addSubview:self.playButton];
    [self addSubview:self.nextButton];
    
    return self;
}

- (void)setPlayImage: (NSString *)playResource {
    [self.playButton setImage:[UIImage imageNamed:playResource] forState:0];
}

#pragma mark AudioControl
-(void)rewind:(id)sender {
    [self.delegate previousClicked:sender];
}

-(void)playPause:(id)sender {
    [self.delegate playClicked:sender];
}

-(void)fastForward:(id)sender {
    [self.delegate nextClicked:sender];
}


@end
