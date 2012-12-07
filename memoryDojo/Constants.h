//
//  Constants.h
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#ifndef memoryDojo_Constants_h
#define memoryDojo_Constants_h

// complete round to level up
#define kGameLevel2Round 3
#define kGameLevel3Round 8
#define kGameLevel4Round 15
#define kGameLevel5Round 1
#define kGameLevel6Round 50
//#define kGameLevel2Round 3
//#define kGameLevel3Round 8
//#define kGameLevel4Round 15
//#define kGameLevel5Round 30
//#define kGameLevel6Round 50


typedef enum {
    kSceneTypeNone = 0,
    kSceneTypeMainMenu,
    kSceneTypeGame,
    kSceneTypeGameOver
} SceneTypes;

typedef enum {
    kLinkTypeTwitter = 1
} LinkTypes;

typedef enum {
    kGameStateNone = 0,
    kGameStateInit,
    kGameStateInstructions,
    kGameStateRoundDisplay,
    kGameStatePlay,
    kGameStateLevelUpScreen1,
    kGameStateLevelUpAnimation,
    kGameStateLevelUpGiftScreen,
    kGameStateLevelUpSmallCatScreen,
    kGameStateLevelUpScreen2,
    kGameStatePause
} GameStates;

typedef enum {
    kDirectionTypeNone = 0,
    kDirectionTypeLeft,
    kDirectionTypeDown,
    kDirectionTypeRight,
    kDirectionTypeUp
} DirectionTypes;

typedef enum {
    kCharacterStateIdle = 0,
    kCharacterStateLeft,
    kCharacterStateDown,
    kCharacterStateRight,
    kCharacterStateUp
} CharacterStates;

// audio items
#define AUDIO_MAX_WAITTIME 150

typedef enum {
    kAudioManagerUninitialized = 0,
    kAudioManagerFailed = 1,
    kAudioManagerInitializing = 2,
    kAudioManagerInitialized = 100,
    kAudioManagerLoading = 200,
    kAudioManagerReady = 300
    
} GameManagerSoundState;

#define SFX_NOTLOADED NO
#define SFX_LOADED YES

#define PLAYSOUNDEFFECT(...) \
[[GameManager sharedGameManager] playSoundEffect:@#__VA_ARGS__]

#define STOPSOUNDEFFECT(...) \
[[GameManager sharedGameManager] stopSoundEffect:__VA_ARGS__]

#endif
