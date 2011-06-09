//
//  Player.h
//  KnightFight
//
//  Created by Loz Archer on 30/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSprite.h"

@interface Player : GameSprite {
	CGPoint lastPosition;
	BOOL speedUpActive;
	BOOL tripleShotsActive;
	float velocityOrdinary, velocitySpeedUp;
}

@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) BOOL speedUpActive, tripleShotsActive;
@property (nonatomic) float velocitySpeedUp, velocityOrdinary;

+(id) player;

@end
