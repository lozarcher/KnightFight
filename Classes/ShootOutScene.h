//
//  ShootOutScene.h
//  KnightFight
//
//  Created by Loz Archer on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Knight.h"
#import "SimpleAudioEngine.h"

@interface ShootOutScene : CCLayer {
	Knight *knight;
	int playerShots;
	CCLabelTTF *playerShotsLabel;
}

@property (nonatomic, retain) Knight *knight;
@property (nonatomic) int playerShots;
@property (nonatomic, retain) CCLabelTTF *playerShotsLabel;

-(void) shootOutMovement;
-(void)spriteMoveFinished:(id)sender;
-(void) finishedShootOut:(BOOL)playerDead;

@end
