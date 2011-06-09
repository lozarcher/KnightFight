//
//  GameSprite.m
//  KnightFight
//
//  Created by Loz Archer on 03/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameSprite.h"
#import "KnightFightAppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation GameSprite

@synthesize isMoving, alive;
@synthesize deathTurns;
@synthesize animation;
@synthesize spriteRunAction;
@synthesize zOrderOffset;
@synthesize velocity;
@synthesize spriteSheet;
@synthesize spritesheetBaseFilename;


int maxSight = 400;

-(id)init
{
    if ((self = [super init]))
    {
		self.deathTurns = 0;
    }
    return self;
}

-(void)cacheFrames {
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	NSArray *directions = [NSArray arrayWithObjects:
						   @"N", @"NE", @"E", @"SE", @"S", @"SW", @"W", @"NW", nil];
	for (NSString *direction in directions) {
		
		NSString *plistFilename = [NSString stringWithFormat:@"%@%@.plist",self.spritesheetBaseFilename,direction];
		[cache addSpriteFramesWithFile:plistFilename];
		NSLog(@"Added %@ to the cache",plistFilename);
	}	
}

-(CGPoint)getLocation {
	return CGPointMake (self.position.x, self.position.y - self.contentSize.height / 4);
}

-(void)changeSpriteAnimation:(NSString *)direction {

	CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
							spriteFrameByName:[NSString stringWithFormat:@"%@%@-1.png",self.spritesheetBaseFilename,direction]];
	[self setDisplayFrame:frame];
	
	NSMutableArray *animFrames = [NSMutableArray array];
	NSString *spriteClass = [NSString stringWithFormat:@"%@",[self class]];
	int frames = 7;
	if ([spriteClass isEqual:@"Knight"]) {
		frames = 11;
	}
	NSLog(@"Frames for %@ = %d", spriteClass, frames);
	for (int i=0; i<=frames; i++) {
		CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache]
								spriteFrameByName:[NSString stringWithFormat:@"%@%@-%d.png",self.spritesheetBaseFilename, direction, i]];
		[animFrames addObject:frame];
	}
	
	self.animation = [CCAnimation animationWithName:@"walking" delay:0.1f frames:animFrames];
	//NSLog(@"Changed sprite animation to %@", direction);
}

-(void)moveSpritePosition:(CGPoint)targetPosition sender:(id)sender{
	
	CGPoint spritePos = self.position;
	
	float angle = [UIAppDelegate.coordinateFunctions getAngleBetweenPoints:spritePos pt2:targetPosition];

	int angleInt = angle / 22.5;
	
	switch (angleInt) {
		case 0:
			[self changeSpriteAnimation:@"W"];
			break;
		case 1:
			[self changeSpriteAnimation:@"SW"];
			break;
		case 2:
			[self changeSpriteAnimation:@"SW"];
			break;
		case 3:
			[self changeSpriteAnimation:@"S"];
			break;
		case 4:
			[self changeSpriteAnimation:@"S"];
			break;
		case 5:
			[self changeSpriteAnimation:@"SE"];
			break;
		case 6:
			[self changeSpriteAnimation:@"SE"];
			break;
		case 7:
			[self changeSpriteAnimation:@"E"];
			break;
		case 8:
			[self changeSpriteAnimation:@"E"];
			break;
		case 9:
			[self changeSpriteAnimation:@"NE"];
			break;
		case 10:
			[self changeSpriteAnimation:@"NE"];
			break;
		case 11:
			[self changeSpriteAnimation:@"N"];
			break;
		case 12:
			[self changeSpriteAnimation:@"N"];
			break;
		case 13:
			[self changeSpriteAnimation:@"NW"];
			break;
		case 14:
			[self changeSpriteAnimation:@"NW"];
			break;
		case 15:
			[self changeSpriteAnimation:@"W"];
			break;
	}
	
	
	CGPoint diff = ccpSub(targetPosition, spritePos);
	float lengthOfMovement = sqrt( pow(diff.x, 2) + pow(diff.y, 2) );
	
	float spriteVelocity = self.velocity;
	
	float realMoveDuration = lengthOfMovement/spriteVelocity;
		
	self.isMoving = YES;
	
	NSLog(@"moving sprite by %f %f for duration %f", diff.x, diff.y, realMoveDuration);
	
	[self stopAllActions];  // don't let old move continue - otherwise the player will stop at old target & start skating!
	
	[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.animation restoreOriginalFrame:NO]]];
	spriteRunAction = [CCSequence actions:
					   [CCMoveBy actionWithDuration:realMoveDuration position:diff],
					   [CCCallFuncN actionWithTarget:sender selector:@selector(spriteMoveFinished:)],
					   nil
					   ];
	[self runAction: spriteRunAction];

}


-(void)spriteMoveFinished:(id)sender {
	
	NSLog(@"%@ stopped moving",[sender class]);
	CGPoint tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:self.position];
	NSLog(@"Tile position %f %f",tilePos.x, tilePos.y);
	self.isMoving = NO;
	[self stopAllActions];
}

-(void) updateVertexZ:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
	float lowestZ = -(tileMap.mapSize.width + tileMap.mapSize.height);
	float currentZ = tilePos.x + tilePos.y;
	
	self.vertexZ = lowestZ + currentZ + (self.zOrderOffset);
	
	//NSLog(@"vertexZ: %.3f at tile pos: (%.1f, %.1f) -- lowestZ: %.0f, currentZ: %.1f", self.vertexZ, tilePos.x, tilePos.y, lowestZ, currentZ);
}


/////////////////
/*
 * Bresenenham line drawing algorithm.
 * ref: http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
 */
void getPointsOnLine(int x0, int y0, int x1, int y1, NSMutableArray *pointsArray) {
	int pointsOnLineGranularity = 1;
	
	int Dx = x1 - x0; 
	int Dy = y1 - y0;
	int steep = (abs(Dy) >= abs(Dx));
	if (steep) {
		//swap x and y values
		int temp = x0;
		x0 = y0;
		y0 = temp;
		temp = x1;
		x1 = y1;
		y1 = temp;
		// recompute Dx, Dy after swap
		Dx = x1 - x0;
		Dy = y1 - y0;
	}
	int xstep = pointsOnLineGranularity;
	if (Dx < 0) {
		xstep = -pointsOnLineGranularity;
		Dx = -Dx;
	}
	int ystep = pointsOnLineGranularity;
	if (Dy < 0) {
		ystep = -pointsOnLineGranularity;		
		Dy = -Dy; 
	}
	int TwoDy = 2*Dy; 
	int TwoDyTwoDx = TwoDy - 2*Dx; // 2*Dy - 2*Dx
	int E = TwoDy - Dx; //2*Dy - Dx
	int y = y0;
	int xDraw, yDraw;	
	int x = x0;
	while (abs(x-x1) > pointsOnLineGranularity) {
		x += xstep;
		//for (int x = x0; x != x1; x += xstep) {		
		if (steep) {			
			xDraw = y;
			yDraw = x;
		} else {			
			xDraw = x;
			yDraw = y;
		}		
		// Add point to arrary.
		[pointsArray addObject:[NSValue valueWithCGPoint:CGPointMake(xDraw, yDraw)]];
		
		// next
		if (E > 0) {
			E += TwoDyTwoDx; //E += 2*Dy - 2*Dx;
			y = y + ystep;
		} else {
			E += TwoDy; //E += 2*Dy;
		}
	}
}


-(BOOL)checkIfPointIsInSight:(CGPoint)targetPos enemySprite:(GameSprite *)enemy
{	
	//CGPoint attackerPos = enemy.position;
	NSString *spriteName = [NSString stringWithFormat:@"%@", [enemy class]];
	CGPoint attackerPos;
	if ([spriteName isEqual:@"Knight"]) {
		attackerPos = enemy.position;
	} else {
		attackerPos = [enemy getLocation];
	}
	CGPoint diff = ccpSub(targetPos, attackerPos);
	if ((abs(diff.x) > maxSight) || abs(diff.y) > maxSight) {
		return NO;
	}

	NSMutableArray *points = [NSMutableArray array];
	getPointsOnLine(targetPos.x, targetPos.y, attackerPos.x, attackerPos.y, points);
	
	BOOL lineOfSight = YES;
	for (int i=0; i<[points count]; i++) {
		CGPoint thisPoint = [[points objectAtIndex:i] CGPointValue];
		CGPoint thisTile = [UIAppDelegate.coordinateFunctions tilePosFromLocation:thisPoint];
		if ([UIAppDelegate.coordinateFunctions isTilePosBlocked:thisTile]) {
			lineOfSight = NO;
		}
	}
	/*
	 if (lineOfSight) {
		glColor4ub(255,0,255,255); // Or whatever drawing setup you need
		ccDrawLine(ccp(targetPos.x, targetPos.y), ccp(attackerPos.x, attackerPos.y));
	}
	 */
	return lineOfSight;
}

-(void) deathSpasm:(ccTime)delta
{
	NSArray *directions = [NSArray arrayWithObjects:@"N",@"NW",@"W",@"SW",@"S",@"SE",@"E",@"NE",nil];

	[self changeSpriteAnimation:[directions objectAtIndex:(deathTurns % 8)]];
	
	self.deathTurns++;
	if (self.deathTurns > 16) {
		[self unschedule:@selector(deathSpasm:)];
		
		NSString *spriteType = [NSString stringWithFormat:@"%@", self.class];
		if ([spriteType isEqual:@"Player"]) {
			NSLog(@"Player died");
			self.visible = NO;
			[self.parent loseLife];
			[self.parent resetGame];
		} else {
			NSLog(@"%@ died, removing from parent",[self class]);
			[self.parent removeChild:self cleanup:YES];
		}
	}

}

-(void)deathSequence {
	self.alive = NO;
	NSString *spriteType = [NSString stringWithFormat:@"%@",[self class]];
	if (([spriteType isEqual:@"Attacker"]) && (UIAppDelegate.soundOn)) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"ghostdeath.wav"];	
	}
	[self stopAllActions];
	[self schedule:@selector(deathSpasm:) interval:0.1];

}

-(void)draw {
	// removes horrible alpha blending problems of transparent layers when sprites are close
	glEnable(GL_ALPHA_TEST);
	glAlphaFunc(GL_GREATER, 0.0f);
	[super draw];
	glDisable(GL_ALPHA_TEST);
}
@end
