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
    kCharacterStateIdle = 0
} CharacterStates;

typedef enum {
    kGameObjectTypeNone = 0,
    kGameObjectTypeNinja
} GameObjectType;

@protocol GameplayLayerDelegate

-(void) createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue;

@end

#endif