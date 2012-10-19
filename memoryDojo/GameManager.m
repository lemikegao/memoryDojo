//
//  GameManager.m
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import "GameManager.h"
#import "MainMenuScene.h"
#import "GameScene.h"
//#import "GameOverScene.h"

@interface GameManager()

@property (nonatomic) SceneTypes currentScene;

@end

@implementation GameManager

static GameManager *_sharedGameManager = nil;   // singleton
@synthesize currentScene = _currentScene;
@synthesize isMusicOn = _isMusicOn;
@synthesize isSoundEffectsOn = _isSoundEffectsOn;
@synthesize hasPlayerDied = _hasPlayerDied;

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class]) {
        if(!_sharedGameManager) {
            _sharedGameManager = [[self alloc] init];
        }
        return _sharedGameManager;
    }
    
    return nil;
}

+(id)alloc {
    @synchronized ([GameManager class]) {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocate a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    
    return nil;
}

-(id)init {
    self = [super init];
    if (self) {
        CCLOG(@"Game Manager singleton->init");
        _isMusicOn = YES;
        _isSoundEffectsOn = YES;
        _hasPlayerDied = NO;
        _currentScene = kSceneTypeNone;
    }
    
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = self.currentScene;
    self.currentScene = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kSceneTypeMainMenu:
            sceneToRun = [MainMenuScene node];
            break;
        case kSceneTypeGame:
            sceneToRun = [GameScene node];
            break;
        case kSceneTypeGameOver:
//            sceneToRun = [GameOverScene node];
            break;
        default:
            CCLOG(@"Unknown sceneID, cannot run scene");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back -- no new scene was found
        self.currentScene = oldScene;
        return;
    }
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
}

-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen {
    // place holder to open Twitter
}

@end
