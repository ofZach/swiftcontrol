#include "ofApp.h"
#import "ofxARKit.h"
#import "zach_controls-Swift.h"
#import <ARKit/ARKit.h>

void logSIMD(const simd::float4x4 &matrix)
{
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
}

ofMatrix4x4 matFromSimd(const simd::float4x4 &matrix){
    ofMatrix4x4 mat;
    mat.set(matrix.columns[0].x,matrix.columns[0].y,matrix.columns[0].z,matrix.columns[0].w,
            matrix.columns[1].x,matrix.columns[1].y,matrix.columns[1].z,matrix.columns[1].w,
            matrix.columns[2].x,matrix.columns[2].y,matrix.columns[2].z,matrix.columns[2].w,
            matrix.columns[3].x,matrix.columns[3].y,matrix.columns[3].z,matrix.columns[3].w);
    return mat;
}


//--------------------------------------------------------------
void ofApp::setup(){
    ARCore::SFormat format;
    format.enablePlaneTracking().enableLighting();
    session = [ARCore::generateNewSession(format) retain];
    processor = ARProcessor::create(session);
    processor->setup();
    img.load("Default.png");
}
vector < matrix_float4x4 > mats;
//--------------------------------------------------------------
void ofApp::update() {

    processor->update();

    mats.clear();

    if (session.currentFrame){
        NSInteger anchorInstanceCount = session.currentFrame.anchors.count;

        for (NSInteger index = 0; index < anchorInstanceCount; index++) {
            ARAnchor *anchor = session.currentFrame.anchors[index];

            // Flip Z axis to convert geometry from right handed to left handed
            matrix_float4x4 coordinateSpaceTransform = matrix_identity_float4x4;
            coordinateSpaceTransform.columns[2].z = -1.0;

            matrix_float4x4 newMat = matrix_multiply(anchor.transform, coordinateSpaceTransform);
            mats.push_back(newMat);
            logSIMD(newMat);
            //anchorUniforms->modelMatrix = matrix_multiply(anchor.transform, coordinateSpaceTransform);
        }
    }

}


//--------------------------------------------------------------
void ofApp::draw(){
    float time = ofGetElapsedTimef();

//    ofDrawRectangle(200, 200 + sin(time) * 80, 50, 50);

    ofPushStyle();
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofDrawRectangle(200, 200, 50, 50);
    ofPopStyle();


    // MARK: AR Stuff
    ofEnableAlphaBlending();

    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();


    if (session.currentFrame){
        if (session.currentFrame.camera){

            camera.begin();
            processor->setARCameraMatrices();

            for (int i = 0; i < mats.size(); i++){
                ofPushMatrix();
                //mats[i].operator=(const simd_float4x4 &)
                ofMatrix4x4 mat;
                mat.set(mats[i].columns[0].x, mats[i].columns[0].y,mats[i].columns[0].z,mats[i].columns[0].w,
                        mats[i].columns[1].x, mats[i].columns[1].y,mats[i].columns[1].z,mats[i].columns[1].w,
                        mats[i].columns[2].x, mats[i].columns[2].y,mats[i].columns[2].z,mats[i].columns[2].w,
                        mats[i].columns[3].x, mats[i].columns[3].y,mats[i].columns[3].z,mats[i].columns[3].w);
                ofMultMatrix(mat);

                ofSetColor(255);
                ofRotate(90,0,0,1);

                float aspect = ARCommon::getNativeAspectRatio();
                img.draw(-aspect/8,-0.125,aspect/4,0.25);


                ofPopMatrix();
            }

            camera.end();
        }

    }
    ofDisableDepthTest();
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
    ofLog() << "mouse " << mouseX << "," << mouseY << endl;

    if ((ofPoint(mouseX, mouseY) - ofPoint(200, 200)).length() < 50) {
        ofxiOSAppDelegate *del = [UIApplication sharedApplication].delegate;
        UIViewController *parentVC = del.glViewController;
        for (id controller in parentVC.childViewControllers) {
            if ([controller isKindOfClass:[ControlsViewController class]]) {
                ControlsViewController *controlsVC = controller;
                [controlsVC showDrawer];
            }
        }
    }
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
