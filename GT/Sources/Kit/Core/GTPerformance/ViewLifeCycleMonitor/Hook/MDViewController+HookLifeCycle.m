//
//  MDViewController+HookLifeCycle.m
//  MomoChat
//
//  Created by ChenZhen on 2018/12/3.
//  Copyright © 2018 wemomo.com. All rights reserved.
//

#import "MDViewController+HookLifeCycle.h"
#import <objc/runtime.h>
#import "GTViewLifeCycleMonitor.h"
@implementation MDViewController (HookLifeCycle)
+ (void)load {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        [self swizzleMethod];
        
    });
}

+ (void)swizzleMethod {
    [self swizzleMethod:@selector(viewDidLoad)
                   with:@selector(gt_viewDidLoad)
                onClass:[self class]];
    [self swizzleMethod:@selector(viewWillAppear:)
                   with:@selector(gt_viewWillAppear:)
                onClass:[self class]];
    [self swizzleMethod:@selector(viewDidAppear:)
                   with:@selector(gt_viewDidAppear:)
                onClass:[self class]];
    [self swizzleMethod:@selector(viewWillDisappear:)
                   with:@selector(gt_viewWillDisappear:)
                onClass:[self class]];
    [self swizzleMethod:@selector(viewDidDisappear:)
                   with:@selector(gt_viewDidDisappear:)
                onClass:[self class]];
}

+ (void)swizzleMethod:(SEL)originalSelector
                 with:(SEL)swizzledSelector
              onClass:(Class)class {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)gt_viewDidLoad {
    NSDate *beforeDate = [NSDate date];
    NSUInteger beforT = (NSUInteger)([beforeDate timeIntervalSince1970] * 1000);
    [self gt_viewDidLoad];
    NSDate *afterDate = [NSDate date];
    NSUInteger afterT = (NSUInteger)([afterDate timeIntervalSince1970] * 1000);
    
    [self recordViewStateWithState:@"viewDidLoad" beforeDate:beforeDate afterDate:afterDate];
}

- (void)gt_viewWillAppear:(BOOL)animated {
    NSDate *beforeDate = [NSDate date];
    NSUInteger beforT = (NSUInteger)([beforeDate timeIntervalSince1970] * 1000);
    [self gt_viewWillAppear:animated];
    NSDate *afterDate = [NSDate date];
    NSUInteger afterT = (NSUInteger)([afterDate timeIntervalSince1970] * 1000);
    
    [self recordViewStateWithState:@"viewWillAppear" beforeDate:beforeDate afterDate:afterDate];
}

- (void)gt_viewDidAppear:(BOOL)animated {
    NSDate *beforeDate = [NSDate date];
    NSUInteger beforT = (NSUInteger)([beforeDate timeIntervalSince1970] * 1000);
    [self gt_viewDidAppear:animated];
    NSDate *afterDate = [NSDate date];
    NSUInteger afterT = (NSUInteger)([afterDate timeIntervalSince1970] * 1000);
    
    [self recordViewStateWithState:@"viewDidAppear" beforeDate:beforeDate afterDate:afterDate];
}

- (void)gt_viewWillDisappear:(BOOL)animated {
    NSDate *beforeDate = [NSDate date];
    NSUInteger beforT = (NSUInteger)([beforeDate timeIntervalSince1970] * 1000);
    [self gt_viewWillDisappear:animated];
    NSDate *afterDate = [NSDate date];
    NSUInteger afterT = (NSUInteger)([afterDate timeIntervalSince1970] * 1000);
    
    [self recordViewStateWithState:@"viewWillDisappear" beforeDate:beforeDate afterDate:afterDate];
}

- (void)gt_viewDidDisappear:(BOOL)animated {
    NSDate *beforeDate = [NSDate date];
    NSUInteger beforT = (NSUInteger)([beforeDate timeIntervalSince1970] * 1000);
    [self gt_viewDidDisappear:animated];
    NSDate *afterDate = [NSDate date];
    NSUInteger afterT = (NSUInteger)([afterDate timeIntervalSince1970] * 1000);
    
    [self recordViewStateWithState:@"viewDidDisappear" beforeDate:beforeDate afterDate:afterDate];
}

- (void)recordViewStateWithState:(NSString *)state
                      beforeDate:(NSDate *)before
                       afterDate:(NSDate *)after {
    NSString *classN = NSStringFromClass([self class]);
    NSString *hashCode = [@(classN.hash) stringValue];
    [GTViewLifeCycleSharedManager recordBusiness:classN businessHashCode:hashCode viewStateBeginTime:before viewStateEndTime:after viewLifeState:state];
}

@end
