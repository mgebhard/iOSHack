//
//  NewReleaseView.h
//  Hack
//
//  Created by Megan Gebhard on 2/9/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@protocol MusicControlViewDelegate <NSObject>

- (void) previousClicked: (id) sender;
- (void) playClicked: (id) sender;
- (void) nextClicked: (id) sender;

@end

@interface MusicControlView : UIView
@property id<MusicControlViewDelegate> delegate;

- (void)setPlayImage: (NSString *)playResource;

@end
