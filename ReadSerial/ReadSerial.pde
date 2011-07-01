SerialController serialController;

void setup() {
  serialController = new SerialController(this);
}

void draw() {
  println(serialController.getRotation());
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      serialController.rotation +=100;
    } 
    else if (keyCode == DOWN) {
      serialController.rotation -=100;
    }
  }
}
