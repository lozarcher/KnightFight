//
//  Attacker.m
//  KnightFight
//
//  Created by Loz Archer on 05/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Attacker.h"
#import "KnightFightAppDelegate.h"
#import "Pathfinding.h"
#import "PathfindingNode.h"
#import "Player.h"
#import "SimpleAudioEngine.h"

@implementation Attacker

@synthesize lastPosition;
@synthesize chasingPlayer;
@synthesize followingPath;
@synthesize path;
@synthesize thread;
-(id) init {
    if ((self = [super init]))
    {
		self.alive = YES;
		self.zOrderOffset = 0;
		self.velocity = (50 + (UIAppDelegate.level * 10))/1;
		self.chasingPlayer = NO;
		self.followingPath = NO;
		self.thread = nil;
		//[[NSThread alloc] init];
		self.spritesheetBaseFilename = @"ghost";
		//self.path = nil;
		self.path = [[NSMutableArray alloc] init];
		[self cacheFrames];
    }
    return self;
}

-(void)dealloc {
	NSLog(@"Deallocating %@",[self class]);
	[self.thread release];
	[super dealloc];
}

+(id) attacker
{
	return [[[self alloc] init] autorelease];
}

-(void)spriteMoveFinished:(id)sender {
	if (self.followingPath) {
		if ([path count]>1) {
			NSLog(@"Continuing along path, %d tiles left on path", [path count]);
			[self followPath];
		} else {
			NSLog(@"Reached end of path");
			[self stopAllActions];

			// create another path
			[self createPathToPlayer];
			

		}
	} else {
		[self stopAllActions];
		self.isMoving = NO;
		self.chasingPlayer = NO;
	}
}


-(void)followPath {
	int numberOfSquares = [path count];
	if (numberOfSquares) {
		// snake along the squares
		int pathIndex = [path count]-2; // ignore the last position, it's the attacker's current square
		PathfindingNode *node = [path objectAtIndex:pathIndex];
		[path removeLastObject];
			
		NSLog(@"Moving sprite to tile pos %f %f", node.tilePos.x, node.tilePos.y);
	
		CGPoint nextPos = [UIAppDelegate.coordinateFunctions locationFromTilePos:node.tilePos];
		nextPos = [UIAppDelegate.coordinateFunctions pointRelativeToCentreFromLocation:nextPos];
		NSLog(@"Moving sprite to %f %f", nextPos.x, nextPos.y);
		[self moveSpritePosition:nextPos sender:self];

	}
}

-(void)setPathToAttacker:(NSMutableArray *)attackerPath {
	self.path = attackerPath;
	[self followPath];
	[self.thread release];
	self.thread = nil;
}

	
-(void)getPath:(NSArray *)tilePositions {
	NSLog(@"in thread - getPath");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CGPoint playerTilePos = [[tilePositions objectAtIndex:0] CGPointValue];
	CGPoint attackerTilePos = [[tilePositions objectAtIndex:1] CGPointValue];
	Pathfinding *pathfinding = [[Pathfinding alloc] init];
	NSLog(@"about to get path");
	NSMutableArray *returnedPath = [pathfinding search:attackerTilePos targetTile:playerTilePos];
	NSLog(@"got path back, with %d nodes",[returnedPath count]);
	
	[self performSelectorOnMainThread:@selector(setPathToAttacker:) withObject:returnedPath waitUntilDone:NO];
	NSLog(@"End of thread - draining pool");
	[pathfinding release];
	[pool drain];
	NSLog(@"End of thread - pool drained");
}

-(void)createPathToPlayer {
	if ((self.alive) && (self.followingPath)) {
		Player *player = [UIAppDelegate.gameScene getPlayer];

		CGPoint attackerTilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:self.position];
		CGPoint playerTilePos = [UIAppDelegate.coordinateFunctions tilePosFromLocation:player.position];
		NSLog(@"Creating path to player");
		NSLog(@"Attacker at %f %f", attackerTilePos.x, attackerTilePos.y);
		NSLog(@"Player at %f %f", playerTilePos.x, playerTilePos.y);
	

		NSArray *tilePositions = [NSArray arrayWithObjects:
							  [NSValue valueWithCGPoint:playerTilePos],
							  [NSValue valueWithCGPoint:attackerTilePos],
							  nil];
	
		
		[self.thread release];
		self.thread = [[NSThread alloc] initWithTarget:self
												 selector:@selector(getPath:)
												   object:tilePositions];
		[self.thread setThreadPriority:0.0];
		[self.thread start];
		
		//[self performSelectorInBackground:@selector(getPath:) withObject:tilePositions];
		
		NSLog(@"Following new path");
	} else {
		NSLog(@"Not creating path to player, because the attacker is dead or not following the player");
	}
}


-(void)chasePlayer:(GameSprite *)player {
	if ((!self.chasingPlayer) && (!self.followingPath) && (UIAppDelegate.soundOn)) {
		[[SimpleAudioEngine sharedEngine]playEffect:@"ghostbirth.wav"];
	}
	if (self.alive) {
		NSLog(@"Chasing player");
		NSLog(@"Player at %f %f",player.position.x, player.position.y);
		NSLog(@"Attacker at %f %f",self.position.x, self.position.y);
		[self moveSpritePosition:player.position sender:self];
		self.chasingPlayer = YES;
	}
}

-(void)updateAStarPath:(ccTime)delta {
	[self stopAllActions];
	[self createPathToPlayer];
}

@end
