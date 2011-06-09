//
//  Attacker.m
//  KnightFight
//
//  Created by Loz Archer on 05/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Knight.h"
#import "KnightFightAppDelegate.h"

@implementation Knight

@synthesize lastPosition;

-(id) init {
    if ((self = [super init]))
    {
		self.alive = YES;
		self.zOrderOffset = 0;
		self.velocity = 40/1;
		self.spritesheetBaseFilename = @"knight";
		[self cacheFrames];
    }
    return self;
}

+(id) knight
{
	return [[[self alloc] init] autorelease];
}

-(void)spriteMoveFinished:(id)sender {
	[self stopAllActions];
	NSLog(@"Knight reached target");
	[self moveInRandomDirection];
}

-(void)moveInRandomDirection {
	CGPoint attackerTilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:self.position];
	int randomDirection = arc4random() % 8;
	int randomDistance = arc4random() % 20;
	CGPoint targetTilePos = attackerTilePos;
	NSLog(@"Random direction = %d", randomDirection);
	switch (randomDirection) {
		case 0:
			targetTilePos.x -= randomDistance;
			break;
		case 1:
			targetTilePos.y -= randomDistance;
			break;
		case 2:
			targetTilePos.x += randomDistance;
			break;
		case 3:
			targetTilePos.y += randomDistance;
			break;
		case 4:
			targetTilePos.x -= randomDistance;
			targetTilePos.y += randomDistance;
			break;
		case 5:
			targetTilePos.x -= randomDistance;
			targetTilePos.y -= randomDistance;
			break;
		case 6:
			targetTilePos.x += randomDistance;
			targetTilePos.y -= randomDistance;
			break;
		case 7:
			targetTilePos.x += randomDistance;
			targetTilePos.y += randomDistance;
			break;
	}
	NSLog(@"Trying to move knight to %f %f, which is %d squares away",targetTilePos.x, targetTilePos.y, randomDistance);

	if (![UIAppDelegate.coordinateFunctions isTilePosIsWithinBounds:targetTilePos]) {
		NSLog(@"Off the map, trying again...");
		[self moveInRandomDirection];
	} else {
		CGPoint targetLocation = [UIAppDelegate.coordinateFunctions pointRelativeToCentreFromLocation:
									[UIAppDelegate.coordinateFunctions locationFromTilePos:targetTilePos]
								  ];
		if ([self checkIfPointIsInSight:targetLocation enemySprite:self]) {
			// move the knight
			NSLog(@"Ok, nothing is in the way");	
			[self moveSpritePosition:targetLocation sender:self];
		} else {
			// something is in the way, recalulate a new random target location
			NSLog(@"There is an obstacle in the way. Recalculating...");	
			[self moveInRandomDirection];
		}
	}

	
}

@end
