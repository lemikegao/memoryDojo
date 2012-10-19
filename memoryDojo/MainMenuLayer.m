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

@synthesize mainMenu = _mainMenu;

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        [self displayMainMenu];
        
        CCSprite *ninja = [CCSprite spriteWithFile:@"louie_dribble.png"];
        ninja.position = ccp(screenSize.width/2, screenSize.height * 0.65f);
        [self addChild:ninja];
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
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // selector needs to run GameScene
    CCMenuItemImage *playGameButton = [CCMenuItemImage itemWithNormalImage:@"PlayGameButtonNormal.png" selectedImage:@"PlayGameButtonSelected.png" disabledImage:nil target:self selector:@selector(playGameScene)];
    
    CCMenuItemImage *aboutUsButton = [CCMenuItemImage itemWithNormalImage:@"BuyBookButtonNormal.png" selectedImage:@"BuyBookButtonSelected.png" disabledImage:nil target:self selector:@selector(showAboutUs)];
    
    self.mainMenu = [CCMenu menuWithItems:playGameButton, aboutUsButton, nil];
    [self.mainMenu alignItemsVerticallyWithPadding:screenSize.height * 0.02f];
    self.mainMenu.position = ccp(screenSize.width/2, screenSize.height * 0.15f);
    
    [self addChild:self.mainMenu z:0 tag:kMainMenuTagValue];
}

@end
