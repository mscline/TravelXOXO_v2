//
//  MCTable.h
//  CSFriends
//
//  Created by new on 2/19/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

// when you create a new MCTable, you will pass an array of data objects to be displayed
// the data objects must implement MCTableItem
// if you are working with a map, you may wish to use MCLocation objects, which implements both <MKAnnotation, MCTableItem>

@protocol MCTableItem <NSObject>

  -(NSString *)returnTitleForTable;
  -(NSString *)returnSubtitleForTable;  // displayed below
  -(NSData *)returnImageDataForTable;
  -(BOOL)returnHasCheckMark;

  -(void)toggleCheckMarkWhenSelected;

@end


@protocol MCTable <NSObject>

  // implement method in view controller (optional) and set delegate

  // MCTable will call the toggleCheckMarkWhenSelected MCTableItem delegate to update the data object upon selection
  // this delegate method will in turn, notify the view controller
  // you will probably, at the very least, want to tell the view controller to refresh the table

  -(void)tableItemSelected:(id)dataObjectSelected;

@end


@interface MCTable : UIView <UITableViewDataSource, UITableViewDelegate>


  -(id)initWithFrame:(CGRect)frame SmallFont:(UIFont *)fontSmall bigFont:(UIFont *)fontBig;
  -(void)resizeTable:(CGRect)frame;

  -(void)refreshTableWithNewData:(NSMutableArray *)data;  // table will be hidden until add data 
  -(void)refreshTable;


  @property id<MCTable>delegate;
  @property NSMutableArray *tableData;


@end
