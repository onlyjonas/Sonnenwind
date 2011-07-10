import swp.WSPRManager;

class World {

  long starttime;
  long interval = 120000;
  int w;  
  int h;
  int x;
  float horizon = 200;
  float r;
  float mySpeed;
  WSPRManager wspr;
  ArrayList<WsprNode> nodes = new ArrayList();
  SunViz sunviz;

  World(int _w, int _h, float _r)
  {
    w=_w;
    h=_h;
    r=_r;
    x=0;
    mySpeed = 0.1;
    // WICHIT, LASSE: in China dann Geokoordinaten nutzen!
    // LongLat myGeoPos;
    long twoMinutes = 60*2*1000;
    int maxAge = 24; // maxAge ist das Alter, nach dem die Spots weggeschmissen werden in Stunden!
    wspr = new WSPRManager("DH3JO", "JO30lw", twoMinutes, maxAge, true); // debug = true, macht jede menge ausgaben
    sunviz = new SunViz(this, 900, 15);
    // init node DB
    starttime = millis()-interval;
  }

  void render()
  {
    if (millis() - starttime > interval) {
      createWsprNodesFromWSPRManager();
      starttime = millis();
    }
    rotateTo(r);
    pushMatrix();
    translate(x, 0);

    // sun
    sunviz.render();

    // nodes
    for (int i = 0;i < nodes.size(); i++) {
      WsprNode node = nodes.get(i);
      node.render();
    }

    popMatrix();
  }

  void rotateTo(float _r)
  {
    // TODO 360 map to
    //    println("-r: "+_r);
    float target = map(_r, 0, 360, 0, -w);
    //    println("target: "+target);
    x += ((target - x) * mySpeed);
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
  
  void renderHorizon(){
    stroke(150);
    line(0, horizon, w, horizon);  
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

  void addRandomNode() {
    // Call Sign
    String name = "ABCDE"+ (int)random(20); 

    // Azimuth (winkel vom Nordpol)
    float azimuth = random(360); // TEST VALUE

    // Distance
    float distance = random(400); // TEST VALUE (maxDis: 400)
    // Energy
    float energy = random(1);

    // check if node already exists 
    int index = -1;
    for (int i=0; i < nodes.size(); i++) {
      if (nodes.get(i).name.equals(name)) {
//        println("same name: "+ name);
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
//    sunviz.setFieldActivityFromWSPRNET(wspr.getWSPRData());
  }
  
  void setSunFieldActivityFromWSPRNET() {
    float step = w/sunviz.sunwind.detail;
    for (int i=0; i < sunviz.sunwind.detail; i++) {
      float angle = step*i/(float)w*360.0;
      float activity = wspr.getWSPRData().estimateSolarActivity((int)angle);
      sunviz.setFieldActivity((int)random(sunviz.activityFields-1), activity);
    }
  }

  void setSunPos(float _x, float _y) {
    sunviz.pos.x = _x;
    sunviz.pos.y = _y;
  }

  void createWsprNodesFromWSPRManager() {
    println("create nodes!");
    // get all spots!
    WSPRSpot[] allSpots = wspr.getWSPRData().getSpotArray();
    for (int i=0; i<allSpots.length; i++) {
      WSPRSpot s = allSpots[i];
      addNodeFromSpot(s);
    }
  }
  
  void addNodeFromSpot(WSPRSpot spot) {
    println("addind node from spot: "+spot);

    // Call Sign
    String name = spot.getCallsign();

    // Azimuth (winkel vom Nordpol)
    float azimuth = spot.getAzimuth();

    // Distance
    float distance = map(spot.getDistance(), 0, 20000, 400, 0); 
    // Energy
    float energy = map(spot.getSNR(), -35, 20, 0, 1);

    // check if node already exists
    int index = -1;
    for (int i=0; i < nodes.size(); i++) {
      if (nodes.get(i).name.equals(name)) {
//        println("same name: "+ name);
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
      println("added new node: "+node);
    }
  }
}

