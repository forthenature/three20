//
//  TTTableFooterPullUpRefreshView.m
//  Three20UI
//
//  Created by yi ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TTTableFooterPullUpRefreshView.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet+DragRefreshHeader.h"

// Network
#import "Three20Network/TTURLCache.h"

// Core
#import "Three20Core/TTGlobalCoreLocale.h"
#import "Three20Core/TTCorePreprocessorMacros.h"

#import <QuartzCore/QuartzCore.h>

@implementation TTTableFooterPullUpRefreshView

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow) {
        [_activityView startAnimating];

    } else {
        [_activityView stopAnimating];
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:(animated ? ttkDefaultFastTransitionDuration : 0.0)];
    _arrowImage.alpha = (shouldShow ? 0.0 : 1.0);
    [UIView commitAnimations];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentDate {
  [self setUpdateDate:[NSDate date]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUpdateDate:(NSDate*)newDate {
  if (newDate) {
    if (_lastUpdatedDate != newDate) {
      [_lastUpdatedDate release];
    }

    _lastUpdatedDate = [newDate retain];

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    _lastUpdatedLabel.text = [NSString stringWithFormat:
                              TTLocalizedString(@"Last updated: %@",
                                                @"The last time the table view was updated."),
                              [formatter stringFromDate:_lastUpdatedDate]];
    [formatter release];

    } else {
    _lastUpdatedDate = nil;
    _lastUpdatedLabel.text = TTLocalizedString(@"Last updated: never",
                                               @"The table view has never been updated");
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImageFlipped:(BOOL)flipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    [_arrowImage layer].transform = (flipped ?
                                     CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) :
                                     CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
    [UIView commitAnimations];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [_lastUpdatedLabel removeFromSuperview];
        _lastUpdatedLabel = nil;
        [_statusLabel removeFromSuperview];
        _statusLabel = nil;
        [_arrowImage removeFromSuperview];
        _arrowImage = nil;
        [_activityView removeFromSuperview];
        _activityView = nil;

        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        _lastUpdatedLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(0.0f, 30.0f,
                                                      frame.size.width, 20.0f)];
        _lastUpdatedLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _lastUpdatedLabel.font            = TTSTYLEVAR(tableRefreshHeaderLastUpdatedFont);
        _lastUpdatedLabel.textColor       = TTSTYLEVAR(tableRefreshHeaderTextColor);
        _lastUpdatedLabel.shadowColor     = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
        _lastUpdatedLabel.shadowOffset    = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.textAlignment   = UITextAlignmentCenter;
        [self addSubview:_lastUpdatedLabel];

        _statusLabel = [[UILabel alloc]
                        initWithFrame:CGRectMake(0.0f, 8.0f,
                                                 frame.size.width, 20.0f )];
        _statusLabel.autoresizingMask =
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _statusLabel.font             = TTSTYLEVAR(tableRefreshHeaderStatusFont);
        _statusLabel.textColor        = TTSTYLEVAR(tableRefreshHeaderTextColor);
        _statusLabel.shadowColor      = TTSTYLEVAR(tableRefreshHeaderTextShadowColor);
        _statusLabel.shadowOffset     = TTSTYLEVAR(tableRefreshHeaderTextShadowOffset);
        _statusLabel.backgroundColor  = [UIColor clearColor];
        _statusLabel.textAlignment    = UITextAlignmentCenter;
        [self setStatus:TTTableFooterPullUpRefreshPullToReload];
        [self addSubview:_statusLabel];

        UIImage* arrowImage = [UIImage imageNamed:@"blueDownArrow.png"];
        _arrowImage = [[UIImageView alloc]
                       initWithFrame:CGRectMake(25.0f, 10.0f,
                                                arrowImage.size.width, arrowImage.size.height)];
        _arrowImage.image             = arrowImage;
        [_arrowImage layer].transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        [self addSubview:_arrowImage];

        _activityView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.frame = CGRectMake( 30.0f, 18.0f, 20.0f, 20.0f );
        _activityView.hidesWhenStopped  = YES;
        [self addSubview:_activityView];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setStatus:(TTTableFooterPullUpRefreshStatus)status {
    switch (status) {
        case TTTableFooterPullUpRefreshReleaseToReload: {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:YES];
            _statusLabel.text = TTLocalizedString(@"Release to update...",
                                @"Release the table view to update the contents.");
            break;
        }

        case TTTableFooterPullUpRefreshPullToReload: {
            [self showActivity:NO animated:NO];
            [self setImageFlipped:NO];
            _statusLabel.text = TTLocalizedString(@"Pull up to update...",
                                    @"Drag the table view up to update the contents.");
            break;
        }

        case TTTableFooterPullUpRefreshLoading: {
            [self showActivity:YES animated:YES];
            [self setImageFlipped:NO];
            _statusLabel.text = TTLocalizedString(@"Updating...",
                                                  @"Updating the contents of a table view.");
            break;
        }

        default: {
            break;
        }
    }
}

@end
