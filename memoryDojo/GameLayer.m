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
#import "Flurry.h"

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
@property (nonatomic) CGFloat timeArrowsHidden;
@property (nonatomic) BOOL didBeatHighScore;
@property (nonatomic) CGFloat secondsIdle;
@property (nonatomic) DirectionTypes directionForLevelUp;

// gameplay
@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic) int currentSequencePosition;
@property (nonatomic) int currentDisplaySequencePosition;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;

// sprite management -- not using tags anymore!
@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSprite *gameInstructions;
@property (nonatomic, strong) CCLabelBMFont *scoreLabel;
@property (nonatomic, strong) CCSprite *gameRoundBg;
@property (nonatomic, strong) CCSprite *gamePausedBg;
@property (nonatomic, strong) CCLayerColor *levelUpBg;
@property (nonatomic, strong) CCSprite *levelUpMessageBg;
@property (nonatomic, strong) CCParticleSystem *confettiEmitter;
@property (nonatomic, strong) CCParticleSystem *level2AuraEmitter;
@property (nonatomic) int nextInactiveNinjaStar;
@property (nonatomic, strong) CCSpriteBatchNode *sequenceArrowsBatch;
@property (nonatomic, strong) CCSprite *smallCat;
@property (nonatomic, strong) CCLayerColor *dimLayer;
@property (nonatomic, strong) CCLayerColor *waitDimLayer;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // record duration of staying on main menu
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
        [Flurry logEvent:@"Playing_Game" withParameters:flurryParams timed:YES];
        
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_art_bg.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_art.plist"];
        self.sequenceArrowsBatch = [CCSpriteBatchNode batchNodeWithFile:@"game_art.pvr.ccz"];
        [self initializeGame];
    }
    
    return self;
}

-(void)initializeSequence {
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    self.sequence = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i=0; i<4; i++) {
        self.sequence[i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
//        self.sequence[i] = [NSNumber numberWithInt:kDirectionTypeUp];
        NSLog(@"sequence at %i: %@", i, self.sequence[i]);
    }
    
    self.roundNumber = 1;
}

-(void)initializeGame {
    // do not allow swipe input until sensei performs the sequence
    self.enableGestures = NO;
    
    // enable touch for level up transitions
    self.isTouchEnabled = YES;
    
    // game is not paused
    self.isGamePaused = NO;
    
    self.didBeatHighScore = NO;
    
    self.currentGameState = kGameStateInit;
    
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
    self.scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score] fntFile:@"grobold_17px.fnt"];
    self.scoreLabel.color = ccc3(229, 214, 172);
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
    self.sensei.position = ccp(screenSize.width/2, screenSize.height * 0.63f);
    [self addChild:self.sensei z:1];
    
    // initialize ninja
    self.ninja = [[Ninja alloc] initFromScene:kSceneTypeGame];
    self.ninja.anchorPoint = ccp(0.5, 0);
    self.ninja.position = ccp(screenSize.width/2, screenSize.height * 0.10f);
    [self addChild:self.ninja z:4];
    
    // add appropriate level upgrades
    int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
    
    if (ninjaLevel >= 2) {
        // add aura behind ninja
        self.level2AuraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1_game.plist"];
        self.level2AuraEmitter.position = ccp(self.ninja.position.x + self.ninja.boundingBox.size.width/8, self.ninja.position.y + self.ninja.boundingBox.size.height/2);
        [self addChild:self.level2AuraEmitter z:2];
    }
    if (ninjaLevel >= 3) {
        // add ninja star
        [self.ninja addNinjaStarWithDirection:kDirectionTypeNone];
        [self addNinjaStarsUpgrade];
    }
    if (ninjaLevel == 4) {
        // add small cat
        self.smallCat = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_cat_small.png"];
        self.smallCat.position = ccp(self.ninja.position.x * 0.33f, self.ninja.position.y * 2.20f);
        [self addChild:self.smallCat z:3];
    }
    if (ninjaLevel >= 5) {
        // add big cat
        CCSprite *bigCat = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_cat_big.png"];
        bigCat.position = ccp(self.ninja.position.x * 0.297f, self.ninja.position.y * 2.40f);
        [self addChild:bigCat z:3];
    }
    
    // initialize sequence
    [self initializeSequence];
    
    // add WATCH SENSEI message bg
    self.waitDimLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 220) width:self.screenSize.width height:self.screenSize.height * 0.46f];
    [self addChild:self.waitDimLayer z:90];
    
    [self addWatchSenseiMessage];
    
    // display the rules then start the game!
    self.gameInstructions = [CCSprite spriteWithSpriteFrameName:@"game_instructions.png"];
    self.gameInstructions.anchorPoint = ccp(0.5f, 0);
    self.gameInstructions.position = ccp(screenSize.width/2, screenSize.height);
    [self addChild:self.gameInstructions z:2];
    
    // add sequence arrows batch node
    [self addChild:self.sequenceArrowsBatch];
#warning - any way to reset position of arrows without CCMoveTo action? lame hack
    [self.sequenceArrowsBatch runAction:[CCMoveTo actionWithDuration:0.1f position:CGPointZero]];
    
    // display sequence after label disappears
    id moveGameInstructionsDown = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height * 0.60f)];
    id setGameStateToInstructions = [CCCallBlock actionWithBlock:^{
        self.currentGameState = kGameStateInstructions;
    }];
    id pauseGameInstructions = [CCDelayTime actionWithDuration:3.0f];
    id moveGameInstructionsUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, topBar.position.y)];
    id removeInstructions = [CCCallFunc actionWithTarget:self selector:@selector(removeInstructions)];
    id callStartDisplaySequenceSelector = [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)];
    
    id action = [CCSequence actions:moveGameInstructionsDown, setGameStateToInstructions, pauseGameInstructions, moveGameInstructionsUp, removeInstructions, callStartDisplaySequenceSelector, nil];
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
    if (self.isGamePaused == NO) {
        // begin game if user inputs a touch during instructions
        if (self.currentGameState == kGameStateInstructions) {
            CGSize screenSize = [CCDirector sharedDirector].winSize;
            self.currentGameState = kGameStateInit;
            [self.gameInstructions stopAllActions];
            id moveGameInstructionsUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height)];
            id removeInstructions = [CCCallFunc actionWithTarget:self selector:@selector(removeInstructions)];
            id callStartDisplaySequenceSelector = [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)];
            
            id action = [CCSequence actions:moveGameInstructionsUp, removeInstructions, callStartDisplaySequenceSelector, nil];
            [self.gameInstructions runAction:action];
        }
        // dismiss round label if user inputs a touch
        else if (self.currentGameState == kGameStateRoundDisplay) {
            self.currentGameState = kGameStatePlay;
            id labelBgAction = [CCSequence actions:[CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
            id labelAction = [CCFadeOut actionWithDuration:0.5f];
            
            [self.gameRoundBg stopAllActions];
            for (CCNode *child in self.gameRoundBg.children) {
                [child stopAllActions];
            }
            
            // fade out bg and children labels
            [self.gameRoundBg runAction:labelBgAction];
            for (CCNode *child in self.gameRoundBg.children) {
                [child runAction:[labelAction copy]];
            }
        }
        // if game is displaying level up screen 1, transition to next level up screen
        else if (self.currentGameState == kGameStateLevelUpScreen1) {
            if ([GameManager sharedGameManager].ninjaLevel == 4) {
                // no upgrade animation -- show sensei gift screen
                [self showSenseiGiftScreen];
            } else {
                [self showLevelUpAnimation];
            }
        }
        else if (self.currentGameState == kGameStateLevelUpGiftScreen) {
            // show small cat
            [self showSmallCatScreen];
        }
        else if (self.currentGameState == kGameStateLevelUpSmallCatScreen) {
            [self showNinjaLevelUpScreen2FromCatScreen];
        }
        else if (self.currentGameState == kGameStateLevelUpScreen2) {
            [self dismissLevelUpScreen];
    //        [self startNewRound];
            [self resetSequenceAfterLevelUp];
        }
    }
}

-(void)removeInstructions {
    [self.gameInstructions removeFromParentAndCleanup:YES];
}

-(void)removeRoundPopup:(CCSprite*)roundBg {
    [roundBg removeAllChildrenWithCleanup:YES];
    [self removeChild:roundBg cleanup:YES];
}

-(void)resetSequenceAfterLevelUp {
    [self initializeSequence];
    
    self.enableGestures = NO;
    [self unscheduleUpdate];
    self.timer.percentage = 100;
    self.currentGameState = kGameStatePlay;
    self.timeArrowsHidden = 0;
    
    // remove arrows from batch node
    [self.sequenceArrowsBatch removeAllChildrenWithCleanup:YES];
    // reset batch node position
# warning - replace move action with setting position
    [self.sequenceArrowsBatch runAction:[CCMoveTo actionWithDuration:0.1f position:CGPointZero]];
    
    // add WATCH SENSEI message
    [self.waitDimLayer removeAllChildrenWithCleanup:YES];
    self.waitDimLayer.opacity = 220;
    [self addWatchSenseiMessage];
    
    // show new round indicator
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    self.gameRoundBg = [CCSprite spriteWithSpriteFrameName:@"game_rounds_bg.png"];
    self.gameRoundBg .position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:self.gameRoundBg  z:100];
    
    CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"ROUND %i", self.roundNumber] fntFile:@"grobold_35px.fnt"];
    newRoundLabel.color = ccc3(153, 136, 94);
    newRoundLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height/2);
    [self.gameRoundBg addChild:newRoundLabel];
    
    
    id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCCallBlock actionWithBlock:^{
        self.currentGameState = kGameStateRoundDisplay;
    }], [CCDelayTime actionWithDuration:2.0f], [CCCallBlock actionWithBlock:^{
        self.currentGameState = kGameStatePlay;
    }], [CCFadeOut actionWithDuration:0.5f], nil];
    
    // have sensei perform new sequence
    id labelBgAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
    
    [newRoundLabel runAction:labelAction];
    [self.gameRoundBg runAction:labelBgAction];
}

-(void)addWatchSenseiMessage {
    // add WATCH SENSEI message
    CCLabelBMFont *waitLabel = [CCLabelBMFont labelWithString:@"WATCH SENSEI" fntFile:@"grobold_25px_nostroke.fnt"];
    waitLabel.color = ccc3(229, 214, 172);
    waitLabel.position = ccp(self.waitDimLayer.boundingBox.size.width/2, self.waitDimLayer.boundingBox.size.height * 0.60f);
    [self.waitDimLayer addChild:waitLabel];
    
    // add arrow
    CCSprite *waitArrow = [CCSprite spriteWithSpriteFrameName:@"game_wait_arrow.png"];
    waitArrow.anchorPoint = ccp(0.5, 0);
    waitArrow.position = ccp(waitLabel.position.x + waitLabel.boundingBox.size.width * 0.52f, waitLabel.position.y);
    [self.waitDimLayer addChild:waitArrow];
}

-(void)startDisplaySequenceSelector {
    self.sequenceArrowsBatch.visible = YES;
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
            displaySequenceInterval = 0.65;
            self.timeToSubtractPerSecond = 100/(10+(self.roundNumber-1)*2);
            break;
        case 2:
            displaySequenceInterval = 0.6;
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
    // add arrow + animate sensei
    switch ([self.sequence[self.currentDisplaySequencePosition] intValue]) {
        case kDirectionTypeLeft:
        {
            CCSprite *arrow = [CCSprite spriteWithSpriteFrameName:@"game_arrow_left.png"];
            arrow.anchorPoint = ccp(0, 0.5);
            arrow.position = ccp(self.screenSize.width/7.0f * self.currentDisplaySequencePosition + self.screenSize.width * 0.03f, self.screenSize.height * .808f);
            [self.sequenceArrowsBatch addChild:arrow];
            [self.sensei changeState:kCharacterStateLeft];
            break;
        }
        case kDirectionTypeDown:
        {
            CCSprite *arrow = [CCSprite spriteWithSpriteFrameName:@"game_arrow_down.png"];
            arrow.anchorPoint = ccp(0, 0.5);
            arrow.position = ccp(self.screenSize.width/7.0f * self.currentDisplaySequencePosition + self.screenSize.width * 0.03f, self.screenSize.height * .808f);
            [self.sequenceArrowsBatch addChild:arrow];
            [self.sensei changeState:kCharacterStateDown];
            break;
        }
        case kDirectionTypeRight:
        {
            CCSprite *arrow = [CCSprite spriteWithSpriteFrameName:@"game_arrow_right.png"];
            arrow.anchorPoint = ccp(0, 0.5);
            arrow.position = ccp(self.screenSize.width/7.0f * self.currentDisplaySequencePosition + self.screenSize.width * 0.03f, self.screenSize.height * .808f);
            [self.sequenceArrowsBatch addChild:arrow];
            [self.sensei changeState:kCharacterStateRight];
            break;
        }
        case kDirectionTypeUp:
        {
            CCSprite *arrow = [CCSprite spriteWithSpriteFrameName:@"game_arrow_up.png"];
            arrow.anchorPoint = ccp(0, 0.5);
            arrow.position = ccp(self.screenSize.width/7.0f * self.currentDisplaySequencePosition + self.screenSize.width * 0.03f, self.screenSize.height * .808f);
            [self.sequenceArrowsBatch addChild:arrow];
            [self.sensei changeState:kCharacterStateUp];
            break;
        }
        default:
        {
            CCLOG(@"Not a valid sequence direction to display");
            return;
            break;
        }
    }
    
    self.currentDisplaySequencePosition++;
    
    if ([self.sequence count] == self.currentDisplaySequencePosition) {
        // no more sequence to display
        [self unschedule:@selector(displaySequence:)];
        
        // start gameplay after a 1 sec delay
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallBlock actionWithBlock:^{
            // remove WATCH SENSEI message
            [self.waitDimLayer removeAllChildrenWithCleanup:YES];
            
            // show GO! message
            CCLabelBMFont *goLabel = [CCLabelBMFont labelWithString:@"GO!" fntFile:@"grobold_50px_GO.fnt"];
            goLabel.color = ccc3(229, 214, 172);
            goLabel.position = ccp(self.waitDimLayer.boundingBox.size.width/2, self.waitDimLayer.boundingBox.size.height * 0.60f);
            [self.waitDimLayer addChild:goLabel];
            
            // enlarge and fade away label with dim bg simultaneously
            [goLabel runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:0.5f scale:2], [CCFadeOut actionWithDuration:0.5f], nil]];
            [self.waitDimLayer runAction:[CCFadeOut actionWithDuration:0.5f]];
            
            // make arrows batch disappear if above level 1
            if ([GameManager sharedGameManager].ninjaLevel > 1) {
                self.sequenceArrowsBatch.visible = NO;
            }
            self.enableGestures = YES;
            // reset idle timer
            self.secondsIdle = 0;
            [self scheduleUpdate];
        }], nil]];
    }
}

-(void)handleLeftSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        self.secondsIdle = 0;
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
        self.secondsIdle = 0;
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
        self.secondsIdle = 0;
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
        self.secondsIdle = 0;
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
        int score = [GameManager sharedGameManager].score;
        
        if ((self.didBeatHighScore == NO) && (score > [GameManager sharedGameManager].highScore)) {
            self.didBeatHighScore = YES;
            self.scoreLabel.color = ccc3(255, 213, 110);
        }
        self.scoreLabel.string = [NSString stringWithFormat:@"%i", score];
        
        // move arrows batch node
        id moveArrows = [CCMoveBy actionWithDuration:0.1f position:ccp(-1 * self.screenSize.width/7.0f, 0)];
        [self.sequenceArrowsBatch runAction:moveArrows];
    } else {
        [self playerLosesWithDirection:direction];
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
            self.directionForLevelUp = [[self.sequence objectAtIndex:([self.sequence count]-1)] intValue];
            [self ninjaLevelUp];
        } else {
            [self startNewRound];
        }
    }
}

-(void)playerLosesWithDirection:(DirectionTypes)direction {
    CCLOG(@"you lose!");
    self.enableGestures = NO;
    [self unscheduleUpdate];
    // trigger losing animation for LEFT and DOWN direction
    id tripAnimation;
    if (direction == kDirectionTypeLeft) {
        tripAnimation = [CCSequence actions:[CCRotateBy actionWithDuration:0.15f angle:-10], [CCRotateBy actionWithDuration:0.15f angle:20], [CCRotateBy actionWithDuration:0.15f angle:-75], [CCCallBlock actionWithBlock:^{
            // remove blinking eyes
            [self.ninja removeBlinkingEyes];
            
            // add spinny eyes
            CCSprite *rightSpinnyEyes;
            CCSprite *leftSpinnyEyes;
            
            if ([GameManager sharedGameManager].ninjaLevel < 6) {
                // add ninja spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.55f, self.ninja.position.y * 2.25f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.72f, rightSpinnyEyes.position.y);
            } else {
                // add sensei spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.42f, self.ninja.position.y * 1.85f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.80f, rightSpinnyEyes.position.y);
            }
            
            [self.ninja addChild:rightSpinnyEyes];
            [self.ninja addChild:leftSpinnyEyes];
            // spin eyes
            id spinEyes = [CCRotateBy actionWithDuration:2.0f angle:-900];
            [rightSpinnyEyes runAction:spinEyes];
            [leftSpinnyEyes runAction:[spinEyes copy]];
        }], nil];
    } else if (direction == kDirectionTypeDown) {
        // need to move eyes lower
        tripAnimation = [CCSequence actions:[CCRotateBy actionWithDuration:0.15f angle:-10], [CCRotateBy actionWithDuration:0.15f angle:20], [CCRotateBy actionWithDuration:0.15f angle:75], [CCCallBlock actionWithBlock:^{
            // remove blinking eyes
            [self.ninja removeBlinkingEyes];
            
            // add spinny eyes
            CCSprite *rightSpinnyEyes;
            CCSprite *leftSpinnyEyes;
            
            if ([GameManager sharedGameManager].ninjaLevel < 6) {
                // add ninja spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.55f, self.ninja.position.y * 2.10f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.72f, rightSpinnyEyes.position.y);
            } else {
                // add sensei spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.42f, self.ninja.position.y * 1.73f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.80f, rightSpinnyEyes.position.y);
            }
            
            [self.ninja addChild:rightSpinnyEyes];
            [self.ninja addChild:leftSpinnyEyes];
            
            // spin eyes
            id spinEyes = [CCRotateBy actionWithDuration:2.0f angle:-900];
            [rightSpinnyEyes runAction:spinEyes];
            [leftSpinnyEyes runAction:[spinEyes copy]];
        }], nil];
    } else {
        tripAnimation = [CCSequence actions:[CCRotateBy actionWithDuration:0.15f angle:10], [CCRotateBy actionWithDuration:0.15f angle:-20], [CCRotateBy actionWithDuration:0.15f angle:75], [CCCallBlock actionWithBlock:^{
            // remove blinking eyes
            [self.ninja removeBlinkingEyes];
            
            // add spinny eyes
            CCSprite *rightSpinnyEyes;
            CCSprite *leftSpinnyEyes;
            
            if ([GameManager sharedGameManager].ninjaLevel < 6) {
                // add ninja spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.55f, self.ninja.position.y * 2.25f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_ninja_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.72f, rightSpinnyEyes.position.y);
            } else {
                // add sensei spinny eyes
                rightSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                rightSpinnyEyes.position = ccp(self.ninja.position.x * 0.42f, self.ninja.position.y * 1.85f);
                
                
                leftSpinnyEyes = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei_trip_eyes.png"];
                leftSpinnyEyes.position = ccp(rightSpinnyEyes.position.x * 0.80f, rightSpinnyEyes.position.y);
            }
            
            [self.ninja addChild:rightSpinnyEyes];
            [self.ninja addChild:leftSpinnyEyes];
            
            // spin eyes
            id spinEyes = [CCRotateBy actionWithDuration:2.0f angle:-900];
            [rightSpinnyEyes runAction:spinEyes];
            [leftSpinnyEyes runAction:[spinEyes copy]];
        }], nil];
    }
    [self.ninja runAction:[CCSequence actions:tripAnimation, [CCDelayTime actionWithDuration:2.0f], [CCCallBlock actionWithBlock:^{
        [self playGameOverScene];
    }], nil]];
}

-(void)ninjaLevelUp {
    // stop gameplay
    self.enableGestures = NO;
    [self unscheduleUpdate];
    
    // increase ninja level
    [GameManager sharedGameManager].ninjaLevel++;
    
    int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
    
    // check highNinjaLevel
    if (ninjaLevel > [GameManager sharedGameManager].highNinjaLevel) {
        [GameManager sharedGameManager].highNinjaLevel = ninjaLevel;
    }
    
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"New_Level", nil];
    [Flurry logEvent:@"Leveled_Up" withParameters:flurryParams];
    
    [self setUpLevelUpScreen];
    
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    
    // add level up message header
    CCLabelBMFont *levelUpMessageHeader = [CCLabelBMFont labelWithString:@"HEY LOOK!" fntFile:@"grobold_30px_nostroke.fnt"];
    levelUpMessageHeader.color = ccc3(153, 136, 94);
    levelUpMessageHeader.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.70f);
    [self.levelUpMessageBg addChild:levelUpMessageHeader];
    
    CCLabelBMFont *levelUpMessageBody = [CCLabelBMFont labelWithString:@"SOMETHING SEEMS TO BE HAPPENING!" fntFile:@"grobold_21px.fnt" width:levelUpMessageBgSize.width * 0.60 alignment:kCCTextAlignmentCenter];
    levelUpMessageBody.color = ccc3(153, 136, 94);
    levelUpMessageBody.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.40f);
    [self.levelUpMessageBg addChild:levelUpMessageBody];
    
    self.currentGameState = kGameStateLevelUpScreen1;
}

-(void)showLevelUpAnimation {
    // dismiss messages and show ninja
    self.currentGameState = kGameStateLevelUpAnimation;
    [self dismissLevelUpScreen];

    switch ([GameManager sharedGameManager].ninjaLevel) {
        case 2:
        {
            // add aura
            self.level2AuraEmitter = [CCParticleSystemQuad particleWithFile:@"aura1_game.plist"];
            self.level2AuraEmitter.position = ccp(self.ninja.position.x + self.ninja.boundingBox.size.width/8, self.ninja.position.y + self.ninja.boundingBox.size.height/2);
            self.level2AuraEmitter.visible = NO;
            [self addChild:self.level2AuraEmitter z:3];
            
            [self.level2AuraEmitter runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCBlink actionWithDuration:1 blinks:5], [CCDelayTime actionWithDuration:1.5f], [CCCallFunc actionWithTarget:self selector:@selector(showNinjaLevelUpScreen2)], nil]];
            
            break;
        }
            
        case 3:
        {
            // add ninja star
            [self.ninja addNinjaStarWithDirection:self.directionForLevelUp];
            [self.ninja hideNinjaStar];
            [self addNinjaStarsUpgrade];
            
            id hideAndShowNinjaStarAction = [CCSequence actions:[CCCallBlock actionWithBlock:^{
                [self.ninja hideNinjaStar];
            }], [CCDelayTime actionWithDuration:0.1f], [CCCallBlock actionWithBlock:^{
                [self.ninja showNinjaStar];
            }], [CCDelayTime actionWithDuration:0.1f], nil];
            
            [self.ninja runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCRepeat actionWithAction:hideAndShowNinjaStarAction times:5], [CCDelayTime actionWithDuration:1.5f], [CCCallFunc actionWithTarget:self selector:@selector(showNinjaLevelUpScreen2)], nil]];
            
            break;
        }
            
        // skip case 4 -- cat gift screen
            
        case 5:
        {
            // evolve little cat to big cat
            CCSprite *bigCat = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_cat_big.png"];
            bigCat.position = ccp(self.ninja.position.x * 0.297f, self.ninja.position.y * 2.40f);
            bigCat.visible = NO;
            [self addChild:bigCat z:3];
            
            [bigCat runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCBlink actionWithDuration:1 blinks:5], [CCCallBlock actionWithBlock:^{
                // remove small cat
                [self.smallCat removeFromParentAndCleanup:YES];
            }], [CCDelayTime actionWithDuration:1.5f], [CCCallFunc actionWithTarget:self selector:@selector(showNinjaLevelUpScreen2)], nil]];
            
            break;
        }
            
        case 6:
        {
            // evolve ninja into sensei
            id switchFromNinjaToSenseiSpriteAction = [CCSequence actions:[CCCallBlock actionWithBlock:^{
                [self.ninja switchToSenseiWithDirection:self.directionForLevelUp];
            }], [CCDelayTime actionWithDuration:0.1f], [CCCallBlock actionWithBlock:^{
                [self.ninja switchToNinjaWithDirection:self.directionForLevelUp];
            }], [CCDelayTime actionWithDuration:0.1f], nil];
            id evolveToSenseiAction = [CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCRepeat actionWithAction:switchFromNinjaToSenseiSpriteAction times:5], [CCCallBlock actionWithBlock:^{
                [self.ninja switchToSenseiWithDirection:self.directionForLevelUp];
            }], [CCDelayTime actionWithDuration:1.5f], [CCCallFunc actionWithTarget:self selector:@selector(showNinjaLevelUpScreen2)], nil];
            
            [self.ninja runAction:evolveToSenseiAction];
            
            break;
        }
            
        default:
        {
            CCLOG(@"Level not recognized in GameLayer.m->showLevelUpAnimation: %i", [GameManager sharedGameManager].ninjaLevel);
            break;
        }
    }
}

-(void)showSenseiGiftScreen {
    self.currentGameState = kGameStateLevelUpGiftScreen;
    
    // clear current messages
    [self.levelUpMessageBg removeAllChildrenWithCleanup:YES];
    
    // add new message
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    CCLabelBMFont *giftMessageBody = [CCLabelBMFont labelWithString:@"YOU'RE DOING SO WELL. HERE'S A LITTLE GIFT!" fntFile:@"grobold_21px.fnt" width:levelUpMessageBgSize.width * 0.65f alignment:kCCTextAlignmentCenter];
    giftMessageBody.color = ccc3(153, 136, 94);
    giftMessageBody.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.75f);
    [self.levelUpMessageBg addChild:giftMessageBody];
    
    // add sensei
    CCSprite *senseiGift = [CCSprite spriteWithSpriteFrameName:@"game_transition_sensei.png"];
    senseiGift.anchorPoint = ccp(0.5, 0);
    senseiGift.position = ccp(levelUpMessageBgSize.width * 0.55f, 0);
    [self.levelUpMessageBg addChild:senseiGift];
}

-(void)showSmallCatScreen {
    self.currentGameState = kGameStateLevelUpSmallCatScreen;

    // fade out old messages and sensei, fade in small cat
    for (CCNode* child in self.levelUpMessageBg.children) {
        [child runAction:[CCSequence actions:[CCCallBlock actionWithBlock:^{
            // disable touch during the gift presentation
            self.isTouchEnabled = NO;
        }], [CCFadeOut actionWithDuration:1.0f], nil]];
    }
    
    // fade in cat after old messages fade out
    id catFadeIn = [CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCFadeIn actionWithDuration:1.0f], [CCCallBlock actionWithBlock:^{
        self.isTouchEnabled = YES;
    }], nil];
    CCSprite *smallCatTransition = [CCSprite spriteWithSpriteFrameName:@"game_transition_cat.png"];
    smallCatTransition.opacity = 0;
    smallCatTransition.position = ccp(self.levelUpMessageBg.boundingBox.size.width/2, self.levelUpMessageBg.boundingBox.size.height/2);
    [self.levelUpMessageBg addChild:smallCatTransition];
    
    [smallCatTransition runAction:catFadeIn];
    
    // add small cat to gameplay
    self.smallCat = [CCSprite spriteWithSpriteFrameName:@"game_upgrades_cat_small.png"];
    self.smallCat.position = ccp(self.ninja.position.x * 0.33f, self.ninja.position.y * 2.20f);
    [self addChild:self.smallCat z:4];
}

-(void)showNinjaLevelUpScreen2 {
    [self setUpLevelUpScreen];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    
    // add new level up messages
    CCLabelBMFont *levelUpMessageBody = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"YOU ARE NOW SUPER NINJA LEVEL %i!", [GameManager sharedGameManager].ninjaLevel] fntFile:@"grobold_30px_nostroke.fnt" width:levelUpMessageBgSize.width * 0.70f alignment:kCCTextAlignmentCenter];
    levelUpMessageBody.color = ccc3(153, 136, 94);
    levelUpMessageBody.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height/2);
    [self.levelUpMessageBg addChild:levelUpMessageBody];
    
    // add confetti
    self.confettiEmitter = [CCParticleSystemQuad particleWithFile:@"confetti.plist"];
    self.confettiEmitter.position = ccp(screenSize.width/2, screenSize.height/2);
    [self.levelUpBg addChild:self.confettiEmitter z:3];
    
    self.currentGameState = kGameStateLevelUpScreen2;
}

-(void)showNinjaLevelUpScreen2FromCatScreen {
    // remove cat
    [self.levelUpMessageBg removeAllChildrenWithCleanup:YES];
    
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CGSize levelUpMessageBgSize = self.levelUpMessageBg.boundingBox.size;
    
    // add new level up messages
    CCLabelBMFont *levelUpMessageBody = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"YOU ARE NOW SUPER NINJA LEVEL %i!", [GameManager sharedGameManager].ninjaLevel] fntFile:@"grobold_30px_nostroke.fnt" width:levelUpMessageBgSize.width * 0.70f alignment:kCCTextAlignmentCenter];
    levelUpMessageBody.color = ccc3(153, 136, 94);
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
    CCSpriteBatchNode *rayBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art_bg.pvr.ccz" capacity:10];
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

#pragma mark --
#pragma mark level up upgrades
-(void)addNinjaStarsUpgrade {
    // init throwing ninja stars
    CCSpriteBatchNode *ninjaStarBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art.pvr.ccz" capacity:8];
    [self addChild:ninjaStarBatchNode z:10];
    
    // Create a max of 8 throwing ninja stars on screen at one time
    for (int i=0; i<8; i++) {
        NinjaStar *ninjaStar = [[NinjaStar alloc] initFromScene:kSceneTypeGame];
        [ninjaStarBatchNode addChild:ninjaStar];
    }
    
    self.ninjaStars = [ninjaStarBatchNode children];
    
    self.nextInactiveNinjaStar = 0;
}

-(void)startNewRound {
    self.enableGestures = NO;
    [self unscheduleUpdate];
    self.timer.percentage = 100;
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    self.currentGameState = kGameStatePlay;
    self.timeArrowsHidden = 0;
    
    // remove arrows from batch node
    [self.sequenceArrowsBatch removeAllChildrenWithCleanup:YES];
    // reset batch node position
# warning - replace move action with setting position
    [self.sequenceArrowsBatch runAction:[CCMoveTo actionWithDuration:0.1f position:CGPointZero]];
    
    int currentSequenceLength = [self.sequence count];
    for (int i=0; i<2; i++) {
        self.sequence[currentSequenceLength + i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
//        self.sequence[currentSequenceLength + i] = [NSNumber numberWithInt:kDirectionTypeUp];
        NSLog(@"sequence at %i: %@", currentSequenceLength + i, self.sequence[currentSequenceLength + i]);
    }
    
    // show WATCH SENSEI message
    [self.waitDimLayer removeAllChildrenWithCleanup:YES];
    self.waitDimLayer.opacity = 220;
    [self addWatchSenseiMessage];

    // show new round indicator
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    self.gameRoundBg = [CCSprite spriteWithSpriteFrameName:@"game_rounds_bg.png"];
    self.gameRoundBg .position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:self.gameRoundBg  z:100];
    
    // add 'nice!' message if player finished round 1
    if (self.roundNumber == 1) {
        self.roundNumber++;
        CCLabelBMFont *niceLabel = [CCLabelBMFont labelWithString:@"NICE!" fntFile:@"grobold_35px.fnt"];
        niceLabel.color = ccc3(153, 136, 94);
        niceLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height/2);
        [self.gameRoundBg addChild:niceLabel];
        id niceLabelBgAction = [CCFadeIn actionWithDuration:0.5f];
        id niceLabelAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCDelayTime actionWithDuration:0.5f], [CCFadeOut actionWithDuration:0.5f], [CCCallFunc actionWithTarget:self selector:@selector(showRoundLabelAfterNiceMessage)], nil];
        [self.gameRoundBg runAction:niceLabelBgAction];
        [niceLabel runAction:niceLabelAction];
    } else {
        self.roundNumber++;
        CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"ROUND %i", self.roundNumber] fntFile:@"grobold_30px_nostroke.fnt"];
        newRoundLabel.color = ccc3(153, 136, 94);
        newRoundLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height * 0.60f);
        [self.gameRoundBg addChild:newRoundLabel];
        
        // display how many rounds left until next level
        int roundsUntilLevelUp;
        int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
        switch (ninjaLevel) {
            case 1:
                roundsUntilLevelUp = kGameLevel2Round - self.roundNumber + 1;
                break;
            case 2:
                roundsUntilLevelUp = kGameLevel3Round - self.roundNumber + 1;
                break;
            case 3:
                roundsUntilLevelUp = kGameLevel4Round - self.roundNumber + 1;
                break;
            case 4:
                roundsUntilLevelUp = kGameLevel5Round - self.roundNumber + 1;
                break;
            case 5:
                roundsUntilLevelUp = kGameLevel6Round - self.roundNumber + 1;
                break;
            default:
                roundsUntilLevelUp = -1;
                break;
        }
        
        CCLabelBMFont *roundsUntilNextLevelLabel = nil;
        
        if (roundsUntilLevelUp > 0) {
            if (roundsUntilLevelUp > 1)
                roundsUntilNextLevelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i MORE ROUNDS...", roundsUntilLevelUp] fntFile:@"grobold_17px.fnt"];
            else
                roundsUntilNextLevelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i MORE ROUND...", roundsUntilLevelUp] fntFile:@"grobold_17px.fnt"];
            roundsUntilNextLevelLabel.position = ccp(newRoundLabel.position.x, newRoundLabel.position.y * 0.50f);
            roundsUntilNextLevelLabel.color = ccc3(104, 95, 82);
            [self.gameRoundBg addChild:roundsUntilNextLevelLabel];
        }
        
        
        id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCCallBlock actionWithBlock:^{
            self.currentGameState = kGameStateRoundDisplay;
        }], [CCDelayTime actionWithDuration:2.0f], [CCCallBlock actionWithBlock:^{
            self.currentGameState = kGameStatePlay;
        }], [CCFadeOut actionWithDuration:0.5f], nil];
        
        // have sensei perform new sequence
        id labelBgAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
        
        [newRoundLabel runAction:labelAction];
        if (roundsUntilNextLevelLabel != nil) {
            id roundsUntilNextLevelLabelAction = [labelAction copy];
            [roundsUntilNextLevelLabel runAction:roundsUntilNextLevelLabelAction];
        }
        [self.gameRoundBg runAction:labelBgAction];
    }
}

-(void)showRoundLabelAfterNiceMessage {
    // remove nice message
    [self.gameRoundBg removeAllChildrenWithCleanup:YES];
    
    CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"ROUND %i", self.roundNumber] fntFile:@"grobold_30px_nostroke.fnt"];
    newRoundLabel.color = ccc3(153, 136, 94);
    newRoundLabel.position = ccp(self.gameRoundBg.boundingBox.size.width/2, self.gameRoundBg.boundingBox.size.height * 0.60f);
    [self.gameRoundBg addChild:newRoundLabel];
    
    // display how many rounds left until next level
    int roundsUntilLevelUp;
    int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
    switch (ninjaLevel) {
        case 1:
            roundsUntilLevelUp = kGameLevel2Round - self.roundNumber + 1;
            break;
        case 2:
            roundsUntilLevelUp = kGameLevel3Round - self.roundNumber + 1;
            break;
        case 3:
            roundsUntilLevelUp = kGameLevel4Round - self.roundNumber + 1;
            break;
        case 4:
            roundsUntilLevelUp = kGameLevel5Round - self.roundNumber + 1;
            break;
        case 5:
            roundsUntilLevelUp = kGameLevel6Round - self.roundNumber + 1;
            break;
        default:
            roundsUntilLevelUp = -1;
            break;
    }
    
    CCLabelBMFont *roundsUntilNextLevelLabel = nil;
    if (roundsUntilLevelUp > 0) {
        if (roundsUntilLevelUp > 1)
            roundsUntilNextLevelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i MORE ROUNDS...", roundsUntilLevelUp] fntFile:@"grobold_17px.fnt"];
        else
            roundsUntilNextLevelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i MORE ROUND...", roundsUntilLevelUp] fntFile:@"grobold_17px.fnt"];
        
        roundsUntilNextLevelLabel.position = ccp(newRoundLabel.position.x, newRoundLabel.position.y * 0.501f);
        roundsUntilNextLevelLabel.color = ccc3(104, 95, 82);
        [self.gameRoundBg addChild:roundsUntilNextLevelLabel];
    }
    
    
    id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:0.5], [CCCallBlock actionWithBlock:^{
        self.currentGameState = kGameStateRoundDisplay;
    }], [CCDelayTime actionWithDuration:2.0f], [CCCallBlock actionWithBlock:^{
        self.currentGameState = kGameStatePlay;
    }], [CCFadeOut actionWithDuration:0.5f], nil];
    
    // have sensei perform new sequence
    id labelBgAction = [CCSequence actions:[CCDelayTime actionWithDuration:2.5f], [CCFadeOut actionWithDuration:0.5f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
    
    [newRoundLabel runAction:labelAction];
    if (roundsUntilNextLevelLabel != nil) {
        id roundsUntilNextLevelLabelAction = [labelAction copy];
        [roundsUntilNextLevelLabel runAction:roundsUntilNextLevelLabelAction];
    }
    [self.gameRoundBg runAction:labelBgAction];
}

-(void)pauseGame {
    if (self.isGamePaused == NO) {
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
        [Flurry logEvent:@"Paused_Game" withParameters:flurryParams];
        self.isGamePaused = YES;
        [self pauseSchedulerAndActions];
        for (CCNode *node in [self children]) {
            [self pauseAllSchedulerAndActions:node];
        }
        
        // dim the gameplay layer
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        self.dimLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
        [self addChild:self.dimLayer z:95];
        
        // show paused menu
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
    pausedText.position = ccp(pausedBgWidth * 0.48f, pausedBgHeight * 0.84f);
    [self.gamePausedBg addChild:pausedText];
    
    // add game paused separator
    CCSprite *pausedSeparator = [CCSprite spriteWithSpriteFrameName:@"game_paused_line.png"];
    pausedSeparator.position = ccp(pausedBgWidth * 0.53f, pausedBgHeight * 0.75f);
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
        
        // remove dim layer
        [self.dimLayer removeFromParentAndCleanup:YES];
        
        // remove paused menu from self
        [self.gamePausedBg removeFromParentAndCleanup:YES];
    }
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
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
    [Flurry logEvent:@"Restarted_Game" withParameters:flurryParams];
    
    // check if new high score
    int score = [GameManager sharedGameManager].score;
    if (score > [GameManager sharedGameManager].highScore) {
        [GameManager sharedGameManager].highScore = score;
    }
    
    [self.sequenceArrowsBatch removeAllChildrenWithCleanup:YES];
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
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel], @"Level", nil];
    // check if player beat high score
    int score = [GameManager sharedGameManager].score;
    if (score > [GameManager sharedGameManager].highScore) {
        [GameManager sharedGameManager].highScore = score;
    }
    
    [Flurry logEvent:@"Quit_Game" withParameters:flurryParams];
    [Flurry endTimedEvent:@"Playing_Game" withParameters:nil];
    // go back to main menu
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

-(void)playGameOverScene {
    [Flurry endTimedEvent:@"Playing_Game" withParameters:nil];
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGameOver];
}

-(void)update:(ccTime)deltaTime {
    [self.ninja updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    [self.sensei updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    
    self.timer.percentage -= self.timeToSubtractPerSecond/60.0f;
    self.secondsIdle = self.secondsIdle + deltaTime;
    if (self.timer.percentage <= 0) {
        [self playGameOverScene];
    }
    
    if (self.sequenceArrowsBatch.visible == NO) {
        self.timeArrowsHidden = self.timeArrowsHidden + deltaTime;
    }
    
    switch ([GameManager sharedGameManager].ninjaLevel) {
        case 2: {
            // level 2 - arrows appear after 1 second, waits 2 sec, then disappears
            if (self.timeArrowsHidden >= 1) {
                self.timeArrowsHidden = 0;
                self.sequenceArrowsBatch.visible = YES;
                [self.sequenceArrowsBatch runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCCallBlock actionWithBlock:^{
                    self.sequenceArrowsBatch.visible = NO;
                }], nil]];
            }
            break;
        }
            
        case 3: {
            // level 3 - arrows appear after 2 seconds, waits 1 sec, then disappears
            if (self.timeArrowsHidden >= 2) {
                self.timeArrowsHidden = 0;
                self.sequenceArrowsBatch.visible = YES;
                [self.sequenceArrowsBatch runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0f], [CCCallBlock actionWithBlock:^{
                    self.sequenceArrowsBatch.visible = NO;
                }], nil]];
            }
            break;
        }
            
        case 4: {
            // level 4 - arrows appear after 2 seconds, waits 0.5 sec, then disappears
            if (self.timeArrowsHidden >= 2) {
                self.timeArrowsHidden = 0;
                self.sequenceArrowsBatch.visible = YES;
                [self.sequenceArrowsBatch runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5f], [CCCallBlock actionWithBlock:^{
                    self.sequenceArrowsBatch.visible = NO;
                }], nil]];
            }
            break;
        }
            
        case 5: {
            // level 5 - arrows appear after player is idle for 1sec
            if (self.secondsIdle >= 1 && self.sequenceArrowsBatch.visible == NO) {
                self.sequenceArrowsBatch.visible = YES;
            } else if (self.secondsIdle < 1 && self.sequenceArrowsBatch.visible == YES) {
                self.sequenceArrowsBatch.visible = NO;
            }
            break;
        }
            
        case 6: {
            // level 5 - arrows appear after player is idle for 1sec
            if (self.secondsIdle >= 1 && self.sequenceArrowsBatch.visible == NO) {
                self.sequenceArrowsBatch.visible = YES;
            } else if (self.secondsIdle < 1 && self.sequenceArrowsBatch.visible == YES) {
                self.sequenceArrowsBatch.visible = NO;
            }
            break;
        }
            
        default: {
            // no other levels...
            break;
        }
    }
}

@end
