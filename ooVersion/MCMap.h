//
//  MCMap.h
//  CSFriends
//
//  Created by new on 2/19/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MCLocation.h"
#import "MCInvocationQueue.h"

typedef enum {pinDetailOptions_showPinOnly, pinDetailOptions_showPopUp, pinDetailOptions_showImage} pinDetailOptions;
typedef enum {mapTypeOptions_displayStandardMap} mapTypeOptions;  // not implemented in code


@protocol MCMap <NSObject>

  // use if want to notify delegate of change to map, don't forget to set delegate
  -(void)mapDidChange_listOfLocationsOnScreen:(NSMutableArray *)listOfLocationsOnScreen;

@end


@protocol MCTour_tourFinished <NSObject>

  // use if want to notify view controller that tour is finished
  -(void)tourFinished;

@end


@protocol MCTour_displayLocation <NSObject>

  // the tour will display locations, but displaying corresponding detail views at the bottom of the screen is up to you
  // use to notify your controller that the map is displaying a particular location
  -(void)displayingLocationInTour:(MCLocation *)loc;

@end



@interface MCMap : UIView <MKMapViewDelegate, AVAudioPlayerDelegate>

    // THE MAP
    // - use with MCLocation objects
    // - and MCAnnotationView objects (must include, but don't need to do anything with)


    -(id)initWithFrame:(CGRect)frame mapType:(mapTypeOptions)mapType displayOptions:(pinDetailOptions)pinDisplayOptions font:(UIFont *)fontX scaleFactorToConvertSizesFromIPhoneToIPad:(float)scaleFactor;  // the map will be hidden until you run moveCenterOfMap_Latitude... to set location

    -(void)moveCenterOfMap_Latitude:(float)latitude Longitude:(float)longitude MKCoordSpanWidth:(int)spanWd MKCoorSpanHeight:(float)spanHt animated:(BOOL)animated;

    -(void)moveCenterOfMapWithWrapper_Latitude:(NSNumber *)latitude Longitude:(NSNumber *)longitude MKCoordSpanWidth:(NSNumber *)spanWd MKCoorSpanHeight:(NSNumber *)spanHt animated:(NSNumber *)animated;  // to wrap use eg, [NSNumber numberWithFloat: 10.09]; for use if save as invocation

    -(void)putPinsOnMap:(NSMutableArray *)listOfFilteredLocations;   
    -(void)resize:(CGRect)frame;
    -(void)refreshMap;


    // OVERLAY
    -(MKPolyline *)createOverlayObjectComposedOfLinesBetweenPoints_orderedMCLocations:(NSMutableArray *)locations;
    -(void)addOverlay:(MKPolyline *)polyline;
    -(void)removeOverlay:(MKPolyline *)polyline;
    -(void)removeAllOverlays;
    -(void)completedEditingOverlaysSoTimeToRefreshMap;


    // TOUR
    -(void)tourLocations:(NSArray *)locationsToTour timeDelayBetween:(int)delay;
    -(void)tourPause;  // ie stop it, but can resume if want
    -(void)tourUnpause;

    -(void)endTour;
    -(void)playMusic;
    -(void)fadeMusic;

    @property (readonly)BOOL tourInProgress;
    @property int tourSpanWdDefault;
    @property int tourSpanHtDefault;


   // DELEGATES
   @property id<MCMap>mcMapDelegate;
   @property id<MCTour_tourFinished>mcTourFinishedDelegate;
   @property id<MCTour_displayLocation>mcTourDisplayLocationDelegate;


   // *properties left public to give greater flexiblity
   @property pinDetailOptions pinDisplayOptions;
   @property mapTypeOptions mapType;     // unimplemented (popup unimplemented, as well)
   @property BOOL rotateEnabled;

   @property MCInvocationQueue *mcInvocations_toDoList;

   @property UIFont *font;
   @property float scaleFactorToConvertSizesFromIPhoneToIPad;
   @property NSArray *defaultColorsForOverlay;



@end

// UPGRADES: allow to change music
