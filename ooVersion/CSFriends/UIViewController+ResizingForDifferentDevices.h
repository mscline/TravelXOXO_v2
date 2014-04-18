//
//  UIViewController+ResizingForDifferentDevices.h
//  CSFriends
//
//  Created by xcode on 1/1/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ResizingForDifferentDevices)

  -(void)changeFontForButtonsAndLabels:(NSMutableArray *)listOfAllTextItems font:(UIFont *)newFont scaleFactorFromIPhoneToIPad:(float)scaleFactorToConvertSizesFromIPhoneToIPad;

  -(void)spaceObjectsEvenlyAlongXAxis:(NSMutableArray *)subviews;

@end
