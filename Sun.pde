class Sun {

  PVector pos;
  color myColor;
  int mySize;
  World world;
  ArrayList<WindCurve> windCurves = new ArrayList();
  int timer, windDelay, windIndex;
  float horizon;

  Sun(World _world, float _x, float _y)
  {
    pos = new PVector(_x, _y);
    myColor = color(255, 255, 0);
    mySize = 20;

    windDelay=5;
    timer=0;
    world = _world;

    for (int i = 0;i < 3; i++) {
      WindCurve wind = new WindCurve(world, _y+i*5);  
      windCurves.add(wind);
    }
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
    // render particles
    for (int i = 0;i < windCurves.size(); i++) {
      windCurves.get(i).update();
      windCurves.get(i).render();
    }

    if (timer>windDelay) {
      for (int i = 0;i < windCurves.size(); i++) {
        windCurves.get(i).pulse(-20);
      }
      timer=0;
    }
    else {
      timer++;
    }
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
}

