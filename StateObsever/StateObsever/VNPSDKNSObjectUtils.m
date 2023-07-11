//
//  TestObjC.m
//  StateObsever
//
//  Created by thebv on 30/01/2023.
//

#import "VNPSDKNSObjectUtils.h"

@implementation VNPSDKNSObjectUtils

+ (NSObject * _Nullable)valueForKeyFromObj:(NSObject * _Nullable)obj key:(NSString *)key {
    @try {
        return [obj valueForKey:key];
    } @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    } @finally {
        
    }
    return nil;
}

+ (NSObject * _Nullable)valueForKeyPathFromObj:(NSObject * _Nullable)obj keyPath:(NSString *)keyPath {
    @try {
        return [obj valueForKeyPath:keyPath];
    } @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    } @finally {
        
    }
    return nil;
}

+ (BOOL)observerFromSelf:(id)mSelf obj:(NSObject * _Nullable)obj key:(NSString *)key {
    @try {
        [obj addObserver:mSelf forKeyPath:key options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld context:nil];
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"exception: %@", exception);
    } @finally {
        
    }
    
    return NO;
}

@end
