//
//  Bullet.m
//  KnightFight
//
//  Created by Loz Archer on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Bullet.h"
#import "KnightFightAppDelegate.h"

@implementation Bullet

-(id) init {
    if ((self = [super init]))
    {
		self.zOrderOffset = 2;
		self.velocity = 360/1;
		self.visible = NO;
    }
    return self;
}

+(id) bullet
{
	return [[[self alloc] initWithFile:@"bullet.png"] autorelease];
}

-(void)shootBullet:(CGPoint)targetPosition player:(Player*)player {
	CGPoint playerPosition = player.position;
	self.visible = YES;
	int realX, realY;
	CGPoint diff = ccpSub(targetPosition, playerPosition);
	NSLog(@"Diff x = %f", diff.x);
	if (diff.x > 0) {
		realX = (UIAppDelegate.tileMap.mapSize.width * UIAppDelegate.tileMap.tileSize.width) + (self.contentSize.width / 2);
	} else {
		realX = -(UIAppDelegate.tileMap.mapSize.width * UIAppDelegate.tileMap.tileSize.width) - (self.contentSize.width / 2);
	}
	float ratio = (float) diff.y / (float) diff.x;
	realY = ((realX - playerPosition.x) * ratio) + playerPosition.y;

	CGPoint realDest = ccp(realX, realY);
	//determine length
	int offRealX = realX - playerPosition.x;
	int offRealY = realY - playerPosition.y;
	float length = sqrtf((offRealX*offRealX) + (offRealY*offRealY));
	float realMoveDuration = length / velocity;	
		
	self.isMoving = YES;
	
	[self stopAllActions];  // don't let old move continue - otherwise the player will stop at old target & start skating!
	
	spriteRunAction = [CCSequence actions:
					   [CCMoveBy actionWithDuration:realMoveDuration position:realDest],
					   [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
					   nil
					   ];
	[self runAction: spriteRunAction];
}


@end
