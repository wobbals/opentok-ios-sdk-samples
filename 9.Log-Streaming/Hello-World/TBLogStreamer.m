//
//  TBLogStreamer.m
//  Hello-World
//
//  Created by Charley Robinson on 3/27/15.
//  Copyright (c) 2015 TokBox, Inc. All rights reserved.
//

#import "TBLogStreamer.h"
#include <zlib.h>

#import <SocketRocket/SRWebSocket.h>

@interface TBLogStreamer() <SRWebSocketDelegate>

@end

@implementation TBLogStreamer {
    z_stream compressor;
    NSMutableArray* messageQueue;
    uint64_t bytesCompressedIn;
    uint64_t bytesCompressedOut;
    NSData* compressorBytesIn;
    unsigned char* compressorOutput;
    SRWebSocket* _webSocket;
}

#define COMPRESSOR_OUTPUT_BUFSIZE 4096

static TBLogStreamer* instance;

+ (void)initialize {
    
}

+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TBLogStreamer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        compressor.zalloc = Z_NULL;
        compressor.zfree = Z_NULL;
        compressor.opaque = Z_NULL;
        bzero(&compressor, sizeof(z_stream));
        int status = deflateInit(&compressor, Z_DEFAULT_COMPRESSION);
        if (Z_OK != status) {
            NSLog(@"defalateInit returned %d: %s", status, compressor.msg);
        }
        messageQueue = [[NSMutableArray alloc] init];
        compressorOutput = malloc(COMPRESSOR_OUTPUT_BUFSIZE + 1);
        compressor.next_out = compressorOutput;
        compressor.avail_out = COMPRESSOR_OUTPUT_BUFSIZE;
        bytesCompressedOut += COMPRESSOR_OUTPUT_BUFSIZE;
        
        _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://192.168.1.13:8080/ws"]];
        [_webSocket setDelegate:self];
        [_webSocket open];
    }
    return self;
}

- (void)compressMessage:(NSString*)message {
    if (SR_OPEN != _webSocket.readyState) {
        [messageQueue addObject:message];
        return;
    }
    
    // cycle compressor input & output
    compressor.next_in =
    (unsigned char*)[[NSString stringWithFormat:@"%@\n", message]
                     cStringUsingEncoding:NSUTF8StringEncoding];
    compressor.avail_in =
    (unsigned int)strlen((const char*)compressor.next_in);
    bytesCompressedIn += compressor.avail_in;
    while (0 < compressor.avail_in) {
        [self tryFlushCompressorOut];
        int result = deflate(&compressor, Z_NO_FLUSH);
        if (Z_OK != result) {
            NSLog(@"deflate error %d: %s", result, compressor.msg);
        }
    }
}

- (BOOL)tryFlushCompressorOut {
    if (0 == compressor.avail_out) {
        NSLog(@"compressed bytes out %llu", bytesCompressedOut);
        NSLog(@"compressed bytes in  %llu", bytesCompressedIn);
        NSLog(@"compression ratio %f",
              (double)bytesCompressedOut / (double)bytesCompressedIn);
        NSData* data = [NSData dataWithBytes:compressorOutput
                                      length:COMPRESSOR_OUTPUT_BUFSIZE];
        [_webSocket send:data];
        compressor.avail_out = COMPRESSOR_OUTPUT_BUFSIZE;
        compressor.next_out = compressorOutput;
        bytesCompressedOut += COMPRESSOR_OUTPUT_BUFSIZE;
        return YES;
    }
    return NO;
}

#pragma mark - SRWebSocketDelegate

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"WSMESSAGE: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"WSOPEN");
    while (messageQueue.count > 0) {
        NSString* message = [messageQueue objectAtIndex:0];
        [messageQueue removeObjectAtIndex:0];
        [self compressMessage:message];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"WSERROR");
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean
{
    NSLog(@"WSCLOSE");
}




@end
