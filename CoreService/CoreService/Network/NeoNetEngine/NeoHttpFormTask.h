//
//  NeoHttpFormTask.h
//  TestLibuv
//
//  Created by Ryou Zhang on 6/14/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#import "NeoHttpTask.h"

@interface NeoHttpFormTask : NeoHttpTask {
@private

    struct curl_httppost *_formData;

}
@end
