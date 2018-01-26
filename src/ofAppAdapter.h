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

- (void)setMode:(int)mode;
- (void)setText:(NSString *)text;

@end;

#if __cplusplus
class ofApp;
@interface ofAppAdapter(cplusplus)
- (id)initWithApp:(ofApp *)app;
@end
#endif


