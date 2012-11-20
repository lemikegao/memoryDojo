//
//  GameLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/19/12.
//
//

#import "GameLayer.h"
#import "Constants.h"
#import "GameManager.h"
#import "Ninja.h"
#import "Sensei.h"
#import "NinjaStar.h"

@interface GameLayer()

// game objects
@property (nonatomic, strong) Ninja *ninja;
@property (nonatomic, strong) Sensei *sensei;
@property (nonatomic, strong) CCArray *ninjaStars;

// game state
@property (nonatomic) BOOL isGamePaused;
@property (nonatomic) int roundNumber;
@property (nonatomic) GameStates currentGameState;
@property (nonatomic, strong) CCProgressTimer *timer;
@property (nonatomic) BOOL enableGestures;
@property (nonatomic) CGFloat timeToSubtractPerSecond;

// gameplay
@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic) int currentSequencePosition;
@property (nonatomic) int currentDisplaySequencePosition;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;

// sprite management -- not using tags anymore!
@property (nonatomic, strong) CCSprite *gameInstructions;
@property (nonatomic, strong) CCLabelBMFont *scoreLabel;
@property (nonatomic, strong) CCSprite *gameRoundBg;
@property (nonatomic, strong) CCSprite *gamePausedBg;
@property (nonatomic, strong) CCLayerColor *levelUpBg;
@property (nonatomic, strong) CCSprite *levelUpMessageBg;
@property (nonatomic, strong) CCParticleSystem *confettiEmitter;
@property (nonatomic, strong) CCParticleSystem *level2AuraEmitter;
@property (nonatomic) int nextInactiveNinjaStar;

-(void)initializeGame;
-(void)removeInstructions;
-(void)removeRoundPopup:(CCSprite*)roundBg;
-(void)displaySequence:(ccTime)deltaTime;
-(void)handleLeftSwipe;
-(void)handleDownSwipe;
-(void)handleRightSwipe;
-(void)handleUpSwipe;
-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction;
-(void)startNewRound;
-(void)showRoundLabelAfterNiceMessage;
-(void)pauseGame;
-(void)pauseAllSchedulerAndActions:(CCNode*)node;
-(void)addPausedMenuItems;
-(void)resumeGame;
-(void)resumeAllSchedulerAndActions:(CCNode*)node;
-(void)confirmRestartGame;
-(void)goBackToPausedMenu;
-(void)restartGame;
-(void)confirmQuitGame;
-(void)quitGame;
-(void)playGameOverScene;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_art.plist"];
        [self initializeGame];
    }
    
    return self;
}

-(void)initializeGame {
    // do not allow swipe input until sensei performs the sequence
    self.enableGestures = NO;
    
    // enable touch for level up transitions
    self.isTouchEnabled = YES;
    
    // game is not paused
    self.isGamePaused = NO;
    
    self.currentGameState = kGameStateIntro;
    
    [GameManager sharedGameManager].score = 0;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    // create topBar sprite for height; position screen separator in the middle below the top bar
    CCSprite *topBar = [CCSprite spriteWithSpriteFrameName:@"game_top_bar.png"];
    // save topBar width and height
    CGFloat topBarWidth = topBar.boundingBox.size.width;
    CGFloat topBarHeight = topBar.boundingBox.size.height;
    
    // add game screen separator
    CCSprite *screenSeparator = [CCSprite spriteWithSpriteFrameName:@"game_screen_separator.png"];
    screenSeparator.position = ccp(screenSize.width/2, (screenSize.height - topBar.boundingBox.size.height)/2);
    [self addChild:screenSeparator z:1];
    
    // add top background half
    CCSprite *backgroundTop = [CCSprite spriteWithSpriteFrameName:@"game_bg_top.png"];
    backgroundTop.anchorPoint = ccp(0, 0);
    backgroundTop.position = ccp(0, screenSeparator.position.y + screenSeparator.boundingBox.size.height/2);
    [self addChild:backgroundTop z:-1];
    
    // add top bar on top of background half
    topBar.anchorPoint = ccp(0, 0);
    topBar.position = ccp(0, screenSeparator.position.y + screenSeparator.boundingBox.size.height/2 + backgroundTop.boundingBox.size.height);
    [self addChild:topBar z:5];
    
    // add score to top bar
    CCSprite *scoreText = [CCSprite spriteWithSpriteFrameName:@"game_top_score.png"];
    scoreText.anchorPoint = ccp(0, 1);
    scoreText.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.90f);
    [topBar addChild:scoreText z:10];
    
    // reset score to 0
    [GameManager sharedGameManager].score = 0;
    self.scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score] fntFile:@"Score.fnt"];
    self.scoreLabel.anchorPoint = ccp(0, 1);
    self.scoreLabel.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.58f);
    [topBar addChild:self.scoreLabel z:10];
    
    // add time to top bar
    CCSprite *timeLabel = [CCSprite spriteWithSpriteFrameName:@"game_top_time.png"];
    timeLabel.anchorPoint = ccp(0, 1);
    timeLabel.position = ccp(topBarWidth * 0.30f, topBarHeight * 0.90f);
    [topBar addChild:timeLabel z:10];
    
    self.timer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_time_active.png"]];
    self.timer.type = kCCProgressTimerTypeBar;
    self.timer.anchorPoint = ccp(0, 1);
    self.timer.midpoint = ccp(0, 0.5f);
    self.timer.barChangeRate = ccp(1, 0);
    self.timer.percentage = 100;
    self.timer.position = ccp(topBarWidth * 0.30f, topBarHeight * 0.58f);
    [topBar addChild:self.timer z:10];
    
    // add pause button to top bar
    CCMenuItemImage *pauseGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_button_pause.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_button_pause_pressed.png"] target:self selector:@selector(pauseGame)];
    pauseGameButton.anchorPoint = ccp(1, 0.5);
    pauseGameButton.position = ccp(topBarWidth * 0.95f, topBarHeight * 0.50f);
    
    CCMenu *pauseMenu = [CCMenu menuWithItems:pauseGameButton, nil];
    pauseMenu.anchorPoint = ccp(0, 0);
    pauseMenu.position = CGPointZero;
    [topBar addChild:pauseMenu z:10];
    
    // add bottom background half below separator
    CCSprite *backgroundBottom = [CCSprite spriteWithSpriteFrameName:@"game_bg_bottom.png"];
    backgroundBottom.anchorPoint = ccp(0, 1);
    backgroundBottom.position = ccp(0, screenSeparator.position.y - screenSeparator.boundingBox.size.height/2);
    [self addChild:backgroundBottom z:-1];
    
    // initialize sensei
    self.sensei = [[Sensei alloc] init];
    self.sensei.position = ccp(screenSize.width/2, screenSize.height * 0.66f);
    [self addChild:self.sensei z:1];
    
    // initialize ninja
    self.ninja = [[Ninja alloc] init];
    self.ninja.position = ccp(screenSize.width/2, screenSize.height * 0.27f);
    [self addChild:self.ninja z:4];
    
    // add appropriate level upgrades
    int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
    
    if (ninjaLevel >= 2) {
        // add aura behind ninja
        self.level2AuraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1_game.plist"];
        self.level2AuraEmitter.position = ccp(self.ninja.position.x + self.ninja.boundingBox.size.width/8, self.ninja.position.y);
        [self addChild:self.level2AuraEmitter z:3];
    }
    if (ninjaLevel >= 3) {
        // add ninja star
        CCSprite *ninjaStar = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_ninjastar2.png"];
        ninjaStar.position = ccp(self.ninja.boundingBox.size.width * 0.33f, self.ninja.boundingBox.size.height * 0.275f);
        [self.ninja addChild:ninjaStar];
        
        // init throwing ninja stars
        CCSpriteBatchNode *ninjaStarBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art.pvr.ccz"];
        [self addChild:ninjaStarBatchNode z:10];
        
        // Create a max of 8 throwing ninja stars on screen at one time
        for (int i=0; i<8; i++) {
            NinjaStar *ninjaStar = [[NinjaStar alloc] init];
            [ninjaStarBatchNode addChild:ninjaStar];
        }
        
        self.ninjaStars = [ninjaStarBatchNode children];
        
        self.nextInactiveNinjaStar = 0;
    }
    
    // initialize sequence
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    self.sequence = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i=0; i<4; i++) {
//        self.sequence[i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
        self.sequence[i] = [NSNumber numberWithInt:kDirectionTypeUp];
        NSLog(@"sequence at %i: %@", i, self.sequence[i]);
    }
    
    self.roundNumber = 1;
    
    // display the rules then start the game!
    self.gameInstructions = [CCSprite spriteWithSpriteFrameName:@"game_instructions.png"];
    self.gameInstructions.anchorPoint = ccp(0.5f, 0);
    self.gameInstructions.position = ccp(screenSize.width/2, topBar.position.y);
    [self addChild:self.gameInstructions z:2];
    
    // display sequence after label disappears
    id moveGameInstructionsDown = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height * 0.60f)];
    id pauseGameInstructions = [CCDelayTime actionWithDuration:3.0f];
    id moveGameInstructionsUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, topBar.position.y)];
    id removeInstructions = [CCCallFunc actionWithTarget:self selector:@selector(removeInstructions)];
    id callStartDisplaySequenceSelector = [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)];
    
    id action = [CCSequence actions:moveGameInstructionsDown, pauseGameInstructions, moveGameInstructionsUp, removeInstructions, callStartDisplaySequenceSelector, nil];
    [self.gameInstructions runAction:action];
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
    CCLOG(@"GameLayer->onExit");
    [super onExit];
    
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeLeftRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeDownRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeRightRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeUpRecognizer];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // if game is displaying level up screen 1, transition to next level up screen
    if (self.currentGameState == kGameStateLevelUpScreen1) {
        [self showLevelUpAnimation];
    } else if (self.currentGameState == kGameStateLevelUpScreen2) {
        [self dismissLevelUpScreen];
        [self startNewRound];
    }
}

-(void)removeInstructions {
    [self.gameInstructions removeFromParentAndCleanup:YES];
}

-(void)removeRoundPopup:(CCSprite*)roundBg {
    [roundBg removeAllChildrenWithCleanup:YES];
    [self removeChild:roundBg cleanup:YES];
}

-(void)startDisplaySequenceSelector {
//    PLAYSOUNDEFFECT(GONG);
    
    // set timeToSubtractPerSecond
    // level 1 - round 1: 10 sec; +2 sec for each round
    // level 2 - round 1: 8 sec; +2 sec for each round
    // level 3 - round 1: 6 sec; +1.5 sec for each round
    // level 4 - round 1: 5 sec; +1.5 sec for each round
    // level 5 - round 1: 4 sec; +1 sec for each round
    // level 6 - round 1: 2 sec; +1 sec for each round
    
    CGFloat displaySequenceInterval;
    switch ([GameManager sharedGameManager].ninjaLevel) {
        case 1:
            displaySequenceInterval = 1.0;
            self.timeToSubtractPerSecond = 100/(10+(self.roundNumber-1)*2);
            break;
        case 2:
            displaySequenceInterval = 0.8;
            self.timeToSubtractPerSecond = 100/(8+(self.roundNumber-1)*2);
            break;
        case 3:
            displaySequenceInterval = 0.6;
            self.timeToSubtractPerSecond = 100/(6+(self.roundNumber-1)*1.5);
            break;
        case 4:
            displaySequenceInterval = 0.4;
            self.timeToSubtractPerSecond = 100/(5+(self.roundNumber-1)*1.5);
            break;
        case 5:
            displaySequenceInterval = 0.3;
            self.timeToSubtractPerSecond = 100/(4+(self.roundNumber-1)*1);
            break;
        case 6:
            displaySequenceInterval = 0.2;
            self.timeToSubtractPerSecond = 100/(2+(self.roundNumber-1)*1);
            break;
        default:
            CCLOG(@"level not supported in GameLayer.m, startDisplaySequenceSelector");
            displaySequenceInterval = 0.2;
            self.timeToSubtractPerSecond = 100/(2+(self.roundNumber-1));
            break;
    
    }
    [self schedule:@selector(displaySequence:) interval:displaySequenceInterval];
}

-(void)displaySequence:(ccTime)deltaTime {
    switch ([self.sequence[self.currentDisplaySequencePosition] intValue]) {
        case kDirectionTypeLeft:
            [self.sensei changeState:kCharacterStateLeft];
            break;
        case kDirectionTypeDown:
            [self.sensei changeState:kCharacterStateDown];
            break;
        case kDirectionTypeRight:
            [self.sensei changeState:kCharacterStateRight];
            break;
        case kDirectionTypeUp:
            [self.sensei changeState:kCharacterStateUp];
            break;
        default:
            CCLOG(@"Not a valid sequence direction to display");
            return;
            break;
    }
    
    self.currentDisplaySequencePosition++;
    
    if ([self.sequence count] == self.currentDisplaySequencePosition) {
        // no more sequence to display
        [self unschedule:@selector(displaySequence:)];
        
        // start gameplay
        
        self.enableGestures = YES;
        [self scheduleUpdate];
    }
}

-(void)handleLeftSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateLeft];
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeLeft];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
        [self checkIfSwipeIsCorrect:kDirectionTypeLeft];
    }
}

-(void)handleDownSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateDown];
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeDown];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
        [self checkIfSwipeIsCorrect:kDirectionTypeDown];
    }
}

-(void)handleRightSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateRight];
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeRight];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
        [self checkIfSwipeIsCorrect:kDirectionTypeRight];
    }
}

-(void)handleUpSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateUp];
        if ([GameManager sharedGameManager].ninjaLevel >= 3) {
            // throw ninja star
            NinjaStar *ninjaStar = (NinjaStar*)[self.ninjaStars objectAtIndex:self.nextInactiveNinjaStar];
            [ninjaStar shootNinjaStarFromNinja:self.ninja withDirection:kDirectionTypeUp];
            self.nextInactiveNinjaStar++;
            if (self.nextInactiveNinjaStar >= [self.ninjaStars count]) {
                self.nextInactiveNinjaStar = 0;
            }
        }
        [self checkIfSwipeIsCorrect:kDirectionTypeUp];
    }
}

-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction {
    if ([self.sequence[self.currentSequencePosition] intValue] == direction) {
        self.currentSequencePosition++;
        CCLOG(@"Correct swipe detected: %i", direction);
        [GameManager sharedGameManager].score = [GameManager sharedGameManager].score + [GameManager sharedGameManager].ninjaLevel;
        self.scoreLabel.string = [NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score];
    } else {
        CCLOG(@"You lose!");
        [self playGameOverScene];
    }
    
    // check if sequence is complete
    if ([self.sequence count] == (self.currentSequencePosition)) {
        int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
        BOOL shouldLevelUp = NO;
        switch (self.roundNumber) {
            case kGameLevel2Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel3Round:
                if (ninjaLevel == 2) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel4Round:
                if (ninjaLevel == 3) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel5Round:
                if (ninjaLevel == 4) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel6Round:
                if (ninjaLevel == 5) {
                    shouldLevelUp = YES;
                }
                break;
                
            default:
                break;
        }
        
        if (shouldLevelUp == YES) {
            [self ninjaLevelUp];
        } else {
            [self startNewRound];
        }
    }
}

-(void)ninjaLevelUp {
    // stop gameplay
    self.enableGestures = NO;
    [self unscheduleUpdate];
    
    // increase ninja level
    [GameManager sharedGameManager].ninjaLevel++;
    
    [self setUpLevelUpScreen];
    
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    
    // add level up message header
    CCLabelBMFont *levelUpMessageHeader = [CCLabelBMFont labelWithString:@"HEY LOOK!" fntFile:@"game_levelup_header.fnt"];
    levelUpMessageHeader.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.70f);
    [self.levelUpMessageBg addChild:levelUpMessageHeader];
    
    CCLabelBMFont *levelUpMessageBody = [CCLabelBMFont labelWithString:@"SOMETHING SEEMS TO BE HAPPENING!" fntFile:@"game_levelup_body.fnt" width:levelUpMessageBgSize.width * 0.60 alignment:kCCTextAlignmentCenter];
    levelUpMessageBody.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.40f);
    [self.levelUpMessageBg addChild:levelUpMessageBody];
    
    self.currentGameState = kGameStateLevelUpScreen1;
}

-(void)showLevelUpAnimation {
    // dismiss messages and show ninja
    self.currentGameState = kGameStateLevelUpAnimation;
    [self dismissLevelUpScreen];
    
    id upgradeToBlink = nil;
    switch ([GameManager sharedGameManager].ninjaLevel) {
        case 2:
        {
            // add aura
            self.level2AuraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1_game.plist"];
            self.level2AuraEmitter.position = ccp(self.ninja.position.x + self.ninja.boundingBox.size.width/8, self.ninja.position.y);
            self.level2AuraEmitter.visible = NO;
            [self addChild:self.level2AuraEmitter z:3];
            upgradeToBlink = self.level2AuraEmitter;
            
            break;
        }
            
        case 3:
        {
            // add ninja star
            CCSprite *ninjaStar = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_ninjastar2.png"];
            ninjaStar.position = ccp(self.ninja.boundingBox.size.width * 0.33f, self.ninja.boundingBox.size.height * 0.275f);
            ninjaStar.visible = NO;
            [self.ninja addChild:ninjaStar];
            upgradeToBlink = ninjaStar;
            
            break;
        }
            
        default:
        {
            CCLOG(@"Level not recognized in GameLayer.m, showLevelUpAnimation");
            break;
        }
    }
    
    if (upgradeToBlink != nil) {
        [upgradeToBlink runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCBlink actionWithDuration:1 blinks:5], [CCDelayTime actionWithDuration:1.5f], [CCCallFunc actionWithTarget:self selector:@selector(showNinjaLevelUpScreen2)], nil]];
    }
}

-(void)showNinjaLevelUpScreen2 {
    [self setUpLevelUpScreen];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    
    // add new level up messages
    CCLabelBMFont *levelUpMessageBody = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"YOU ARE NOW SUPER NINJA LEVEL %i!", [GameManager sharedGameManager].ninjaLevel] fntFile:@"game_levelup_header.fnt" width:levelUpMessageBgSize.width * 0.70f alignment:kCCTextAlignmentCenter];
    levelUpMessageBody.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height/2);
    [self.levelUpMessageBg addChild:levelUpMessageBody];
    
    // add confetti
    self.confettiEmitter = [CCParticleSystemQuad particleWithFile:@"confetti.plist"];
    self.confettiEmitter.position = ccp(screenSize.width/2, screenSize.height/2);
    [self.levelUpBg addChild:self.confettiEmitter z:3];
    
    self.currentGameState = kGameStateLevelUpScreen2;
}

-(void)setUpLevelUpScreen {
    // add background color layer first
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    self.levelUpBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:screenSize.height];
    [self addChild:self.levelUpBg z:150];
    
    // add rays to sprite batch node
    CGPoint screenMidpoint = ccp(screenSize.width/2, screenSize.height/2);
    CCSpriteBatchNode *rayBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art.pvr.ccz"];
    rayBatchNode.position = screenMidpoint;
    
    float rayAngle = 0;
    while (rayAngle < 360) {
        CCSprite *ray = [CCSprite spriteWithSpriteFrameName:@"game_transition_ray.png"];
        ray.anchorPoint = ccp(0.5, 0);
        ray.rotation = rayAngle;
        ray.position = CGPointZero;
        [rayBatchNode addChild:ray];
        
        // next ray is 40 degrees apart
        rayAngle = rayAngle + 40;
    }
    
    [self.levelUpBg addChild:rayBatchNode z:1];
    
    // spin the ray batch node
    //    id rotateRayAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1f], [CCRotateBy actionWithDuration:0.1f angle:10], nil]];
    id rotateRayAction = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:40]];
    [rayBatchNode runAction:rotateRayAction];
    
    // add level up message bg
    self.levelUpMessageBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
    self.levelUpMessageBg.position = screenMidpoint;
    [self.levelUpBg addChild:self.levelUpMessageBg z:5];
}

-(void)dismissLevelUpScreen {
    [self.levelUpBg removeAllChildrenWithCleanup:YES];
    [self.levelUpBg removeFromParentAndCleanup:YES];
}

-(void)startNewRound {
    self.enableGestures = NO;
    [self unscheduleUpdate];
    self.timer.percentage = 100;
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    self.currentGameState = kGameStatePlay;
    
    int currentSequenceLength = [self.sequence count];
    for (int i=0; i<2; i++) {
//        self.sequence[currentSequenceLength + i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
        self.sequence[currentSequenceLength + i] = [NSNumber numberWithInt:kDirectionTypeUp];
        NSLog(@"sequence at %i: %@", currentSequenceLength + i, self.sequence[currentSequenceLength + i]);
    }

    // show new round indicator
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    self.gameRoundBg = [CCSprite spriteWithSpriteFrameName:@"game_rounds_bg.png"];
    self.gameRoundBg .position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:self.gameRoundBg  z:100];
    
    // add 'nice!' message if player finished round 1
    if (self.roundNumber == 1) {
        self.roundNumber++;
        CCLabelBMFont *niceLabel = [CCLabelBMFont labelWithString:@"Nice!" fntFile:@"Round.fnt"];
        niceLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height/2);
        [self.gameRoundBg addChild:niceLabel];
        id niceLabelBgAction = [CCFadeIn actionWithDuration:1.0f];
        id niceLabelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFunc actionWithTarget:self selector:@selector(showRoundLabelAfterNiceMessage)], nil];
        [self.gameRoundBg runAction:niceLabelBgAction];
        [niceLabel runAction:niceLabelAction];
    } else {
        self.roundNumber++;
        CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Round %i", self.roundNumber] fntFile:@"Round.fnt"];
        newRoundLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height/2);
        [self.gameRoundBg addChild:newRoundLabel];
        
        
        id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], nil];
        
        // have sensei perform new sequence
        id labelBgAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
        
        [newRoundLabel runAction:labelAction];
        [self.gameRoundBg runAction:labelBgAction];
    }
}

-(void)showRoundLabelAfterNiceMessage {
    CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Round %i", self.roundNumber] fntFile:@"Round.fnt"];
    newRoundLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height/2);
    [self.gameRoundBg addChild:newRoundLabel];
    
    
    id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], nil];
    
    // have sensei perform new sequence
    id labelBgAction = [CCSequence actions:[CCDelayTime actionWithDuration:3.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
    
    [newRoundLabel runAction:labelAction];
    [self.gameRoundBg runAction:labelBgAction];
}

-(void)pauseGame {
    if (self.isGamePaused == NO) {
        self.isGamePaused = YES;
        [self pauseSchedulerAndActions];
        for (CCNode *node in [self children]) {
            [self pauseAllSchedulerAndActions:node];
        }
        
        // show paused menu
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        self.gamePausedBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
        self.gamePausedBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:self.gamePausedBg z:100];
        [self addPausedMenuItems];
    }
}

-(void)pauseAllSchedulerAndActions:(CCNode*)node {
    [node pauseSchedulerAndActions];
    for (CCNode *nodeChild in [node children]) {
        if (nodeChild.children) {
            [self pauseAllSchedulerAndActions:nodeChild];
        } else {
            [nodeChild pauseSchedulerAndActions];
        }
    }
}

-(void)addPausedMenuItems {
    CGFloat pausedBgHeight = self.gamePausedBg.boundingBox.size.height;
    CGFloat pausedBgWidth = self.gamePausedBg.boundingBox.size.width;
    
    // add game paused label
    CCSprite *pausedText = [CCSprite spriteWithSpriteFrameName:@"game_paused_text.png"];
    pausedText.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.88f);
    [self.gamePausedBg addChild:pausedText];
    
    // add game paused separator
    CCSprite *pausedSeparator = [CCSprite spriteWithSpriteFrameName:@"game_paused_line.png"];
    pausedSeparator.position = ccp(pausedBgWidth * 0.55f, pausedBgHeight * 0.77f);
    [self.gamePausedBg addChild:pausedSeparator];
    
    // create game paused resume button
    CCMenuItemImage *pausedResumeButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_resume.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_resume_pressed.png"] target:self selector:@selector(resumeGame)];
    pausedResumeButton.anchorPoint = ccp(0, 0.5f);
    
    // create game paused restart button
    CCMenuItemImage *pausedRestartButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_restart.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_restart_pressed.png"] target:self selector:@selector(confirmRestartGame)];
    pausedRestartButton.anchorPoint = ccp(0, 0.5f);
    
    CCMenuItemImage *pausedQuitButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit_pressed.png"] target:self selector:@selector(confirmQuitGame)];
    pausedQuitButton.anchorPoint = ccp(0, 0.5f);
    
    CCMenu *pausedMenu = [CCMenu menuWithItems:pausedResumeButton, pausedRestartButton, pausedQuitButton, nil];
    [pausedMenu alignItemsVerticallyWithPadding:pausedBgHeight * 0.085f];
    pausedMenu.anchorPoint = ccp(0, 0.5);
    pausedMenu.position = ccp(pausedBgWidth * 0.23f, pausedBgHeight * 0.44f);
    [self.gamePausedBg addChild:pausedMenu z:10];
}

-(void)resumeGame {
    if (self.isGamePaused == YES) {
        self.isGamePaused = NO;
        [self resumeSchedulerAndActions];
        for (CCNode *node in [self children]) {
            [self resumeAllSchedulerAndActions:node];
        }
    }
    
    // remove paused menu from self
    [self.gamePausedBg removeFromParentAndCleanup:YES];
}

-(void)resumeAllSchedulerAndActions:(CCNode*)node {
    [node resumeSchedulerAndActions];
    for (CCNode *nodeChild in [node children]) {
        if (nodeChild.children) {
            [self resumeAllSchedulerAndActions:nodeChild];
        } else {
            [nodeChild resumeSchedulerAndActions];
        }
    }
}

-(void)confirmRestartGame {
    CGFloat pausedBgWidth = self.gamePausedBg.boundingBox.size.width;
    CGFloat pausedBgHeight = self.gamePausedBg.boundingBox.size.height;
    
    // remove all children from pausedBg first
    [self.gamePausedBg removeAllChildrenWithCleanup:YES];
    
    // add restart confirmation text
    CCSprite *pausedRestartConfirmation = [CCSprite spriteWithSpriteFrameName:@"game_paused_restartconfirmation_text.png"];
    pausedRestartConfirmation.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.73f);
    [self.gamePausedBg addChild:pausedRestartConfirmation];
    
    // add no or yes options
    CCMenuItemImage *pausedButtonNo = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no_pressed.png"] target:self selector:@selector(goBackToPausedMenu)];
    pausedButtonNo.anchorPoint = ccp(0.5f, 0);
    
    CCMenuItemImage *pausedButtonYes = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes_pressed.png"] target:self selector:@selector(restartGame)];
    pausedButtonYes.anchorPoint = ccp(0.5f, 0);
    
    CCMenu *pausedMenuRestartConfirmation = [CCMenu menuWithItems:pausedButtonNo, pausedButtonYes, nil];
    [pausedMenuRestartConfirmation alignItemsHorizontallyWithPadding:pausedBgWidth * 0.2f];
    pausedMenuRestartConfirmation.anchorPoint = ccp(0.5f, 0);
    pausedMenuRestartConfirmation.position = ccp(pausedBgWidth * 0.5f, pausedBgHeight * 0.30f);
    [self.gamePausedBg addChild:pausedMenuRestartConfirmation z:10];
}

-(void)goBackToPausedMenu {
    [self.gamePausedBg removeAllChildrenWithCleanup:YES];
    
    [self addPausedMenuItems];
}

-(void)restartGame {
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [self initializeGame];
}

-(void)confirmQuitGame {
    CGFloat pausedBgWidth = self.gamePausedBg.boundingBox.size.width;
    CGFloat pausedBgHeight = self.gamePausedBg.boundingBox.size.height;
    
    // remove all children from pausedBg first
    [self.gamePausedBg removeAllChildrenWithCleanup:YES];
    
    // add restart confirmation text
    CCSprite *pausedQuitConfirmation = [CCSprite spriteWithSpriteFrameName:@"game_paused_quitconfirmation_text.png"];
    pausedQuitConfirmation.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.73f);
    [self.gamePausedBg addChild:pausedQuitConfirmation];
    
    // add no or yes options
    CCMenuItemImage *pausedButtonNo = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no_pressed.png"] target:self selector:@selector(goBackToPausedMenu)];
    pausedButtonNo.anchorPoint = ccp(0.5f, 0);
    
    CCMenuItemImage *pausedButtonYes = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes_pressed.png"] target:self selector:@selector(quitGame)];
    pausedButtonYes.anchorPoint = ccp(0.5f, 0);
    
    CCMenu *pausedMenuRestartConfirmation = [CCMenu menuWithItems:pausedButtonNo, pausedButtonYes, nil];
    [pausedMenuRestartConfirmation alignItemsHorizontallyWithPadding:pausedBgWidth * 0.2f];
    pausedMenuRestartConfirmation.anchorPoint = ccp(0.5f, 0);
    pausedMenuRestartConfirmation.position = ccp(pausedBgWidth * 0.5f, pausedBgHeight * 0.30f);
    [self.gamePausedBg addChild:pausedMenuRestartConfirmation z:10];
}

-(void)quitGame {
    // go back to main menu
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

-(void)playGameOverScene {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGameOver];
}

-(void)update:(ccTime)deltaTime {
    [self.ninja updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    [self.sensei updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    
    // level 1 - round 1: 10 sec; +2 sec for each round
    // level 2 - round 1: 8 sec; +2 sec for each round
    // level 3 - round 1: 6 sec; +1.5 sec for each round
    // level 4 - round 1: 5 sec; +1.5 sec for each round
    // level 5 - round 1: 4 sec; +1.5 sec for each round
    // level 6 - round 1: 4 sec; +1 sec for each round
    self.timer.percentage -= self.timeToSubtractPerSecond/60.0f;
    if (self.timer.percentage <= 0) {
        [self playGameOverScene];
    }
}

@end
