//
//  TTTableFooterPullUpRefreshView.h
//  Three20UI
//
//  Created by yi ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    TTTableFooterPullUpRefreshReleaseToReload,
    TTTableFooterPullUpRefreshPullToReload,
    TTTableFooterPullUpRefreshLoading
} TTTableFooterPullUpRefreshStatus;


@interface TTTableFooterPullUpRefreshView : UIView
{
    NSDate*                   _lastUpdatedDate;
    UILabel*                  _lastUpdatedLabel;
    UILabel*                  _statusLabel;
    UIImageView*              _arrowImage;
    UIActivityIndicatorView*  _activityView;
}

- (void)setCurrentDate;
- (void)setUpdateDate:(NSDate*)date;
- (void)setStatus:(TTTableFooterPullUpRefreshStatus)status;
@end
