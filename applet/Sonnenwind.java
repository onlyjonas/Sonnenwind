import processing.core.*; 
import processing.xml.*; 

import processing.video.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class Sonnenwind extends PApplet {

World world;
Webcam webcam;
int screenW; 
int screenH;
int drawMode;
float myRotation; 

public void setup() {
  size(1024, 600, P2D); // Webcam 512*600 | Screen 512*600
  frameRate(24);
  strokeWeight(1); 
  background(0); 
  myRotation = 0; 
  world = new World((600 * 8), 512, myRotation); // screenSize.x * 8 = camera FOV: ~45\u00b0
  //webcam = new Webcam(this, 600, 450);

  PFont font;
  font = loadFont("Gulim-11.vlw");
  textFont(font, 11);
}


public void draw() {

  // drawmode: 0 = present / 1 = debug  
  int drawmode = 1;

  switch(drawmode) {
  case 0: 
    rotate(radians(-90));
    translate(-height, width/2); 

    noStroke();
    fill(0, 100);
    rect(0, -62, height, width/2+62); 

    world.render();

    translate(0, -width/2);
    webcam.render();
    break;

  case 1:
    noStroke();
    fill(0, 100);
    rect(0, 0, width, height); 
    translate(0, 50);
    world.render();
    world.renderBorder();
    break;
  }
}

public void mousePressed() {
  world.addNode();
}

public void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      myRotation +=100;
      world.setRotation(myRotation);
    } 
    else if (keyCode == DOWN) {
      myRotation -= 100;
      world.setRotation(myRotation);
    }
    else if (keyCode == ALT) {
      world.addAtractor();
    }
  }
}

class PAtractor {

  PVector pos;
  float mySize;
  
  PAtractor(float _x, float _y, float _size) {
    pos = new PVector(_x, _y);
    mySize = _size;
  }

  public void render() {
    noFill();
    stroke(255);
    line(pos.x,pos.y-mySize/2, pos.x,pos.y+mySize/2);
    line(pos.x-mySize/2, pos.y,pos.x+mySize/2, pos.y); 
    //ellipse(pos.x, pos.y, mySize, mySize);
  }
}

class Sun{

    PVector pos;
    int myColor;
    int mySize;
    int myParticle;
    World world;
    ArrayList<WindParticle> windParticle = new ArrayList();
    int timer, windDelay, windIndex;
    float horizon;
    
    Sun(World _world, float _x, float _y)
    {
      pos = new PVector(_x, _y);
      myColor = color(255,255,0);
      mySize = 20;
      myParticle = 800;
      windDelay=10;
      windIndex=0;
      timer=0;
      world = _world;
      
      for (int i = 0;i < myParticle; i++) {
         WindParticle wind = new WindParticle(world, _x, _y);  
         windParticle.add(wind);
      }
     
    }
    
    public void render()
    {
      drawSun();
      drawWind();
    }
    
    private void drawSun()
    {
      stroke(myColor);
      line(pos.x-mySize/2+2,pos.y-mySize/2+2,pos.x+mySize/2-2,pos.y+mySize/2-2);
      line(pos.x-mySize/2+2,pos.y+mySize/2-2,pos.x+mySize/2-2,pos.y-mySize/2+2);
      line(pos.x-mySize/2,pos.y, pos.x+mySize/2,pos.y);
      line(pos.x,pos.y-mySize/2, pos.x, pos.y+mySize/2);
    }
    
    float direction = -100;
    private void drawWind()
    {
     
      // emit particles
        if(direction==-100) direction = world.w +100 ;
        else direction = -100;
        
        windParticle.get(windIndex).setTarget(direction, random(40,50));
        
        if(windIndex<windParticle.size()-1) windIndex++;
        else windIndex=0;
        
      // render particles
      for (int i = 0;i < windParticle.size(); i++) {
        windParticle.get(i).render();
      }
    }
    
    public void setPos(float _x, float _y)
    {
        pos.x = _x;
        pos.y = _y;
    }

    public void setColor(int r, int g, int b)
    {
      myColor = color(r,g,b);
    }
}


class Webcam{
    Capture cam;
    int w, h;
    
    Webcam(PApplet parent, int _w, int _h)
    { 
      w = _w;
      h = _h;
      cam = new Capture(parent, 320, 240);
    }
    
    public void render(){
        
        if (cam.available() == true) {
          cam.read();
          image(cam,0,0,w,h);
        }
    }
    
    public void brightnessControl( int maxBrightness){
      
      // How many pixels to skip in either direction 
      int increment = 10;
      
      int index = 0;
      int rtot = 0;
      int gtot = 0;
      int btot = 0;
      int aBrightness = 0;
       
      for (int j = 0; j < cam.height; j += increment) {
       for (int i = 0; i < cam.width; i += increment) {
       
         int pixelColor = cam.pixels[j*cam.width + i];
         int r = (pixelColor >> 16) & 0xff;
         int g = (pixelColor >> 8) & 0xff;
         int b = pixelColor & 0xff;
         rtot = rtot + r;
         gtot = gtot + g;
         btot = btot + b;
         index++;
       }
     }
     rtot = rtot/index;
     gtot = gtot/index;
     btot = btot/index;
     aBrightness = (rtot+gtot+btot)/3;
     
//     println("r: "+rtot+"g: "+gtot+"b: "+btot+"brightness: "+aBrightness);  

     if (maxBrightness < aBrightness) {
       // -- ???
       int t = 255 + maxBrightness - aBrightness;
//       println(t); 
//       tint(t);
       tint(50);
     }
    }
}
class WindParticle {

  PVector origin;
  PVector pos;
  PVector posHist;
  PVector target;  

  int myColor;
  int delayLength = 10;
  float[] delayLine;
  int delayPos;
  float speed;

  WindParticle (World _world, float _x, float _y) {
    world = _world;
    origin = new PVector(_x, _y);
    pos = new PVector(_x, _y);
    posHist = new PVector(_x, _y);
    target = new PVector(_x, _y);
    myColor = color(255, 255, 0);
    delayLine = new float[delayLength];
    delayPos=0;
    speed = random(2, 5);
  }


  public void render() {
    update();
    stroke(myColor);
    line(pos.x, pos.y, posHist.x, posHist.y);
  }


  float angle = 0;
  PVector  nextAtractorPos = new PVector(0, 0);
  float nextAtractorSize = 50;

  public void update() {

    // posHist to create lines
    if (random(10)>8) {
      posHist.x = pos.x;
      posHist.y = pos.y;
    }

    // MOVE IN CIRCLE: atractor influence
    if (pos.dist(nextAtractorPos) < nextAtractorSize) {
    
      if (angle<500) {
        angle+=10;
        pos.x = nextAtractorPos.x+cos(radians(angle))*(nextAtractorSize/2);
        pos.y = nextAtractorPos.y+sin(radians(angle))*(nextAtractorSize/2);
      }
      else {
        getNextAtractor();
        angle = 0;
      }
    }
    // MOVE TO TARGET
    else {
      // pos.x 
      //if(pos.x < target.x) pos.x += speed;
      //else pos.x -= speed;

      pos.x +=constrain(((target.x - pos.x) * 0.01f), -6, 6);

      // pos.y bounce easing  
      delayLine[delayPos] = pos.y;
      if (delayPos < delayLength-1) delayPos++;
      else delayPos=0;

      // influence pos.y easing by WsprNodes
      float ty = target.y;
      for (int i=0; i < world.nodes.size(); i++) {

        if (pos.x > world.nodes.get(i).pos.x-world.nodes.get(i).getSize()/2 &&
          pos.x < world.nodes.get(i).pos.x+world.nodes.get(i).getSize()/2) {
          ty= target.y- world.nodes.get(i).getEnergy()*100;
        }
      }
      pos.y += ((ty - delayLine[(delayPos+1)%delayLine.length]) * 0.08f);
    }

    // Reset origin position 
    if (pos.dist(target)<100) {
      resetToOrigin();
    }
  } 

  public void setTarget(float _x, float _y) {
    target = new PVector(_x, _y);
    getNextAtractor();
  }

  public void getNextAtractor() {

    nextAtractorPos = new PVector(target.x*10, target.y*10);

    for (int i=0; i < world.atractors.size(); i++) {

      // check direction
      if (pos.x < target.x) {
        if (pos.x < world.atractors.get(i).pos.x && 
          pos.dist(nextAtractorPos) > pos.dist(world.atractors.get(i).pos)) {
          nextAtractorPos = world.atractors.get(i).pos;
          nextAtractorSize = world.atractors.get(i).mySize;
        }
      }
      else {
        if (pos.x > world.atractors.get(i).pos.x && 
          pos.dist(nextAtractorPos) > pos.dist(world.atractors.get(i).pos)) {
          nextAtractorPos = world.atractors.get(i).pos;
          nextAtractorSize = world.atractors.get(i).mySize;
        }
      }
    }
  }

  public void resetToOrigin() {
    pos.x = origin.x;
    pos.y = origin.y;
    posHist.x = origin.x;
    posHist.y = origin.y;
    angle=0;
  }
}

class World {

  int w;  
  int h;
  int x;
  float horizon;
  float r;
  float mySpeed;
  ArrayList<WsprNode> nodes = new ArrayList();
  ArrayList<PAtractor> atractors = new ArrayList();
  Sun sun;
  
  World(int _w, int _h, float _r)
  {
    w=_w;
    h=_h;
    r=_r;
    horizon = 100;
    x=0;
    mySpeed = 0.1f;
    
    sun = new Sun(this, 1200, 15);
  }

  public void render()
  {
    rotateTo(r);
    pushMatrix();
    translate(x, 0);

    // horizon
    stroke(150);
    line(0, horizon, w, horizon);

    // nodes
    for (int i = 0;i < nodes.size(); i++) {
      WsprNode node = nodes.get(i);
      node.render();
    }
    
    // atractors
    for (int j = 0;j < atractors.size(); j++) {
      PAtractor atractor = atractors.get(j);
      atractor.render();
    }
    
    // sun
    sun.render();
    
    popMatrix();
  }

  public void rotateTo(float _r)
  {
    x += ((_r - x) * mySpeed);
  }  

  public void renderBorder()
  {
    pushMatrix();
    translate(x, 0);
    noFill();
    stroke(0, 255, 0);
    rect(0, 0, w, h);
    popMatrix();
  }

  public void setRotation(float _r)
  {
    r=_r;
  }
  
  public void addAtractor() {
  
    // Pos
    float _x = random(w);
    float _y = random(30, horizon-30);
    
    // Energy (Size)
    float _s = random(20, 80);
    
    // Add Atractor
    PAtractor atractor = new PAtractor(_x,_y,_s);
    atractors.add(atractor);
  }
  
  public void addNode() {
    // Call Sign
    String name = "ABCDE"+ (int)random(20); 

    // Azimuth (winkel vom Nordpol)
    float azimuth = random(360); // TEST VALUE
    
    // Distance
    float distance = random(500); // TEST VALUE (maxDis: 500)
    // Energy
    float energy = random(1);
   
    // check if node already exists 
    int index = -1;
    for (int i=0; i < nodes.size(); i++) {
      if (nodes.get(i).name.equals(name)) {
        println("same name: "+ name);
        index = i;
        break;
      }
    }

    if (index >= 0) {
      // NODE ALREADY EXISTS
      //nodes.get(index).update(azimuth, distance, energy);
      nodes.get(index).updateEnergy(energy);
    }    
    else {
      // NEW NODE
      WsprNode node = new WsprNode(this, name, azimuth, distance, energy);
      nodes.add(node);
    } 
  } 
 
  
  /*
  void mapWsprNode(){
   // http://wsprnet.org/olddb
   wsprManager.getAllSpots();
   ...
   einen spot nehmen:
   WSPRSpot s = blabla;
   s.getAzimuth(); // winkel vom nordpol, float
   s.getDistance();  // entfernung in km, int
   s.getSpotCount(); // anzahl der sichtungen, int
   s.getAge();  // alter der letzten sichtung, ms in long
   s.getDate(); // datum der letzten sichtung, java.util.Date
   s.getCallsing(); // name, string
   s.getDecibel(); s.getSNR(); //usw... http://wsprnet.org/olddb
   }
   */
}

class WsprNode{
  
    PVector pos;
    float[] energy = new float[10];
    float newEnergy;
    float currentEnergy;
    int myColor;
    String name; 
    private int history;
    
    WsprNode(World world, String _name, float _azimuth, float _distance, float _energy)
    {
      name = _name;
      setNodeParam(_azimuth, _distance, _energy);
      
      myColor = color(255,255,255);      
      history = 0;
      
      currentEnergy = 0;
      newEnergy= 0;
    }
    
    public void update(float _azimuth, float _distance, float _energy)
    {
      setNodeParam(_azimuth, _distance, _energy);
    }

    public void updateEnergy(float _energy)
    {
       // Energy
      energy[history] = _energy;
      newEnergy = _energy;
      
      // History
      if(history<energy.length-1)history++;
      else history = 0;
    }
    
    public void setNodeParam(float _azimuth, float _distance, float _energy){
      // Position X, Y
      float maxDis = 500; 
      float x = world.w/360 * _azimuth;
      float y = world.h - (_distance *(world.h - world.horizon) / maxDis);
      pos = new PVector(x, y);  
      
      // Energy
      energy[history] = _energy;
      newEnergy = _energy;
      
      // History
      if(history<energy.length-1)history++;
      else history = 0;
      
    }
    
    public void render()
    {
      drawcircle();
      drawname(name);
    }
 
    public void drawcircle()
    {
      pushMatrix();
        translate(pos.x,pos.y);
        noStroke();
        fill(myColor, 30);
        for(int i=0; i< energy.length-1 ; i++){
          if(energy[i]>0)ellipse(0,0, 10+energy[i]*100, 10+energy[i]*100);
        }
        
        fill(myColor, 50*currentEnergy);
        stroke(myColor, 255*currentEnergy);
        currentEnergy += ((newEnergy - currentEnergy) * 0.1f);
        ellipse(0,0, 10+currentEnergy*100, 10+currentEnergy*100);
        
        if(currentEnergy >= newEnergy -0.01f) newEnergy=0;
      popMatrix();
    }   

    
    public void drawname(String name){
      fill(myColor);
      text(name, (int)pos.x, (int)pos.y);
    }
    
    public void setColor(int r, int g, int b){
      myColor = color(r,g,b);
    }
    
    public float getEnergy(){
      float e=0; 
      int count=0;
      for(int i=0; i< energy.length-1 ; i++){
        if (energy[i] != 0){
          e += energy[i];
          count++;
        }  
      }
      
      if(count > 0) e = e/count;
      return e; 
    }
    
    public float getSize(){
      float s = 10+getEnergy()*100;
      return s;
    }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--stop-color=#cccccc", "Sonnenwind" });
  }
}
