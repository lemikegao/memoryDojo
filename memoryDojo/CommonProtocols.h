//
//  CommonProtocols.h
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#ifndef memoryDojo_CommonProtocols_h
#define memoryDojo_CommonProtocols_h

typedef enum {
    kGameObjectTypeNone = 0,
    kGameObjectTypeNinja,
    kGameObjectTypeSensei,
    kGameObjectTypeNinjaStar
} GameObjectType;

@protocol GameplayLayerDelegate

-(void) createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue;

@end

@protocol MainMenuSceneDelegate

-(void)showSettings;
-(void)hideSettings;
-(void)disableAllMenus;
-(void)enableAllMenus;

@end

@protocol MainMenuLayerDelegate

-(void) showUpgradesForLevel:(int)newLevel fromLevel:(int)oldLevel;

@end

#endif
