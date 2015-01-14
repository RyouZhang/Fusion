//
//  SafeARC.h
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Availability.h>

#ifndef __IPHONE_5_0
#warning "This project uses features only available in iOS SDK 5.0 and later."
#endif

#ifdef __OBJC__
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif


#if !defined(__clang__) || __clang_major__ < 3
#ifndef __bridge
#define __bridge
#endif
#ifndef __bridge_retain
#define __bridge_retain
#endif

#ifndef __bridge_retained
#define __bridge_retained
#endif

#ifndef __autoreleasing
#define __autoreleasing
#endif

#ifndef __strong
#define __strong
#endif

#ifndef __unsafe_unretained
#define __unsafe_unretained
#endif

#ifndef __weak
#define __weak
#endif
#endif

#if __has_feature(objc_arc)
// ARC is On
#define SafeRelease(obj) if(obj){obj=nil;}
#define SafeRetain(obj) obj
#define SafeAutoRelease(obj) obj
#define SafeSuperDealloc(obj)
#define SafeAutoReleasePoolStart @autoreleasepool {
#define SafeAutoReleasePoolEnd }
#else
// ARC is Off
#define __bridge
#define SafeRelease(obj) if(obj){[obj release]; obj=nil;}
#define SafeRetain(obj) [obj retain]
#define SafeAutoRelease(obj) [obj autorelease]
#define SafeSuperDealloc(obj) [super dealloc]
#define SafeAutoReleasePoolStart NSAutoreleasePool *pool = [NSAutoreleasePool new];
#define SafeAutoReleasePoolEnd [pool release];
#endif