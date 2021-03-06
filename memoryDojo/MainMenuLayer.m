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
#import "Ninja.h"
#import "NinjaStar.h"
#import "Flurry.h"

@interface MainMenuLayer()

// game objects
@property (nonatomic, strong) Ninja *ninja;
@property (nonatomic, strong) CCArray *ninjaStars;
@property (nonatomic, strong) CCMenu *mainMenu;

// game state
@property (nonatomic) int nextInactiveNinjaStar;
@property (nonatomic) DirectionTypes lastDirection;

// upgrades
@property (nonatomic, strong) CCParticleSystem *auraEmitter;
@property (nonatomic, strong) CCSprite *smallCat;
@property (nonatomic, strong) CCSprite *bigCat;

// player input actions
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;

@end

@implementation MainMenuLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // add appropriate level upgrades
        int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
        self.enableGestures = YES;
        self.nextInactiveNinjaStar = 0;
        self.lastDirection = kDirectionTypeNone;
        
        // record duration of staying on main menu
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", ninjaLevel], @"Level", nil];
        [Flurry logEvent:@"On_MainMenu" withParameters:flurryParams timed:YES];
        
        // add background image
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithSpriteFrameName:@"mainmenu_bg.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background z:-1];
        
        // add Memory Dojo title
        CCSprite *gameTitle = [CCSprite spriteWithSpriteFrameName:@"mainmenu_game_title.png"];
        gameTitle.anchorPoint = ccp(1, 1);
        gameTitle.position = ccp(screenSize.width * 0.95f, screenSize.height * 0.97f);
        [self addChild:gameTitle];
        
        // add high score
        CCLabelBMFont *highScoreCopy = [CCLabelBMFont labelWithString:@"HIGH SCORE" fntFile:@"grobold_14px.fnt"];
        highScoreCopy.color = ccc3(104, 95, 82);
        highScoreCopy.anchorPoint = ccp(0, 1);
        highScoreCopy.position = ccp(screenSize.width * 0.05f, screenSize.height * 0.95f);
        [self addChild:highScoreCopy];
        
        CCLabelBMFont *highScoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].highScore] fntFile:@"grobold_25px.fnt"];
        highScoreLabel.color = ccc3(229, 214, 172);
        highScoreLabel.anchorPoint = ccp(0, 1);
        highScoreLabel.position = ccp(highScoreCopy.position.x, highScoreCopy.position.y - highScoreCopy.boundingBox.size.height * 1.1f);
        [self addChild:highScoreLabel];
        
        self.ninja = [[Ninja alloc] initFromScene:kSceneTypeMainMenu];
        self.ninja.anchorPoint = ccp(0.5, 0);
        self.ninja.position = ccp(screenSize.width * 0.76f, screenSize.height * 0.20f);
        [self addChild:self.ninja z:100];
        
        // initialize upgrades (minus the aura, which has to be reinitialized in showUpgradesForLevel:)
        self.smallCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catsmall.png"];
        self.smallCat.anchorPoint = ccp(0.5, 0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.smallCat.position = ccp(self.ninja.position.x * 0.58f, self.ninja.position.y * 1.05f);
        } else {
            self.smallCat.position = ccp(self.ninja.position.x * 0.50f, self.ninja.position.y * 1.05f);
        }
        self.bigCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catbig.png"];
        self.bigCat.anchorPoint = ccp(0.5, 0);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.bigCat.position = ccp(self.ninja.position.x * 0.54f, self.ninja.position.y * 1.10f);
        } else {
            self.bigCat.position = ccp(self.ninja.position.x * 0.48f, self.ninja.position.y * 1.10f);
        }
        
        [self showUpgradesForLevel:ninjaLevel fromLevel:1];
        
        [self displayMainMenu];
        [self scheduleUpdate];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeLeftRecognizer];
    
    self.swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipe)];
    self.swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeDownRecognizer];
    
    self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeRightRecognizer];
    
    self.swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwipe)];
    self.swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeUpRecognizer];
}

-(void)onExit {
    CCLOG(@"MainMenuLayer->onExit");
    [super onExit];
    
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeLeftRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeDownRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeRightRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeUpRecognizer];
}

-(void)handleLeftSwipe {
    if (self.enableGestures) {
        CCLOG(@"left swipe detected");
        [self.ninja changeState:kCharacterStateLeft];
        self.lastDirection = kDirectionTypeLeft;
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeLeft];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
    }
}

-(void)handleDownSwipe {
    if (self.enableGestures) {
        CCLOG(@"down swipe detected");
        [self.ninja changeState:kCharacterStateDown];
        self.lastDirection = kDirectionTypeDown;
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeDown];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
    }
}

-(void)handleRightSwipe {
    if (self.enableGestures) {
        CCLOG(@"right swipe detected");
        [self.ninja changeState:kCharacterStateRight];
        self.lastDirection = kDirectionTypeRight;
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeRight];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
    }
}

-(void)handleUpSwipe {
    if (self.enableGestures) {
        CCLOG(@"up swipe detected");
        [self.ninja changeState:kCharacterStateUp];
        self.lastDirection = kDirectionTypeUp;
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeUp];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
    }
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
    [self.mainMenuSceneDelegate showSettings];
}

-(void)displayMainMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    CCMenuItemImage *playGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_button_start_pressed.png"] target:self selector:@selector(playGameScene)];
    
    // add menu background (black bar)
    CCLayerColor *menuBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:playGameButton.boundingBox.size.height * 1.50f];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        menuBg.contentSize = CGSizeMake(screenSize.width, playGameButton.boundingBox.size.height * 1.13f);
    }
    menuBg.anchorPoint = ccp(0, 0);
    menuBg.position = ccp(0, 0);
    [self addChild:menuBg z:0];

    playGameButton.position = ccp(screenSize.width * 0.47f, menuBg.boundingBox.size.height/2);
    
    CCMenuItemImage *settingsButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_info.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_info_pressed.png"] target:self selector:@selector(showSettings)];
    settingsButton.position = ccp(screenSize.width * 0.87f, playGameButton.position.y);
    
    self.mainMenu = [CCMenu menuWithItems:playGameButton, settingsButton, nil];

    // set menu position at 0,0 so menu items can be set with a normal offset
    self.mainMenu.position = CGPointZero;
    
    [menuBg addChild:self.mainMenu];
}

-(void)disableAllMenus {
    self.mainMenu.isTouchEnabled = NO;
}

-(void)enableAllMenus {
    self.mainMenu.isTouchEnabled = YES;
}

-(void)showUpgradesForLevel:(int)newLevel fromLevel:(int)oldLevel {
    if (oldLevel > newLevel) {
        if (oldLevel == 6) {
            // switch back to ninja
            [self.ninja switchToNinjaWithDirection:self.lastDirection];
        }
        // remove upgrades
        switch (newLevel) {
            case 5:
                // placeholder for when there's a level 6 upgrade
                break;
            case 4:
                // replace big cat with small cat
                [self removeChild:self.bigCat cleanup:YES];
                [self addChild:self.smallCat z:95];
                break;
            case 3:
                // remove cat
                if (oldLevel >=5) {
                    [self removeChild:self.bigCat cleanup:YES];
                } else {
                    [self removeChild:self.smallCat cleanup:YES];
                }
                break;
            case 2:
                // remove appropriate cat
                if (oldLevel >=5) {
                    [self removeChild:self.bigCat cleanup:YES];
                } else if (oldLevel == 4) {
                    [self removeChild:self.smallCat cleanup:YES];
                }
                
                // remove ninja star
                [self.ninja removeNinjaStar];
                
                break;
            case 1:
                // remove appropriate cat
                if (oldLevel >=5) {
                    [self removeChild:self.bigCat cleanup:YES];
                } else if (oldLevel == 4) {
                    [self removeChild:self.smallCat cleanup:YES];
                }
                
                // remove ninja star if appropriate
                if (oldLevel >=3 ) {
                    [self.ninja removeNinjaStar];
                }
                
                // remove aura
                [self removeChild:self.auraEmitter cleanup:YES];
                break;
            default:
                CCLOG(@"Invalid level in MainMenuLayer->showUpgradesForLevel: %i", newLevel);
                break;
        }
    } else {
        // add upgrades
        if (oldLevel < 2 && newLevel >= 2) {
            // add aura behind ninja
            self.auraEmitter = [CCParticleSystemQuad particleWithFile:@"aura3_mainmenu.plist"];
            self.auraEmitter.position = ccp(self.ninja.position.x * 0.95f, self.ninja.position.y + self.ninja.boundingBox.size.height/2);
            [self addChild:self.auraEmitter z:10];
            // z:10
        }
        if (oldLevel < 3 && newLevel >= 3) {
            // add ninja star
            [self.ninja addNinjaStarWithDirection:self.lastDirection];
            [self addNinjaStarsUpgrade];
        }
        if (oldLevel < 4 && newLevel == 4) {
            // add small cat
            [self addChild:self.smallCat z:95];
        }
        if (oldLevel < 5 && newLevel >= 5) {
            // remove small cat if coming from level 4
            if (oldLevel == 4) {
                [self removeChild:self.smallCat cleanup:YES];
            }
            
            // add big cat
            [self addChild:self.bigCat z:95];
        }
        if (newLevel >= 6) {
            // placeholder for level 6 upgrade
            [self.ninja switchToSenseiWithDirection:self.lastDirection];
        }
    }
}

-(void)addNinjaStarsUpgrade {
    // init throwing ninja stars
    CCSpriteBatchNode *ninjaStarBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"mainmenu_art.pvr.ccz" capacity:8];
    [self addChild:ninjaStarBatchNode z:105];
    
    // Create a max of 8 throwing ninja stars on screen at one time
    for (int i=0; i<8; i++) {
        NinjaStar *ninjaStar = [[NinjaStar alloc] initFromScene:kSceneTypeMainMenu];
        [ninjaStarBatchNode addChild:ninjaStar];
    }
    
    self.ninjaStars = [ninjaStarBatchNode children];
    
    self.nextInactiveNinjaStar = 0;
}

-(void)update:(ccTime)deltaTime {
    [self.ninja updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
}

@end
