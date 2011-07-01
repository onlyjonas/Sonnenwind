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
    myGeo.lng = 7;  //Position, etwa hier, muss anders gemacht werden
    myGeo.lat = 51;
    sun = new Sun(myGeo, 1000);  // 1000 = 1 s update zyklus
    sun.start();
    sunwind = new SunWind(pos.x, pos.y, world.w+135, world.horizon, activityFields); //+135 - anders passt es nicht ???
  }

  void render()
  {
    updateSunPos();
    drawSun();
    drawWind();
  }

  private void drawSun()
  {
    stroke(myColor);
    line(pos.x-mySize/2+2, pos.y-mySize/2+2, pos.x+mySize/2-2, pos.y+mySize/2-2);
    line(pos.x-mySize/2+2, pos.y+mySize/2-2, pos.x+mySize/2-2, pos.y-mySize/2+2);
    line(pos.x-mySize/2, pos.y, pos.x+mySize/2, pos.y);
    line(pos.x, pos.y-mySize/2, pos.x, pos.y+mySize/2);
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
    pos.y = map((float)sun.getElevation(), 70, -70, world.horizon-200, world.horizon+100); 
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

