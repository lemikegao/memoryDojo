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
    kStateIdle = 0
} CharacterStates;

typedef enum {
    kObjectTypeNone = 0,
    kNinjaType
} GameObjectType;

@protocol GameplayLayerDelegate

-(void) createObjectOfType:(GameObjectType)objectType atLocation:(CGPoint)spawnLocation withZValue:(int)ZValue;

@end

#endif
