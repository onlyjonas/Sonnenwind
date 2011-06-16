class Sun{

    PVector pos;
    color myColor;
    int mySize;
    World world;
    ArrayList<WindParticle> windParticle = new ArrayList();
    int timer, windDelay, windIndex;
    
    Sun(World _world, float _x, float _y, int particle)
    {
      pos = new PVector(_x, _y);
      myColor = color(255,255,0);
      mySize = 10;
      windDelay=2;
      windIndex=0;
      timer=0;
      world = _world;
      
      for (int i = 0;i < particle; i++) {
         WindParticle wind = new WindParticle(world, _x, _y);  
         windParticle.add(wind);
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
      line(pos.x-mySize/2+2,pos.y-mySize/2+2,pos.x+mySize/2-2,pos.y+mySize/2-2);
      line(pos.x-mySize/2+2,pos.y+mySize/2-2,pos.x+mySize/2-2,pos.y-mySize/2+2);
      line(pos.x-mySize/2,pos.y, pos.x+mySize/2,pos.y);
      line(pos.x,pos.y-mySize/2, pos.x, pos.y+mySize/2);
    }
    
    private void drawWind()
    {
      if(timer>windDelay){
        windParticle.get(windIndex).setTarget(-40, random(90,100));
        
        if(windIndex<windParticle.size()-1) windIndex++;
        else windIndex=0;
        timer=0;
      }else{
        timer++;
      } 
      
      
      for (int i = 0;i < windParticle.size(); i++) {
        windParticle.get(i).render();
      }
    }
    
    void setPos(float _x, float _y)
    {
        pos.x = _x;
        pos.y = _y;
    }

    void setColor(int r, int g, int b)
    {
      myColor = color(r,g,b);
    }
}
