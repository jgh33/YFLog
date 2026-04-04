//
//  LogBridge.h
//  yun
//
//  Created by jiaoguohui on 11/22/25.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LogLevel) {
    LogLevelVerbose = 0,
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelError,
    LogLevelFatal,
    LogLevelNone
};

NS_ASSUME_NONNULL_BEGIN

@interface LogBridge : NSObject
+ (void)openWithLogDir:(NSString *)logDir
             cacheDays:(NSInteger)cacheDays
           consoleOpen:(BOOL)consoleOpen
                 level:(LogLevel)level;

+ (void)logWithLevel:(LogLevel)level
                 tag:(nullable NSString *)tag
             message:(NSString *)message
                file:(NSString *)file
            function:(NSString *)function
                line:(int)line;

+ (void)flush;
+ (void)close;
@end

NS_ASSUME_NONNULL_END
