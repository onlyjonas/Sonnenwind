/** Download spots from a receiver in Japan...  */
import swp.*;

//String myCall = "JQ2WDO";
//String myGrid = "PM95gi";

String myCall = "A0A0A0";
String myGrid = "OM89EW";  // BEIJING!

WSPRManager wspr;
Sun sun;

PFont f;

void setup() {
  size(400, 400);
  background(255);
  f = createFont("Courier New", 16);
  textFont(f);
  
  wspr = new WSPRManager(myCall, myGrid, 120000, false, true);
  wspr.getWSPRData().setMaxSize(500);
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

//    float ageAlpha = 255.0-255.0*((float)wspr.getWSPRData().getYoungest().getAge()-s.getAge())/(wspr.getWSPRData().getYoungest().getAge()-(float)wspr.getWSPRData().getOldest().getAge());
    float ageAlpha = 255;
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
  rotate(radians((float)sun.getAzimuth())+PI);
  fill(255,255,0,100);
  noStroke();
  float sunSize = (float)(sun.getElevation()+45.0)/135.0 * 50.0;
  ellipse(0, 160, sunSize, sunSize);
  popMatrix();
}

void keyPressed() {
  if (key=='s') {
    print("saving... ");
    try {
      wspr.saveFakeData();
      println("success!");
    } catch (Exception e) {
      println("failed. Because "+e);
    }
  } else if (key=='l') {
    print("loading... ");
    try {
      wspr.loadFakeData();
      println(wspr.getWSPRData()+"");
    } catch (Exception e) {
      println("failed. Because "+e);
    }
  }
}
