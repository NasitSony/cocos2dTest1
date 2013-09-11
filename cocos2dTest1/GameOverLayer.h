//
//  GameOverLayer.h
//  cocos2dTest1
//
//  Created by Nasit Sarwar Sony on 8/1/13.
//  Copyright 2013 IMpulse BD Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor{
    
}

+(CCScene *) sceneWithWon:(BOOL)won;
- (id)initWithWon:(BOOL)won;

@end
