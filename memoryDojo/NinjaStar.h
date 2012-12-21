//
//  NinjaStar.h
//  memoryDojo
//
//  Created by Michael Gao on 11/18/12.
//
//

#import "GameObject.h"
#import "Constants.h"
#import "Ninja.h"

@interface NinjaStar : GameObject

-(id)initFromScene:(SceneTypes)scene;
-(void)shootNinjaStarFromNinja:(Ninja*)ninja withDirection:(DirectionTypes)direction;

@end
