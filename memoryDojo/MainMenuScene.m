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
#import "SettingsLayer.h"

@interface MainMenuScene ()

@property (nonatomic, strong) MainMenuLayer *mainMenuLayer;
@property (nonatomic, strong) LevelSelectionLayer *levelSelectionLayer;
@property (nonatomic, strong) SettingsLayer *settingsLayer;
@property (nonatomic) BOOL isSettingsDisplayed;

@end

@implementation MainMenuScene

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art_bg.plist"];
        self.isSettingsDisplayed = NO;
        
        self.mainMenuLayer = [MainMenuLayer node];
        [self addChild:self.mainMenuLayer z:1];
        self.mainMenuLayer.mainMenuSceneDelegate = self;
        
        self.levelSelectionLayer = [LevelSelectionLayer node];
        [self addChild:self.levelSelectionLayer z:2];
        
        self.levelSelectionLayer.delegate = self.mainMenuLayer;
        
        self.settingsLayer = [SettingsLayer node];
        self.settingsLayer.ignoreAnchorPointForPosition = NO;
        self.settingsLayer.anchorPoint = ccp(0, 1);
#warning -- fix for iphone 5 & 4
        self.settingsLayer.position = ccp(0, -44);
        [self addChild:self.settingsLayer z:10];
        self.settingsLayer.mainMenuSceneDelegate = self;
    }
    
    return self;
}

-(void)showSettings {
    if (self.isSettingsDisplayed == NO) {
        self.isSettingsDisplayed = YES;
        self.mainMenuLayer.isTouchEnabled = NO;
        self.mainMenuLayer.enableGestures = NO;
        self.levelSelectionLayer.isTouchEnabled = NO;
        [self.settingsLayer runAction:[CCMoveTo actionWithDuration:0.25f position:ccp(0, [CCDirector sharedDirector].winSize.height)]];
    }
}

-(void)hideSettings {
    if (self.isSettingsDisplayed == YES) {
        self.isSettingsDisplayed = NO;
        self.mainMenuLayer.isTouchEnabled = YES;
        self.mainMenuLayer.enableGestures = YES;
        self.levelSelectionLayer.isTouchEnabled = YES;
        [self.settingsLayer runAction:[CCMoveTo actionWithDuration:0.25f position:ccp(0, -1*[CCDirector sharedDirector].winSize.height)]];
    }
}

@end
