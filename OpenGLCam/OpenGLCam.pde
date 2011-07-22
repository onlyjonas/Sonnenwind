Webcam cam;

void setup() {
 size(640, 480, OPENGL);
 cam = new Webcam(this, 640,480, 640,480);
}

void draw(){
  cam.render();
  print(".");
  
}
