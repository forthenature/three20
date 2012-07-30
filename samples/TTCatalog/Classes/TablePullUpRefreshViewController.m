//
//  TablePullUpRefreshViewController.m
//  TTCatalog
//
//  Created by yi ren on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TablePullUpRefreshViewController.h"
#import "MockDataSource.h"

@interface TablePullUpRefreshViewController ()

@end

@implementation TablePullUpRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) createModel {
  MockDataSource *ds = [[MockDataSource alloc] init];
  ds.addressBook.fakeLoadingDuration = 1.0;
  self.dataSource = ds;
  [ds release];
}

- (id<UITableViewDelegate>)createDelegate {
  return [[[TTTableViewPullUpRefreshDelegate alloc] initWithController:self] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
  [super viewDidLoad];
  
}

- (void)modelDidFinishLoad:(id<TTModel>)model
{
  [super modelDidFinishLoad:model];
  
}

@end
