//
//  MCInvocationQueue.h
//  MCInvocationQueue
//
//  Created by xcode on 3/4/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

// Store invocations in a queue to run at your discretion.

// The MCInvocationQueue is designed to only handle objects, if you want to run a method that takes an int, you have three options.  You can wrap your method in another method (ugly, but effective).  You can edit the receiver to take an integer object, if it is yours.  Or you can create your own custom invocation - there were too many permuations to include them all here.  (See directions below.)

// The Invocation: The concept of messages is central to the objective-c philosophy. Any time you call a method, or access a variable of some object, you are sending it a message. NSInvocation comes in handy when you want to send a message to an object at a different point in time, or send the same message several times. NSInvocation allows you to describe the message you are going to send, and then invoke it (actually send it to the target object) later on.

@interface MCInvocationQueue : NSObject


  @property BOOL isQueueNotStack;


  -(void)runQueueUntilHitPauseOrStop_controller:(id)controller;

  -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller parA:(id)parameterA;
  -(void)addStopToQueue;
  -(void)addPauseToQueue:(float)duration;  // will resume runQueueUntilHitPauseOrStop after x seconds

  -(void)deleteAllInvocationsInQueue;


        //xxxxxxxxxxx
        // Misc: use to work with commands manually (use eg, if want to get a copy of an invocation)
        -(id)returnNextCommand;
        -(void)removeNextCommand;
        -(void)addCustomInvocation:(NSInvocation *)invocation;

        // Related Methods/Variants
        -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller;
        -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller parA:(id)parameterA parB:(id)parameterB;
        -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC;
        -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC parD:(id)parameterD;
        -(void)addSelectorToQueue:(SEL)selector fromController:(id)controller parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC parD:(id)parameterD parE:(id)parameterE;


@end

/* ADDING A CUSTOM INVOCATION:
 
    // NSMethodSignature specifies the number of parameters a method has, the type of each of these parameters, and a method's return type.  To get the signature, just run methodSignatureForSelector on an existing selector with the same format or create a method with the desired format, to work with.  (You could also build it yourself, in C code, but it is not well documented.  Not recommended.)
 
        eg -(void)templateForMethodSignatureWithOneParameter:(NSString *)a { }
 
 
 NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:parB:parC:parD:)];  // NSMethodSignature specifies parameters and return type,
 NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
 [invocation retainArguments];
 
 [invocation setTarget:viewController];
 [invocation setSelector:selector];
 [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
 [invocation setArgument:&parameterB atIndex:3];
 [invocation setArgument:&parameterB atIndex:4];
 [invocation setArgument:&parameterB atIndex:5];
 
 // then run addCustomInvocation: to add it to the queue
 

 */
