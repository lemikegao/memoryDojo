//
//  GameLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/19/12.
//
//

#import "GameLayer.h"

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        
        CCLabelBMFont *gameBeginLabel = [CCLabelBMFont labelWithString:@"Game Start" fntFile:@"SpaceVikingFont.fnt"];
        gameBeginLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:gameBeginLabel];
        id labelAction = [CCSpawn actions:[CCScaleBy actionWithDuration:2.0f scale:4], [CCFadeOut actionWithDuration:2.0f], nil];
        [gameBeginLabel runAction:labelAction];
    }
    
    return self;
}

@end
