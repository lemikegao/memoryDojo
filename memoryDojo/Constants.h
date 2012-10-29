//
//  Constants.h
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#ifndef memoryDojo_Constants_h
#define memoryDojo_Constants_h

#define kMainMenuTagValue 1
#define kProgressTimerTagValue 2

#define kProgressZValue 100
#define kInitialTimer 4.0f

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
    kDirectionTypeNone = 0,
    kDirectionTypeLeft,
    kDirectionTypeDown,
    kDirectionTypeRight,
    kDirectionTypeUp
} DirectionTypes;

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
