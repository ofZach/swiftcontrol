#include "ofApp.h"
#import "ofxARKit.h"
#import <ARKit/ARKit.h>

//--------------------------------------------------------------
void ofApp::setup(){
    ARCore::SFormat format;
    format.enablePlaneTracking().enableLighting();
    session = [ARCore::generateNewSession(format) retain];

}

//--------------------------------------------------------------
void ofApp::update(){

}

//--------------------------------------------------------------
void ofApp::draw(){
    float time = ofGetElapsedTimef() * 0.2;

    ofDrawRectangle(200, 500 + sin(time) * 80, 50, 50);
}

void ofApp::setMode(int mode) {
    ofLog() << "mode = " << mode << endl;
}

void ofApp::setText(NSString *text) {
    ofLog() << "text = " << [text UTF8String] << endl;
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    ofLog() << "touched" << endl;
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}
