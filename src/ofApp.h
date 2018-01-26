#pragma once
#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"

#include <Foundation/Foundation.h>

@class ARSession;

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

    void setMode(int mode);
    void setText(NSString *text);

protected:
    ARSession *session;
    ofVbo vbo;
    ofTrueTypeFont font;
    ARRef processor;
    ofImage img;
    ofCamera camera;


};


