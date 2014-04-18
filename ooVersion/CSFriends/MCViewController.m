//
//  MCViewController.m
//  CSFriends
//
//  Created by xcode on 11/27/13.
//  Copyright (c) 2013 xcode. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <math.h>

#import "MCAppDelegate.h"
#import "MCViewController.h"
#import "MCDetailViewController.h"
#import "MCSelectTagViewController.h"
//#import "MCAddPinViewController.h"        // in .h file

#import "MCLocation.h"
#import "MCAnnotationView.h"
#import "MCTag.h"

#import "MCInvocationQueue.h"
#import "MCArchiveFileManager.h"
#import "UIViewController+ResizingForDifferentDevices.h"

@interface MCViewController ()

  @property MCTable *mcTable;
  @property MCMap *mcMap;
  @property MCInvocationQueue *mcInvocationQueue_toDoItems;

  // arrays
  @property NSMutableArray *listOfAllLocations;
  @property NSMutableArray *listOfFilteredLocations;
  @property NSMutableArray *listOfLocationsOnScreen;
  @property NSMutableArray *listOfTags;

  @property NSMutableArray *selectedPinsForSegue;  // not actively maintained (ie, don't just call it)
  @property NSMutableArray *mapViewOverlays;

  @property NSMutableArray *queueOfSelectors;      // easier to work with timing sequences with queue/stack; also helpful in segue, can specify what to do upon return/viewDidLoad, simplifying the code; should contain selectors or @"pause" to end iterative process (no passing of vaiables, however!)

  // views and buttons
  @property (strong, nonatomic) IBOutlet UIView *menu_tableIsFullScreen;
  @property (strong, nonatomic) IBOutlet UIView *menu_moveToRegion;
  @property (strong, nonatomic) IBOutlet UIView *menu_mainMenu;

  @property (strong, nonatomic) IBOutlet UIButton *filterByTagButton;
  @property (strong, nonatomic) IBOutlet UIButton *addFriendsButton;
  @property (strong, nonatomic) IBOutlet UIButton *viewSelection;
  @property (strong, nonatomic) IBOutlet UIButton *optionsButton;
  @property (strong, nonatomic) IBOutlet UIButton *backButtonForFullScreenMenu;

  // for going on a tour
  @property MCAnnotationView *tour_NameAndImage;
  @property UILabel *tour_LocationLabel;
  @property float defaultDelay;

  @property UIButton *fullScreenViewToBlockInputs;
  @property BOOL terminateAutomatedTour;

  @property AVAudioPlayer *musicAndPlayer;
  
  // action sheets
  @property UIActionSheet *actionSheetPinOptions;
  @property UIActionSheet *actionSheetTour;

  // fonts
  @property UIFont *fontBig, *fontNormal, *fontSmall;
  @property float scaleFactorToConvertSizesFromIPhoneToIPad;

  // misc
  @property BOOL screenAndPositionLayoutCompleted;
  @property (strong, nonatomic) IBOutlet UILabel *labelShowingTagsSelected;
  @property BOOL showImageNotPin;
  @property MCArchiveFileManager *archiveFM;       // to prevent early release of object before delegate call

  // setup                                  
  -(void)initializeScreenElementsAndArrays;
  -(void)loadData_fileNameForPinPlistData:(NSString *)fileNamePins fileNameForTagPlistData:(NSString *)fileNameTags;
  -(void)intro_delay:(int)delayBeforeBegin;
  -(void)setScreenPositionsAndFonts;
     -(void)moveMajorScreenElementsToStartingPositions;
     -(void)changeFontSize;
     -(void)spaceMenuItems:(UIView *)view;

  // update
  -(void)filterPinsAndDisplayMap;
  -(void)updateTableWhenMapRegionChanges;
  -(void)sortLocations:(NSMutableArray *)arry;

  // buttons
  - (IBAction)europeButtonPressed:(id)sender;
  - (IBAction)asiaButtonPressed:(id)sender;
  - (IBAction)northAmericaButtonPressed:(id)sender;
  - (IBAction)southAmericaButtonPressed:(id)sender;
  - (IBAction)africaButtonPressed:(id)sender;

  - (IBAction)viewFullListButtonPressed:(id)sender;
  - (IBAction)tourChoices:(id)sender;
  - (IBAction)swipeLeft:(id)sender;   // calls viewFullList
  - (IBAction)swipeRight:(id)sender;  // hides viewFullList
  - (IBAction)pinOptionButtonPressed:(id)sender;

  // Full Screen Buttons
  - (IBAction)backButtonPressed:(id)sender;
  - (IBAction)selectAllButtonPressed:(id)sender;
  - (IBAction)deselectAllButtonPressed:(id)sender;
  - (IBAction)viewSelectionButtonPressed:(id)sender;
  - (IBAction)deleteSelectionButtonPressed:(id)sender;

  // build overlay
  -(void)makeMapPolygonForTags;
  -(void)displayTripLinesOverlay;
  -(NSMutableArray *)makeListOfFilteredLocationsForTag:(MCTag *)tag;
  -(MCTag *)searchForTag:(MCTag *)searchFor inLocationObject:(MCLocation *)loc;

  // automated tour 
  - (void)tourRegionSetup;
  - (void)tourWorldSetup;
  - (void)tourTripSetup:(MCTag *)trip;
  - (void)tourSetup2:(NSMutableArray *)arry;
  - (void)nextStepOnMapWithArray:(NSMutableArray *)arry;
  - (void)zoomInOnLocation:(MCLocation *)loc;
  - (void)zoomOutFromLocation:(NSMutableArray *)arry;
  - (IBAction)fullScreenToBlockInputsRecievesInput:(id)sender;
  - (void)terminateAutomatedProcess;

  // smoothing out transitions, little interface features, etc.
  -(void)makeScreenObjectsVisable;
  -(void)makeScreenObjectsInvisable;
  -(void)fadeMenus;
  -(void)unfadeMenus;

  // File Management
  //-(void)savePins;      // in .h file
  -(void)deletePins;

@end


// UPGRADES:
// allow to pull data from webserver
// Map: allow to change to satallite
// Tour: add option that mixes slide show with the tour
// Tour: add airplane flying from one point to the next with line following behind (overlay may be expensive)
// Tour: consider breaking out the tour as an object that can be reused (it is tightly integrated with mapview and rest of program, so it might be tricky; note: mapView cannot be subclassed)
//  [initially this was just a small project, so I put a lot of functionality within the view controllers, the tag controller takes care of updating the list of tags, for instance (tags and locations, of course, are their own classes); it may be worth considering breaking out this functionality as classes of their own (subclass NSMutableArray and move the functionality there), but probably not worth the effort, and delegate methods often have to go back through the controller (MVC)]

// LITTLE THINGS:
// can hit edit trip if nothing selected??
// add exit button to detail page so don't have to scroll thru (or change the last "next" to exit)???
// detail label names should be changed???
// overlay didn't disappear when deleted tags (it is a caching thing or not called) or did when not supposed to??? ahhh
// option for delete all pins for trip (vs just the label)?

// KNOWN ISSUES:
// pointer to playing music lost upon deactivation, then can't cancel it upon reload ????

// if change name/title of a location which is marked as the final destination, it will not update the final destination (not a big deal, but would be nice to address)

// displaying photos on the map is problematic: (removed from beta release)
// -without reuse ids, get memory issues
// -if have reuse for each location, see improvement because not making the same one twice, but still have potential memory issues - could turn off photo on memory warning) 
// -if use reuse location objects, mapKit not reusing properly (I can reset the values, but mapKit has it cached or something, maybe a problem with subclassing?) [mapkit treats annotations like a list in a table, when the top field becomes free all values are moved up one, the problem is that the locations are no longer in the correct position

// check, I think that sometimes overlays don't refresh (at least in sim), probably mapKit caching and memory

// map kit provides no animation on long animations across globe (see more often on device than simulator), a guess is that it has to do with memory and caching

// in China, map kit given different data stream (showing Tiawan as a province of China, et. al), resulting in CGBitmapContextCreate error, but does not crash app; online discussion boards concerning are in Chinese

@implementation MCViewController
  @synthesize listOfFilteredLocations, listOfAllLocations, listOfLocationsOnScreen, mcTable, fullScreenViewToBlockInputs, terminateAutomatedTour, listOfTags, addFriendsButton, filterByTagButton, labelShowingTagsSelected, selectedPinsForSegue, menu_tableIsFullScreen, menu_moveToRegion, menu_mainMenu, viewSelection, showImageNotPin, tour_NameAndImage, tour_LocationLabel, optionsButton, screenAndPositionLayoutCompleted, fontBig, fontNormal, fontSmall, backButtonForFullScreenMenu, scaleFactorToConvertSizesFromIPhoneToIPad, musicAndPlayer, mapViewOverlays, actionSheetPinOptions, actionSheetTour, archiveFM, mcMap, queueOfSelectors, mcInvocationQueue_toDoItems, defaultDelay;


#pragma mark Setup, Filter, & Display

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MCArchiveFileManager *aFM = [MCArchiveFileManager new];
    [aFM cleanUpOldFiles];
    
    
    // SETUP QUEUE OF THINGS NEED TO DO (in order to make more readable and easy to work with, and to avoid recursive timing sequences, the setup uses a queue of invocations, which are all listed here in viewDidLoad)
    
    mcInvocationQueue_toDoItems = [MCInvocationQueue new];
    
    // view did load
    
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(initializeFontsForiPadAndiPhoneAndCorrespondingScaleFactor) fromController:self];
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(initializeScreenElementsAndArrays) fromController:self];
    [mcInvocationQueue_toDoItems addStopToQueue];
    
    // xxx stop xxx
    
    // view did appear
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(setScreenPositionsAndFonts) fromController:self];
    
    // then run intro tour (adding delay between calls)
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(playMusic) fromController:mcMap];
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(fadeMenus) fromController:self];

    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(northAmericaButtonPressed:) fromController:self parA:nil];
      [mcInvocationQueue_toDoItems addPauseToQueue:1.5];
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(europeButtonPressed:) fromController:self parA:nil];
      [mcInvocationQueue_toDoItems addPauseToQueue:1.5];

    // upon completion of tour, load saved data and refresh
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(loadData_fileNameForPinPlistData:fileNameForTagPlistData:) fromController:self parA:@"csfriends.plist" parB:@"listOfTags.plist"];
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(refreshAll) fromController:self];

    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(unfadeMenus) fromController:self];
      [mcInvocationQueue_toDoItems addPauseToQueue:5];
    [mcInvocationQueue_toDoItems addSelectorToQueue:@selector(fadeMusic) fromController:mcMap];
    
    [mcInvocationQueue_toDoItems addStopToQueue];
    
    // xxx stop xxx
    
    
    // RUN QUEUE
    [mcInvocationQueue_toDoItems runQueueUntilHitPauseOrStop_controller:self];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    if(!screenAndPositionLayoutCompleted) {

        [mcInvocationQueue_toDoItems runQueueUntilHitPauseOrStop_controller:self];
        
    }else{

        // when coming back from an unwind segue
        [self refreshAll];
        
    }

}


-(void)refreshAll
{

    [self checkToSeeIfNewDataAndImport];         // if new data to import, will present tag controller
    [self filterPinsAndDisplayMap];
    [self updateTableWhenMapRegionChanges];
    [self makeMapPolygonForTags];                // better to move to finish setup, but would need to set up delegate method to call when leave tag view controller
    [self displayTripLinesOverlay];
    [self makeScreenObjectsVisable];             // to avoid flicker, when updating
}

-(void)initializeFontsForiPadAndiPhoneAndCorrespondingScaleFactor
{
    
    // initialize fonts resize UIViews (containers)
    if(self.view.frame.size.width < 700.0 ){
        
        // it is a phone (there are a couple of ways to do it, but all have drawbacks)
        fontSmall = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        fontNormal = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        fontBig = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        scaleFactorToConvertSizesFromIPhoneToIPad = 1.0;
        
    }else{
        
        // it is a iPad
        fontSmall = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        fontNormal = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
        fontBig = [UIFont fontWithName:@"HelveticaNeue-Light" size:26.0];
        scaleFactorToConvertSizesFromIPhoneToIPad = 20.0/12;
        // note: remember to add dec place, or it will treat as an int and round, even though it is a float
        
    }
}

-(void)initializeScreenElementsAndArrays
{
    
    // initialize arrays
    listOfAllLocations = [NSMutableArray new];
    listOfFilteredLocations = [NSMutableArray new];
    listOfLocationsOnScreen = [NSMutableArray new];
    
    selectedPinsForSegue = [NSMutableArray new];
    listOfTags = [NSMutableArray new];
    mapViewOverlays = [NSMutableArray new];
    
    // create mapView
    mcMap = [[MCMap alloc]initWithFrame:CGRectMake(0, 0, 1, 1)
                                          mapType: mapTypeOptions_displayStandardMap
                                   displayOptions: pinDetailOptions_showPinOnly
                                             font: fontNormal
        scaleFactorToConvertSizesFromIPhoneToIPad: scaleFactorToConvertSizesFromIPhoneToIPad];
    
    mcMap.mcMapDelegate = self;
    mcMap.mcTourFinishedDelegate = self;
    
    [self.view addSubview:mcMap];
    [self.view sendSubviewToBack:mcMap];
    
    // create table
    mcTable = [[MCTable alloc] initWithFrame:CGRectMake(0, 0, 1, 1) SmallFont:fontSmall bigFont:fontBig];
    mcTable.delegate = self;
    [self.view addSubview:mcTable];

    
    // hide table to full screen menu
    menu_tableIsFullScreen.hidden = TRUE;
    backButtonForFullScreenMenu.hidden = TRUE;
    
    // create bubble to display info during tour (use existing annotation format to create)
    MCLocation *loc = [[MCLocation alloc] initWithTitle:@"title" coordinate:CLLocationCoordinate2DMake(0.0,0.0) location:nil country:nil notes:nil imageLocation:@"person" tags:nil];
    tour_NameAndImage = [[MCAnnotationView alloc] initFromLocationToDisplay:loc font: fontBig scaleFactor:scaleFactorToConvertSizesFromIPhoneToIPad];
    
    tour_NameAndImage.hidden = TRUE;
    [self.view addSubview:(UIView *)tour_NameAndImage];
    [self.view bringSubviewToFront:tour_NameAndImage];
    
    // add additional label for during tour
    tour_LocationLabel = [UILabel new];
    
    tour_LocationLabel.backgroundColor = [UIColor clearColor];
    tour_LocationLabel.font = fontBig;
    tour_LocationLabel.textColor = [UIColor blackColor];
    tour_LocationLabel.textAlignment = NSTextAlignmentCenter;
    
    tour_LocationLabel.hidden = true;
    [self.view addSubview:tour_LocationLabel];

    // create overlay to block inputs when desired
    fullScreenViewToBlockInputs = [[UIButton alloc]initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
    fullScreenViewToBlockInputs.backgroundColor = [UIColor clearColor];
    fullScreenViewToBlockInputs.hidden = TRUE;    
    [fullScreenViewToBlockInputs addTarget:self action:@selector(terminateAutomatedProcess) forControlEvents:UIControlEventAllTouchEvents];
    [self.view addSubview:fullScreenViewToBlockInputs];
    [self.view bringSubviewToFront:fullScreenViewToBlockInputs];
    
}


-(void)loadData_fileNameForPinPlistData:(NSString *)fileNamePins fileNameForTagPlistData:(NSString *)fileNameTags
{
    // LOCATIONS: 
    // access plist and build listOfAllLocations
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray * loadedData = [NSArray arrayWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:@"csfriends.plist"] ];
    
    // convert data back into objects (each object is a dictionary)
    for(id z in loadedData)
    {
        MCLocation *pinToAdd = [[MCLocation alloc] initFromDictionary:z];
        [listOfAllLocations addObject:pinToAdd];
    }
    

    // TAGS: 
    // load tags and build listOfTags array
    NSMutableArray *arry = [NSArray arrayWithContentsOfURL:[documentDirectory URLByAppendingPathComponent:@"listOfTags.plist"] ];

    for(NSDictionary *z in arry) {
        
        // convert dictionary to object and add to listOfTags
        [listOfTags addObject: [[MCTag alloc]initFromDictionary:z]];       
    }

    // IMAGES: 
    // image location is stored in location and will be retrived when needed
    
    
    // set initialization complete
    screenAndPositionLayoutCompleted = TRUE;
    
}

-(void)filterPinsAndDisplayMap
{

    // filter list of locations: if loc has any of the tags, keep it
    [listOfFilteredLocations removeAllObjects];
    
    // make list of selected tags
    NSMutableArray *listOfSelectedTags = [NSMutableArray new];
    
    for(MCTag *z in listOfTags){
        
        if(z.selected){ [listOfSelectedTags addObject:z];}
        
    }
    
    // if no tags selected, show all
    if([listOfSelectedTags count] == 0){
    
        labelShowingTagsSelected.text = @"";
        
        for(MCLocation *z in listOfAllLocations){
            
            [listOfFilteredLocations addObject:z];
            
        }
        
    }else{
    
        // for each selected pin, look at each of its tags and see if in master list
        for(MCLocation *checkThisPin in listOfAllLocations){

            if([self checkToSeeIfPinMeetsFilterCriteria:checkThisPin listOfSelectedTags:listOfSelectedTags]){
                        
                [listOfFilteredLocations addObject:checkThisPin];
            
            }
    
        }
        
        // update labelShowingTagsSelected in mainscreen
        NSString *str = [NSString stringWithFormat:@"Tags:"];
        
        for(MCTag *z in listOfSelectedTags){
            str = [NSString stringWithFormat:@"%@ %@", str, z.tagName];
        }
            
        labelShowingTagsSelected.text = str;
    }
    
    // update map
    [mcMap putPinsOnMap:listOfFilteredLocations];
    
}

-(MCTag *)checkToSeeIfPinMeetsFilterCriteria:(MCLocation *)checkThisPin listOfSelectedTags:(NSMutableArray *)listOfSelectedTags
{

    for(MCTag *checkThisTag in checkThisPin.tags) {
            
            // check to see if it is in the listOfTags
            for(MCTag *requiredTag in listOfSelectedTags){
        
                if([checkThisTag.tagName isEqual: requiredTag.tagName]){ return checkThisTag;}
            }
        
    }
    
    return nil;

}

-(void)togglePin:(MCLocation *)loc      
{
    loc.selected = (loc.selected + 1) % 2; 
}


#pragma mark Import New Data
-(void)checkToSeeIfNewDataAndImport
{
    archiveFM = [MCArchiveFileManager new];
    [archiveFM checkToSeeIfNewDataAndPrepareForImport:self];
}

-(void)importNewData  // called by archiveFM, when checkToSeeIfNewDataAndPrepareForImport complete
{
    
    MCAppDelegate *appDel = [[UIApplication sharedApplication] delegate];
    
    // add new locations to listOfAllLocations, and tags to listOfTags
    [listOfAllLocations addObjectsFromArray: appDel.locationsToImport];
    [listOfTags addObjectsFromArray: appDel.tagsToImport];
    
    // delete temp location and tag data
    appDel.locationsToImport = nil;
    appDel.tagsToImport = nil;
    
    // manually save listOfAllLocations to hard drive
    [self savePins];
    
    // but will take the lazy approach to saving the list of tags and updating
    //   MCViewController properties to reflect the new data
    // we open tag view controller letting the user select pins (eleminating a source of possible confusion)
    // when exit tagViewController, it will save the list of tags and run viewDidAppear
    //   which will rebuild everything else from the ground up
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Data Import Complete" message:@"Before returning to the main screen, select the tags you wish to view.\n\nPlease note that all imported locations have been given a tag showing you the date they were imported.  This alows you to easily locate your imported locations.  After you are done organizing your new locations, you may wish to delete the tag." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    [self performSegueWithIdentifier:@"toSelectTagViewController" sender:filterByTagButton];
    
}


#pragma mark App Activated / Add Observer 

// upon notification that app reactivated runs viewDidAppear
- (void)appActivated:(NSNotification *)note
{

    // this will be called both when app is started and when activated
    // don't want it to run viewDidAppear on start

    if(screenAndPositionLayoutCompleted){
        
        [self viewDidAppear:YES];
    }
    
    return;
    
}

- (void)appDeActivated:(NSNotification *)note
{
    
    [musicAndPlayer stop];  
    
        // note: fadeMusic (change vol) won't work and loose ability to control it when app reactivated (maybe loses pointer, not sure, but don't have time to play with)
    
}

// add observer
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // add Observer - want to be able to respond to application events, eg, incoming data
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appActivated: )
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil]; 
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( appDeActivated: )
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil]; 
}

// remove observer
- (void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    
}


#pragma mark Setup Screen Positions And Fonts

-(void)setScreenPositionsAndFonts { 

    [self moveMajorScreenElementsToStartingPositions];
    [self changeFontSize];

    [self spaceMenuItems: menu_moveToRegion];
    [self spaceMenuItems: menu_mainMenu];
    [self spaceMenuItems: menu_tableIsFullScreen];
    
        
    [self makeScreenObjectsVisable];  // it is easier to conceputalize and design using the storyboard, but it is necessary to calcuate positioning manually, so all screen objects are hidden (set in storyboard), and after position adjusted, they will be unhidden 

}


-(void)moveMajorScreenElementsToStartingPositions
{
    
    float screenWidth = self.view.frame.size.width;
    float screenHeight = self.view.frame.size.height;
    
    float regionsMenuBarHt = menu_moveToRegion.frame.size.height;
    float mainMenuBarHt = menu_mainMenu.frame.size.height;
    float fullScreenMenuBarHt = menu_tableIsFullScreen.frame.size.height;
    float labelForTagsHt = labelShowingTagsSelected.frame.size.height;

    // resize if iPad
    regionsMenuBarHt = regionsMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    mainMenuBarHt = mainMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    
    fullScreenMenuBarHt = fullScreenMenuBarHt * scaleFactorToConvertSizesFromIPhoneToIPad;
    labelForTagsHt = labelForTagsHt * scaleFactorToConvertSizesFromIPhoneToIPad;
        

    // move screen objects
    menu_moveToRegion.frame = CGRectMake(0, 0, screenWidth, regionsMenuBarHt);
    [mcMap resize: CGRectMake(0, regionsMenuBarHt, screenWidth, screenHeight * .60)];
    menu_mainMenu.frame = CGRectMake(0, regionsMenuBarHt + mcMap.frame.size.height, screenWidth, mainMenuBarHt);
    [mcTable resizeTable: CGRectMake(0, regionsMenuBarHt + mcMap.frame.size.height + mainMenuBarHt, screenWidth, screenHeight  - regionsMenuBarHt - mcMap.frame.size.height - mainMenuBarHt)];
    
    menu_tableIsFullScreen.frame = CGRectMake(0, 0, screenWidth, fullScreenMenuBarHt);
    labelShowingTagsSelected.frame = CGRectMake(15, regionsMenuBarHt + mcMap.frame.size.height - labelShowingTagsSelected.frame.size.height - 10, screenWidth - 30, labelForTagsHt);
    
    // tour positions/frame defined in displayTourHeaderInfo

}

-(void)changeFontSize
{
    NSMutableArray *listOfAllNormalTextItems = [NSMutableArray new];
    NSMutableArray *listOfBigTextItems = [NSMutableArray new];
    
    // add items to array
    [listOfAllNormalTextItems addObjectsFromArray: menu_moveToRegion.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: labelShowingTagsSelected.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: menu_mainMenu.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: menu_tableIsFullScreen.subviews];
    [listOfAllNormalTextItems addObjectsFromArray: tour_LocationLabel.subviews];

    [listOfBigTextItems addObject:backButtonForFullScreenMenu];
    
    
    [self changeFontForButtonsAndLabels:listOfAllNormalTextItems font:fontNormal scaleFactorFromIPhoneToIPad:scaleFactorToConvertSizesFromIPhoneToIPad];

    [self changeFontForButtonsAndLabels:listOfBigTextItems font:fontBig scaleFactorFromIPhoneToIPad:scaleFactorToConvertSizesFromIPhoneToIPad];
    
}

-(void)spaceMenuItems:(UIView *)view
{

    [self spaceObjectsEvenlyAlongXAxis:[view subviews].mutableCopy]; 
    
}

-(void)makeScreenObjectsVisable
{
    [UIView animateWithDuration:.1 animations:^{

        menu_moveToRegion.hidden = FALSE;
        mcMap.hidden = FALSE;
        menu_mainMenu.hidden = FALSE;
        mcTable.hidden = FALSE;
        
        labelShowingTagsSelected.hidden = FALSE;         
        
    }];
    
}

-(void)makeScreenObjectsInvisable
{

    [UIView animateWithDuration:.1 animations:^{
        
        menu_moveToRegion.hidden = TRUE;
        mcMap.hidden = TRUE;
        menu_mainMenu.hidden = TRUE;
        mcTable.hidden = TRUE;
        
        labelShowingTagsSelected.hidden = TRUE;        
        
    }];

}


#pragma mark Buttons - View Region

- (IBAction)europeButtonPressed:(id)sender {
    
    [mcMap moveCenterOfMap_Latitude:52.5 Longitude:13.4 MKCoordSpanWidth:30 MKCoorSpanHeight:30 animated:YES];
}

- (IBAction)asiaButtonPressed:(id)sender {
    
    [mcMap moveCenterOfMap_Latitude:32 Longitude:105 MKCoordSpanWidth:65 MKCoorSpanHeight:65 animated:YES];
}

- (IBAction)northAmericaButtonPressed:(id)sender {
    
    [mcMap moveCenterOfMap_Latitude:39 Longitude:-95 MKCoordSpanWidth:50 MKCoorSpanHeight:50 animated:YES];
}

- (IBAction)southAmericaButtonPressed:(id)sender {
    
    [mcMap moveCenterOfMap_Latitude:-15 Longitude:-56 MKCoordSpanWidth:60 MKCoorSpanHeight:60 animated:YES];
}

- (IBAction)africaButtonPressed:(id)sender {
    
    [mcMap moveCenterOfMap_Latitude:2 Longitude:21 MKCoordSpanWidth:75 MKCoorSpanHeight:75 animated:YES];
}


#pragma mark Buttons - MapView
// for "Tour" button, see Tour Region
// "Filters"  button opens View Controller (see storyboard)

- (IBAction)viewFullListButtonPressed:(id)sender {
    
    // show back button
    backButtonForFullScreenMenu.hidden = FALSE;
    
    // change height of table
    [mcTable resizeTable: CGRectMake(mcTable.frame.origin.x, mcTable.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - menu_tableIsFullScreen.frame.size.height)];
    
    // move up
    [UIView animateWithDuration:.7 animations:^{
        
        menu_tableIsFullScreen.hidden = FALSE;
        [mcTable resizeTable:CGRectMake(0, menu_tableIsFullScreen.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - menu_tableIsFullScreen.frame.size.height)];
    }];
    
}

- (IBAction)swipeLeft:(id)sender {
    
    if(fullScreenViewToBlockInputs.hidden == FALSE){
        
        return;
    }
    
    if(menu_tableIsFullScreen.hidden){
        
        [self viewFullListButtonPressed:nil];
        
    }else{
        
        [self viewSelectionButtonPressed:nil];
        
    }
    
}

- (IBAction)pinOptionButtonPressed:(id)sender {
    
   // temporarily removed until issue fixed
    
   // actionSheetPinOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"MAP SELECTIONS:", @"Show name & photo.", @"Show red pin.",  @" ", @"SHARE LOCATIONS:", @"For Selected Tags", @"Selected Locations", @" ", @"About", nil];

   // removed MAP SELECTIONS: so always show red pin
   // to put functionality back in play, just un-comment-out above text
   // see known issues (top)
    
    actionSheetPinOptions = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"SHARE LOCATIONS:", @"For Selected Tags", @"Selected Locations", @" ", @"About", nil];
    
    [actionSheetPinOptions showInView:self.view];

}

-(void)pinOptionsActionSheetResponseTree:(NSString *)buttonPressed
{

    if([buttonPressed isEqualToString:@"Show name & photo."]){
        
            showImageNotPin = TRUE;
            mcMap.pinDisplayOptions = pinDetailOptions_showImage;
            [mcMap refreshMap];
    
    }else if ([buttonPressed isEqualToString:@"Show red pin."]){

            showImageNotPin = FALSE;
            mcMap.pinDisplayOptions = pinDetailOptions_showPinOnly;
            [mcMap refreshMap];
        
    }else if ([buttonPressed isEqualToString:@"For Selected Tags"]){
            
            [self shareTags];
        
    }else if ([buttonPressed isEqualToString:@"Selected Locations"]){
        
            [self shareLocs];
        
    }else if ([buttonPressed isEqualToString:@"About"]){
        
            [self about];
    
    }
    
}

-(void)about
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"About:" message:@"Created By: M.S. Cline\nMusic: Duelin' Daltons performed by Steve Dudash & Stephen Cline, 1980." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alert show];
}

-(void)shareTags
{
        
    //make list of selected tags 
    NSMutableArray *tagsToShare = [NSMutableArray new];
    
    for(MCTag *tag in listOfTags){
        if(tag.selected){ [tagsToShare addObject:tag];}
    }
    
    // if no tags selected, then give all tags
    if([tagsToShare count] == 0){ tagsToShare = listOfTags; }
    
    // notify user which tags exporting (they can cancel later)
    // notify user which locations exporting (they can cancel later)
    NSString *str = @"";
    NSString *rtn = @"";
    
    for(MCTag *tag2 in tagsToShare){
        
        str = [NSString stringWithFormat:@"%@%@%@", str, rtn, tag2.tagName ];
        rtn = @"\n";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Exporting Locations For Selected Tags:" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    
    // create archive file and active activity view / share screen
    MCArchiveFileManager *aFM = [[MCArchiveFileManager alloc] initAndCreateArchiveWithTags:(NSArray *)tagsToShare andTheirFilteredLocations:(NSArray *)listOfFilteredLocations];
    [aFM shareFileUsingActivityViewWithFileUrl:aFM.url withPointerToActiveViewController_NeededSoCanPresentActivityVC:self];
    
}

-(void)shareLocs
{

    // make list of all selected pins
    NSMutableArray *selectedPins = [NSMutableArray new];
    
    for(MCLocation *pin in listOfFilteredLocations){
        
        if(pin.selected == TRUE){
            
            [selectedPins addObject:pin]; }
        
    }            

    // if no selected pins, notify user and exit
    if([selectedPins count]==0){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please make selection:" message:@"Before exporting data, please select the locations you would like to share." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    }else{
        
        // notify user which locations exporting (they can cancel later)
        NSString *str = @"";
        NSString *rtn = @"";
        
        for(MCLocation *loc in selectedPins){
            
            str = [NSString stringWithFormat:@"%@%@%@", str, rtn, loc.title ];
            rtn = @"\n";
        }
        
        UIAlertView *alert2 = [[UIAlertView alloc] initWithTitle:@"Exporting Selected Locations:" message:str delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert2 show];
        
        // create archive file and active activity view / share screen
        MCArchiveFileManager *aFM = [[MCArchiveFileManager alloc] initAndCreateArchiveWithPins:(NSArray *)selectedPins];
        [aFM shareFileUsingActivityViewWithFileUrl:aFM.url withPointerToActiveViewController_NeededSoCanPresentActivityVC:self];
    }
    
}


#pragma mark Buttons - FullView

- (IBAction)backButtonPressed:(id)sender {
    
    [mcMap refreshMap];
    
    // change back to default screen view by moving/resizing table (which is hidding other elements)
    [UIView animateWithDuration:.7 animations:^{
        
        menu_tableIsFullScreen.hidden = TRUE;
        backButtonForFullScreenMenu.hidden = TRUE;
        [mcTable resizeTable: CGRectMake(0, menu_mainMenu.frame.size.height + mcMap.frame.size.height + menu_moveToRegion.frame.size.height, mcTable.frame.size.width, mcTable.frame.size.height)];
        
    } completion:^(BOOL finished) {
        
        // change height of the table
        [mcTable resizeTable: CGRectMake(mcTable.frame.origin.x, mcTable.frame.origin.y, mcTable.frame.size.width, self.view.frame.size.height - menu_moveToRegion.frame.size.height - menu_mainMenu.frame.size.height - mcMap.frame.size.height)];
        
    }];

}

- (IBAction)swipeRight:(id)sender {
    
    if(fullScreenViewToBlockInputs.hidden == FALSE){
        
        return;
    }
    
    [self backButtonPressed:nil];
}

- (IBAction)selectAllButtonPressed:(id)sender {
    
    // rem: "is selected" is equivalent to saying show image not pin
    // just need to change the MCLocation
    
    for(MCLocation *z in listOfLocationsOnScreen){
        
        z.selected = TRUE;
        
    }
    
    [mcTable refreshTable];
}

- (IBAction)deselectAllButtonPressed:(id)sender {
    
    for(MCLocation *z in listOfFilteredLocations){
        
        z.selected = FALSE;
        
    }
    
    [mcTable refreshTable];
    
}

- (IBAction)deleteSelectionButtonPressed:(id)sender {

    // get list of selected pins
        
    NSMutableArray *listOfPinsToDelete = [NSMutableArray new];
        
    for(MCLocation *loc in listOfFilteredLocations) {
            
            // if selected, then delete
            if(loc.selected) {
                
                [listOfPinsToDelete addObject:loc];
                
            }
    }
    
    
    // confirm deletion
    
    if([listOfPinsToDelete count] == 0 ){
    
        UIAlertView *alert2 = [[UIAlertView alloc]initWithTitle:@"Please select friends to delete." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert2 show];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete Friends" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert show];
        
    }
    
}

-(void)deletePins
{
    
    // get list of selected pins to delete
    NSMutableArray *listOfPinsToDelete = [NSMutableArray new];
    
    for(MCLocation *loc in listOfFilteredLocations) {
        
        // if selected (ie, showing full image, not pin), then delete
        if(loc.selected) {
            
            [listOfPinsToDelete addObject:loc];
            
        }
    }
    
    // delete items from lists lists of locations to display
    [listOfAllLocations removeObjectsInArray:listOfPinsToDelete]; // master list
    [listOfFilteredLocations removeObjectsInArray:listOfPinsToDelete];  // so don't have to refilter
    
    
    // update map
    [mcMap putPinsOnMap:listOfFilteredLocations];
    
    // update table
    [self updateTableWhenMapRegionChanges];
    
    // save list of pins (now without delete objects)
    [self savePins];
    
    // delete image
    for(MCLocation *loc in listOfPinsToDelete){
    
        if(![loc.imageLocation isEqualToString:@""]){
            
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            documentDirectory = [documentDirectory URLByAppendingPathComponent:loc.imageLocation];
            
            [fileManger removeItemAtURL:documentDirectory error:nil];  // Apple recommends not checking for file existence first - in order to predicate behavior, but to deal with errors later
            
        }    
    }
    
}


#pragma mark AlertViews / Action Sheets
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if([alertView.title isEqualToString:@"Delete Friends"]){
    
        switch (buttonIndex) {
            case 0:
                break;
            case 1:
                [self deletePins];
                break;            
        }
        
   } else { NSLog(@"passing thru alertView - no response required"); }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    // if edit, nice to refactor with if(buttonTitle == ) throughout
    // - not as efficient, but would increase readibility 
    // - although code remains brittle: with indexes, if add or delete or reorder, code doesn't work
    //   with titles, if change, code doesn't work
    
    
    if(actionSheet == actionSheetTour){
        
        
        // make list of trips so can look up which index selected 
        
        NSMutableArray *selectedTrips = [NSMutableArray new];
        
        for(MCTag *trip in listOfTags){
            
            if(trip.selected && trip.displayTripLines){
                
                [selectedTrips addObject:trip];
            }
        }
        
        
        if(buttonIndex == 0){ 
            
            [self tourRegionSetup]; 
            
        } else if(buttonIndex == 1){    
            
            [self tourWorldSetup];          
            
        } else if (buttonIndex == [selectedTrips count] + 2){     
            
            // total number of buttons: hard coded buttons (2) + cancel button (1) + a button for each trip
            // the cancel button is the last one
            // for index number, subtract one
            
            return;
            
        } else {                                
            
            int indexOfTripInSelectedTags = (int)buttonIndex - 2;
            MCTag *tripToView = selectedTrips[indexOfTripInSelectedTags]; 
            [self tourTripSetup: tripToView];
        }
        
        
    // For Second Action Sheet    
    }else if(actionSheet == actionSheetPinOptions){

        [self pinOptionsActionSheetResponseTree:buttonTitle];
        
    }
    
}


#pragma mark Segue & Save

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    [self makeScreenObjectsInvisable];
    
    if(sender == filterByTagButton){
        
        MCSelectTagViewController *tagViewController = segue.destinationViewController;
        tagViewController.delegate = self;
        tagViewController.listOfTags = listOfTags;
        return;
        
    } 
  
    else if(sender == addFriendsButton) {
       
        // create true/deep copy of listOfTags to work with 
        NSMutableArray *copyOfListOfTags = [NSMutableArray new];
        for(MCTag *z in listOfTags){
            [copyOfListOfTags addObject:[[MCTag alloc]initWithTitle:z.tagName isSelected:FALSE]];}
        
        // set delegate, etc.
        MCAddPinViewController *addPinViewController = segue.destinationViewController;
        addPinViewController.pointerToMainViewController = self;
        addPinViewController.listOfTags = copyOfListOfTags;
        return;
        
    }
    
    else if([sender isEqualToString:@"viewSelection"]) {
        
        MCDetailViewController *dvc = segue.destinationViewController;
        dvc.listOfPinsToDisplay = (NSArray *)selectedPinsForSegue;
        dvc.listOfTags = (NSArray *)listOfTags;
        dvc.pointerToMainViewController = self;
        return;
        
    } 
    
}

- (IBAction)viewSelectionButtonPressed:(id)sender {
    
    // make list of all selected pins
    [selectedPinsForSegue removeAllObjects];
    
    for(MCLocation *pin in listOfLocationsOnScreen){

            if(pin.selected == TRUE){
                
                [selectedPinsForSegue addObject:pin]; }
        
    }

    
    // if no selected pins, notify user and exit
    if([selectedPinsForSegue count]==0){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Please make selection." message:@"Before going to the detail page, it is necessary to select which friends you are interested in viewing." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
    }else{
    
        [self performSegueWithIdentifier:@"toDetailViewController" sender:@"viewSelection"];
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

-(void)addNewPinToListOfLocationsAndSave:(MCLocation *)newPin originalPin:(MCLocation *)oldPin
{
    
    // if editing
    if(oldPin){  

        // if changed photo, need to delete the old
        if(![newPin.imageLocation isEqualToString: oldPin.imageLocation] && ![oldPin.imageLocation isEqualToString:@""]){
        
            NSFileManager *fileManger = [NSFileManager defaultManager];
            NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            documentDirectory = [documentDirectory URLByAppendingPathComponent:oldPin.imageLocation];

            [fileManger removeItemAtURL:documentDirectory error:nil];  // Apple recommends not checking for file existence first - in order to predicate behavior, but to deal with errors later
        
        }
        
        // update old pin with new information
        [oldPin editLocationWithTitle:newPin.title coordinate:newPin.coordinate location:newPin.location country:newPin.country notes:newPin.notes imageLocation:newPin.imageLocation tags:newPin.tags];
        oldPin.selected = TRUE;
           
    }else{
        
        // add newPin to the array of MCLocations
        newPin.selected = TRUE;
        [listOfAllLocations addObject:newPin];

    }

    [self savePins];  
    [mcMap putPinsOnMap:listOfAllLocations];
    [self updateTableWhenMapRegionChanges];  // ????? check
    
}

-(void)savePins  // small number of objects, so will just overwrite for simplicity
{
  
    [self sortLocations:listOfAllLocations];
    
    // convert objects to dictionaries and store in array
    NSMutableArray *plist = [NSMutableArray new];
    
    for(MCLocation *z in listOfAllLocations){
        
        // convert objects into dictionaries and add to plist (an array)
        [plist addObject:[z returnDictionaryOfLocationObject]];
        
    }
    
    // save in plist
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSURL *documentDirectory = [[fileManger URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    //NSLog(@"%@", documentDirectory);
    
    [plist writeToURL:[documentDirectory URLByAppendingPathComponent:@"csfriends.plist"] atomically:YES];

}


#pragma mark Map Overlay

-(void)makeMapPolygonForTags
{
    
    // for each tag, create trip lines (ie a polyline) by getting all locations in trip and calling MCMap method
    
    for(MCTag *tag in listOfTags){
        
        // if has trip line and is selected, make trip polyline
        if(tag.selected && tag.displayTripLines){
            
            // get locations that have this tag
            NSMutableArray *locationsWithTag = [self makeListOfFilteredLocationsForTag:tag];
            
            // see if any of these are marked as final destination
            MCLocation *finalDestination = [self findPointerToFinalDestinationForTrip:tag locationsForTag:locationsWithTag];
            
            // if so, add final destination to list of locations
            if(finalDestination){
             
                [locationsWithTag addObject:finalDestination];
            
            }
            
            tag.linesConnectingTripLocations = [mcMap createOverlayObjectComposedOfLinesBetweenPoints_orderedMCLocations:locationsWithTag];

        }
    }
    
    // add to map
    [self displayTripLinesOverlay];
 
}

-(void)displayTripLinesOverlay
{
 
    // use MCMap to add new overlays
    
    [mcMap removeAllOverlays];
    
    // for each selected tag set to display trip lines, add overlay
    for(MCTag *tag in listOfTags){
        
        if(tag.selected && tag.displayTripLines){
            
            [mcMap addOverlay:tag.linesConnectingTripLocations];
            
        }
        
    }
    
    [mcMap completedEditingOverlaysSoTimeToRefreshMap];
    
}


#pragma mark *** helper methods ***

-(NSMutableArray *)makeListOfFilteredLocationsForTag:(MCTag *)tag
{
    // filter locations so displays only locations with selected tag
    // (ie, the tag is in the attached array of tags)
    
    NSMutableArray *listOfFilteredLocationsForTag = [NSMutableArray new];
    
    for(MCLocation *loc in listOfAllLocations){
        
        // does the loc have the desired tag and what is the pointer to the tag?
        MCTag *foundTag = [self searchForTag:tag inLocationObject:loc];
        
        // notes: tags will be ordered (unless new location added)
        if(foundTag){
            
            loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt = foundTag;
            [listOfFilteredLocationsForTag addObject:loc];
            
        }
        
    }
    
    // sort
    [listOfFilteredLocationsForTag sortUsingComparator:^NSComparisonResult(MCLocation *obj1, MCLocation *obj2) {
        
        if(obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray
           < obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray){
            return -1;
        }else{
            return 1;
        }
        
    }];
    
    return listOfFilteredLocationsForTag;
}

-(MCTag *)searchForTag:(MCTag *)searchFor inLocationObject:(MCLocation *)loc
{
    for(MCTag *tag in loc.tags){
        
        if ([tag.tagName isEqualToString: searchFor.tagName]){
            
            return tag; }
        
    }
    
    return nil;
}


-(MCLocation *)findPointerToFinalDestinationForTrip:(MCTag *)tag locationsForTag:(NSMutableArray *)locationsForTag
{
    
    for(MCLocation *loc in locationsForTag){
        
        if([loc.title isEqualToString: tag.finalDestination]){
            
            return loc;
            
        }
        
    }
    
    return nil;
}


#pragma mark Map Delegate

-(void)mapDidChange_listOfLocationsOnScreen:(NSMutableArray *)locations
{
    
    listOfLocationsOnScreen = locations;
    
    if(screenAndPositionLayoutCompleted) {
    
        [self updateTableWhenMapRegionChanges];
    }

}


#pragma mark TableView 

-(void)updateTableWhenMapRegionChanges
{
    
    [self sortLocations:listOfLocationsOnScreen];
    [mcTable refreshTableWithNewData:listOfLocationsOnScreen];

}

-(void)sortLocations:(NSMutableArray *)arry
{
    // sort by longitude
    
    [arry sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
     
         
         if([(MCLocation *)obj1 coordinate].longitude < [(MCLocation *)obj2 coordinate].longitude){
             
             return -1;
         
         }else{
             
             return 1;
     
         }
         
     }];
     
}

-(void)tableItemSelected:(id)dataObjectSelected   // delegate method
{
    [mcMap refreshMap];
    [mcTable refreshTable];
    
}


#pragma mark Tour Region

- (IBAction)tourChoices:(id)sender {
    
    // create action sheet so you can choose your tour
    actionSheetTour = [[UIActionSheet alloc]initWithTitle:@"Choose Your Tour" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    // add buttons (can't pass an array into an action sheet, so need to add manually)

    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Tour Region"]];
    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Tour World"]];
     
    // one button for each selected tag
    for(MCTag *trip in listOfTags){
    
        if(trip.selected && trip.displayTripLines){
        
            [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"%@ Trip", [trip.tagName substringWithRange:NSMakeRange(1, [trip.tagName length]-2 )]]];
        }
        
    }
    
    [actionSheetTour addButtonWithTitle:[NSString stringWithFormat:@"Cancel"]];
          
    [actionSheetTour showInView:self.view];

}

-(void)tourWorldSetup
{
    
    // if there are no locations
    if([listOfFilteredLocations count] == 0) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"There are currently no locations to tour.  Please adjust your filters." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // create copy of list of all locations to work with
    NSMutableArray *arry = [NSMutableArray arrayWithArray: listOfFilteredLocations ];
    
    [self sortLocations:arry];
    
    [mcMap tourLocations:arry timeDelayBetween: defaultDelay];
    
}

-(void)tourRegionSetup
{
    
    // if there are no locations, run world tour instead
    if([listOfLocationsOnScreen count] == 0) {

        [self tourWorldSetup];
        return;
        
    }
    
    // make copy of list of locations to work with, we will view each item in the list (already in correct order)
    NSMutableArray *arry = [NSMutableArray arrayWithArray:listOfLocationsOnScreen];
    
    // start tour
    [mcMap tourLocations:arry timeDelayBetween:defaultDelay];
 
}


-(void)tourTripSetup:(MCTag *)trip
{
    
    // for all locations, check to see if it has the desired tag and store in arry
    // (similar to code in overlay section, but with a couple differences)
    
    NSMutableArray *locationsForTrip = [NSMutableArray new];

    for(MCLocation *checkThisLoc in listOfAllLocations){
        
        // if find tag, save pointer to it (just makes it a little easier to work with)
        checkThisLoc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt = [self checkToSeeIfPinMeetsFilterCriteria:checkThisLoc listOfSelectedTags:[NSMutableArray arrayWithObject:trip]];
        
        // if find tag, add location to list of places will tour
        if(checkThisLoc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt){
            
            [locationsForTrip addObject:checkThisLoc];
            
        }
        
    }
    
    // sort
    [self sortByPositionInTrip:locationsForTrip];
    
    
    // add final destination to our list
    for(MCLocation *loc in locationsForTrip){
        
        if([loc.title isEqualToString: trip.finalDestination]){
            
            [locationsForTrip insertObject:loc atIndex:0];
            break;
        }
        
    }
    
    //debug
    //for(MCLocation *loc in locationsForTrip){NSLog(@"%i %@", loc.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray, loc.title);}  // note: the position number is used to sort, then the final position is added to the stack, but it is just a pointer to the its first occurence
    
    // start tour
    [mcMap tourLocations:locationsForTrip timeDelayBetween:3];
    
}

-(void)sortByPositionInTrip:(NSMutableArray *)locationsForTrip
{

    // sort by position
    [locationsForTrip sortUsingComparator:^NSComparisonResult(MCLocation *obj1, MCLocation *obj2) {
        
        int a = obj1.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray;
        int b = obj2.tempPointerToInternalTagWorkingOnSoNotHaveToSearchForIt.positionInTripAndArray;
        
        if(a <= b){
            
            return 1;
            
        }else{
            
            return -1;
            
        }
        
    }];
}


-(void)tourFinished  // MCMapDelegate Method
{
    
    mcTable.hidden = FALSE;
    [self performSelector:@selector(unfadeMenus) withObject:nil afterDelay:.6];

}

-(void)fadeMenus
{

    menu_mainMenu.alpha = .5;
    menu_moveToRegion.alpha = .5;
}

-(void)unfadeMenus
{

    menu_mainMenu.alpha = 1;
    menu_moveToRegion.alpha = 1;

}

/*
 
 -(void)displayTourHeaderInfo:(MCLocation *)loc
 {
 
 // update display/annotation field and display
 tour_NameAndImage.locationToDisplay = loc;
 [tour_NameAndImage setViewComponentsValues];
 
 tour_NameAndImage.frame = CGRectMake(
 self.view.frame.size.width/2 - tour_NameAndImage.frame.size.width/2,
 menu_moveToRegion.frame.size.height + mcMap.frame.size.height + menu_mainMenu.frame.size.height + self.view.frame.size.height * .045,
 (self.view.frame.size.width - 20) * scaleFactorToConvertSizesFromIPhoneToIPad,
 tour_NameAndImage.frame.size.height * scaleFactorToConvertSizesFromIPhoneToIPad   );
 
 // update text field
 tour_LocationLabel.text = loc.location;
 tour_LocationLabel.frame = CGRectMake(0,
 tour_NameAndImage.frame.origin.y + self.view.frame.size.height * .08,
 self.view.frame.size.width,
 30);
 
 }
 */


#pragma mark Global Access

-(UIFont *)returnFontSmall { return fontSmall; }
-(UIFont *)returnFontBig { return fontBig; }
-(UIFont *)returnFontNormal { return fontNormal; }
-(float)returnScaleFactor { return scaleFactorToConvertSizesFromIPhoneToIPad; }
-(NSMutableArray *)returnListOfAllLocations {return listOfAllLocations;}
-(NSMutableArray *)returnListOfFilteredLocations {return listOfFilteredLocations;}
-(NSMutableArray *)returnListOfTags {return listOfTags;}

@end



