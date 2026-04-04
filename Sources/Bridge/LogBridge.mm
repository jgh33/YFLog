//
//  LogBridge.m
//  yun
//
//  Created by jiaoguohui on 11/22/25.
//

#import "LogBridge.h"

#import <TargetConditionals.h>
#import <sys/time.h>
#include <string>

#if TARGET_OS_SIMULATOR

@implementation LogBridge

+ (void)openWithLogDir:(NSString *)logDir
             cacheDays:(NSInteger)cacheDays
           consoleOpen:(BOOL)consoleOpen
                 level:(LogLevel)level {
    // Simulator stub: no-op for native xlog to avoid linking device-only binaries.
}

+ (void)logWithLevel:(LogLevel)level
                 tag:(NSString *)tag
             message:(NSString *)message
                file:(NSString *)file
            function:(NSString *)function
                line:(int)line {
    NSLog(@"[Log][%ld][%@] %@", (long)level, tag ?: @"", message);
}

+ (void)flush {}

+ (void)close {}

@end

#else

#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger.h>
#import <mars/xlog/xloggerbase.h>

static BOOL g_xlogOpened = NO;
static const char *PUBLIC_KEY = "f7ee42ffbcb5d2d22f94dde297afe0cbc"
                                "68212fd3ff9cef303b698b039ecd65128b"
                                "850a2074c69954073c30cc50cece775c50"
                                "9c2997199afce4d107d4625920c";
@implementation LogBridge

+ (void)openWithLogDir:(NSString *)logDir
             cacheDays:(NSInteger)cacheDays
           consoleOpen:(BOOL)consoleOpen
                 level:(LogLevel)level {
    if (g_xlogOpened) {
        return;
    }

    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [logDir UTF8String];
    config.nameprefix_ = "log";
    config.cache_days_ = (int)cacheDays;
    config.pub_key_ = PUBLIC_KEY;

    mars::xlog::appender_set_max_file_size(3 * 1024 * 1024); // 3MB per file
    mars::xlog::appender_set_max_alive_duration(7 * 24 * 60 * 60); // Alive for 1 week
    
    mars::xlog::appender_set_console_log(consoleOpen);
    mars::xlog::appender_open(config);
    xlogger_SetLevel((TLogLevel)level);

    g_xlogOpened = YES;
}

+ (void)logWithLevel:(LogLevel)level
                 tag:(NSString *)tag
             message:(NSString *)message
                file:(NSString *)file
            function:(NSString *)function
                line:(int)line {
    if (!g_xlogOpened) {
        return;
    }

    XLoggerInfo info = XLOGGER_INFO_INITIALIZER;
    info.level = (TLogLevel)level;
    info.line = line;

    std::string tagHolder = tag ? [tag UTF8String] : "";
    std::string fileHolder = file ? [file UTF8String] : "";
    std::string funcHolder = function ? [function UTF8String] : "";
    std::string messageHolder = message ? [message UTF8String] : "";

    info.tag = tagHolder.c_str();
    info.filename = fileHolder.c_str();
    info.func_name = funcHolder.c_str();

    gettimeofday(&info.timeval, nullptr);
    info.pid = xlogger_pid();
    info.tid = xlogger_tid();
    info.maintid = xlogger_maintid();
    info.traceLog = 0;

    xlogger_Write(&info, messageHolder.c_str());
}

+ (void)flush {
    if (!g_xlogOpened) {
        return;
    }
    mars::xlog::appender_flush_sync();
}

+ (void)close {
    if (!g_xlogOpened) {
        return;
    }
    mars::xlog::appender_close();
    g_xlogOpened = NO;
}

@end

#endif
