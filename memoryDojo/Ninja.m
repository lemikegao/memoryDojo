//
//  Ninja.m
//  memoryDojo
//
//  Created by Michael Gao on 11/4/12.
//
//

#import "Ninja.h"
#import "GameManager.h"

@interface Ninja ()

@property (nonatomic, strong) CCSprite *ninjaOpenEyes;
@property (nonatomic, readonly) CGPoint defaultNinjaEyesPosition;
@property (nonatomic, readonly) CGPoint defaultNinjaEyesDownPosition;
@property (nonatomic, readonly) CGPoint defaultSenseiEyesPosition;
@property (nonatomic, readonly) CGPoint defaultSenseiEyesDownPosition;
@property (nonatomic, strong) CCAnimation *blinkingAnim;
@property (nonatomic) float secondsStayingIdle;
@property (nonatomic) BOOL isNinjaBlinking;
@property (nonatomic) BOOL isNinjaSenseiMode;


@end

@implementation Ninja

-(id)init {
    if ([GameManager sharedGameManager].ninjaLevel == 6) {
        self.isNinjaSenseiMode = YES;
        self = [super initWithSpriteFrameName:@"game_sensei_up_repeat.png"];
    } else {
        self.isNinjaSenseiMode = NO;
        self = [super initWithSpriteFrameName:@"game_ninja_up_repeat.png"];
    }
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeNinja;
        self.characterState = kCharacterStateIdle;
        
        _defaultNinjaEyesPosition = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
        _defaultNinjaEyesDownPosition = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.574f);
        _defaultSenseiEyesPosition = ccp(self.boundingBox.size.width * 0.50f, self.boundingBox.size.height * 0.65f);
        _defaultSenseiEyesDownPosition = ccp(self.boundingBox.size.width * 0.50f, self.boundingBox.size.height * 0.61f);
        
        // initialize blinking
        self.secondsStayingIdle = 0;
        self.isNinjaBlinking = NO;
        if (self.isNinjaSenseiMode == YES) {
            // add eyes
            self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:@"game_sensei_eyes_1.png"];
            self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
            [self addChild:self.ninjaOpenEyes z:100];
        } else {
            // add eyes
            self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:@"game_ninja_eyes_1.png"];
            self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
            [self addChild:self.ninjaOpenEyes z:100];
        }
    }
    
    return self;
}

-(void)initAnimations {
    if (self.isNinjaSenseiMode == YES) {
        self.blinkingAnim = [self loadPlistForAnimationWithName:@"blinkingAnim" andClassName:@"Sensei"];
    } else {
        self.blinkingAnim = [self loadPlistForAnimationWithName:@"blinkingAnim" andClassName:NSStringFromClass([self class])];
    }
    self.blinkingAnim.restoreOriginalFrame = YES;
}

-(void)blink {
    self.isNinjaBlinking = YES;
    id blinkAction = [CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(stopBlinking)], nil];
    [self.ninjaOpenEyes runAction:blinkAction];
}

-(void)stopBlinking {
    self.isNinjaBlinking = NO;
}

-(void)changeState:(CharacterStates)newState {
    [self stopAllActions];
    id action = nil;
    CharacterStates oldState = self.characterState;
    self.characterState = newState;
    self.secondsStayingIdle = 0;
    
    // adjust ninja eyes
    if (newState == kCharacterStateDown) {
        if (self.isNinjaSenseiMode == NO) {
            self.ninjaOpenEyes.position = self.defaultNinjaEyesDownPosition;
        } else {
            self.ninjaOpenEyes.position = self.defaultSenseiEyesDownPosition;
        }
    } else {
        if (self.isNinjaSenseiMode == NO) {
            self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
        } else {
            self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
        }
    }

    switch (newState) {
        case kCharacterStateIdle:
            if (self.isNinjaSenseiMode == NO) {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_up_repeat.png"];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up_repeat.png"];
            }
            break;
            
        case kCharacterStateLeft:
        {
            // perform repeat action
            NSString *spriteFrameName;
            NSString *repeatSpriteFrameName;
            if (self.isNinjaSenseiMode == NO) {
                spriteFrameName = @"game_ninja_left.png";
                repeatSpriteFrameName = @"game_ninja_left_repeat.png";
            } else {
                spriteFrameName = @"game_sensei_left.png";
                repeatSpriteFrameName = @"game_sensei_left_repeat.png";
            }
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:repeatSpriteFrameName], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            }
            break;
        }
            
        case kCharacterStateDown:
        {
            // perform repeat action
            NSString *spriteFrameName;
            NSString *repeatSpriteFrameName;
            if (self.isNinjaSenseiMode == NO) {
                spriteFrameName = @"game_ninja_down.png";
                repeatSpriteFrameName = @"game_ninja_down_repeat.png";
            } else {
                spriteFrameName = @"game_sensei_down.png";
                repeatSpriteFrameName = @"game_sensei_down_repeat.png";
            }
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:repeatSpriteFrameName], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.08f];
                repeatAnimation.loops = 1;
                
                id moveEyesAction = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(moveEyesDownRepeat)], [CCDelayTime actionWithDuration:0.08f], [CCCallFunc actionWithTarget:self selector:@selector(moveEyesDown)], nil];
                action = [CCSpawn actions:moveEyesAction, [CCAnimate actionWithAnimation:repeatAnimation], nil];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            }
            break;
        }
            
        case kCharacterStateRight:
        {
            // perform repeat action
            NSString *spriteFrameName;
            NSString *repeatSpriteFrameName;
            if (self.isNinjaSenseiMode == NO) {
                spriteFrameName = @"game_ninja_right.png";
                repeatSpriteFrameName = @"game_ninja_right_repeat.png";
            } else {
                spriteFrameName = @"game_sensei_right.png";
                repeatSpriteFrameName = @"game_sensei_right_repeat.png";
            }
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:repeatSpriteFrameName], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            }
            break;
        }
            
        case kCharacterStateUp:
        {
            NSString *spriteFrameName;
            NSString *repeatSpriteFrameName;
            if (self.isNinjaSenseiMode == NO) {
                spriteFrameName = @"game_ninja_up.png";
                repeatSpriteFrameName = @"game_ninja_up_repeat.png";
            } else {
                spriteFrameName = @"game_sensei_up.png";
                repeatSpriteFrameName = @"game_sensei_up_repeat.png";
            }
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:repeatSpriteFrameName], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName];
            }
            break;
        }
            
        default:
        {
            CCLOG(@"Unhandled state %d in Ninja", newState);
            break;
        }
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

-(void)moveEyesDownRepeat {
    if (self.isNinjaSenseiMode == YES) {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.50f, self.boundingBox.size.height * 0.63f);
    } else {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.6f);
    }
}

-(void)moveEyesDown {
    if (self.isNinjaSenseiMode == YES) {
        self.ninjaOpenEyes.position = self.defaultSenseiEyesDownPosition;
    } else {
        self.ninjaOpenEyes.position = self.defaultNinjaEyesDownPosition;
    }
}

-(void)removeBlinkingEyes {
    [self removeAllChildrenWithCleanup:YES];
}

-(void)switchToSensei {
    CCLOG(@"sensei bounding box size: %@", NSStringFromCGSize(self.boundingBox.size));
    self.isNinjaSenseiMode = YES;
    self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up_repeat.png"];
    // recalculate position for eyes with new sensei bounding box
    _defaultSenseiEyesPosition = ccp(self.boundingBox.size.width * 0.50f, self.boundingBox.size.height * 0.65f);
    _defaultSenseiEyesDownPosition = ccp(self.boundingBox.size.width * 0.50f, self.boundingBox.size.height * 0.61f);
    self.ninjaOpenEyes.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_eyes_1.png"];
    self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
}

-(void)switchToNinja {
    CCLOG(@"ninja bounding box size: %@", NSStringFromCGSize(self.boundingBox.size));
    self.isNinjaSenseiMode = NO;
    self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_up_repeat.png"];
    // reset eyes to ninja position
    self.ninjaOpenEyes.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_eyes_1.png"];
    self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
    // blink every 2 seconds when idle
    self.secondsStayingIdle = self.secondsStayingIdle + deltaTime;
    if (self.secondsStayingIdle > 2.0f && self.isNinjaBlinking == NO) {
        [self blink];
    }
}

@end
