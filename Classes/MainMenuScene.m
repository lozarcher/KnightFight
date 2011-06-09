//
//  MainMenuScene.m
//  KnightFight
//
//  Created by Loz Archer on 16/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MainMenuScene.h"
#import "cocos2d.h"
#import "KnightFightAppDelegate.h"
#import "SimpleAudioEngine.h"

@implementation MainMenuScene

CCMenuItem *musicItem, *soundItem;

+(id) scene
{
	CCScene *scene = [CCScene node];
	MainMenuScene *layer = [MainMenuScene node];
	[scene addChild: layer];
	return scene;
}

-(void)callStartGame:(ccTime)delta {
	[self removeAllChildrenWithCleanup:YES];
	[self drawMenu];
	[UIAppDelegate startGame];
}

-(void)newGame:(id)sender {
	NSLog(@"Start game pressed");
	NSLog(@"Parent class: %@", [self.parent class]);
	
	[self removeAllChildrenWithCleanup:YES];
	
	[CCMenuItemFont setFontName: @"GrusskartenGotisch"];
	
	[CCMenuItemFont setFontSize:72];
	
	CCMenuItem *titleItem = [CCMenuItemFont itemFromString:@"Loading..."];
	[titleItem setIsEnabled:NO];
	
	CCMenu *menu = [CCMenu menuWithItems:titleItem, nil];
	[menu alignItemsVertically];
	
	[self addChild:menu];
	[self performSelector:@selector(callStartGame:) withObject:nil afterDelay:0.1];
	//[UIAppDelegate startGame];
}

-(void)instructions:(id)sender {
	[UIAppDelegate showInstructions];
	NSLog(@"Instructions pressed");
}


-(void)soundToggle:(id)sender {
	if (UIAppDelegate.soundOn) {
		UIAppDelegate.soundOn = NO;
		[self drawMenu];
	} else {
		UIAppDelegate.soundOn = YES;
		[self drawMenu];
	}
}

-(void)musicToggle:(id)sender {
	if (UIAppDelegate.musicOn) {
		UIAppDelegate.musicOn = NO;
		[self drawMenu];
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	} else {
		UIAppDelegate.musicOn = YES;
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"titletheme.m4a"];

		[self drawMenu];
	}
}

-(void)drawMenu {
	[self removeAllChildrenWithCleanup:YES];
	
	[CCMenuItemFont setFontName: @"GrusskartenGotisch"];
	
	[CCMenuItemFont setFontSize:72];
	
	CCMenuItem *titleItem = [CCMenuItemFont itemFromString:@"Knight Fight"];
	[titleItem setIsEnabled:NO];
	
	[CCMenuItemFont setFontSize:32];
	
	CCMenuItem *newGameItem = [CCMenuItemFont itemFromString:@"New Game" target:self selector:@selector(newGame:)];
	CCMenuItem *instructionsItem = [CCMenuItemFont itemFromString:@"Instructions" target:self selector:@selector(instructions:)];
	[CCMenuItemFont setFontSize:24];

	if (UIAppDelegate.musicOn) {
		musicItem = [CCMenuItemFont itemFromString:@"Music On" target:self selector:@selector(musicToggle:)];
	} else {
		musicItem = [CCMenuItemFont itemFromString:@"Music Off" target:self selector:@selector(musicToggle:)];
	}
	if (UIAppDelegate.soundOn) {
		soundItem = [CCMenuItemFont itemFromString:@"Sound On" target:self selector:@selector(soundToggle:)];
	} else {
		soundItem = [CCMenuItemFont itemFromString:@"Sound Off" target:self selector:@selector(soundToggle:)];

	}
	CCMenu *menu = [CCMenu menuWithItems:titleItem,newGameItem, instructionsItem, musicItem, soundItem, nil];
	[menu alignItemsVertically];
	 
	[self addChild:menu];
}

-(id) init
{
	if( (self=[super init] )) {
		UIAppDelegate.musicOn = YES;
		UIAppDelegate.soundOn = YES;
		
		[self drawMenu];
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}


@end
