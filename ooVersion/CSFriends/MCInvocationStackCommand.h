//
//  MCInvoationStackCommand.h
//  MCInvocationQueue
//
//  Created by xcode on 3/4/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {unused, stack_pause, stack_stop} commands;

@interface MCInvocationStackCommand : NSObject

  @property float pauseDuration;
  @property commands stackCommand;

@end
