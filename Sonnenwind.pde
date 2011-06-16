World world;
int screenW; 
int screenH;
int drawMode;
float myRotation; 

void setup() {
  size(1024,600,P2D); // Webcam 512*600 | Screen 512*600
  frameRate(24);
  strokeWeight(1); 
  background(0); 
  myRotation = 0; 
  world = new World((600 * 8), 512, myRotation); // screenSize.x * 8 = camera FOV: ~45°
  
  PFont font;
  font = loadFont("Gulim-11.vlw");
  textFont(font, 11); 
}


void draw() {
   //background(0);
   noStroke();
   fill(0,100);
   rect(0,0,width,height);
   
   //rotate(radians(-90));
   //translate(-height,width/2); 
   translate(0,50);
  
   world.render();
   world.renderBorder();
}

void mousePressed() {
  world.addNode();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      myRotation +=100;
    } else if (keyCode == DOWN) {
      myRotation -= 100;
    }
    world.setRotation(myRotation);
  }
}

