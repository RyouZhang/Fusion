//
//  CommonErrorCode.h
//  FusionApp
//
//  Created by Ryou Zhang on 1/10/15.
//  Copyright (c) 2015 Ryou Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

//通用错误代码
#define ERROR_UNKNOWN                   0
#define ERROR_MTOP_ERROR                1
#define ERROR_KUADI_ERROR               2
#define ERROR_INVALID_PHONE_ERROR       3
#define ERROR_RESERVE_ORDER_EXIST       10

//错误域
#define ERROR_DOMAIN_NETWORK            1
#define ERROR_DOMAIN_USER               2
#define ERROR_DOMAIN_FILE_SYSTEM        3
#define ERROR_DOMAIN_DATABASE           4
#define ERROR_DOMAIN_LOCATION           5
#define ERROR_DOMAIN_BUSINESS           6
#define ERROR_DOMAIN_ACCOUNT            7

//network错误代码
#define ERROR_INVALID_URL                   1
#define ERROR_INVALID_DOWNLOAD_LOCAL_PATH   2

//user
#define ERROR_INVALID_PARAMS            1

//location错误代码
#define ERROR_NOT_SUPPORT_CITY          100
#define ERROR_SERVICE_NOT_ENABLE        101


//account错误代码
#define ERROR_USER_SESSION_INVALID      1
#define ERROR_USER_CHANGED              2

//错误信息
#define ERROR_MSG_PARAMS_ERROR      @"params error"
#define ERROR_MSG_NET_ERROR         @"net error"
#define ERROR_MSG_PARSER_ERROR      @"parser error"
#define ERROR_MSG_FILE_SYSTEM_ERROR @"file system error"
#define ERROR_MSG_DATABASE_ERROR    @"db error"
#define ERROR_MSG_SERVER_ERROR      @"server error"