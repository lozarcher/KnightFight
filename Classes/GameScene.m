//
//  HelloWorldLayer.m
//  KnightFight
//
//  Created by Loz Archer on 27/04/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// Import the interfaces
#import "GameScene.h"
#import "KnightFightAppDelegate.h"

// HelloWorld implementation
@implementation KnightFight

@synthesize meta;
@synthesize hudLayer = _hudLayer;
@synthesize collisionsTick, linesOfSightTick, zPositionTick, aStarUpdateTick, collisionPlayerEnvironTick;
@synthesize player, attackers, bullets, doors, knight;
@synthesize powerUpAlert;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	KnightFight *layer = [KnightFight node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	HudLayer *hud = [HudLayer node];
	[scene addChild:hud];
	layer.hudLayer = hud;
	
	// return the scene
	return scene;
}

-(void)spawnAttackers {
	if (attackers) {
		for (Attacker *attacker in attackers) {
			[self removeChild:attacker cleanup:YES];
		}
		[attackers release];
	}
	attackers = [[NSMutableArray alloc] init];
	CCTMXLayer* metaLayer = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	for (int x=0; x<UIAppDelegate.tileMap.mapSize.width; x++) {
		for (int y=0; y<UIAppDelegate.tileMap.mapSize.height; y++) {
			CGPoint tilePos = CGPointMake(x,y);
			unsigned int metaTileGID = [metaLayer tileGIDAt:tilePos];
			if (metaTileGID > 0)
			{
				NSDictionary *properties = [UIAppDelegate.tileMap propertiesForGID:metaTileGID];
				if (properties) {
					NSString *ghostSpawn = [properties valueForKey:@"GhostSpawn"];
					if ([ghostSpawn isEqualToString:@"True"]) {
						NSLog(@"Ghost Spawn found at %d %d", x, y);
						Attacker *attacker = [Attacker attacker];
						[attacker updateVertexZ:tilePos tileMap:UIAppDelegate.tileMap];
						CGPoint attackerStart = [UIAppDelegate.coordinateFunctions locationFromTilePos:tilePos];
						attackerStart = [UIAppDelegate.coordinateFunctions pointRelativeToCentreFromLocation:attackerStart];
						attacker.position=attackerStart;
						[attacker changeSpriteAnimation:@"S"];
						[self addChild:attacker];
						[attackers addObject:attacker];
					} 
				}
			}
		}
	}
	NSLog(@"Number of attackers %d", [attackers count]);
}

-(void) resetGame {
	NSLog(@"In reset game. Player lives: %d",UIAppDelegate.playerLives);
	[self removeAllChildrenWithCleanup:YES];

	if (UIAppDelegate.playerLives <= 0) {
		UIAppDelegate.gameState = GameOver;
		[[CCDirector sharedDirector] pause];
		[self.hudLayer gameOver];
		return;
	}
	[self.hudLayer updateLevel:UIAppDelegate.level];
	[[CCDirector sharedDirector] resume];

	UIAppDelegate.gameState = Play;
	if (bullets) {
		[bullets release];
	}
	if (doors) {
		[doors release];
	}
	
	int mapLevel = ((UIAppDelegate.level-1) % UIAppDelegate.maxLevels) + 1;
	//int mapLevel = UIAppDelegate.level;
	/*
	if (mapLevel > UIAppDelegate.maxLevels) {
		mapLevel = mapLevel - UIAppDelegate.maxLevels;
	}
	*/
	NSString *mapName = [NSString stringWithFormat:@"level-%d.tmx", mapLevel];

	NSLog(@"Loading map %@", mapName);
	UIAppDelegate.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:mapName];
	
	NSLog(@"tilemap %@",UIAppDelegate.tileMap);
	meta = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	meta.visible = NO;
	/*
	CCTMXLayer *houses = [UIAppDelegate.tileMap layerNamed:@"Houses"];
	houses.visible = NO;
	*/
	[self addChild:UIAppDelegate.tileMap z:-1 tag:TileMapNode];

	UIAppDelegate.coordinateFunctions.playableAreaMin = CGPointMake(0,0);
	UIAppDelegate.coordinateFunctions.playableAreaMax = CGPointMake(UIAppDelegate.tileMap.mapSize.width -1 , UIAppDelegate.tileMap.mapSize.height -1);
		
	player = [Player player];
	[self addChild:self.player]; 
	
	CGPoint playerStart = [self getPlayerSpawn];
	
	UIAppDelegate.tileMap.position = [UIAppDelegate.coordinateFunctions locationFromTilePos:playerStart];

	[player changeSpriteAnimation:@"W"];
	player.visible = YES;
	[self.hudLayer showSpeedUpSprite:NO];
	[self.hudLayer showTripleShotsSprite:NO];
	
	knight = [Knight knight];
	[self addChild:knight];
	
	// position knight to start in a random unblocked tile
	CGPoint knightStart;
	BOOL farFromPlayer = YES;
	do{
		int startX = arc4random() % (int)UIAppDelegate.tileMap.mapSize.width;
		int startY = arc4random() % (int)UIAppDelegate.tileMap.mapSize.height;
		knightStart = CGPointMake(startX, startY);
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		CGPoint diffKnightPlayer = ccpSub(playerStart, knightStart);

		NSLog(@"Knight is being spawned %d %d squares away", diffKnightPlayer.x, diffKnightPlayer.y);
		// Respawn if too close to player
		if ((abs(diffKnightPlayer.x) < winSize.width / 2) && (abs(diffKnightPlayer.y) < winSize.height / 2)) {
			farFromPlayer = NO;
		}
	}
	while(([UIAppDelegate.coordinateFunctions isTilePosBlocked:knightStart]) || (farFromPlayer));
	knightStart = [UIAppDelegate.coordinateFunctions locationFromTilePos:knightStart];
	knightStart = [UIAppDelegate.coordinateFunctions pointRelativeToCentreFromLocation:knightStart];
	knightStart.y = knightStart.y + knight.contentSize.height/4;
	knight.position=knightStart;
	[knight moveInRandomDirection];

	[self spawnAttackers];
	
	bullets = [[NSMutableArray alloc] init];
	doors = [[NSMutableArray alloc] init];
	[self setUpHouseContents];
}

-(CGPoint)getPlayerSpawn {
	CCTMXLayer* metaLayer = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	for (int x=0; x<UIAppDelegate.tileMap.mapSize.width; x++) {
		for (int y=0; y<UIAppDelegate.tileMap.mapSize.height; y++) {
			CGPoint tilePos = CGPointMake(x,y);
			unsigned int metaTileGID = [metaLayer tileGIDAt:tilePos];
			if (metaTileGID > 0)
			{
				NSDictionary *properties = [UIAppDelegate.tileMap propertiesForGID:metaTileGID];
				if (properties) {
					NSString *playerSpawn = [properties valueForKey:@"PlayerSpawn"];
					if ([playerSpawn isEqualToString:@"True"]) {
						NSLog(@"Player Spawn found at %d %d", x, y);
						return tilePos;
					} 
				}
			}
		}
	}
	NSLog(@"Error: Player spawn not found on map");
	return CGPointMake(0,0);
}

-(id) init
{
	if( (self=[super init] )) {
		
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"bullet.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"ghostbirth.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"ghostdeath.wav"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"neigh.wav"];

		self.isTouchEnabled = YES;
		UIAppDelegate.gameScene = self;
		UIAppDelegate.playerLives = UIAppDelegate.maxPlayerLives;

		[self resetGame];
		
		[self scheduleUpdate];

	}
	return self;
}

-(void)setUpHouseContents {
	
	CCTMXLayer* metaLayer = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	for (int x=0; x<UIAppDelegate.tileMap.mapSize.width; x++) {
		for (int y=0; y<UIAppDelegate.tileMap.mapSize.height; y++) {
			CGPoint tilePos = CGPointMake(x,y);
			unsigned int metaTileGID = [metaLayer tileGIDAt:tilePos];
			if (metaTileGID > 0)
			{
				NSDictionary *properties = [UIAppDelegate.tileMap propertiesForGID:metaTileGID];
				if (properties) {
					NSString *collision = [properties valueForKey:@"Door"];
					if ([collision isEqualToString:@"True"]) {
						NSLog(@"Door found at %d %d", x, y);
						Door *door = [Door door];
						door.tilePos = CGPointMake(x,y);
						[doors addObject:door];
					} 
				}
			}
		}
	}
}

-(void)loseLife {
	UIAppDelegate.playerLives--;
	[self.hudLayer updateLives:UIAppDelegate.playerLives];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{

	NSLog(@"GameScene dealloc");
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];

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

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / UIAppDelegate.tileMap.tileSize.width;
    int y = ((UIAppDelegate.tileMap.mapSize.height * 
			  UIAppDelegate.tileMap.tileSize.height) - position.y) / 
				UIAppDelegate.tileMap.tileSize.height;
    return ccp(x, y);
}

-(void)fireBullet:(CGPoint)target {
	Bullet *bullet = [Bullet bullet];		
	bullet.visible = YES;
	bullet.position = player.position;
	[self addChild:bullet];
	[bullets addObject:bullet];
	[bullet shootBullet:target player:player];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (UIAppDelegate.gameState == GameOver) {
		NSLog(@"Game over touch");
		[UIAppDelegate showMenu];
		return;
	}
	
	if (UIAppDelegate.gameState == PowerUp) {
		[[CCDirector sharedDirector] resume];
		[self removeChild:powerUpAlert cleanup:YES];
	}
	
	CGPoint touchLocation = [touch locationInView: [touch view]];		
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	touchLocation = [self convertToNodeSpace:touchLocation];
	if (touch.tapCount != 2) {
		if (player.alive) {
			[player moveSpritePosition:touchLocation sender:player];
		}
	} else {
		[player stopAllActions];
		[self fireBullet:touchLocation]; 
		
		CGPoint diff = ccpSub(player.position, touchLocation);
		float distance = sqrt( pow(diff.x, 2) + pow(diff.y, 2) );

		int bulletOffsetAngle = 5;
		if (player.tripleShotsActive) {
			float originalAngle = [UIAppDelegate.coordinateFunctions getAngleBetweenPoints:player.position pt2:touchLocation];
			float bullet1Angle = originalAngle + bulletOffsetAngle;
			float bullet2Angle = originalAngle - bulletOffsetAngle;
			
			NSLog(@"original angle %f",originalAngle);
			NSLog(@"bullet 1 angle %f",bullet1Angle);
			NSLog(@"bullet 2 angle %f",bullet2Angle);
			
			CGPoint bullet1Target = [UIAppDelegate.coordinateFunctions pointFromAngleAndDistance:bullet1Angle
																			startPosition:player.position
																			distance:distance];
			CGPoint bullet2Target = [UIAppDelegate.coordinateFunctions pointFromAngleAndDistance:bullet2Angle
																			startPosition:player.position
																			distance:distance];
			[self fireBullet:bullet1Target]; 
			[self fireBullet:bullet2Target]; 
		}
		
		if (UIAppDelegate.soundOn) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"bullet.wav"];
		}
	}
}

-(NSString *)getHouseContentsAtTilePos:(CGPoint)tilePos {
	
	for (Door *door in doors) {
		if ((door.tilePos.x == tilePos.x) && (door.tilePos.y == tilePos.y)) {
			return door.contents;
		}
	}
	return nil;
}

-(void)checkPlayerCollisionWithEnvironment {
	CGPoint tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:[player getLocation]];
	if ([UIAppDelegate.coordinateFunctions isTilePosBlocked:tilePos]) {
		NSLog(@"Collision!");
		[player stopAllActions];
		self.player.isMoving = NO;
		player.position = player.lastPosition;
	} else {
		player.lastPosition = player.position;
	}
} 

-(void)destroyBullet:(Bullet *)bullet {
	[bullet stopAllActions];
	[self removeChild:bullet cleanup:YES];
	[bullets removeObject:bullet];
}

-(void)startShootOut:(ccTime)delta {
	[self removeChild:powerUpAlert cleanup:YES];
	[UIAppDelegate shootOut];
}

-(void)checkCollisions {
	
	// Bullet collision detection
    NSMutableArray *bulletsToDestroy = [[NSMutableArray alloc] init];
	for (Bullet *bullet in bullets) {
		CGPoint tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:bullet.position];
		if (([UIAppDelegate.coordinateFunctions isTilePosIsWithinBounds:tilePos]) && (bullet.isMoving)) {
			
			// check bullet collision with knight
			if ([UIAppDelegate.coordinateFunctions spritesCollided:bullet sprite2:knight]) {

				if (player.alive) {
					NSLog(@"HIT KNIGHT");
					if (UIAppDelegate.soundOn) {
						[[SimpleAudioEngine sharedEngine]playEffect:@"neigh.wav"];
					}
					powerUpAlert = [CCSprite spriteWithFile:@"ShootOut.png"];
					CGSize winSize = [[CCDirector sharedDirector] winSize];
					powerUpAlert.position = ccp(player.position.x, player.position.y);
					[self addChild:powerUpAlert];
                    [bulletsToDestroy addObject:bullet];
					[self performSelector:@selector(startShootOut:) withObject:nil afterDelay:3];

					[[CCDirector sharedDirector] pause];
					UIAppDelegate.gameState = ShootOut;
				}

			} else {
				// Check collision of bullets with landscape
				if ([UIAppDelegate.coordinateFunctions isTilePosBlocked:tilePos]) {
					NSLog(@"Bullet collision with landscape!");
                    [bulletsToDestroy addObject:bullet];
				} else {
					// Check collision of bullets with attackers
                    NSMutableArray *attackersToDestroy = [[NSMutableArray alloc] init];
					for (Attacker *attacker in attackers) {
                        if ([attacker alive]) {
                            if ([UIAppDelegate.coordinateFunctions spritesCollided:bullet sprite2:attacker]) {
                                [attacker deathSequence];
                                [bulletsToDestroy addObject:bullet];
                            }
                        }
					}
                    for (Attacker *attacker in attackersToDestroy) {
                        [attackers removeObject:attacker];
                    }
                    [attackersToDestroy release];
				}
			}
		} else {
			//bullet out of bounds
			NSLog(@"Bullet out of bounds");
            [bulletsToDestroy addObject:bullet];
		}
	}
    for (Bullet *bullet in bulletsToDestroy) {
        [self destroyBullet:bullet];
    }
    [bulletsToDestroy release];
	
	// Check if player is at door
	CGPoint tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:[player getLocation]];
	if ([UIAppDelegate.coordinateFunctions atDoor:tilePos]) {
		NSLog(@"At door!!");
		[[CCDirector sharedDirector] pause];
		UIAppDelegate.gameState = PowerUp;
		NSString *powerUp = [self getHouseContentsAtTilePos:tilePos];
		NSString *spriteFilename = [NSString stringWithFormat:@"%@.png",powerUp];
		
		powerUpAlert = [CCSprite spriteWithFile:spriteFilename];
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		powerUpAlert.position = ccp(player.position.x, player.position.y);
		[self addChild:powerUpAlert];

		NSLog(@"Found power up: %@", powerUp);

		if (![powerUp isEqual:@"EmptyHouse"]) {
			NSLog(@"Setting house to be empty");
			for (Door *door in doors) {
				if ((door.tilePos.x == tilePos.x) && (door.tilePos.y == tilePos.y)) {
					door.contents = @"EmptyHouse";
					break;
				}
			}
		}
		
		if ([powerUp isEqual:@"ExtraLife"]) {
			UIAppDelegate.playerLives++;
			NSLog(@"Extra life awarded");
			[self.hudLayer updateLives:UIAppDelegate.playerLives];
		}

		if ([powerUp isEqual:@"SpeedUp"]) {
			if (player.speedUpActive) {
				[self unschedule:@selector(removeSpeedUp:)];
			} else {
				player.velocity = player.velocitySpeedUp;
			}
			[self schedule:@selector(removeSpeedUp:) interval:15];
			player.speedUpActive = YES;
			[self.hudLayer showSpeedUpSprite:YES];
			NSLog(@"Speed Up awarded");
		}
		
		if ([powerUp isEqual:@"TripleShots"]) {
			if (player.tripleShotsActive) {
				[self unschedule:@selector(removeTripleShots:)];
			}
			[self schedule:@selector(removeTripleShots:) interval:15];
			player.tripleShotsActive = YES;
			[self.hudLayer showTripleShotsSprite:YES];
			NSLog(@"Triple Shots awarded");
		}
		
		if ([powerUp isEqual:@"GhostRespawn"]) {
			NSLog(@"Ghost Respawn!");
			[self spawnAttackers];
		}
	}
	
    NSMutableArray *attackersToDestroy = [[NSMutableArray alloc] init];
	for (Attacker *attacker in attackers) {
		//Check collision of player with attackers
		if (([UIAppDelegate.coordinateFunctions spritesCollided:attacker sprite2:player]) && (attacker.alive)) {
			[player deathSequence];
            [attacker deathSequence];
		}
	}
    for (Attacker *attacker in attackersToDestroy) {
        [attackers removeObject:attacker];
    }
    [attackersToDestroy release];
	
	//Check collision of player with knight
	if (([UIAppDelegate.coordinateFunctions spritesCollided:knight sprite2:player]) && (knight.alive)) {
		[player deathSequence];
	}

}
									 
-(void)removeSpeedUp:(ccTime)delta {
	player.speedUpActive = NO;
	[self unschedule:@selector(removeSpeedUp:)];
	[self.hudLayer showSpeedUpSprite:NO];
	player.velocity = player.velocityOrdinary;
}

-(void)removeTripleShots:(ccTime)delta {
	player.tripleShotsActive = NO;
	[self.hudLayer showTripleShotsSprite:NO];
	[self unschedule:@selector(removeTripleShots:)];
}

-(void)setViewpointCenter:(CGPoint) position {
	
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	int x = -position.x+(winSize.width/2);
	int y = -position.y+(winSize.height/2);
	
	self.position = CGPointMake(x, y);
}

-(void) updateAstarPaths {
	for (Attacker *attacker in attackers) {
		if (attacker.followingPath) {
			NSLog(@"Updating path");
			[attacker stopAllActions];
			[attacker createPathToPlayer];
		}
	}
}

-(void) checkLinesOfSight
{	
	NSLog(@"In Check Lines of sight for %d attackers",[attackers count]);
	
	// check attackers' line of sight with player
	for (Attacker *attacker in attackers) {
		//if ([attacker checkIfPointIsInSight:player.position enemySprite:attacker]) {
		if ([attacker checkIfPointIsInSight:[player getLocation] enemySprite:attacker]) {
			if (attacker.alive) {
				NSLog(@"GOT LINE OF SIGHT - going straight at player!");
				NSLog(@"...");
				NSLog(@"Attacker is following path? %i",attacker.followingPath);
				if (attacker.followingPath) {
					attacker.followingPath = NO;
					if (UIAppDelegate.isIPad) {
						[attacker unschedule:@selector(updateAStarPath:)];
					}
				}
				[attacker chasePlayer:player];

			} else {
				NSLog(@"Attacker not alive");
			}
		} else {
			if (attacker.chasingPlayer) {
				attacker.followingPath = YES;
				attacker.chasingPlayer = NO;
				[attacker stopAllActions];
				NSLog(@"Lost line of site... using A* pathfinding instead");
				[attacker createPathToPlayer];
				if (UIAppDelegate.isIPad) {
					float delay = ((arc4random() % 9) / 3) + 4;
					[attacker schedule:@selector(updateAStarPath:) interval:delay];
				}
			}
		}
	}
}

-(Player *)getPlayer {
	return player;
}

-(void) update:(ccTime)delta
{	
	collisionsTick += delta;
	linesOfSightTick += delta;
	zPositionTick += delta;
	aStarUpdateTick += delta;
	collisionPlayerEnvironTick += delta;
	
	if (collisionPlayerEnvironTick > 0.1) {
		[self checkPlayerCollisionWithEnvironment];
		collisionPlayerEnvironTick = 0;
	}
	
	if (collisionsTick > 0.1) {
		[self checkCollisions];
		collisionsTick = 0;
	}
	
	if (linesOfSightTick > 1) {
		[self checkLinesOfSight];
		linesOfSightTick = 0;
	}

	if (aStarUpdateTick > 5) {
		//[self updateAstarPaths];
		aStarUpdateTick = 0;
	}
	
	if (zPositionTick > 0.1) {
		// set the player's Z position
		CGPoint tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:[player getLocation]];
		[player updateVertexZ:tilePos tileMap:UIAppDelegate.tileMap];
	
		tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:[knight getLocation]];
		[knight updateVertexZ:tilePos tileMap:UIAppDelegate.tileMap];
		
		for (Attacker *attacker in attackers) {
			// set the attacker's z position
			tilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:[attacker getLocation]];
			[attacker updateVertexZ:tilePos tileMap:UIAppDelegate.tileMap];
		}
	}
	
	// reset the viewpoint so they player is always in the centre
	[self setViewpointCenter:[player getLocation]];
}

@end
