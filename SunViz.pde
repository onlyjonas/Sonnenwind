import swp.Sun;

class SunViz {

  PVector pos;
  color myColor;
  int mySize =20;
  World world;
  Sun sun;
  SunWind sunwind;

  int timer, windDelay, windIndex;
  int activityFields=36;
  float horizon;

  SunViz(World _world, float _x, float _y)
  {
    pos = new PVector(_x, _y);
    myColor = color(255, 255, 0);
    windDelay=5;
    timer=0;
    world = _world;
    LongLat myGeo = new LongLat();
    myGeo.lng = 116.37182;  // PEKING!
    myGeo.lat = 39.92948;
    sun = new Sun(myGeo, 1000);  // 1000 = 1 s update zyklus
    sun.start();
    float sunwindHeight = 80;
    sunwind = new SunWind(world.horizon-20, world.w, sunwindHeight, activityFields); 
  }

  void render()
  {
    updateSunPos();
    drawSun(pos.x, pos.y);
    drawSun(pos.x+world.w, pos.y);  // wrap hack!
    drawWind();
  }

  private void drawSun(float px, float py)
  {
    float s = mySize;
    if(py<world.horizon) s = mySize + dist(px,py, px, world.horizon); 
    stroke(myColor);
    line(px-s/3, py-s/3, px+s/3, py+s/3);
    line(px-s/3, py+s/3, px+s/3, py-s/3);
    line(px-s/2, py, px+s/2, py);
    line(px, py-s/2, px, py+s/2);
  }

  private void drawWind()
  {
    sunwind.update(pos.x, pos.y);
    updateNodeEnergy();
    sunwind.render();
  }

  void updateSunPos()
  {
    pos.x = map((float)sun.getAzimuth(), 0, 360, 0, world.w); // Muss Lasse noch kontrollieren
    pos.y = map((float)sun.getElevation(), 70, -70, world.horizon-200, world.horizon+200); 
    //    println("sun: "+sun.getAzimuth()+", "+sun.getElevation());
  }

  void setPos(float _x, float _y)
  {
    pos.x = _x;
    pos.y = _y;
  }

  void setColor(int r, int g, int b)
  {
    myColor = color(r, g, b);
  }

  void setFieldActivity(int i, float activity) {
    sunwind.setFieldActivity(i, activity);
  }
  
  void updateNodeEnergy() {
    for (int i=0;i<world.nodes.size();i++) {
      float nodeX = world.nodes.get(i).pos.x;
      float nodeEnergy = world.nodes.get(i).getEnergy();
      sunwind.updateNodeEnergy(nodeX, nodeEnergy);
    }
  }
}
