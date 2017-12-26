//
//  CloudwalkAudioPlayer.h
//  CloudwalkAudioPlayer
//
//  Created by DengWuPing on 15/6/19.
//  Copyright (c) 2015年 dengwuping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CWAudioPlayerDelegate <NSObject>
//语音播放完成的代理方法
-(void)audioPlayFinished;

@end

@interface CWAudioPlayer : NSObject<AVAudioPlayerDelegate>

@property(nonatomic,retain)AVAudioPlayer * plaer;

@property(nonatomic,weak)id<CWAudioPlayerDelegate> delegate;

+(instancetype)sharedInstance;

//开始播放语音
-(void)startPlayAudio:(NSString * )filePath AndDelegae:(id<CWAudioPlayerDelegate>)delegae;
//设置声音大小
-(void)setVolume:(float)vloume;
//关闭语音播放
-(void)stopPlay;

@end

