//
//  GameManager.h
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface GameManager : NSObject

@property (nonatomic) BOOL isMusicOn;
@property (nonatomic) BOOL isSoundEffectsOn;
@property (nonatomic) BOOL hasPlayerDied;
@property (nonatomic) int score;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)openSiteWithLinkType:(LinkTypes)linkTypeToOpen;

@end
