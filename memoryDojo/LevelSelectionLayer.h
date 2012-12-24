//
//  LevelSelectionLayer.h
//  memoryDojo
//
//  Created by Michael Gao on 12/10/12.
//
//

#import "CCLayer.h"
#import "CommonProtocols.h"

@interface LevelSelectionLayer : CCLayer

@property (nonatomic, weak) id<MainMenuLayerDelegate> delegate;
-(void)disableAllMenus;
-(void)enableAllMenus;

@end
