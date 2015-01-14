//
//  DNSSocketContext.h
//  CoreService
//
//  Created by Ryou Zhang on 12/7/14.
//  Copyright (c) 2014 trip.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNSSocketContext : NSObject {
@public
    CFSocketRef         socketRef;
    CFRunLoopSourceRef  sourceRef;
    int                 socket;
}
@end
