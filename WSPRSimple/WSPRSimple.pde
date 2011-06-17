/** A simple demo.
    TODO: cache activity results for each angle(?) */

import swp.*;

String myCall = "DH3JO";
String myGrid = "JO30lw";
// in China dann Geokoordinaten nutzen!
// LongLat myGeoPos;

WSPRManager wspr;
Sun sun;

PFont f;

void setup() {
  size(400, 400);
  background(255);
  f = createFont("Courier New", 16);
  textFont(f);
  
  wspr = new WSPRManager(myCall, myGrid, 120000, 50, true);
  wspr.start();
  
  sun = new Sun(wspr.getWSPRData().getGeoPos(), 1000);
  sun.start();
}

void draw() {
  smooth();
  background(255);
  
  WSPRSpot[] allSpots = wspr.getWSPRData().getSpotArray();

  translate(width/2, height/2);  
  for (int i=0; i<allSpots.length; i++) {
    WSPRSpot s = allSpots[i];
    pushMatrix();
    
    // warum + PI???
    rotate(radians((float)s.getAzimuth())+PI);

    float ageAlpha = 255.0-255.0*((float)wspr.getWSPRData().getYoungest().getAge()-s.getAge())/(wspr.getWSPRData().getYoungest().getAge()-(float)wspr.getWSPRData().getOldest().getAge());
    float snrSize = 30-s.getSNR()/30.0*50;
    
    color c = color(128,ageAlpha);
    noStroke();
    fill(c);
    ellipseMode(CENTER);
    ellipse(0, (float)s.getDistance()/20.0, snrSize, snrSize);
    stroke(c);
    line(0, 0, 0, (float)s.getDistance()/20.0);
    
    c = color(0,ageAlpha+25);
    fill(c);
    text(s.getCallsign(), 4, (float)s.getDistance()/20.0+5);
    popMatrix();
  }

  // let's check solar activity for a few directions
  for (int i=15; i<360; i+=30) {
    double activity = wspr.getWSPRData().estimateSolarActivity(i);
    pushMatrix();
    rotate(radians(i));
    stroke(255,0,0);
    strokeWeight(1);
    line(0, 0, 0, (float)(activity/10.0*width/2)+50);
    popMatrix();
  }
  
  // sun
  pushMatrix();
  // warum + PI???
  rotate(radians((float)sun.getAzimuth()));
  fill(255,255,0,100);
  noStroke();
  float sunSize = (float)(sun.getElevation()+45.0)/135.0 * 50.0;
  ellipse(0, 160, sunSize, sunSize);
  popMatrix();
}
