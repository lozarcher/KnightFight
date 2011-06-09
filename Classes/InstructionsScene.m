//
//  InstructionsScene.m
//  KnightFight
//
//  Created by Loz Archer on 16/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InstructionsScene.h"
#import "KnightFightAppDelegate.h"

@implementation InstructionsScene

+(id) scene
{
	CCScene *scene = [CCScene node];
	InstructionsScene *layer = [InstructionsScene node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if( (self=[super init] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];

		CCSprite *instructions = [CCSprite spriteWithFile:@"Instructions.png"];

		instructions.position = ccp(winSize.width/2, 
									winSize.height/2);
		[self addChild:instructions];
		
		self.isTouchEnabled = YES;

	}
	return self;
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
	[UIAppDelegate showMenu];
}

@end
