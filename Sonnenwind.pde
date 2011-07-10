import processing.opengl.*;

SerialController serialController;
RotationCorrection rotCorrect;
World world;
Webcam webcam;
int screenW; 
int screenH;
int drawMode;
float myRotation; 

// drawmode: 0 = present / 1 = debug  
int drawmode = 0;

void setup() {
  size(1024, 600, OPENGL); // Webcam 512*600 | Screen 512*600
  frameRate(24);
  strokeWeight(1);
  background(0);
  
  myRotation = 0;
  world = new World((600 * 8), 512, myRotation); // screenSize.x * 8 = camera FOV: ~45°
  if(drawmode==0) webcam = new Webcam(this, 600, 450);

  PFont font;
  font = loadFont("Gulim-11.vlw");
  textFont(font, 11);
  
  rotCorrect = new RotationCorrection();
  rotCorrect.loadNorth();
  serialController = new SerialController(this);
}


void draw() {

  serialController.readSerial();
  float rotationFromNorth = rotCorrect.normalizeRotation(serialController.getRotation());
  world.setRotation(rotationFromNorth);

  switch(drawmode) {
  case 0: 
    rotate(radians(90));
    translate(0, -width); 

    noStroke();
    fill(0);
    rect(0, -62, height, width/2+62); 

    world.render();
  
    translate(0, width/2+(width/2-450));
//    fill(255,0,0);
//    rect(0,0,600,450);
    webcam.render();
    break;

  case 1:
    noStroke();
    fill(0);
    rect(0, 0, width, height); 
    translate(0, 50);
    world.render();
    world.renderHorizon();
    world.renderBorder();
    break;
  }
}

void mousePressed() {
  world.addRandomNode();
}


// TMP
PVector sunPos = new PVector(800,15);

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      serialController.rotation += 5;
    } 
    else if (keyCode == DOWN) {
      serialController.rotation -= 5;
    }   
    else if (keyCode == LEFT) {
      sunPos.x -= 10;
      world.setSunPos(sunPos.x, sunPos.y);
    }
    else if (keyCode == RIGHT) {
      sunPos.x += 10;
      world.setSunPos(sunPos.x, sunPos.y);
    }
    
    else if (keyCode == ALT) {
      //world.addAtractor();
      world.setSunFieldActivityFromWSPRNET();
    }
  } else {
    if (key == 'c') {
      rotCorrect.calibrateNorth(serialController.getRotation());
    }
  }
}
