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
@property (nonatomic, strong) CCSprite *ninjaStar;
@property (nonatomic) CGPoint defaultNinjaEyesPosition;
@property (nonatomic) CGPoint defaultNinjaEyesDownPosition;
@property (nonatomic) CGPoint defaultNinjaEyesDownRepeatPosition;
@property (nonatomic) CGPoint defaultSenseiEyesPosition;
@property (nonatomic) CGPoint defaultSenseiEyesDownPosition;
@property (nonatomic) CGPoint defaultSenseiEyesDownRepeatPosition;
@property (nonatomic) CGPoint defaultNinjaStarPosition;
@property (nonatomic) CGPoint defaultNinjaStarDownPosition;
@property (nonatomic) CGPoint defaultNinjaStarDownRepeatPosition;
@property (nonatomic) CGPoint defaultSenseiStarPosition;
@property (nonatomic) CGPoint defaultSenseiStarDownPosition;
@property (nonatomic) CGPoint defaultSenseiStarDownRepeatPosition;
@property (nonatomic, strong) CCAnimation *blinkingAnim;
@property (nonatomic, strong) CCAction *blinkAction;
@property (nonatomic) float secondsStayingIdle;
@property (nonatomic) BOOL isNinjaBlinking;
@property (nonatomic) BOOL isNinjaSenseiMode;
@property (nonatomic, strong) NSString *scenePrefix;


@end

@implementation Ninja

-(id)init {
    if ([GameManager sharedGameManager].ninjaLevel == 6) {
        self.isNinjaSenseiMode = YES;
        self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"%@_sensei_up_repeat.png", self.scenePrefix]];
    } else {
        self.isNinjaSenseiMode = NO;
        self = [super initWithSpriteFrameName:[NSString stringWithFormat:@"%@_ninja_up_repeat.png", self.scenePrefix]];
    }
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeNinja;
        self.characterState = kCharacterStateIdle;
        
        CCSprite *ninjaSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_ninja_up_repeat.png", self.scenePrefix]];
        CCSprite *senseiSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_sensei_up_repeat.png", self.scenePrefix]];
        
        self.defaultNinjaEyesPosition = ccp(ninjaSprite.boundingBox.size.width * 0.455f, ninjaSprite.boundingBox.size.height * 0.63f);
        self.defaultNinjaEyesDownPosition = ccp(ninjaSprite.boundingBox.size.width * 0.455f, ninjaSprite.boundingBox.size.height * 0.574f);
        self.defaultNinjaEyesDownRepeatPosition = ccp(ninjaSprite.boundingBox.size.width * 0.455f, ninjaSprite.boundingBox.size.height * 0.6f);
        
        self.defaultSenseiEyesPosition = ccp(senseiSprite.boundingBox.size.width * 0.50f, senseiSprite.boundingBox.size.height * 0.65f);
        self.defaultSenseiEyesDownPosition = ccp(senseiSprite.boundingBox.size.width * 0.50f, senseiSprite.boundingBox.size.height * 0.61f);
        self.defaultSenseiEyesDownRepeatPosition = ccp(senseiSprite.boundingBox.size.width * 0.50f, senseiSprite.boundingBox.size.height * 0.63f);
        
        self.defaultNinjaStarPosition = ccp(ninjaSprite.boundingBox.size.width * 0.33f, ninjaSprite.boundingBox.size.height * 0.275f);
        self.defaultNinjaStarDownPosition = ccp(ninjaSprite.boundingBox.size.width * 0.33f, ninjaSprite.boundingBox.size.height * 0.225f);
        self.defaultNinjaStarDownRepeatPosition = ccp(ninjaSprite.boundingBox.size.width * 0.33f, ninjaSprite.boundingBox.size.height * 0.25f);
        
        self.defaultSenseiStarPosition = ccp(senseiSprite.boundingBox.size.width * 0.39f, senseiSprite.boundingBox.size.height * 0.275f);
        self.defaultSenseiStarDownPosition = ccp(senseiSprite.boundingBox.size.width * 0.39f, senseiSprite.boundingBox.size.height * 0.225f);
        self.defaultSenseiStarDownRepeatPosition = ccp(senseiSprite.boundingBox.size.width * 0.39f, senseiSprite.boundingBox.size.height * 0.25f);
        
        // initialize blinking
        self.secondsStayingIdle = 0;
        self.isNinjaBlinking = NO;
        if (self.isNinjaSenseiMode == YES) {
            // add eyes
            self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_sensei_eyes_1.png", self.scenePrefix]];
            self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
            [self addChild:self.ninjaOpenEyes z:100];
        } else {
            // add eyes
            self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_ninja_eyes_1.png", self.scenePrefix]];
            self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
            [self addChild:self.ninjaOpenEyes z:100];
        }
    }
    
    return self;
}

-(id)initFromScene:(SceneTypes)scene {
    if (scene == kSceneTypeMainMenu) {
        self.scenePrefix = @"mainmenu";
    } else if (scene == kSceneTypeGame) {
        self.scenePrefix = @"game";
    } else {
        CCLOG(@"Ninja->initFromScene: Unknown scene type: %i", scene);
    }
    self = [self init];
    
    return self;
}

-(void)initAnimations {
    self.blinkingAnim = [CCAnimation animation];
    
    if (self.isNinjaSenseiMode == YES) {
        [self.blinkingAnim addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_eyes_2.png", self.scenePrefix]]];
    } else {
        [self.blinkingAnim addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_eyes_2.png", self.scenePrefix]]];
    }
    
    self.blinkingAnim.delayPerUnit = 0.20f;
    self.blinkingAnim.restoreOriginalFrame = YES;
}

-(void)blink {
    self.isNinjaBlinking = YES;
    self.blinkAction = [CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(stopBlinking)], nil];
    [self.ninjaOpenEyes runAction:self.blinkAction];
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
            self.ninjaStar.position = self.defaultNinjaStarDownPosition;
        } else {
            self.ninjaOpenEyes.position = self.defaultSenseiEyesDownPosition;
            self.ninjaStar.position = self.defaultSenseiStarDownPosition;
        }
    } else {
        if (self.isNinjaSenseiMode == NO) {
            self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
            self.ninjaStar.position = self.defaultNinjaStarPosition;
        } else {
            self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
            self.ninjaStar.position = self.defaultSenseiStarPosition;
        }
    }

    switch (newState) {
        case kCharacterStateIdle:
            if (self.isNinjaSenseiMode == NO) {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_up_repeat.png", self.scenePrefix]];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_up_repeat.png", self.scenePrefix]];
            }
            break;
            
        case kCharacterStateLeft:
        {
            // perform repeat action
            NSString *spriteFrameName;
            NSString *repeatSpriteFrameName;
            if (self.isNinjaSenseiMode == NO) {
                spriteFrameName = [NSString stringWithFormat:@"%@_ninja_left.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_ninja_left_repeat.png", self.scenePrefix];
            } else {
                spriteFrameName = [NSString stringWithFormat:@"%@_sensei_left.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_sensei_left_repeat.png", self.scenePrefix];
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
                spriteFrameName = [NSString stringWithFormat:@"%@_ninja_down.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_ninja_down_repeat.png", self.scenePrefix];
            } else {
                spriteFrameName = [NSString stringWithFormat:@"%@_sensei_down.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_sensei_down_repeat.png", self.scenePrefix];
            }
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:repeatSpriteFrameName], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:spriteFrameName], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.08f];
                repeatAnimation.loops = 1;
                
                id moveEyesAction = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(moveChildrenDownRepeat)], [CCDelayTime actionWithDuration:0.08f], [CCCallFunc actionWithTarget:self selector:@selector(moveChildrenDown)], nil];
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
                spriteFrameName = [NSString stringWithFormat:@"%@_ninja_right.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_ninja_right_repeat.png", self.scenePrefix];
            } else {
                spriteFrameName = [NSString stringWithFormat:@"%@_sensei_right.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_sensei_right_repeat.png", self.scenePrefix];
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
                spriteFrameName = [NSString stringWithFormat:@"%@_ninja_up.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_ninja_up_repeat.png", self.scenePrefix];
            } else {
                spriteFrameName = [NSString stringWithFormat:@"%@_sensei_up.png", self.scenePrefix];
                repeatSpriteFrameName = [NSString stringWithFormat:@"%@_sensei_up_repeat.png", self.scenePrefix];
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

-(void)moveChildrenDownRepeat {    
    if (self.isNinjaSenseiMode == YES) {
        self.ninjaOpenEyes.position = self.defaultSenseiEyesDownRepeatPosition;
        self.ninjaStar.position = self.defaultSenseiStarDownRepeatPosition;
    } else {
        self.ninjaOpenEyes.position = self.defaultNinjaEyesDownRepeatPosition;
        self.ninjaStar.position = self.defaultNinjaStarDownRepeatPosition;
    }
}

-(void)moveChildrenDown {
    if (self.isNinjaSenseiMode == YES) {
        self.ninjaOpenEyes.position = self.defaultSenseiEyesDownPosition;
        self.ninjaStar.position = self.defaultSenseiStarDownPosition;
    } else {
        self.ninjaOpenEyes.position = self.defaultNinjaEyesDownPosition;
        self.ninjaStar.position = self.defaultNinjaStarDownPosition;
    }
}

-(void)removeBlinkingEyes {
    [self stopAction:self.blinkAction];
    [self.ninjaOpenEyes removeFromParentAndCleanup:YES];
}

-(void)addNinjaStarWithDirection:(DirectionTypes)direction {
    self.ninjaStar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@_upgrades_ninjastar2.png", self.scenePrefix]];
    if (direction == kDirectionTypeDown) {
        if (self.isNinjaSenseiMode == YES) {
            self.ninjaStar.position = self.defaultSenseiStarDownPosition;
        } else {
            self.ninjaStar.position = self.defaultNinjaStarDownPosition;
        }
    } else {
        if (self.isNinjaSenseiMode == YES) {
            self.ninjaStar.position = self.defaultSenseiStarPosition;
        } else {
            self.ninjaStar.position = self.defaultNinjaStarPosition;
        }
    }
    
    [self addChild:self.ninjaStar];
}

-(void)removeNinjaStar {
    [self.ninjaStar removeFromParentAndCleanup:YES];
}

-(void)showNinjaStar {
    self.ninjaStar.visible = YES;
}

-(void)hideNinjaStar {
    self.ninjaStar.visible = NO;
}

-(void)switchToSenseiWithDirection:(DirectionTypes)direction {
    [self stopAction:self.blinkAction];
    self.secondsStayingIdle = 0;
    self.isNinjaBlinking = NO;
    self.isNinjaSenseiMode = YES;
    self.ninjaOpenEyes.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_eyes_1.png", self.scenePrefix]];
    self.position = ccp(self.position.x * 0.95f, self.position.y);
    if (direction == kDirectionTypeDown) {
        self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_down.png", self.scenePrefix]];
        self.ninjaOpenEyes.position = self.defaultSenseiEyesDownPosition;
        self.ninjaStar.position = self.defaultSenseiStarDownPosition;
    } else {
        self.ninjaOpenEyes.position = self.defaultSenseiEyesPosition;
        self.ninjaStar.position = self.defaultSenseiStarPosition;
        if (direction == kDirectionTypeLeft) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_left.png", self.scenePrefix]];
        } else if (direction == kDirectionTypeRight) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_right.png", self.scenePrefix]];
        } else if (direction == kDirectionTypeUp) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_up.png", self.scenePrefix]];
        } else {
            CCLOG(@"Invalid direction in Ninja->switchToSenseiWithDirection:");
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_sensei_up_repeat.png", self.scenePrefix]];
        }
    }
}

-(void)switchToNinjaWithDirection:(DirectionTypes)direction {
    [self stopAction:self.blinkAction];
    self.secondsStayingIdle = 0;
    self.isNinjaBlinking = NO;
    self.isNinjaSenseiMode = NO;
    self.ninjaOpenEyes.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_eyes_1.png", self.scenePrefix]];
    self.position = ccp(self.position.x * 100/95, self.position.y);
    
    if (direction == kDirectionTypeDown) {
        self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_down.png", self.scenePrefix]];
        self.ninjaOpenEyes.position = self.defaultNinjaEyesDownPosition;
        self.ninjaStar.position = self.defaultNinjaStarDownPosition;
    } else {
        self.ninjaOpenEyes.position = self.defaultNinjaEyesPosition;
        self.ninjaStar.position = self.defaultNinjaStarPosition;
        if (direction == kDirectionTypeLeft) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_left.png", self.scenePrefix]];
        } else if (direction == kDirectionTypeRight) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_right.png", self.scenePrefix]];
        } else if (direction == kDirectionTypeUp) {
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_up.png", self.scenePrefix]];
        } else {
            CCLOG(@"Invalid direction in Ninja->switchToNinjaWithDirection:");
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_ninja_up_repeat.png", self.scenePrefix]];
        }
    }
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
    // blink every 2 seconds when idle
    self.secondsStayingIdle = self.secondsStayingIdle + deltaTime;
    if (self.secondsStayingIdle > 2.0f && self.isNinjaBlinking == NO) {
        [self blink];
    }
}

@end
