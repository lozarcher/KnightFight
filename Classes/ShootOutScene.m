//
//  ShootOutScene.m
//  KnightFight
//
//  Created by Loz Archer on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ShootOutScene.h"
#import "KnightFightAppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation ShootOutScene

@synthesize knight, playerShots, playerShotsLabel;

int numberOfPlayerDeathBullets;
BOOL playerDead, knightDead;

+(id) scene
{
	CCScene *scene = [CCScene node];
	ShootOutScene *layer = [ShootOutScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		NSLog(@"Initialising shoot out scene");
		knight = [Knight knight];
		
		self.playerShots = 3;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];

		playerShotsLabel = [CCLabelTTF labelWithString:@"init" dimensions:CGSizeMake(200, 20) 
									   alignment:UITextAlignmentRight fontName:@"Verdana-Bold" fontSize:18];
		playerShotsLabel.color = ccc3(255,255,255);
		int margin = 10;
		playerShotsLabel.position = CGPointMake(winSize.width - (playerShotsLabel.contentSize.width/2)
										  -margin, (playerShotsLabel.contentSize.height/2 + margin));
		[self addChild:playerShotsLabel];
		[self updatePlayerShots:playerShots];
		
		
		int allowedScreenWidth = winSize.width - knight.contentSize.width;
		int allowedScreenHeight = winSize.height - knight.contentSize.height;
		int startScreenX = knight.contentSize.width / 2;
		int startScreenY = knight.contentSize.height / 2;
		
		CGPoint knightStart = CGPointMake( startScreenX + (arc4random() % allowedScreenWidth),
										   startScreenY + (arc4random() % allowedScreenHeight));

		knight.position = knightStart;
		knight.visible = YES;
		knight.velocity = (300 + (UIAppDelegate.level * 100))/1;

		[self addChild:self.knight]; 

		[[CCDirector sharedDirector] resume];
		[self schedule:@selector(shootOutTimeout:) interval:2];
		[self shootOutMovement];
		
		self.isTouchEnabled = YES;
		
		numberOfPlayerDeathBullets = 5;
		playerDead = NO;
		knightDead = NO;
	}
	return self;
}

-(void) finishedShootOut:(ccTime)delta  {
	[self unschedule:@selector(finishedShootOut:)];
	[self removeAllChildrenWithCleanup:YES];
	[UIAppDelegate finishedShootOut:(!playerDead)];
}

-(void)updatePlayerShots:(int)shots {
	NSLog(@"Updating player shots: %d", playerShots);
	[playerShotsLabel setString:[NSString stringWithFormat:@"Shots: %d",playerShots]];
}
	 
-(void)showMessage:(NSString *)text {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CCLabelTTF *label = [CCLabelTTF labelWithString:text dimensions:CGSizeMake(winSize.width,100) 
										  alignment:UITextAlignmentCenter fontName:@"GrusskartenGotisch" fontSize:72];

	label.position = CGPointMake(winSize.width - (label.contentSize.width / 2), winSize.height / 2);

	[self addChild:label];
}

-(void)showPlayerDeathBullet:(ccTime)delta {
	CCSprite *bullet = [CCSprite spriteWithFile:@"BulletHole.png"];		
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int allowedScreenWidth = winSize.width - knight.contentSize.width;
	int allowedScreenHeight = winSize.height - knight.contentSize.height;
	int startScreenX = knight.contentSize.width / 2;
	int startScreenY = knight.contentSize.height / 2;
	bullet.position = CGPointMake( startScreenX + (arc4random() % allowedScreenWidth),
								  startScreenY + (arc4random() % allowedScreenHeight));
	[self addChild:bullet];
	if (UIAppDelegate.soundOn) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"bullet.wav"];
	}
	numberOfPlayerDeathBullets--;
	if (numberOfPlayerDeathBullets == 0) {
		[self unschedule:@selector(showPlayerDeathBullet:)];
		[self showMessage:@"You're Dead!"];
		[self schedule:@selector(finishedShootOut:) interval:3];
	} else {
		[self unschedule:@selector(showPlayerDeathBullet:)];
		[self schedule:@selector(showPlayerDeathBullet:) interval:0.5];

	}
}

-(void)shootOutTimeout:(ccTime)delta {
	[self unschedule:@selector(shootOutTimeout:)];
	[knight stopAllActions];
	
	playerDead = YES;

	[self schedule:@selector(showPlayerDeathBullet:) interval:0];
}

-(void) shootOutMovement {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int allowedScreenWidth = winSize.width - knight.contentSize.width;
	int allowedScreenHeight = winSize.height - knight.contentSize.height;
	int startScreenX = knight.contentSize.width / 2;
	int startScreenY = knight.contentSize.height / 2;
		
	int randomDirection = arc4random() % 8;
	int randomDistance = arc4random() % allowedScreenWidth;
		
	CGPoint targetPosition = knight.position;
	
	NSLog(@"Random direction = %d", randomDirection);
	switch (randomDirection) {
		case 0:
			targetPosition.x -= randomDistance;
			break;
		case 1:
			targetPosition.y -= randomDistance;
			break;
		case 2:
			targetPosition.x += randomDistance;
			break;
		case 3:
			targetPosition.y += randomDistance;
			break;
		case 4:
			targetPosition.x -= randomDistance;
			targetPosition.y += randomDistance;
			break;
		case 5:
			targetPosition.x -= randomDistance;
			targetPosition.y -= randomDistance;
			break;
		case 6:
			targetPosition.x += randomDistance;
			targetPosition.y -= randomDistance;
			break;
		case 7:
			targetPosition.x += randomDistance;
			targetPosition.y += randomDistance;
			break;
	}
	NSLog(@"Trying to move knight to %f %f",targetPosition.x, targetPosition.y);
		
	if ((targetPosition.x < startScreenX) ||
		(targetPosition.x > startScreenX + allowedScreenWidth) ||
		(targetPosition.y < startScreenY) ||
		(targetPosition.y > startScreenY + allowedScreenHeight)) 
	{
		NSLog(@"Off the map, trying again...");
		[self shootOutMovement];
	} else {
		// move the knight
		NSLog(@"Moving the knight to %f %f", targetPosition.x, targetPosition.y);
		[knight moveSpritePosition:targetPosition sender:self];
	}
}

-(void)spriteMoveFinished:(id)sender {
	[self stopAllActions];
	NSLog(@"Knight reached target");
	[self shootOutMovement];
}

- (void) dealloc
{
	[super dealloc];
}


-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self 
													 priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{		
	if ((!playerDead) && (!knightDead) && (playerShots)) {
		
		playerShots--;
		[self updatePlayerShots:playerShots];

		if (UIAppDelegate.soundOn) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"bullet.wav"];
		}
		CGPoint touchLocation = [touch locationInView: [touch view]];		
		touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
		touchLocation = [self convertToNodeSpace:touchLocation];
	
		CGPoint diff = ccpSub(knight.position, touchLocation);
		if ((abs(diff.x) <= knight.contentSize.width / 3) &&
			(abs(diff.y) <= knight.contentSize.height / 3)) {

			[self unschedule:@selector(shootOutTimeout:)];
			[knight stopAllActions];
		
			CCSprite *bullet = [CCSprite spriteWithFile:@"BulletHole.png"];		
			bullet.position = knight.position;
			[self addChild:bullet];
			[self showMessage:@"You got him!"];
			knightDead = YES;
			if (UIAppDelegate.soundOn) {
				[[SimpleAudioEngine sharedEngine]playEffect:@"neigh.wav"];
			}
			[self schedule:@selector(finishedShootOut:) interval:3];

		}
	}

}

@end
