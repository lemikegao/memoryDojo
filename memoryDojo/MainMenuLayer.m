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

// game state
@property (nonatomic) BOOL enableGestures;
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
        
        self.ninja = [[Ninja alloc] initFromScene:kSceneTypeMainMenu];
        self.ninja.anchorPoint = ccp(0.5, 0);
        self.ninja.position = ccp(screenSize.width * 0.76f, screenSize.height * 0.25f);
        [self addChild:self.ninja z:100];
        
        // initialize upgrades (minus the aura, which has to be reinitialized in showUpgradesForLevel:)
        self.smallCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catsmall.png"];
        self.smallCat.anchorPoint = ccp(0.5, 0);
        self.smallCat.position = ccp(self.ninja.position.x * 0.50f, self.ninja.position.y * 1.05f);
        self.bigCat = [CCSprite spriteWithSpriteFrameName:@"mainmenu_upgrades_catbig.png"];
        self.bigCat.anchorPoint = ccp(0.5, 0);
        self.bigCat.position = ccp(self.ninja.position.x * 0.48f, self.ninja.position.y * 1.10f);
        
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

-(void)showUpgradesForLevel:(int)newLevel fromLevel:(int)oldLevel {
    if (oldLevel > newLevel) {
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
            self.auraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1.plist"];
            self.auraEmitter.position = ccp(self.ninja.position.x + self.ninja.boundingBox.size.width/8, self.ninja.position.y + self.ninja.boundingBox.size.height/2);
            [self addChild:self.auraEmitter z:10];
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
