class Sun {

  PVector pos;
  color myColor;
  int mySize =20;
  World world;
  SunWind sunwind;
  
  int timer, windDelay, windIndex;
  int activityFields=36;
  float horizon;

  Sun(World _world, float _x, float _y)
  {
    pos = new PVector(_x, _y);
    myColor = color(255, 255, 0);
    windDelay=5;
    timer=0;
    world = _world;
    sunwind = new SunWind(pos.x, pos.y, 0, world.w+135, activityFields); //+135 - anders passt es nicht ???
  }

  void render()
  {
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
    sunwind.render();
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
    sunwind.setFieldActivity(i,activity);
  }
}

