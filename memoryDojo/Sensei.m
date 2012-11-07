//
//  Sensei.m
//  memoryDojo
//
//  Created by Michael Gao on 11/6/12.
//
//

#import "Sensei.h"

@interface Sensei()

@property (nonatomic, strong) CCSprite *senseiOpenEyes;
@property (nonatomic, strong) CCAnimation *blinkingAnim;
-(void)initAnimations;

@end

@implementation Sensei

-(id)init {
    self = [super initWithSpriteFrameName:@"game_sensei_neutral.png"];
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeSensei;
        self.characterState = kCharacterStateIdle;
        
        // add eyes
        self.senseiOpenEyes = [CCSprite spriteWithSpriteFrameName:@"game_ninja_eyes_1.png"];
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.64f);
        [self addChild:self.senseiOpenEyes z:100];
        
        // initialize blinking
#warning -- change blinking so that the timer begins if player is IDLE (blink after 1 sec of idleness)
        
        id blinkAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], nil]];
        [self.senseiOpenEyes runAction:blinkAction];
    }
    
    return self;
}

-(void)initAnimations {
    self.blinkingAnim = [self loadPlistForAnimationWithName:@"blinkingAnim" andClassName:NSStringFromClass([self class])];
    self.blinkingAnim.restoreOriginalFrame = YES;
}

-(void)changeState:(CharacterStates)newState {
    [self stopAllActions];
    id action = nil;
    self.characterState = newState;
    
    // adjust sensei eyes
    if (newState == kCharacterStateDown) {
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.574f);
    } else {
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
    }
    
    switch (newState) {
        case kCharacterStateIdle:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_neutral"];
            break;
            
        case kCharacterStateLeft:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_left.png"];
            break;
            
        case kCharacterStateDown:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_down.png"];
            break;
            
        case kCharacterStateRight:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_right.png"];
            break;
            
        case kCharacterStateUp:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up.png"];
            break;
            
        default:
            CCLOG(@"Unhandled state %d in Sensei", newState);
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

@end