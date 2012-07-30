//
//  TTTableViewPullUpRefreshDelegate.m
//  Three20UI
//
//  Created by yi ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Three20UI/TTTableViewPullUpRefreshDelegate.h"

// UI
#import "Three20UI/TTTableFooterPullUpRefreshView.h"
#import "Three20UI/TTTableViewController.h"
#import "Three20UI/UIViewAdditions.h"

// UICommon
#import "Three20UICommon/TTGlobalUICommon.h"

// Style
#import "Three20Style/TTGlobalStyle.h"
#import "Three20Style/TTDefaultStyleSheet+DragRefreshHeader.h"

// Network
#import "Three20Network/TTModel.h"

// Core
#import "Three20Core/TTCorePreprocessorMacros.h"


#import "Three20UI/UIViewAdditions.h"


// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
static const CGFloat kRefreshDeltaY = 65.0f;

// The height of the refresh header when it is in its "loading" state.
static const CGFloat kHeaderVisibleHeight = 60.0f;

@implementation TTTableViewPullUpRefreshDelegate

@synthesize footerView = _footerView;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithController:(TTTableViewController*)controller {
    self = [super initWithController:controller];
    if (self) {

        // Add our refresh header
        _footerView = [[TTTableFooterPullUpRefreshView alloc]
                       initWithFrame:CGRectMake(0,
                                                0,
                                                _controller.tableView.width,
                                                60)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _footerView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
        [_footerView setStatus:TTTableFooterPullUpRefreshPullToReload];
      _controller.tableView.tableFooterView = _footerView;
      _footerView.hidden = YES;
        // Hook up to the model to listen for changes.
        _model = controller.model;
        [_model.delegates addObject:self];

        // Grab the last refresh date if there is one.
        if ([_model respondsToSelector:@selector(loadedTime)]) {
            NSDate* date = [_model performSelector:@selector(loadedTime)];

            if (nil != date) {
                [_footerView setUpdateDate:date];
            }
        }
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    [_model.delegates removeObject:self];
    [_footerView removeFromSuperview];
    TT_RELEASE_SAFELY(_footerView);
    TT_RELEASE_SAFELY(_model);

    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIScrollViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView*)scrollView {
    [super scrollViewDidScroll:scrollView];

    CGFloat totalDragLength = scrollView.contentSize.height - scrollView.frame.size.height;
    CGFloat deltaY = totalDragLength + kRefreshDeltaY;
    if (scrollView.dragging && !_model.isLoading) {
        if (scrollView.contentOffset.y > scrollView.contentSize.height - 416)
        {
          CGRect rec = scrollView.frame;
          rec.origin.y = scrollView.contentSize.height+416;
//          scrollView.frame = rec;
          _footerView.hidden = NO;
        }

        if (scrollView.contentOffset.y < kRefreshDeltaY
            && scrollView.contentOffset.y > totalDragLength) {
            [_footerView setStatus:TTTableFooterPullUpRefreshPullToReload];

        } else if (scrollView.contentOffset.y > deltaY) {
            [_footerView setStatus:TTTableFooterPullUpRefreshReleaseToReload];
        }
    }

    // This is to prevent odd behavior with plain table section headers. They are affected by the
    // content inset, so if the table is scrolled such that there might be a section header abutting
    // the top, we need to clear the content inset.
    if (_model.isLoading) {
        if (scrollView.contentOffset.y <= totalDragLength) {
            _controller.tableView.contentInset = UIEdgeInsetsZero;

        } else if (scrollView.contentOffset.y > totalDragLength) {
            _controller.tableView.contentInset = UIEdgeInsetsMake(0, 0, kHeaderVisibleHeight, 0);
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    CGFloat totalDragLength = scrollView.contentSize.height - scrollView.frame.size.height;
    CGFloat deltaY = totalDragLength + kRefreshDeltaY;
    // If dragging ends and we are far enough to be fully showing the header view trigger a
    // load as long as we arent loading already
    if (scrollView.contentOffset.y >= deltaY && !_model.isLoading) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"DragRefreshTableReload" object:nil];
        [_model load:TTURLRequestCachePolicyNetwork more:NO];
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidStartLoad:(id<TTModel>)model {
    [_footerView setStatus:TTTableFooterPullUpRefreshLoading];
    CGFloat totalDragLength = _controller.tableView.contentSize.height
  - _controller.tableView.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    if (_controller.tableView.contentOffset.y > totalDragLength) {
        _controller.tableView.contentInset =
      UIEdgeInsetsMake(0.0f, 0.0f, kHeaderVisibleHeight, 0.0f);
    }
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
    [_footerView setStatus:TTTableFooterPullUpRefreshPullToReload];
    CGRect rec = _footerView.frame;
    rec.origin.y = _controller.tableView.contentSize.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _controller.tableView.contentInset = UIEdgeInsetsZero;
//    _footerView.frame = rec;
    [UIView commitAnimations];

    if ([model respondsToSelector:@selector(loadedTime)]) {
        NSDate* date = [model performSelector:@selector(loadedTime)];
        [_footerView setUpdateDate:date];

    } else {
        [_footerView setCurrentDate];
    }
    CGRect recBak = _footerView.frame;
    recBak.origin.y = _controller.tableView.contentSize.height;
    _footerView.frame = recBak;
    [_footerView setNeedsDisplay];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error {
    [_footerView setStatus:TTTableFooterPullUpRefreshPullToReload];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _controller.tableView.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidCancelLoad:(id<TTModel>)model {
    [_footerView setStatus:TTTableFooterPullUpRefreshPullToReload];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _controller.tableView.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
}
@end
