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
#import "MainMenuNinja.h"

@interface MainMenuLayer()

@property (nonatomic, strong) CCParticleSystem *confettiEmitter;
-(void)playGameScene;
-(void)showSettings;
-(void)displayMainMenu;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"mainmenu_art.plist"];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"mainmenu_bg.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background z:-1];
        
        CCSprite *gameTitle = [CCSprite spriteWithSpriteFrameName:@"mainmenu_game_title.png"];
        [self addChild:gameTitle];
        gameTitle.position = ccp(screenSize.width * 0.77f, screenSize.height * 0.85f);
        
        MainMenuNinja *ninja = [[MainMenuNinja alloc] init];
        ninja.position = ccp(screenSize.width * 0.612f, screenSize.height * 0.468f);
        [self addChild:ninja z:100];
        
        [self displayMainMenu];
        
        // add confetti
        self.confettiEmitter = [CCParticleSystemQuad particleWithFile:@"confetti.plist"];
        self.confettiEmitter.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:self.confettiEmitter z:10];
    }
    
    return self;
}

-(void)playGameScene {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGame];
}

-(void)showSettings {
    // placeholder
    CCLOG(@"settings button was pressed");
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    CCMenuItemImage *playGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start_pressed.png"] target:self selector:@selector(playGameScene)];
    playGameButton.position = ccp(screenSize.width * 0.44f, screenSize.height * 0.13f);
    
    // position ninja star relative to playGameButton
    CCSprite *ninjaStar = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja_star.png"];
    [self addChild:ninjaStar];
    ninjaStar.position = ccp(playGameButton.position.x * 0.42f, playGameButton.position.y * 1.27f);
    
    CCMenuItemImage *settingsButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_settings.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_settings_pressed.png"] target:self selector:@selector(showSettings)];
    settingsButton.position = ccp(screenSize.width * 0.87f, screenSize.height * 0.13f);
    
    CCMenu *mainMenu = [CCMenu menuWithItems:playGameButton, settingsButton, nil];

    // set menu position at 0,0 so menu items can be set with a normal offset
    mainMenu.position = CGPointZero;
    
    [self addChild:mainMenu];
}

@end
