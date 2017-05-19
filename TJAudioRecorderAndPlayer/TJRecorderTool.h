//
//  TJRecorderTool.h
//  TJAudioRecorderAndPlayer
//
//  Created by TanJian on 17/5/19.
//  Copyright © 2017年 Joshpell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


@class TJRecorderTool ;

typedef TJRecorderTool *(^configerOrAction)();
typedef TJRecorderTool*(^configureURL)(NSURL *url);
typedef void (^configerTimeFeedback)(CGFloat totalTime,CGFloat currentTime);
typedef void (^configerVolume)(CGFloat colume);
typedef NSData *(^configerRecorderData)();


@interface TJRecorderTool : NSObject

/*
 *  录音工具单例
 */
+ (instancetype)sharedInstance;
/*
 *  录音前需要做的配置(必须调用)
 */
@property (nonatomic, copy, readonly) configerOrAction configureRecorder;
/*
 *  开始录音
 */
@property (nonatomic, copy, readonly) configerOrAction startRecord;
/*
 *  结束录音
 */
@property (nonatomic, copy, readonly) configerOrAction stopRecorder;
/*
 *  暂停录音
 */
@property (nonatomic, copy, readonly) configerOrAction pauseRecord;
/*
 *  播放本地录音
 */
@property (nonatomic, copy, readonly) configerOrAction playRecorderLocal;
/*
 *  播放网络音频前需要做的配置
 */
@property (nonatomic, copy, readonly) configerOrAction configureNetwork;
/*
 *  播放网络音频录音
 */
@property (nonatomic, copy, readonly) configureURL playNetworkaAudio;
/*
 *  播放时间回调Block
 */
@property (nonatomic, copy) configerTimeFeedback timeObserverBlock;
/*
 *  音量监听回调Block
 */
@property (nonatomic, copy) configerVolume volumeObserverBlock;
/*
 *  获取最后一次录音的数据
 */
@property (nonatomic, copy) configerRecorderData getRecorderDataBlock;

@end
