//
//  HudLayer.m
//  KnightFight
//
//  Created by Loz Archer on 13/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HudLayer.h"
#import "KnightFightAppDelegate.h"

@implementation HudLayer

@synthesize livesLabel, levelLabel, gameOverLabel;
@synthesize speedUpSprite, tripleShotsSprite;

-(id) init
{
	if ((self = [super init])) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		int margin = 10;
		levelLabel = [CCLabelTTF labelWithString:@"init" dimensions:CGSizeMake(100, 20) 
									   alignment:UITextAlignmentLeft fontName:@"Verdana-Bold" fontSize:18];
		levelLabel.position = ccp(margin+levelLabel.contentSize.width / 2, levelLabel.contentSize.height/2 + margin); 
		levelLabel.color = ccc3(255,255,255);
		
		
		[self addChild:levelLabel];
		
		livesLabel = [CCLabelTTF labelWithString:@"init" dimensions:CGSizeMake(100,20) alignment:UITextAlignmentRight fontName:@"Verdana-Bold" fontSize:18];
		livesLabel.color = ccc3(255,255,255);
		livesLabel.position = CGPointMake(winSize.width - margin - livesLabel.contentSize.width/2, (livesLabel.contentSize.height/2 + margin));
		[self addChild:livesLabel];
		
		[self updateLives:UIAppDelegate.playerLives];
		[self updateLevel:UIAppDelegate.level];

		speedUpSprite = [CCSprite spriteWithFile:@"SpeedUpIcon.png"];
		speedUpSprite.position = CGPointMake(winSize.width / 2 - speedUpSprite.contentSize.width /2, speedUpSprite.contentSize.height /2 + margin);
		speedUpSprite.visible = NO;
		[self addChild:speedUpSprite];
		
		tripleShotsSprite = [CCSprite spriteWithFile:@"TripleShotsIcon.png"];
		tripleShotsSprite.position = CGPointMake(winSize.width / 2 + tripleShotsSprite.contentSize.width /2, tripleShotsSprite.contentSize.height/2 + margin);
		tripleShotsSprite.visible = NO;
		[self addChild:tripleShotsSprite];
	}
	return self;
}

-(void) showSpeedUpSprite:(BOOL)show {
	speedUpSprite.visible = show;
}

-(void) showTripleShotsSprite:(BOOL)show {
	tripleShotsSprite.visible = show;
}

-(void) updateLives:(int)lives {
	NSLog(@"UpdateLives called");
	[livesLabel setString:[NSString stringWithFormat:@"Lives: %d",lives]];
}

-(void) updateLevel:(int)level {
	NSLog(@"UpdateLevel called");
	[levelLabel setString:[NSString stringWithFormat:@"Level: %d",level]];
}

-(void)gameOver {
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	gameOverLabel = [CCLabelTTF labelWithString:@"Game Over" dimensions:CGSizeMake(winSize.width,80) 
								   alignment:UITextAlignmentCenter fontName:@"GrusskartenGotisch" fontSize:72];
	gameOverLabel.position = CGPointMake(winSize.width / 2, winSize.height/2 + gameOverLabel.contentSize.height/2);
	CCLabelTTF *tapLabel = [CCLabelTTF labelWithString:@"Tap to continue" dimensions:CGSizeMake(winSize.width,40) 
									  alignment:UITextAlignmentCenter fontName:@"GrusskartenGotisch" fontSize:32];
	tapLabel.position = CGPointMake(winSize.width / 2, winSize.height/2 - tapLabel.contentSize.height/2);	
	[self addChild:gameOverLabel];
	[self addChild:tapLabel];
	
	[[CCDirector sharedDirector] pause];
}

-(void)restartGame {
	[self updateLives:3];
	[self removeAllChildrenWithCleanup:YES];
}

@end
