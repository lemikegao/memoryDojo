//
//  MainMenuScene.m
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"
#import "LevelSelectionLayer.h"

@implementation MainMenuScene

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art_bg.plist"];
        
        MainMenuLayer *mainMenuLayer = [MainMenuLayer node];
        [self addChild:mainMenuLayer z:1];
        
        LevelSelectionLayer *levelSelectionLayer = [LevelSelectionLayer node];
        [self addChild:levelSelectionLayer z:2];
        
        levelSelectionLayer.delegate = mainMenuLayer;
    }
    
    return self;
}

@end
