//
//  MCTable.m
//  CSFriends
//
//  Created by new on 2/19/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "MCTable.h"

@interface MCTable()

    @property UITableView *tableView;
    @property UIFont *fontSmall;
    @property UIFont *fontBig;
  //@property NSMutableArray *tableData;  // in .h file

@end

@implementation MCTable
  @synthesize tableView, tableData, fontBig, fontSmall, delegate;

-(id)initWithFrame:(CGRect)frame SmallFont:(UIFont *)fontS bigFont:(UIFont *)fontB
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // create table
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];    //can set style:]
        tableView.hidden = TRUE;
        [self addSubview:tableView];
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        fontSmall = fontS;
        fontBig = fontB;
    }
    
    return self;
}

-(void)refreshTable
{

    [tableView reloadData];

}

-(void)refreshTableWithNewData:(NSMutableArray *)data
{

    tableData = data;
    tableView.hidden = FALSE;
    [tableView reloadData];
    
}

-(void)resizeTable:(CGRect)frame
{

    self.frame = frame;
    tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [tableView reloadData];
    
}


#pragma mark TableView Delegate

-(UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:@"aza"];
    
    if(!cell){
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"aza"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = fontBig;
        cell.detailTextLabel.font = fontSmall;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    // get table item and set title, subtitle, image
    
    id<MCTableItem>item = [tableData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [item returnTitleForTable];
    cell.detailTextLabel.text = [item returnSubtitleForTable];
    cell.imageView.image = [UIImage imageWithData:[item returnImageDataForTable]];
    
    // add checkmark
    if([item returnHasCheckMark]) {
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // get data object and tell it to toggle checkmark
    id<MCTableItem>item = [tableData objectAtIndex:indexPath.row];
    [item toggleCheckMarkWhenSelected];
    
    // tell delegate that item selected (optional protocol)
    if(delegate){
        
        [delegate tableItemSelected:item];
    }

    [table reloadData];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 2 * fontBig.lineHeight;
    
}


@end
