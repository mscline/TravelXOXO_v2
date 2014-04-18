//
//  MCLocation.h
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MCTag.h"
#import "MCTable.h"

@interface MCLocation : NSObject <MKAnnotation, MCTableItem>

  //@property title                     //properties inherrited from MKAnnotation
  //          coordinate            

  @property NSString *country;
  @property NSString *location;
  @property NSString *notes;
  @property NSString *imageLocation;
  @property NSMutableArray *tags;
  @property BOOL selected;

  @property MCTag *tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt;  // a location has a list of tags, when editing a specific tag, it is annoying and time consuming to have to keep going back and having to search for it


  -(id)initWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags;

  -(void)editLocationWithTitle:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinateLocation location:(NSString *)loc country:(NSString *)currentCountry notes:(NSString *)info imageLocation:(NSString *)imageName tags:(NSMutableArray *)locationTags;

  -(void)editTagsAttachedToMCLocationObject_OldTagName: (NSString *)oldTagName newTagName_orEmptyStringToDelete:(NSString *)newTagName;  // to change tag names, enumerate thru list of tags (if loc doesn't have, will remain unaffected)


  // archive/unarchive (did custom)
  -(id)createCopy;
  -(id)initFromDictionary:(NSDictionary *)dict;
  -(NSDictionary *)returnDictionaryOfLocationObject;  // ie archive
  -(NSData *)returnImageData;


  // MCTableItem Protocol Methods Implemented

    //-(NSString *)returnTitleForTable;
    //-(NSString *)returnSubtitleForTable;
    //-(NSData *)returnImageDataForTable;
    //-(BOOL)returnHasCheckMark;
    //-(void)tableItemSelected;

@end
