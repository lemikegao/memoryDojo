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

#endif
