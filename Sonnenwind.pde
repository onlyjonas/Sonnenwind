import processing.opengl.*;

SerialController serialController;
World world;
Webcam webcam;
int screenW; 
int screenH;
int drawMode;
float myRotation; 

void setup() {
  size(1024, 600, OPENGL); // Webcam 512*600 | Screen 512*600
  frameRate(24);
  strokeWeight(1); 
  background(0);
  
  serialController = new SerialController(this);
  myRotation = 0;
  world = new World((600 * 8), 512, myRotation); // screenSize.x * 8 = camera FOV: ~45°
//  webcam = new Webcam(this, 600, 450);

  PFont font;
  font = loadFont("Gulim-11.vlw");
  textFont(font, 11);
}


void draw() {

  // drawmode: 0 = present / 1 = debug  
  int drawmode = 1;

  switch(drawmode) {
  case 0: 
    rotate(radians(-90));
    translate(-height, width/2); 

    noStroke();
    fill(0);
    rect(0, -62, height, width/2+62); 

    world.render();

    translate(0, -width/2);
//    webcam.render();
    break;

  case 1:
    noStroke();
    fill(0);
    rect(0, 0, width, height); 
    translate(0, 50);
    world.render();
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
      serialController.rotation +=100;
      world.setRotation(serialController.getRotation());
    } 
    else if (keyCode == DOWN) {
      serialController.rotation -=100;
      world.setRotation(serialController.getRotation());
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
      world.setSunFieldActivity();
    }
  }
}

