//
//  TestObjC.h
//  StateObsever
//
//  Created by thebv on 30/01/2023.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VNPSDKNSObjectUtils : NSObject

+ (NSObject * _Nullable)valueForKeyFromObj:(NSObject * _Nullable)obj key:(NSString *)key;
+ (NSObject * _Nullable)valueForKeyPathFromObj:(NSObject * _Nullable)obj keyPath:(NSString *)keyPath;
+ (BOOL)observerFromSelf:(id)mSelf obj:(NSObject * _Nullable)obj key:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
