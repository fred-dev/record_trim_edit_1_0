#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    
//************OSC INSTRUCTIONS- Message with address "/Recording" and an int of value 1 starts recording. Same address with value 0 stops recording
                        //
 
    
    ofSetVerticalSync(true);

    XML.setVerbose(true);
    
	message = "loading mySettings.xml";
 	if( XML.loadFile("SPAHIPSMAYxml.xml") ){
		message = "mySettings.xml loaded!";
	}else{
		message = "unable to load mySettings.xml check data/ folder";
	}
    cout << message << endl;
    message = "loading App_Presets.xml";
 	if( appPresets.loadFile("App_Presets.xml") ){
		message = "App_Presets.xml loaded!";
	}else{
		message = "unable to load App_Presets.xml check data/ folder";
	}
    cout << message << endl;
	//-------
    
    XML.pushTag("xmeml");
    
    if (XML.getNumTags("project") >0){
        XML.pushTag("project");
        XML.pushTag("children");
    }
    
    XML.pushTag("sequence");
    XML.pushTag("media");
    XML.pushTag("video");
    XML.pushTag("track");
    
	int numDragTags = XML.getNumTags("clipitem");
    cout << "numDragTags" << numDragTags << endl;
	//if there is at least one <STROKE> tag we can read the list of points
	//and then try and draw it as a line on the screen
	if(numDragTags > 0){
        
        //<in>1796</in>
        //<out>1853</out>
        //<start>0</start>
        //<end>57</end>
        for(int i = 0; i < numDragTags; i++){
            XML.pushTag("clipitem", i);
            
            editKz editTemp;
            
            //the last argument of getValue can be used to specify
            //which tag out of multiple tags you are refering to.
            editTemp.inFrame = XML.getValue("in", 0);
            editTemp.outFrame = XML.getValue("out", 0);
            editTemp.startFrame = XML.getValue("start", 0);
            editTemp.endFrame = XML.getValue("end", 0);
            cout <<   editTemp.inFrame << " " << editTemp.outFrame << " " <<   editTemp.startFrame << " " << editTemp.endFrame <<  endl;
            
            XML.popTag();
            
            editsFCP.push_back(editTemp);
        }
        
        
		//this pops us out of the STROKE tag
		//sets the root back to the xml document
		XML.popTag();
        XML.popTag();
        XML.popTag();
        XML.popTag();
        XML.popTag();
	}
    
	//load a monospaced font
	//which we will use to show part of the xml structure
    
    
    
    
    
    timeStamper = 25;
    /*
     edits.push_back(ofVec2f(0,600));  // inPoint (Sourcefile , duration) - 600 with timeStamper 600 = 1 second. might have to change to KKKinPoint, KKKoutPoint
     edits.push_back(ofVec2f(300,600));
     edits.push_back(ofVec2f(500,600));
     edits.push_back(ofVec2f(500,100));
     edits.push_back(ofVec2f(500,100));
     edits.push_back(ofVec2f(500,100));
     */
    for (int i=0;i< editsFCP.size();i++){
        edits.push_back(ofVec2f(editsFCP[i].inFrame,editsFCP[i].outFrame-editsFCP[i].inFrame));
        cout << editsFCP[i].inFrame << " " << (editsFCP[i].outFrame-editsFCP[i].inFrame) << endl;
    }
    
    for (int i=0;i< 350;i++){
        int inP= ofRandom(25*(60+55));
        edits.push_back(ofVec2f(inP,5));
        cout << inP << " " << 25 << endl;
    }
    
    
    
    
    
    
    //video Recorder
    
    sampleRate = 48000;
    channels = 2;
    
    ofSetFrameRate(50);
    ofSetLogLevel(OF_LOG_VERBOSE);
    vidGrabber.listDevices();
    //vidGrabber.setDeviceID(4);
    vidGrabber.setDesiredFrameRate(25);
    vidGrabber.listVideoCodecs();
    vidGrabber.listAudioCodecs();
    vidGrabber.setVideoCodec("QTCompressionOptionsLosslessAnimationVideo");
    vidGrabber.setAudioCodec("QTCompressionOptionsHighQualityAACAudio");
    vidGrabber.initGrabber(1920, 1080);
    //    vidRecorder.setFfmpegLocation(ofFilePath::getAbsolutePath("ffmpeg")); // use this is you have ffmpeg installed in your data folder
    
    fileName = "Recording_";
    fileExt = ".mov"; // ffmpeg uses the extension to determine the container type. run 'ffmpeg -formats' to see supported formats
    
    // override the default codecs if you like
    // run 'ffmpeg -codecs' to find out what your implementation supports (or -formats on some older versions)
    vidRecorder.setVideoCodec("mpeg4");
    vidRecorder.setVideoBitrate("25000k");
    vidRecorder.setAudioCodec("mp3");
    vidRecorder.setAudioBitrate("640k");
    
    soundStream.listDevices();
    //soundStream.setDeviceID(11);
    soundStream.setup(this, 0, channels, sampleRate, 256, 4);
    
    ofSetWindowShape(vidGrabber.getWidth(), vidGrabber.getHeight()	);
    bRecording = false;
    ofEnableAlphaBlending();
    
    //Timeline
    
    timeline.setup();
    timeline.setFrameRate(25);
	timeline.setDurationInFrames(90);
	timeline.setLoopType(OF_LOOP_NORMAL);
    ofxTLVideoTrack* videoTrack = timeline.addVideoTrack("Video", lastFileName);
    
    font.loadFont("GUI/NewMedia Fett.ttf", 15, true, true);
	font.setLineHeight(34.0f);
	font.setLetterSpacing(1.035);
    timelineFbo.allocate(1920, 1080);
    
    
    //OSC Recieve
    oscInPort=appPresets.getValue("OSCINPORT", 6003);
    oscReciever.setup(oscInPort);
    
    //In case it crashes
    chosenMovie=appPresets.getValue("CHOSEN_MOVIE", "NULL");
    
    //Playback
    ofBackground(255, 255, 255);
    
	
	
    mustSetSaveDirectory=false;
    hasSetSaveDirectory=false;
    
    modeCount=RECORDMODE;
    hasEditied=false;
    playMovie=false;
    ofSetBackgroundColor(0, 0, 0);
    output ="";
    openedFile=false;
    saveDestination=appPresets.getValue("SAVEDESTINATION", "/Users/fredrodrigues/desktop");
    recordLocation=appPresets.getValue("RECORDDESTINATION", "/Users/fredrodrigues/desktop");
    if (myDir.doesDirectoryExist(saveDestination)!=true) {
        mustSetSaveDirectory=true;
    }
    if (myDir.doesDirectoryExist(recordLocation)!=true) {
        mustSetRecordDirectory=true;
    }
    
    //Buttons
    
    selectOutputPath.set(100, 500, 200, 50);
    selectRecordPath.set(100, 600, 200, 50);
    selectMovie.set(100, 700, 200, 50);
    cancelOpenedMovie.set(100, 800, 200, 50);
    
    
    // Candy
    logo.loadImage("pipslabLogo.gif");
    titleFont.loadFont("GUI/NewMedia Fett.ttf", 35, true, true);
    warningFont.loadFont("GUI/NewMedia Fett.ttf", 45, true, true);
    
    isEditing=false;
    
    
    



}

//--------------------------------------------------------------
void testApp::update(){
    switch (modeCount) {
        case RECORDMODE:
            vidGrabber.update();
            
            
            if (selectMovie.isMousePressed(0)) {
                chosenMovie=openFile();
                openedFile=true;
                lastFileName=chosenMovie;
                
            }
            if (selectOutputPath.isMousePressed(0)) {
                saveDestination=saveFile();
                appPresets.setValue("SAVEDESTINATION", saveDestination);
                appPresets.saveFile();
                mustSetSaveDirectory=false;
            }
            if (selectRecordPath.isMousePressed(0)) {
                recordLocation=saveFile();
                appPresets.setValue("RECORDDESTINATION", recordLocation);
                appPresets.saveFile();
                mustSetRecordDirectory=false;
            }
            if (cancelOpenedMovie.isMousePressed(0)) {
                openedFile=false;
            }
            
            if(vidGrabber.isFrameNew() && bRecording){
                vidRecorder.addFrame(vidGrabber.getPixelsRef());
            }
            while (oscReciever.hasWaitingMessages()) {
                    ofxOscMessage m;
                    oscReciever.getNextMessage(&m);
                if (m.getAddress()=="/Recording") {
                    if (m.getArgAsInt32(0)==1) {
                        bRecording ==true;
                        if(bRecording && !vidRecorder.isInitialized()) {
                            lastFileName=fileName+ofGetTimestampString()+fileExt;
                            cout<<recordLocation+"/"+lastFileName+"/n";
                            vidRecorder.setup(recordLocation+"/"+lastFileName, vidGrabber.getWidth(), vidGrabber.getHeight(), 25, sampleRate, channels);
                            //          vidRecorder.setup(fileName+ofGetTimestampString()+fileExt, vidGrabber.getWidth(), vidGrabber.getHeight(), 30); // no audio
                            //            vidRecorder.setup(fileName+ofGetTimestampString()+fileExt, 0,0,0, sampleRate, channels); // no video
                            //          vidRecorder.setupCustomOutput(vidGrabber.getWidth(), vidGrabber.getHeight(), 30, sampleRate, channels, "-vcodec mpeg4 -b 1600k -acodec mp2 -ab 128k -f mpegts udp://localhost:1234"); // for custom ffmpeg output string (streaming, etc)
                        }
                        
                    }
                    if (m.getArgAsInt32(0)==0) {
                        bRecording = false;
                        vidRecorder.close();
                        
                    }
                }
                
                
            }
            break;
        case EDITMODE:
            if (hasEditied==false) {
                isEditing=true;
                if (openedFile==true) {
                    openTheMovie(chosenMovie);
                    cout<<"Editing opened Movie "+chosenMovie+"\n";
                }
                if (openedFile==false) {
                    string tempLoc =recordLocation+"/"+lastFileName;
                    openTheMovie(tempLoc);
                    cout<<"Editing recorded Movie "+tempLoc+"\n";
                }
                
                // openTheMovie("/Users/keezpipslab/Movies/theone.mov");
                NSLog(@"Ok:%f",asset.preferredRate);
                // insertionPoint = kCMTimeZero;
                // cout << "asset.duration:" << asset.duration << endl;
                cout << "about to edit" << endl;
                editAV(asset);
                cout << "about to export" << endl;
                isEditing=false;
            

                cout<<"Exporting to "+ saveDestination + "/ouputNu.mov \n";
                // exportMovie(asset, "/Users/keezpipslab/Movies/movies_socialfiction/ouputNu.mov");
                exportMovie(asset, "ouputNu.mov");
                hasEditied=true;
                
            }
            
            break;
        case PLAYBACKMODE:
            editedMovie.update();
            while (oscReciever.hasWaitingMessages()) {
                ofxOscMessage m;
                oscReciever.getNextMessage(&m);
                if (m.getAddress()=="/playMovie") {
                    if (m.getArgAsInt32(0)==1) {
                        playMovie ==true;                           
            }
            break;
            
                }
            }
    }
}

//--------------------------------------------------------------
void testApp::draw(){
   
    
    
    stringstream ss;
    switch (modeCount) {
        case RECORDMODE:
            ofBackground(0, 0, 0);
            ofPushStyle();
            ofSetColor(200, 12, 12);
            titleFont.drawString("The Edit Machine", 750, 95);
            ofPopStyle();
            logo.draw(1600,50);
            selectRecordPath.draw();
            selectOutputPath.draw();
            selectMovie.draw();
            cancelOpenedMovie.draw();
            vidGrabber.draw(vidGrabber.getWidth()/4,vidGrabber.getHeight()/4,vidGrabber.getWidth()/2,vidGrabber.getHeight()/2);
            
            ofSetColor(255, 255, 255);
            
            font.drawString("To start recording press 'r' ", 100, 150);
            font.drawString("To complete the recording press 'c' ", 100, 175);
            font.drawString("Open a recorded file", selectMovie.getMinX(), selectMovie.getMinY()-5);
            font.drawString("Set export location", selectOutputPath.getMinX(), selectOutputPath.getMinY()-5);
            font.drawString("Export Location " + saveDestination, 100, 200);
            font.drawString("Record Location " + recordLocation, 100, 225);
            font.drawString("Select record Location ", selectRecordPath.getMinX(), selectRecordPath.getMinY()-5);
            font.drawString("Cancel Opened Movie ", cancelOpenedMovie.getMinX(), cancelOpenedMovie.getMinY()-5);
            
            if (openedFile) {
                font.drawString("File opened for processing " + chosenMovie, 100, 250);
            }
            
            ofSetColor(0,0,0,100);
            ofRect(0, 0, 260, 75);
            ofSetColor(255, 255, 255);
            ofDrawBitmapString(ss.str(),15,15);
            
            
            if(bRecording){
                openedFile=false;
                ofPushStyle();
                ofSetColor(255, 0, 0);
                font.drawString("Recording", 910, 120);
                ofCircle(960*1.5 + 20,540/2- 20, 10);
                ofPopStyle();
            }
            if (mustSetSaveDirectory) {
                ofPushStyle();
                ofSetColor(255, 0, 0);
                warningFont.drawString("INVALID EXPORT DESTINATION!!!!!", 600, 900);
                ofPopStyle();
                
            }
            if (mustSetRecordDirectory) {
                ofPushStyle();
                ofSetColor(255, 0, 0);
                warningFont.drawString("INVALID RECORD DESTINATION!!!!!", 600, 980);
                ofPopStyle();
                
            }
            break;
        
        case   TRIMMODE:
            
            timelineFbo.begin();
            ofClear(0, 0, 0);
            ofSetColor(255, 255, 255);
            timeline.draw();
            if (loaded) {
                timeline.getVideoPlayer("Video")->draw(timeline.getVideoPlayer("Video")->getWidth()/4,timeline.getVideoPlayer("Video")->getHeight()/4,timeline.getVideoPlayer("Video")->getWidth()/2,timeline.getVideoPlayer("Video")->getHeight()/2);
                inPoint = timeline.getInTimeInMillis();
                ofPushStyle();
                ofSetColor(255, 255, 255);
                font.drawString("In point " + ofToString(inPoint), 100,200);
            
                ofPopStyle();
                
                }
            timelineFbo.end();
            timelineFbo.draw(0, 0);
            break;
            
        case EDITMODE:
            if (isEditing==true&&isExported==false) {
                ofSetColor(255, 255, 255);
                font.drawString("Editing movie", 960, 540);
            }
            if (isEditing==true&&isExported==false) {
                ofSetColor(255, 255, 255);
                font.drawString("Exporting, relax", 960, 540);
            }
            if (isExported) {
                ofSetColor(255, 255, 255);
                font.drawString("Klaar", 960, 540);
                
            }
            break;
            
        case PLAYBACKMODE:
            ofBackground(0,0,0);
            if (playMovie==true) {
                editedMovie.draw(0, 0, 1920, 1080);
                //editedMovie.draw(960/2, 540/2, 960, 540);
            }
        default:
            break;
    }
    
    
}

string testApp::openFile(){
	// first, create a string that will hold the URL
	string URL;
	
	// openFile(string& URL) returns 1 if a file was picked
	// returns 0 when something went wrong or the user pressed 'cancel'
	int response = ofxFileDialogOSX::openFile(URL);
	if(response){
		// now you can use the URL
		return URL;
        cout<<URL + "\n";
        openedFile=true;
	}else {
		output = "OPEN canceled. ";
	}
}

string testApp::saveFile(){
	// create a string to hold the folder URL
	string folderURL;
	
	// and one for the filename
	string fileName;
	// saveFile(string& folderURL, string& fileName) returns 1 if a folder + file were specified
	// returns 0 when something went wrong or the user pressed 'cancel'
	int response = ofxFileDialogOSX::saveFile(folderURL, fileName);
	if(response){
		// now you can use the folder URL and the filename.
        cout<<fileName + "\n";
        return folderURL;
		output = "SAVE: \n "+fileName+"\n to: \n "+folderURL;
	}else {
		output = "SAVE canceled ";
	}
}

void testApp::audioIn(float *input, int bufferSize, int nChannels){
    
    if(bRecording)
        vidRecorder.addAudioSamples(input, bufferSize, nChannels);
}
void testApp::loadVideo(string videoPath){
    ofxTLVideoTrack* videoTrack = timeline.getVideoTrack("Video");
    
    if(videoTrack == NULL){
	    videoTrack = timeline.addVideoTrack("Video", videoPath);
        loaded = (videoTrack != NULL);
    }
    else{
        loaded = videoTrack->load(videoPath);
    }
    
    if(loaded){
        //timeline.clear();
        //At the moment with video and audio tracks
        //ofxTimeline only works correctly if the duration of the track == the duration of the timeline
        //plan is to be able to fix this but for now...
        timeline.setFrameRate(videoTrack->getPlayer()->getTotalNumFrames()/videoTrack->getPlayer()->getDuration());
        timeline.setDurationInFrames(videoTrack->getPlayer()->getTotalNumFrames());
        timeline.setTimecontrolTrack(videoTrack); //video playback will control the time
		timeline.bringTrackToTop(videoTrack);
    }
    else{
        videoPath = "";
    }
    settings.setValue("videoPath", videoPath);
    settings.saveFile();
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){
    
    if(key=='r'){
        bRecording = !bRecording;
        if(bRecording && !vidRecorder.isInitialized()) {
            lastFileName=fileName+ofGetTimestampString()+fileExt;
            cout<<recordLocation+"/"+lastFileName+"/n";
            vidRecorder.setup(recordLocation+"/"+lastFileName, vidGrabber.getWidth(), vidGrabber.getHeight(), 25, sampleRate, channels);

        }
    }
    if(key=='c'){
        bRecording = false;
        vidRecorder.close();
    }

    if(key=='1'){
        cancelOpenedMovie.enabled=true;
        selectMovie.enabled=true;
        selectOutputPath.enabled=true;
        selectRecordPath.enabled=true;
        modeCount=RECORDMODE;
        
    }
    if(key=='2'){
        modeCount=TRIMMODE;
        if (openedFile==true) {
            loadVideo(chosenMovie);
            cout<< "Movie chosen from trim is "+chosenMovie +"\n";
            appPresets.setValue("CHOSEN_MOVIE", chosenMovie);
            appPresets.saveFile();
        }
        if (openedFile==false) {
            loadVideo(recordLocation+"/"+lastFileName);
            cout<< "Movie chosen from trim is "+recordLocation+"/"+lastFileName +"\n";
            appPresets.setValue("CHOSEN_MOVIE", recordLocation+"/"+lastFileName);
            appPresets.saveFile();
        }
        
        
        
        cancelOpenedMovie.enabled=false;
        selectMovie.enabled=false;
        selectOutputPath.enabled=false;
        selectRecordPath.enabled=false;
    }
    if(key=='3'){
        modeCount=EDITMODE;
        cancelOpenedMovie.enabled=false;
        selectMovie.enabled=false;
        selectOutputPath.enabled=false;
        selectRecordPath.enabled=false;
        
    }
    if(key=='4'){
        ofQTKitDecodeMode decodeMode = OF_QTKIT_DECODE_TEXTURE_ONLY;
        editedMovie.loadMovie(saveDestination+"/"+lastFileName, decodeMode);
        editedMovie.setSpeed(1.0);
        editedMovie.setLoopState(OF_LOOP_NONE);
        editedMovie.setSynchronousSeeking(false);
        modeCount=PLAYBACKMODE;
        cancelOpenedMovie.enabled=false;
        selectMovie.enabled=false;
        selectOutputPath.enabled=false;
        selectRecordPath.enabled=false;
    }
    if (modeCount==PLAYBACKMODE) {
        if (key=='p') {
                playMovie=true;
            editedMovie.play();
        }
    }
    if (modeCount==TRIMMODE) {
        if (key=='i') {
            timeline.setInPointAtFrame(timeline.getCurrentFrame());
        }
        if (key=='o') {
            timeline.setOutPointAtFrame(timeline.getCurrentFrame());
        }
        if (key==OF_KEY_RIGHT) {
            timeline.setInPointAtFrame(timeline.getInFrame()+1);
            timeline.getVideoTrack("Video")->selectFrame(timeline.getInFrame());
            
        }
        if (key==OF_KEY_LEFT) {
            timeline.setInPointAtFrame(timeline.getInFrame()-1);
            timeline.getVideoTrack("Video")->selectFrame(timeline.getInFrame());
        }
        
    }
    if (key=='f') {
        ofToggleFullscreen();
    }
    
    if (modeCount==RECORDMODE) {
        if (key=='o') {
            //openFile();
        }
        if (key=='s') {
           // saveFile();
        }
    }

}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
    
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
    
}
void testApp::exit() {
    vidRecorder.close();
}
//--------------------------------------------------------------
void testApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
    
}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){
    
}

void testApp::openTheMovie(string fileName){
    NSString *objcFileNameString = [NSString stringWithCString:fileName.c_str() encoding:[NSString defaultCStringEncoding]];
    
    asset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:objcFileNameString] options:nil];
    
    // AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:@""] options:nil];
}

void testApp::editAV(AVAsset* asset){
    AVAssetTrack *videoTrack = nil;
    AVAssetTrack *audioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    }
    
    
    NSError * error = nil;
    
    mutableComposition = [AVMutableComposition composition];
    //
    if(videoTrack != nil) {
        AVMutableCompositionTrack *vtrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        int total = 0;
        for (int i=0; i<edits.size(); i++) {
            CMTime partInPoint = CMTimeMake((int)edits[i][0], timeStamper);
            CMTime partDuration = CMTimeMake((int)edits[i][1], timeStamper);
            CMTime insertionPoint = CMTimeMake(total, timeStamper);
            [vtrack insertTimeRange:CMTimeRangeMake(partInPoint, partDuration) ofTrack:videoTrack atTime:insertionPoint error:&error];
            total += (int)edits[i][1];
        }
        
        
    }
    if(audioTrack != nil) {
        AVMutableCompositionTrack *atrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        int total = 0;
        for (int i=0; i<edits.size(); i++) {
            CMTime partInPoint = CMTimeMake((int)edits[i][0], timeStamper);
            CMTime partDuration = CMTimeMake((int)edits[i][1], timeStamper);
            CMTime insertionPoint = CMTimeMake(total, timeStamper);
            [atrack insertTimeRange:CMTimeRangeMake(partInPoint, partDuration) ofTrack:audioTrack atTime:insertionPoint error:&error];
            total += (int)edits[i][1];
        }
        //[atrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimmedDuration) ofTrack:audioTrack atTime:insertionPoint error:&error];
    }
    //}else {
    // Remove the second half of the existing composition to trim
    // [mutableComposition removeTimeRange:CMTimeRangeMake(trimmedDuration, [mutableComposition duration])];
    //}
}



void testApp::trim(AVAsset* asset){
    AVAssetTrack *videoTrack = nil;
    AVAssetTrack *audioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    }
    
    CMTime insertionPoint = kCMTimeZero;
    NSError * error = nil;
    // Trim to half duration
    double halfDuration = CMTimeGetSeconds([asset duration])/2.0;
    CMTime trimmedDuration = CMTimeMakeWithSeconds(halfDuration, 1);
    // Check if a composition already exists, i.e., another tool has been applied
    //if(!mutableComposition){
    // Create a new composition
    //// AVMutableComposition* mutableComposition;
    mutableComposition = [AVMutableComposition composition];
    // Insert half time range of the video and audio tracks from AVAsset
    if(videoTrack != nil) {
        AVMutableCompositionTrack *vtrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [vtrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimmedDuration) ofTrack:videoTrack atTime:insertionPoint error:&error];
    }
    if(audioTrack != nil) {
        AVMutableCompositionTrack *atrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [atrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimmedDuration) ofTrack:audioTrack atTime:insertionPoint error:&error];
    }
    //}else {
    // Remove the second half of the existing composition to trim
    // [mutableComposition removeTimeRange:CMTimeRangeMake(trimmedDuration, [mutableComposition duration])];
    //}
}


void testApp::exportMovie(AVAsset* asset, string fileName){
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *outputURL = [paths objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *objcFileNameString = [NSString stringWithCString:fileName.c_str() encoding:[NSString defaultCStringEncoding]];
    
    
    
    // outputURL = [outputURL stringByAppendingPathComponent:@"outputNu.mp4"];
    outputURL = [outputURL stringByAppendingPathComponent: objcFileNameString];
    // Remove Existing File
    [manager removeItemAtPath:outputURL error:nil];
    
    //dispatch_queue_t exportQueue = dispatch_queue_create("Export Queue", NULL);
    // Create an export session with the composition
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:[mutableComposition copy] presetName:AVAssetExportPresetAppleProRes422LPCM];
    
    //exportSession.videoComposition = mutableVideoComposition;
    // exportSession.audioMix = mutableAudioMix;
    //exportSession.videoComposition = mutableVideoComposition;
    
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType=AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void){
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                // Notify AVSEDocument about export completion
                // [[NSNotificationCenter defaultCenter]
                //  postNotificationName:AVSEExportNotification
                //  object:self];
                NSLog(@"Okay, Exported like a motherfucker");
               
                isExported=true;
                break;
            case AVAssetExportSessionStatusFailed:
                //
                NSLog(@"Failed:%@",exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                //
                NSLog(@"Canceled:%@",exportSession.error);
                break;
            default:
                break;
        }
    }];
    
}





/*
 
 string conversion
 NSString *objcString = [NSString stringWithCString:cppString.c_str() encoding:[NSString defaultCStringEncoding]];
 
 
 // 5 - Create exporter
 AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
 presetName:AVAssetExportPresetHighestQuality];
 exporter.outputURL=url;
 exporter.outputFileType = AVFileTypeQuickTimeMovie;
 exporter.shouldOptimizeForNetworkUse = YES;
 [exporter exportAsynchronouslyWithCompletionHandler:^{
 dispatch_async(dispatch_get_main_queue(), ^{
 [self exportDidFinish:exporter];
 });
 
 ////
 
 
 
 @implementation AVSETrimCommand
 
 @synthesize mutableComposition;
 
 - (void)performWithAsset:(AVAsset*)asset
 {
 AVAssetTrack *videoTrack = nil;
 AVAssetTrack *audioTrack = nil;
 // Check if the asset contains video and audio tracks
 if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
 videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
 }
 if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
 audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
 }
 
 CMTime insertionPoint = kCMTimeZero;
 NSError * error = nil;
 // Trim to half duration
 double halfDuration = CMTimeGetSeconds([asset duration])/2.0;
 CMTime trimmedDuration = CMTimeMakeWithSeconds(halfDuration, 1);
 // Check if a composition already exists, i.e., another tool has been applied
 if(!mutableComposition){
 // Create a new composition
 mutableComposition = [AVMutableComposition composition];
 // Insert half time range of the video and audio tracks from AVAsset
 if(videoTrack != nil) {
 AVMutableCompositionTrack *vtrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
 [vtrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimmedDuration) ofTrack:videoTrack atTime:insertionPoint error:&error];
 }
 if(audioTrack != nil) {
 AVMutableCompositionTrack *atrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
 [atrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, trimmedDuration) ofTrack:audioTrack atTime:insertionPoint error:&error];
 }
 }else {
 // Remove the second half of the existing composition to trim
 [mutableComposition removeTimeRange:CMTimeRangeMake(trimmedDuration, [mutableComposition duration])];
 }
 
 // Notify AVSEDocument class to reload the player view with the changes
 [[NSNotificationCenter defaultCenter]
 postNotificationName:AVSEReloadNotification
 object:self];
 }
 
 @end
 */