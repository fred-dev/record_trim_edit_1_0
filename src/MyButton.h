/********  Test sample for ofxInteractiveObject									********/
/********  Make sure you open your console to see all the events being output	********/


#pragma once

#include "ofxMSAInteractiveObject.h"

#define		IDLE_COLOR		0xFFFFFF
#define		OVER_COLOR		0x00FF00
#define		DOWN_COLOR		0xFF0000


class MyButton : public ofxMSAInteractiveObject {
public:
	void setup() {
		printf("MyButton::setup() - hello!\n");
		enableMouseEvents();
		enableKeyEvents();
	}
	
	
	void exit() {
		printf("MyButton::exit() - goodbye!\n");
	}
	
	
	void update() {
		//		x = ofGetWidth()/2 + cos(ofGetElapsedTimef() * 0.2) * ofGetWidth()/4;
		//		y = ofGetHeight()/2 + sin(ofGetElapsedTimef() * 0.2) * ofGetHeight()/4;
	}
	
	
	void draw() {
        ofPushStyle();
		if(isMousePressed()) ofSetHexColor(DOWN_COLOR);
		else if(isMouseOver()) ofSetHexColor(OVER_COLOR);
		else ofSetHexColor(IDLE_COLOR);
		
		ofRect(x, y, width, height);
        ofPopStyle();
	}
	
	virtual void onRollOver(int x, int y) {
		printf("MyButton::onRollOver(x: %i, y: %i)\n", x, y);
	}
	
	virtual void onRollOut() {
		printf("MyButton::onRollOut()\n");
	}
	
	virtual void onMouseMove(int x, int y){
		printf("MyButton::onMouseMove(x: %i, y: %i)\n", x, y);
	}
	
	virtual void onDragOver(int x, int y, int button) {
		printf("MyButton::onDragOver(x: %i, y: %i, button: %i)\n", x, y, button);
	}
	
	virtual void onDragOutside(int x, int y, int button) {
		printf("MyButton::onDragOutside(x: %i, y: %i, button: %i)\n", x, y, button);
	}
	
	virtual void onPress(int x, int y, int button) {
		printf("MyButton::onPress(x: %i, y: %i, button: %i)\n", x, y, button);
	}
	
	virtual void onRelease(int x, int y, int button) {
		printf("MyButton::onRelease(x: %i, y: %i, button: %i)\n", x, y, button);
	}
	
	virtual void onReleaseOutside(int x, int y, int button) {
		printf("MyButton::onReleaseOutside(x: %i, y: %i, button: %i)\n", x, y, button);
	}
	
	virtual void keyPressed(int key) {
		printf("MyButton::keyPressed(key: %i)\n", key);
	}
	
	virtual void keyReleased(int key) {
		printf("MyButton::keyReleased(key: %i)\n", key);
	}
	
};