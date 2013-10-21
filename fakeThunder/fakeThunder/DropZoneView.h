//
//  DropZoonView.h
//  fakeThunder
//
//  Created by Martian Z on 13-10-21.
//  Copyright (c) 2013年 MartianZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DropZoneDelegate <NSObject>

@optional
- (void)didRecivedTorrentFile: (NSString*)filePath;

@end

@interface DropZoneView : NSView {
    BOOL isHighLight;
    BOOL isWrongFile;
    BOOL isNotSigle;
}

@property (nonatomic, assign) id <DropZoneDelegate> delegate;


@end
