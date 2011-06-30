class World {

  int w;  
  int h;
  int x;
  float horizon;
  float r;
  float mySpeed;
  ArrayList<WsprNode> nodes = new ArrayList();
  SunViz sunviz;
  
  World(int _w, int _h, float _r)
  {
    w=_w;
    h=_h;
    r=_r;
    horizon = 100;
    x=0;
    mySpeed = 0.1;
    
    sunviz = new SunViz(this, 900, 15);
  }

  void render()
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
    
    // sun
    sunviz.render();
    
    popMatrix();
  }

  void rotateTo(float _r)
  {
    x += ((_r - x) * mySpeed);
  }  

  void renderBorder()
  {
    pushMatrix();
    translate(x, 0);
    noFill();
    stroke(0, 255, 0);
    rect(0, 0, w, h);
    popMatrix();
  }

  void setRotation(float _r)
  {
    r=_r;
  }
  
  void addAtractor() {
  
    // Pos
    float _x = random(w);
    float _y = random(30, horizon-30);
    
    // Energy (Size)
    float _s = random(20, 80);

  }
  
  void addNode() {
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
 
 void setSunFieldActivity() {
   sunviz.setFieldActivity((int)random(sunviz.activityFields-1), random(1));  
 }
 
 void setSunPos(float _x, float _y) {
   sunviz.pos.x = _x;
   sunviz.pos.y = _y;
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

