//
//  MainMenuLayer.h
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import "CCLayer.h"
#import "CommonProtocols.h"

@interface MainMenuLayer : CCLayer <MainMenuLayerDelegate>

@property (nonatomic, weak) id<MainMenuSceneDelegate> mainMenuSceneDelegate;
@property (nonatomic) BOOL enableGestures;

@end
