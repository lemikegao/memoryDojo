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
        // load additional sprite sheets for ipad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art_ninja.plist"];
            [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art_sensei.plist"];
        }
        self.isSettingsDisplayed = NO;
        
        self.mainMenuLayer = [MainMenuLayer node];
        [self addChild:self.mainMenuLayer z:1];
        self.mainMenuLayer.mainMenuSceneDelegate = self;
        
        self.levelSelectionLayer = [LevelSelectionLayer node];
        [self addChild:self.levelSelectionLayer z:2];
        
        self.levelSelectionLayer.delegate = self.mainMenuLayer;
        self.levelSelectionLayer.mainMenuSceneDelegate = self;
        
        self.settingsLayer = [SettingsLayer node];
        self.settingsLayer.visible = NO;
        self.settingsLayer.ignoreAnchorPointForPosition = NO;
        self.settingsLayer.anchorPoint = ccp(0, 1);
        self.settingsLayer.position = ccp(0, 0);
        [self addChild:self.settingsLayer z:10];
        self.settingsLayer.mainMenuSceneDelegate = self;
    }
    
    return self;
}

-(void)showSettings {
    if (self.isSettingsDisplayed == NO) {
        self.settingsLayer.visible = YES;
        self.isSettingsDisplayed = YES;
        self.mainMenuLayer.enableGestures = NO;
        [self disableAllMenus];
        [self.settingsLayer runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.25f position:ccp(0, [CCDirector sharedDirector].winSize.height)], [CCCallBlock actionWithBlock:^{
            self.mainMenuLayer.visible = NO;
            self.levelSelectionLayer.visible = NO;
        }], nil]];
    }
}

-(void)hideSettings {
    if (self.isSettingsDisplayed == YES) {
        self.mainMenuLayer.visible = YES;
        self.levelSelectionLayer.visible = YES;
        [self.settingsLayer runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.25f position:ccp(0, -1*[CCDirector sharedDirector].winSize.height)], [CCCallBlock actionWithBlock:^{
            self.settingsLayer.visible = NO;
            self.isSettingsDisplayed = NO;
            self.mainMenuLayer.enableGestures = YES;
            [self enableAllMenus];
        }], nil]];
    }
}

-(void)disableAllMenus {
    [self.mainMenuLayer disableAllMenus];
    [self.levelSelectionLayer disableAllMenus];
}

-(void)enableAllMenus {
    [self.mainMenuLayer enableAllMenus];
    [self.levelSelectionLayer enableAllMenus];
}

@end
