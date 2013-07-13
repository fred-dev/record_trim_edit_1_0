#pragma once

#include "ofMain.h"
#include "ofxXmlSettings.h"
//#include <Cocoa/Cocoa.h>
#include <AVFoundation/AVFoundation.h>
#include <CoreMedia/CoreMedia.h>
#include "ofxVideoRecorder.h"
#include "ofxOsc.h"
#include "ofxTimeline.h"
#include "ofxFileDialogOSX.h"
#include "MyButton.h"
#include "ofxQTKitVideoGrabber.h"



#define RECORDMODE 1
#define TRIMMODE 2
#define EDITMODE 3
#define PLAYBACKMODE 4

struct editKz {
  int inFrame;
  int outFrame;
  int startFrame;
  int endFrame;
  int timebase;
} ;

class testApp : public ofBaseApp{
  
public:
  void setup();
  void update();
  void draw();
    void exit();
  
  void keyPressed  (int key);
  void keyReleased(int key);
  void mouseMoved(int x, int y );
  void mouseDragged(int x, int y, int button);
  void mousePressed(int x, int y, int button);
  void mouseReleased(int x, int y, int button);
  void windowResized(int w, int h);
  void dragEvent(ofDragInfo dragInfo);
  void gotMessage(ofMessage msg);
  
  
  void openTheMovie(string fileName);
  void trim(AVAsset* asset);
  void editAV(AVAsset* asset);
  void exportMovie(AVAsset* asset, string fileName);


  string openFile();
    string saveFile();
    
    void audioIn(float * input, int bufferSize, int nChannels);
    
    void loadVideo(string videoPath);
  
  AVMutableComposition* mutableComposition;
  AVMutableVideoComposition* mutableVideoComposition;
  AVAsset* asset;
  
  vector <ofVec2f> edits;
  int timeStamper;
  
  
    vector <editKz> editsFCP;
  	ofxXmlSettings XML;
  string message;
    
    //Video Recorder
    
    ofxQTKitVideoGrabber      vidGrabber;
    ofxVideoRecorder    vidRecorder;
    ofSoundStream       soundStream;
    bool bRecording;
    int sampleRate;
    int channels;
    string fileName;
    string fileExt;
    
    ofFbo recordFbo;
    ofPixels recordPixels;
    
    int modeCount;
    
    //Timeline
    bool loaded;
    string lastFileName;
    int imageCount;
    int inPoint;
    ofFbo timelineFbo;
    
    bool hasEditied;
    ofxTimeline timeline;
    ofTrueTypeFont font;
    ofxXmlSettings          settings;
    ofxXmlSettings          appPresets;
    
    //OSC Stuff
    ofxOscReceiver          oscReciever;
    int oscInPort;
    
    //In case it crashes
    string chosenMovie;
    bool    isEditing;
    bool    isExported;
    
    //playback
    ofQTKitPlayer editedMovie;
    bool    playMovie;
    
    bool openedFile;
    string output;
    string  saveDestination;
    string recordLocation;
    
    
    bool setDestination;
    ofDirectory myDir;
    bool mustSetSaveDirectory;
    bool mustSetRecordDirectory;
    bool hasSetSaveDirectory;
    bool hasSetRecordDirectory;
    MyButton selectMovie ,selectOutputPath ,selectRecordPath, cancelOpenedMovie;
    ofImage logo;
    ofTrueTypeFont titleFont;
    ofTrueTypeFont  warningFont;
 
    
};

/*
 @interface AVSETrimCommand{
 
 }
 @property AVMutableComposition *mutableComposition;
 
 @end
 */