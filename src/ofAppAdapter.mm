//
//  ofAppAdapter.m
//  zach-controls
//
//  Created by Ying Quan Tan on 1/25/18.
//

#import <Foundation/Foundation.h>

#import "ofAppAdapter.h"
#import "ofApp.h"

@interface ofAppAdapter()
@property (assign, nonatomic) ofApp *app;
@end

@implementation ofAppAdapter;

- (id)initWithApp:(ofApp *)app {
    self.app = (ofApp *)app;
    return self;
}

- (void)setMode:(int)mode {
    self.app->setMode(mode);
}
- (void)setText:(NSString *)text {
    self.app->setText(text);
}

@end;
