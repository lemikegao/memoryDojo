//
//  MainMenuLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import "MainMenuLayer.h"
#import "Constants.h"
#import "GameManager.h"

@interface MainMenuLayer()

@property (nonatomic, strong) CCMenu *mainMenu;
-(void)playGameScene;
-(void)showAboutUs;
-(void)displayMainMenu;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art.plist"];
        CCSpriteBatchNode *mainmenuSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_art.pvr.ccz"];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        
        CCSprite *ninja = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja.png"];
        [mainmenuSpriteBatchNode addChild:ninja];
        ninja.position = ccp(screenSize.width * 0.67f, screenSize.height * 0.46f);
        
        [self addChild:mainmenuSpriteBatchNode];
        
        [self displayMainMenu];
    }
    
    return self;
}

-(void)playGameScene {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGame];
}

-(void)showAboutUs {
    // placeholder
}

-(void)displayMainMenu {
//    CGSize screenSize = [CCDirector sharedDirector].winSize;
//    
//    // selector needs to run GameScene
//    CCMenuItemImage *playGameButton = [CCMenuItemImage itemWithNormalImage:@"PlayGameButtonNormal.png" selectedImage:@"PlayGameButtonSelected.png" disabledImage:nil target:self selector:@selector(playGameScene)];
//    
//    CCMenuItemImage *aboutUsButton = [CCMenuItemImage itemWithNormalImage:@"BuyBookButtonNormal.png" selectedImage:@"BuyBookButtonSelected.png" disabledImage:nil target:self selector:@selector(showAboutUs)];
//    
//    self.mainMenu = [CCMenu menuWithItems:playGameButton, aboutUsButton, nil];
//    [self.mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.02f];
//    self.mainMenu.position = ccp(screenSize.width/2, screenSize.height * 0.15f);
//    
//    [self addChild:self.mainMenu z:0 tag:kMainMenuTagValue];
}

@end
