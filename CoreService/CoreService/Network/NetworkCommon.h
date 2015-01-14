//
//  NetworkCommon.h
//  Network
//
//  Created by Ryou Zhang on 8/8/14.
//  Copyright (c) 2014 Ryou Zhang. All rights reserved.
//

#ifndef Network_NetworkCommon_h
#define Network_NetworkCommon_h


#define HTTP_GET_METHOD     @"GET"
#define HTTP_POST_METHOD    @"POST"

#define HTTP_RESPONSE_CODE      @"response_code"
#define HTTP_RESPONSE_DATA      @"response_data"
#define HTTP_RESPONSE_HEADER    @"response_header"
#define HTTP_EFFECTIVE_URL      @"effective_url"

#define NET_REMOTE_URL       @"remote_url"
#define NET_DNS_RESOLVE      @"dns_resolve"
#define NET_LOCAL_PATH       @"local_path"
#define NET_HTTP_HEADER      @"http_header"
#define NET_HTTP_PARAMS      @"http_params"
#define NET_HTTP_METHOD      @"http_method"
#define NET_FORCE_DOWNLOAD   @"force_download"   //bool
#define NET_TEMP_PATH        @"temp_path"
#define HTTP_DISABLE_FOLLOW     @"http_disabel_follow"  //bool


#define ERROR_DOMAIN_NETWORK    1
//network错误代码
#define ERROR_INVALID_URL                   1
#define ERROR_INVALID_DOWNLOAD_LOCAL_PATH   2

#endif
