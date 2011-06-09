//
//  MainMenuScene.h
//  KnightFight
//
//  Created by Loz Archer on 16/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MainMenuScene : CCLayer {

}

+(id) scene;
-(void) newGame:(id)sender;
-(void) instructions:(id)sender;
-(void)quit:(id)sender;
-(void)drawMenu;

@end
