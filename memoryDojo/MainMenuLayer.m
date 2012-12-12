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
#import "Flurry.h"

@interface MainMenuLayer()

@property (nonatomic, strong) CCParticleSystem *auraEmitter;
-(void)playGameScene;
-(void)showSettings;
-(void)displayMainMenu;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // add appropriate level upgrades
        int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
        
        // record duration of staying on main menu
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", ninjaLevel], @"Level", nil];
        [Flurry logEvent:@"On_MainMenu" withParameters:flurryParams timed:YES];
        
        // add background image
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"mainmenu_bg.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background z:-1];
        
        // add menu background (black bar)
#warning - modify position for iphone 4 and 5
        CCLayerColor *menuBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:60];
        menuBg.anchorPoint = ccp(0, 0);
        menuBg.position = ccp(0, 44);
        [self addChild:menuBg z:0];
        
        // add Memory Dojo title
        CCSprite *gameTitle = [CCSprite spriteWithSpriteFrameName:@"mainmenu_game_title.png"];
        gameTitle.anchorPoint = ccp(1, 1);
        gameTitle.position = ccp(screenSize.width * 0.95f, screenSize.height * 0.90f);
        [self addChild:gameTitle];
        
        // add high score
        CCLabelBMFont *highScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].highScore] fntFile:@"grobold_25px_nostroke.fnt"];
        highScoreLabel.color = ccc3(229, 214, 172);
        highScoreLabel.anchorPoint = ccp(0, 0.5);
        highScoreLabel.position = ccp(screenSize.width * 0.05f, screenSize.height * 0.84f);
        [self addChild:highScoreLabel];
        
        MainMenuNinja *ninja = [[MainMenuNinja alloc] init];
        ninja.position = ccp(screenSize.width * 0.76f, screenSize.height * 0.50f);
        [self addChild:ninja z:100];
        
        if (ninjaLevel >= 2) {
            // add aura behind ninja
            self.auraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1.plist"];
            self.auraEmitter.position = ccp(ninja.position.x + ninja.boundingBox.size.width/8, ninja.position.y);
            [self addChild:self.auraEmitter z:10];
        }
        if (ninjaLevel >= 3) {
            // add ninja star
            CCSprite *ninjaStar = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_ninjastar2.png"];
            ninjaStar.position = ccp(ninja.boundingBox.size.width * 0.33f, ninja.boundingBox.size.height * 0.285f);
            [ninja addChild:ninjaStar];
        }
        if (ninjaLevel == 4) {
            // add small cat
            CCSprite *smallCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catsmall.png"];
            smallCat.position = ccp(ninja.position.x * 0.50f, ninja.position.y * 0.78f);
            [self addChild:smallCat z:95];
        }
        if (ninjaLevel >= 5) {
            // add big cat
            CCSprite *bigCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catbig.png"];
            bigCat.position = ccp(ninja.position.x * 0.48f, ninja.position.y * 0.83f);
            [self addChild:bigCat z:95];
        }
        
        [self displayMainMenu];
    }
    
    return self;
}

-(void)playGameScene {
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
    [Flurry logEvent:@"Clicked_Play_Game" withParameters:flurryParams];
    [Flurry endTimedEvent:@"On_MainMenu" withParameters:nil];
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGame];
}

-(void)showSettings {
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
    [Flurry logEvent:@"Clicked_Settings" withParameters:flurryParams];
    // placeholder
    CCLOG(@"settings button was pressed");
}

-(void)selectLevel:(int)level {
    CCLOG(@"select level: %i", level);
}

-(void)showSelectLevelMenu {
    
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    CCMenuItemImage *playGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start_pressed.png"] target:self selector:@selector(playGameScene)];
    playGameButton.position = ccp(screenSize.width * 0.44f, screenSize.height * 0.13f);
    
    CCMenuItemImage *settingsButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_settings.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_settings_pressed.png"] target:self selector:@selector(showSettings)];
    settingsButton.position = ccp(screenSize.width * 0.87f, screenSize.height * 0.13f);
    
    CCMenu *mainMenu = [CCMenu menuWithItems:playGameButton, settingsButton, nil];

    // set menu position at 0,0 so menu items can be set with a normal offset
    mainMenu.position = CGPointZero;
    
    [self addChild:mainMenu];
}

@end
