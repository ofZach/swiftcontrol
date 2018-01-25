//
//  ofAppAdapter.h
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

//#ifndef ofAppAdapter_h
//#define ofAppAdapter_h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma once

@interface ofAppAdapter : NSObject;


- (id)initWithApp:(void *)app;
- (void)setMode:(int)mode;
- (void)setText:(NSString *)text;


@end;

//#endif /* ofAppAdapter_h */

