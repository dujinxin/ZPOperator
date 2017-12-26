//
//  AudioPlayer.m
//  CloudWalkFaceForDev
//
//  Created by DengWuPing on 15/6/19.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import "CWAudioPlayer.h"

@implementation CWAudioPlayer

+(instancetype)sharedInstance{
    static CWAudioPlayer * instance ;
    static dispatch_once_t token;
    dispatch_once(&token,^{
        instance = [[CWAudioPlayer alloc]initSingle];
    });
    return instance;
}
//只是把原来在init方法中的代码，全都搬到initSingle
- (id)initSingle{
    self = [super init];
    if(self){
        //在这里可以进行类的初始化工作
    }
    return self;
}

- (id)init{
    return [CWAudioPlayer sharedInstance];
}
//开始播放语音
-(void)startPlayAudio:(NSString *)filePath AndDelegae:(id<CWAudioPlayerDelegate>)delegae{
    NSURL * audioUrl = [NSURL URLWithString:filePath];
    if (_plaer) {
        if ([_plaer play]) {
            [_plaer stop];
        }
        _plaer = nil;
    }
    NSError * error;
    _plaer = [[AVAudioPlayer alloc]initWithContentsOfURL:audioUrl error:&error];
    _plaer.volume = 1.f;
    [_plaer setDelegate:self];
    self.delegate = delegae;
    [_plaer play];
}

-(void)setVolume:(float)vloume{
    _plaer.volume = vloume;
}
//停止播放语音
-(void)stopPlay{
    if (self.plaer) {
        [self.plaer stop];
    }
    self.plaer.delegate = nil;
    if (self.delegate) {
        self.delegate = nil;
    }
}

//播放完成的代理方法
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioPlayFinished)]) {
        [self.delegate audioPlayFinished];
    }
}
#pragma mark // 播放音频文件时中断的操作
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
     [player pause];
}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    [player play];
}

@end
