#include "ofApp.h"
#import "zach_controls-Swift.h"
#import "PureLayout.h"
#import "ofAppAdapter.h"

int main() {
    
    //  here are the most commonly used iOS window settings.
    //------------------------------------------------------
    ofiOSWindowSettings settings;
    settings.enableRetina = false; // enables retina resolution if the device supports it.
    settings.enableDepth = false; // enables depth buffer for 3d drawing.
    settings.enableAntiAliasing = false; // enables anti-aliasing which smooths out graphics on the screen.
    settings.numOfAntiAliasingSamples = 0; // number of samples used for anti-aliasing.
    settings.enableHardwareOrientation = false; // enables native view orientation.
    settings.enableHardwareOrientationAnimation = false; // enables native orientation changes to be animated.
    settings.glesVersion = OFXIOS_RENDERER_ES1; // type of renderer to use, ES1, ES2, ES3
    settings.windowMode = OF_FULLSCREEN;
    ofCreateWindow(settings);

    ofApp *app = new ofApp;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ofxiOSAppDelegate *del = [UIApplication sharedApplication].delegate;
        UIViewController *parentVC = del.glViewController;

        ControlsViewController * controller = [[ControlsViewController alloc] initWithNibName:nil
                                                                                       bundle:nil];
        controller.app = [[ofAppAdapter alloc] initWithApp:app];
        [parentVC addChildViewController:controller];
        [parentVC.view addSubview:controller.view];
        [controller.view autoPinEdgesToSuperviewEdges];
    });

	return ofRunApp(app);
}
