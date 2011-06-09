//
//  HudLayer.h
//  KnightFight
//
//  Created by Loz Archer on 13/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface HudLayer : CCLayer {
	CCLabelTTF *livesLabel;
	CCLabelTTF *levelLabel;
	CCLabelTTF *gameOverLabel;
	CCSprite *speedUpSprite, *tripleShotsSprite;
}

@property (nonatomic, retain) CCLabelTTF *livesLabel;
@property (nonatomic, retain) CCLabelTTF *levelLabel;
@property (nonatomic, retain) CCLabelTTF *gameOverLabel;
@property (nonatomic, retain) CCSprite *speedUpSprite, *tripleShotsSprite;

-(void)updateLives:(int)lives;
-(void)updateLevel:(int)level;
-(void)showSpeedUpSprite:(BOOL)show;
-(void)showTripleShotsSprite:(BOOL)show;
-(void)gameOver;

@end
