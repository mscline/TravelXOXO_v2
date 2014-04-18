//
//  MCTag.h
//  CSFriends
//
//  Created by xcode on 12/7/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// tags are used in a master list of tags
// they may also be attached to a location (each of these tags is its own object, not a pointer to a tag in the master list)

@interface MCTag : NSObject

  @property NSString *tagName;
  @property BOOL selected;

  // only used in master tag list
  @property BOOL displayTripLines;
  @property NSString *finalDestination;
  @property MKPolyline *linesConnectingTripLocations;

  // only used by tags attached to locations
  @property int positionInTripAndArray;  

  -(id)initWithTitle:(NSString *)tag isSelected:(BOOL)checkmark;

  // encode/decode (did custom)
  -(id)initFromDictionary:(NSDictionary *)dict;
  -(NSDictionary *)convertToDictionary;

@end
