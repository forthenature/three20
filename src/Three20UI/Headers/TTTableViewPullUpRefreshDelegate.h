//
//  TTTableViewPullUpRefreshDelegate.h
//  Three20UI
//
//  Created by yi ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// UI
#import "Three20UI/TTTableViewVarHeightDelegate.h"

@class TTTableFooterPullUpRefreshView;
@class TTTableHeaderDragRefreshView;
@protocol TTModel;

@interface TTTableViewPullUpRefreshDelegate : TTTableViewVarHeightDelegate
{
    TTTableFooterPullUpRefreshView* _footerView;
    id<TTModel>                   _model;
}
@property (nonatomic, retain) TTTableFooterPullUpRefreshView* footerView;
@end
