//
//  MCViewController.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>

#import "MCTable.h"
#import "MCMap.h"
#import "MCAddPinViewController.h"

@interface MCViewController : UIViewController <MCAddPinViewProtocol, UIAlertViewDelegate, UIActionSheetDelegate, AVAudioPlayerDelegate, MCTable, MCMap, MCTour_tourFinished>

  -(void)savePins;
  -(void)importNewData;

  // application data
  -(float)returnScaleFactor;
  -(UIFont *)returnFontSmall;
  -(UIFont *)returnFontBig;
  -(UIFont *)returnFontNormal;
  -(NSMutableArray *)returnListOfAllLocations;
  -(NSMutableArray *)returnListOfFilteredLocations;
  -(NSMutableArray *)returnListOfTags; 

@end
