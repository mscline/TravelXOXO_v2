//
//  MCMap.m
//  CSFriends
//
//  Created by new on 2/19/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MCMap.h"
#import "MCAnnotationView.h"

typedef enum {displayNextLocation, zoomIn, zoomOut, moveStep, quickPause} stackCommands;  // in order to fire off events after completion of previous use a stack that is run by a recursive loop (otherwise end up with a mess of recursive calls or completion blocks, nested and branched)


@interface MCMap ()

  // map
  @property MKMapView *mapView;
  @property id<MKMapViewDelegate>delegate;
  @property NSMutableArray *listOfFilteredLocations;

  -(void)mapDidChange;

  // overlay
  @property NSMutableArray *colorsForMapOverlay;  // when run, delegate will pop colors one by one

  // tour
  @property (readwrite)BOOL tourInProgress;  // publically readonly, privately readwrite (see .h)
  @property float delay;
  @property MCLocation *previousLocation;
  @property UIButton *tour_blockTouchesView;
  @property AVAudioPlayer *musicAndPlayer;

@end


@implementation MCMap
@synthesize mapView, font, scaleFactorToConvertSizesFromIPhoneToIPad, mcMapDelegate, listOfFilteredLocations, rotateEnabled, mapType, pinDisplayOptions, defaultColorsForOverlay, colorsForMapOverlay, delegate, tourInProgress, tour_blockTouchesView, musicAndPlayer, mcTourDisplayLocationDelegate, mcTourFinishedDelegate, delay, mcInvocations_toDoList, previousLocation, tourSpanHtDefault, tourSpanWdDefault;


#pragma mark Map - Methods

-(id)initWithFrame:(CGRect)frame mapType:(mapTypeOptions)mapTypeX displayOptions:(pinDetailOptions)pinDisplayOptionsX font:(UIFont *)fontX scaleFactorToConvertSizesFromIPhoneToIPad:(float)scaleFactor
{
    self = [super initWithFrame:frame];
    if (self) {
        
        mapView = [[MKMapView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        mapView.delegate = self;
        mapView.hidden = TRUE;
        
        // set view properties
        mapType = mapTypeX;
        pinDisplayOptions = pinDisplayOptionsX;
        font = fontX;
        scaleFactorToConvertSizesFromIPhoneToIPad = scaleFactor;
        mapView.rotateEnabled = rotateEnabled;  // default is nil/false
        
        
        // setup stuff for optional overlay; set colors to default
        defaultColorsForOverlay = [NSArray arrayWithObjects:[UIColor redColor], [UIColor blueColor], [UIColor brownColor], [UIColor purpleColor], [UIColor orangeColor], [UIColor greenColor], [UIColor yellowColor], [UIColor magentaColor], [UIColor cyanColor], nil];
        colorsForMapOverlay = [NSMutableArray arrayWithArray:defaultColorsForOverlay].mutableCopy; // when run, delegate will pop colors one by one
        
        [self addSubview:mapView];

    }
    return self;
}

-(void)resize:(CGRect)frame
{

    self.frame = frame;
    mapView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
}

-(void)putPinsOnMap:(NSMutableArray *)locations
{
    
    // to update pins on screen, remove old and add new
    // do the same to reload/refresh
    // to reload/refresh map view, remove all and re-add them
    //   (or to refresh a single pin, remove it and re-add all - but probably better to just reload all)
    //   you will have an unavoidable itermitent flicker
    
    [self.mapView removeAnnotations: listOfFilteredLocations];
    listOfFilteredLocations = locations;
    [self.mapView addAnnotations: listOfFilteredLocations];
    
    [mapView reloadInputViews];
}

-(void)refreshMap
{
    
    [self putPinsOnMap:listOfFilteredLocations];
    
}

-(void)moveCenterOfMap_Latitude:(float)latitude Longitude:(float)longitude MKCoordSpanWidth:(int)spanWd MKCoorSpanHeight:(float)spanHt animated:(BOOL)animated
{
    // unhide
    mapView.hidden = FALSE;
    
    // set map region
    CLLocationCoordinate2D centerPointOfMap = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(spanWd, spanHt);
    MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
    
    [mapView setRegion:showMapRegion animated:animated];
}

-(void)moveCenterOfMapWithWrapper_Latitude:(NSNumber *)latitude Longitude:(NSNumber *)longitude MKCoordSpanWidth:(NSNumber *)spanWd MKCoorSpanHeight:(NSNumber *)spanHt animated:(NSNumber *)animated
{

    [self moveCenterOfMap_Latitude:[latitude floatValue] Longitude:[longitude floatValue] MKCoordSpanWidth:[spanWd intValue] MKCoorSpanHeight:[spanHt intValue] animated:[animated boolValue]];

}

#pragma mark Map - Delegate

-(MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)locationToDisplay
{
    
    // if pin unselected return purple pin
    if( ![(MCLocation *)locationToDisplay selected]){
        
        MKPinAnnotationView *pin;
        pin = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
        
        if (!pin) {
            
            pin =[[MKPinAnnotationView alloc]initWithAnnotation:locationToDisplay reuseIdentifier:@"pin"];
            
        } else {
            
            pin.annotation = locationToDisplay;
        }
        
        pin.pinColor = MKPinAnnotationColorPurple;
        pin.alpha = .6;
        return pin;
        
    }else{
        // when refactor, add popup too (below), both can display the same view?
        // if pin is selected and default set to show imagePin
        if(pinDisplayOptions == pinDetailOptions_showImage && tourInProgress == FALSE){
            
            MCAnnotationView *pin2;
            pin2 = (MCAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pinImage"];
            
            NSLog(@"pin %@", pin2.locationToDisplay.title);
            
            if (!pin2) {
                
                pin2 = [[MCAnnotationView alloc]initFromLocationToDisplay:locationToDisplay font:font scaleFactor:scaleFactorToConvertSizesFromIPhoneToIPad];
                
            } else {
                
                NSLog(@"     %@", locationToDisplay.title);
                
                pin2.annotation = locationToDisplay;
                [pin2 reloadInputViews];
                
                NSLog(@"            %@", pin2.annotation.title);
                
                [pin2 setViewComponentsValues];
                
            }
            
            return pin2;
            
        }else{
            
            // return red pin to show that it is selected
            MKPinAnnotationView *pin3;
            pin3 = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
            
            if (!pin3) {
                
                pin3 =[[MKPinAnnotationView alloc]initWithAnnotation:locationToDisplay reuseIdentifier:@"pin"];
                
            } else {
                
                pin3.annotation = locationToDisplay;
            }
            
            pin3.pinColor = MKPinAnnotationColorRed;
            pin3.alpha = 1;
            return pin3;
            
        }
    }
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // pop up button not required
}

-(void)mapView:(MKMapView *)mv regionDidChangeAnimated:(BOOL)animated
{
    
    [self mapDidChange];
    
    NSLog(@"NEED TO CHANGE");
    if(tourInProgress){
        // [self notifyTourThatRegionDidChange];
    }
    
}

-(void)mapView:(MKMapView *)mv didSelectAnnotationView:(MKAnnotationView *)view
{
    
    // touch events are blocked by mapView
    // when select item, it will call this method, so you can intercept it here
    
    // Apple will deselect all other items
    // to get touches, keep everything deselected
    // then, when something is selected, track it yourself
    
    
    // remember that your Annotation is passed by reference to MCAnnotationViews
    // ie, it is attached to your view: view.annotation
    // so any changes that you make to your MCLocations, will be made to the views
    // as well and when you call mapView methods, the info will be current
    
    
    // deselect all pins
    for(MCLocation *z in listOfFilteredLocations)
    {
    	[mapView deselectAnnotation:z animated:NO];
    }
    
    // toggle pin, refresh map, and notify delegate
    MCLocation *loc = (MCLocation *)[view annotation];
    loc.selected = (loc.selected + 1) % 2;
    [self refreshMap];
    [self mapDidChange];
    
}


-(void)mapDidChange     // notify delegate that the user made a change to the map
{
    
    NSMutableArray *listOfLocationsOnScreen = [NSMutableArray new];
    
    for(MCLocation *z in [mapView annotationsInMapRect: mapView.visibleMapRect]){
        
        [listOfLocationsOnScreen addObject: z];
    }
    
    [mcMapDelegate mapDidChange_listOfLocationsOnScreen:listOfLocationsOnScreen];
    
}


#pragma mark Overlay - Methods

//  1) create an MKPolygon (or MKPolyline)
//  2) add it to mapView (it is just a chunk of data)
//  3) now, you need to tell your mapView how to display the data
//     it will ask you for additional info in the mapView viewForOverlay delegate
//     (it will give you your MKPolygon data and ask you to wrap it in a view;
//     it is the view which will define things like line width and color)


-(MKPolyline *)createOverlayObjectComposedOfLinesBetweenPoints_orderedMCLocations:(NSMutableArray *)locations
{
    
    // store map coordinates for polygon in c array
    int lengthCArray = (int)[locations count];
    CLLocationCoordinate2D cArray[lengthCArray];
    
    int counter = 0;
    
    for(MCLocation *loc in locations){
        
        cArray[counter] = CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude);
        counter++;
    }
    
    return [MKPolyline polylineWithCoordinates:cArray count:lengthCArray];
    
}

-(void)addOverlay:(MKPolyline *)polyline
{

    [mapView addOverlay:polyline];
    
}

-(void)removeOverlay:(MKPolyline *)polyline
{
    
    [mapView removeOverlay: polyline];
    
}

-(void)removeAllOverlays
{
    // remove old overlay, it may have been changed
    for(id x in mapView.overlays){
        
        if([x isKindOfClass:[MKPolyline class]]){
            
            [mapView removeOverlay: x];
        }
        
    }
}

-(void)completedEditingOverlaysSoTimeToRefreshMap
{
    
    [mapView reloadInputViews];
    
    // reset colors for next time overlays updated
    colorsForMapOverlay = [NSArray arrayWithArray:defaultColorsForOverlay].mutableCopy; // when run, delegate will pop colors one by one
}


#pragma mark Overlay - Delegate
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
    // get color
    UIColor *color;
    
    if([colorsForMapOverlay count] > 0){
    
        color = [colorsForMapOverlay objectAtIndex:0];
        [colorsForMapOverlay removeObject:color];
        
    }else{
        
        color = [UIColor grayColor];
    
    }
    
    // create overlay
    if ([overlay isKindOfClass:[MKPolyline class]])  {
        
        MKPolylineRenderer* polyView = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
        
        polyView.strokeColor = [color colorWithAlphaComponent:.5];
        polyView.lineWidth = 5;
        polyView.lineDashPattern =  [NSArray arrayWithObjects:[NSNumber numberWithFloat:12],[NSNumber numberWithFloat:8], nil];
        
        return polyView;
        
    } else {
        
        return nil;
    }
    
}


#pragma mark Tour - Methods

-(void)tourLocations:(NSArray *)locationsToTour timeDelayBetween:(int)delayInSec
{

    [self tourSetupWithDelay:delayInSec];
    
    [self tourUncheckPins];

    [self tourBuildListOfLocationsToTraverse: locationsToTour];
    
    // run queue
    [mcInvocations_toDoList runQueueUntilHitPauseOrStop_controller:self];
    
}


#pragma mark Tour - Making it all happen

-(void)tourSetupWithDelay:(float)delayInSec
{
    
    delay = delayInSec;
    tourInProgress = TRUE;
    tourSpanWdDefault = 25;  // this is a bit sloppy, because it does not reflect the fact that the map is not square
    tourSpanHtDefault = 25;  //   but not really particularly important
    previousLocation = nil;
    
    // create a view (really a button) to block inputs during tour
    tour_blockTouchesView = [[UIButton alloc]initWithFrame: CGRectMake(-500, -500, 1000, 1000)];  // hacky, but nice & clean
    [tour_blockTouchesView addTarget:self action:@selector(endTour)forControlEvents:UIControlEventTouchDown];
    [self addSubview:tour_blockTouchesView];
    
    // start music
    [self playMusic];
    
}

-(void)tourUncheckPins
{
    
    // uncheck all pins
    for(MCLocation *loc in listOfFilteredLocations){        // the listOfFilteredLocations is kept by the map
        
        loc.selected = FALSE;
    }
    
    [self refreshMap];
    
}

-(void)tourBuildListOfLocationsToTraverse:(NSArray *)locationsToTour
{
    // (I set this up as a queue, which allows the controller to easily access and modify while in progress, and simplifies recursive timing sequences)
    
    mcInvocations_toDoList = [MCInvocationQueue new];
    
    // fade, move to first pin, and unfade
    [mcInvocations_toDoList addSelectorToQueue:@selector(fadeMap) fromController:self];
    [mcInvocations_toDoList addPauseToQueue:.1];
    
    MCLocation *firstLoc = [locationsToTour objectAtIndex:0];
    [mcInvocations_toDoList addSelectorToQueue:@selector(moveCenterOfMapWithWrapper_Latitude:Longitude:MKCoordSpanWidth:MKCoorSpanHeight:animated:) fromController:self
                                          parA:[NSNumber numberWithFloat:firstLoc.coordinate.latitude]
                                          parB:[NSNumber numberWithFloat:firstLoc.coordinate.longitude]
                                          parC:[NSNumber numberWithInt:tourSpanWdDefault]
                                          parD:[NSNumber numberWithInt:tourSpanHtDefault]
                                          parE:[NSNumber numberWithBool:NO]];
    
    [mcInvocations_toDoList addSelectorToQueue:@selector(unfadeMap) fromController:self];
    
    // the map is centered on the first pin and the queue will move to the second, so set:
    previousLocation = firstLoc;
    
    
    // for each subsequent item in locationsToTour, add invocation to queue
    
    MCLocation *loc;
    
    for(int x = 1; x < [locationsToTour count]; x++){
        
        loc = [locationsToTour objectAtIndex: x];
        
        [mcInvocations_toDoList addSelectorToQueue:@selector(tourRunNextStepInSequence:) fromController:self parA:loc];
        [mcInvocations_toDoList addPauseToQueue:delay];
        
    }
    
    [mcInvocations_toDoList addSelectorToQueue:@selector(endTour) fromController:self];
}

-(void)endTour
{

    [mcInvocations_toDoList deleteAllInvocationsInQueue];
    tourInProgress = FALSE;
    
    // remove blocker view (don't really like having hacky button/view floating around, so set to nil and let it be deallocated)
    [tour_blockTouchesView removeFromSuperview];
    tour_blockTouchesView = nil;

    [self fadeMusic];
    
    if(mcTourFinishedDelegate){
    
        [mcTourFinishedDelegate tourFinished];
    }
    
}

-(void)tourRunNextStepInSequence:(MCLocation *)loc
{

    loc.selected = TRUE;
    if(previousLocation){  previousLocation.selected = FALSE; }

    [self refreshMap];
    
    // zoom out if zoomed in too far (only relivant after first pass)
    //[self zoomOutFromLocation: arry];  // this method will call nextStepOnMapWithArrayB when completed, after appropriate delay
    //  [self zoomInOnLocation:loc];

}


#pragma mark Tour - Helper Methods

/*-(void)zoomOutFromLocation:(NSMutableArray *)arry
{
    
    MCLocation *nextPin = [arry objectAtIndex:[arry count]-1];
    BOOL shouldZoomOut = TRUE;
    
    // check to see if next pin is on the screen
    for(MCLocation *loc in listOfLocationsOnScreen){
        
        if(loc == nextPin){ shouldZoomOut = FALSE;}
    }
    
    if(shouldZoomOut){
        
        // set map region
        MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(25,25);
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(mapView.region.center, sizeOfMapToShow);
        [mapView setRegion:showMapRegion animated:YES];
        
        // run nextStep
        [self performSelector:@selector(nextStepOnMapWithArrayB:) withObject:arry afterDelay:1.3];
        
    }else{
        
        [self nextStepOnMapWithArrayB:arry];
        
    }
    
}

-(void)zoomInOnLocation:(MCLocation *)centerPin
{
    
    // look at other pins, if too close, zoom in more
    
    float minDistanceBetweenPins = 20;
    
    
    // first, will need to convert center pin location from lat/long to CGPoint (location in view)
    
    // REMEMBER:
    // map coordinate = latitude/longitude
    // map point = x,y on flattened map (use MKMapSize and MKMapRect structures)
    // point = x,y in view
    // (see guide for conversion from one to another, or google mk framework)
    
    CGPoint centerPoint = [mapView convertCoordinate:centerPin.coordinate toPointToView:mapView];
    
    // go thru each pin to find out how far it is from the center
    
    float distance;
    float smallestDistance = 100000;  // just big number (sloppy, but simplifies code)
    // CGPoint nearestPoint;
    
    for(MCLocation *pin in listOfLocationsOnScreen){
        
        CGPoint otherPoint = [mapView convertCoordinate:pin.coordinate toPointToView:mapView];
        
        // find distance using distance formula
        distance = sqrtf(pow(centerPoint.x - otherPoint.x, 2) + pow(centerPoint.y - otherPoint.y, 2));
        
        
        // keep track of smallest  (if checking self or pin sharing same loc, skip)
        if(distance > 0.00001 && distance < smallestDistance) {
            
            smallestDistance = distance;    // nearestPoint = otherPoint;
        }
        
    }
    
    // if nearby pin too close, calculate how far need to move it away and do so
    if(smallestDistance < minDistanceBetweenPins){
        
        // to simplify the process, we will pretend that the distance is an x component
        //  which will give us a suitable scale factor
        
        // smallestDistance * scaleFactor = minDistanceBetweenPins
        float scaleFactor = minDistanceBetweenPins/smallestDistance;
        
        // switch back into coord (more convenient, giving it a center point)
        //  scaleFactor will also work on span (want smaller number so divide)
        [mcMap changeRegionWithLatitude:centerPin.coordinate.latitude Longitude:centerPin.coordinate.longitude MKCoordSpanWidth:mcMap.region.span.latitudeDelta/scaleFactor MKCoorSpanHeight:mcMap.region.span.longitudeDelta/scaleFactor];
        
        MKCoordinateSpan sizeOfMapToShow = MKCoordinateSpanMake(mapView.region.span.latitudeDelta/scaleFactor, mapView.region.span.longitudeDelta/scaleFactor);
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, sizeOfMapToShow);
        
        [mapView setRegion:showMapRegion animated:YES];
        
    }else{
        
        CLLocationCoordinate2D centerPointOfMap = centerPin.coordinate;
        MKCoordinateRegion showMapRegion = MKCoordinateRegionMake(centerPointOfMap, mapView.region.span);
        [mapView setRegion:showMapRegion animated:YES];
        
    }
    
}*/







// removed fade menus

//tour_NameAndImage.hidden = FALSE;
//tour_LocationLabel.hidden = FALSE;
//
//        tour_NameAndImage.hidden = TRUE;
//        tour_LocationLabel.hidden = TRUE;
//        mcTable.hidden = FALSE;
//
//        [self performSelector:@selector(unfadeMenus) withObject:nil afterDelay:.6];
//        [self performSelector:@selector(fadeMusic) withObject:nil afterDelay:1];
//
//
//
//-(void)displayTourHeaderInfo:(MCLocation *)loc
//{
//    
//    // update display/annotation field and display
//    tour_NameAndImage.locationToDisplay = loc;
//    [tour_NameAndImage setViewComponentsValues];
//    
//    tour_NameAndImage.frame = CGRectMake(
//                                         self.view.frame.size.width/2 - tour_NameAndImage.frame.size.width/2,
//                                         menu_moveToRegion.frame.size.height + mcMap.frame.size.height + menu_mainMenu.frame.size.height + self.view.frame.size.height * .045,
//                                         (self.view.frame.size.width - 20) * scaleFactorToConvertSizesFromIPhoneToIPad,
//                                         tour_NameAndImage.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad   );
//    
//    // update text field
//    tour_LocationLabel.text = loc.location;
//    tour_LocationLabel.frame = CGRectMake(0,
//                                          tour_NameAndImage.frame.origin.y + self.view.frame.size.height * .08,
//                                          self.view.frame.size.width,
//                                          30);
//    
//}


-(void)tourPause{
    
    [mcInvocations_toDoList addStopToQueue];
    tourInProgress = FALSE;
}

-(void)tourUnpause
{
    [mcInvocations_toDoList runQueueUntilHitPauseOrStop_controller:self];
}

-(void)playMusic
{
    
    // get file from the app bundle (it is not in the documents folder)
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/music.m4a", [[NSBundle mainBundle] resourcePath]]];
	NSError *error;
	musicAndPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	musicAndPlayer.numberOfLoops = -1;  // -1 means will loop
	
	if (musicAndPlayer == nil) {
		NSLog(@"%@",[error description]);
    }
	else {
        [musicAndPlayer setVolume: .6];
        musicAndPlayer.currentTime = 0;   // restart from begining
		[musicAndPlayer play];         // will be paused in terminatedAutomatedProc
                                       // or perhaps if put in queue will keep memory address? prob not
    }
    
}

-(void)fadeMusic
{
    
    musicAndPlayer.volume -= .1;
    
    if (musicAndPlayer.volume <= 0) {
        
        [musicAndPlayer stop];  // was pause
        
    }else{
        
        [self performSelector:@selector(fadeMusic) withObject:nil afterDelay:.3];
    }
    
}


-(void)fadeMap
{
    
    [MCMap animateWithDuration:.4 animations:^{
        
        mapView.alpha = .1;
        
    }];
    
}

-(void)unfadeMap
{
    
    [MCMap animateWithDuration:.4 animations:^{
        
        mapView.alpha = 1;
        
    }];
    
}

@end

