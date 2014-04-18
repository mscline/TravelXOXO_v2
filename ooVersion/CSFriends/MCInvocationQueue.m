//
//  MCInvocationQueue.m
//  MCInvocationQueue
//
//  Created by xcode on 3/4/14.
//  Copyright (c) 2014 xcode. All rights reserved.
//

#import "MCInvocationQueue.h"
#import "MCInvocationStackCommand.h"

@interface MCInvocationQueue ()

  @property NSMutableArray *queue;

@end

// check synch, if run next before finish first

// [NSTimer scheduledTimerWithTimeInterval:1 invocation:invocation repeats:NO];

@implementation MCInvocationQueue
  @synthesize queue, isQueueNotStack;

-(id)init
{
    self = [super init];
    
    if(self){
    
        queue = [NSMutableArray new];
        isQueueNotStack = TRUE;
        
    }
    
    return self;

}


#pragma mark Methods

-(void)runQueueUntilHitPauseOrStop_controller:(id)controller
{
    
    while([queue count] > 0){
    
        // if it is a queue, get first item; if stack, get last
        
        id nextCommand;
        
        if(isQueueNotStack){
        
            nextCommand = [queue objectAtIndex:0];
                          [queue removeObjectAtIndex:0];
            
        }else{
        
            nextCommand = [queue lastObject];
                          [queue removeLastObject];
        }
        
        
        // if the next object is a stop or pause stack command (not an invocation)
        // - if stop: exit routine
        // - if pause: use selector to run runQueueUtilHitPauseOrStop after delay, and exit
        
        if([nextCommand isKindOfClass:[MCInvocationStackCommand class]]){
        
            MCInvocationStackCommand *next = nextCommand;
            
            if(next.stackCommand == stack_stop){                NSLog(@"  xxx Queue Stopped xxx");
                
                return;
                
            }
            
            if(next.stackCommand == stack_pause){               NSLog(@"  xxx Queue Paused xxx");
                
                [self performSelector:@selector(runQueueUntilHitPauseOrStop_controller:) withObject:controller afterDelay:next.pauseDuration];
                return;
            }
        
        }

        // else run invocation
        NSLog(@"  Run: %@", NSStringFromSelector([nextCommand selector]));
        
        [nextCommand invoke];
    
    }


}

-(void)addStopToQueue
{
    MCInvocationStackCommand *addStop = [MCInvocationStackCommand new];
    addStop.stackCommand = stack_stop;
    
    [queue addObject:addStop];
}

-(void)addPauseToQueue:(float)duration
{

    MCInvocationStackCommand *addPause = [MCInvocationStackCommand new];
    addPause.stackCommand = stack_pause;
    addPause.pauseDuration = duration;
    
    [queue addObject:addPause];
}

-(void)addCustomInvocation:(NSInvocation *)invocation
{
    [queue addObject:invocation];
}

-(void)deleteAllInvocationsInQueue
{

    [queue removeAllObjects];
    
}

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController parA:(id)parameterA
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
    
    [queue addObject:invocation];
}


#pragma mark *Related Methods - addSelectorToQueue

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignature)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    
    [queue addObject:invocation];

}

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController parA:(id)parameterA parB:(id)parameterB
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:parB:)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
    [invocation setArgument:&parameterB atIndex:3];
    
    [queue addObject:invocation];

}

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:parB:parC:)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
    [invocation setArgument:&parameterB atIndex:3];
    [invocation setArgument:&parameterC atIndex:4];
    
    [queue addObject:invocation];

}

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC parD:(id)parameterD
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:parB:parC:parD:)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
    [invocation setArgument:&parameterB atIndex:3];
    [invocation setArgument:&parameterB atIndex:4];
    [invocation setArgument:&parameterB atIndex:5];
    
    [queue addObject:invocation];

}

-(void)addSelectorToQueue:(SEL)selector fromController:(id)viewController parA:(id)parameterA parB:(id)parameterB parC:(id)parameterC parD:(id)parameterD parE:(id)parameterE
{
    
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(templateForMethodSignatureWithParA:parB:parC:parD:parE:)];  // NSMethodSignature specifies parameters and return type,
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation retainArguments];
    
    [invocation setTarget:viewController];
    [invocation setSelector:selector];
    [invocation setArgument:&parameterA atIndex:2];  // pass pointer; parameters start at index 2
    [invocation setArgument:&parameterB atIndex:3];
    [invocation setArgument:&parameterB atIndex:4];
    [invocation setArgument:&parameterB atIndex:5];
    [invocation setArgument:&parameterB atIndex:6];
    
    [queue addObject:invocation];

}


#pragma mark *Method Signature Templates

-(void)templateForMethodSignature {}
-(void)templateForMethodSignatureWithParA:(NSString *)a { }
-(void)templateForMethodSignatureWithParA:(NSString *)a parB:(NSString *)b { }
-(void)templateForMethodSignatureWithParA:(NSString *)a parB:(NSString *)b parC:(NSString *)c { }
-(void)templateForMethodSignatureWithParA:(NSString *)a parB:(NSString *)b parC:(NSString *)c parD:(NSString *)d { }
-(void)templateForMethodSignatureWithParA:(NSString *)a parB:(NSString *)b parC:(NSString *)c parD:(NSString *)d parE:(NSString *)e { }


#pragma mark Misc Methods

-(id)returnNextCommand
{
    
    id nextCommand;
    
    if(isQueueNotStack){
        
        nextCommand = [queue objectAtIndex:0];
        
    }else{
        
        nextCommand = [queue lastObject];
        
    }
    
    return nextCommand;
    
}

-(void)removeNextCommand
{
    
    if(isQueueNotStack){
        
        [queue removeObjectAtIndex:0];
        
    }else{
        
        [queue removeLastObject];
    }
    
}

@end
