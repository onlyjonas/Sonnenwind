class WsprNode{
    
    PVector pos;
    ArrayList<Float> energyList = new ArrayList();
    float currentEnergy;
    float minSize=10;
    float maxSize=200;
    color strokeColor;
    String name; 
    
    WsprNode(World world, String _name, float _azimuth, float _distance, float _energy)
    {
      name = _name;
      setNodeParam(_azimuth, _distance, _energy);
      
      strokeColor = color(255,255,255);      
      
      currentEnergy = 0;
    }
    
    void update(float _azimuth, float _distance, float _energy)
    {
      setNodeParam(_azimuth, _distance, _energy);
    }

    void updateEnergy(float _energy)
    {
       // Energy
      Float e = new Float(_energy);;
      energyList.add(e);
    }
    
    void setNodeParam(float _azimuth, float _distance, float _energy){
      // Position X, Y
      float x = world.w/360 * _azimuth;
      float y = _distance;
      pos = new PVector(x, y);  
      
      // Energy
      Float e = new Float(_energy);;
      energyList.add(e);
      
    }
    
    void render()
    {
      drawcircle(pos.x,pos.y);
      drawname(name, pos.x,pos.y);
    
      // draw node twice : viz offset world.w + 600
      if(pos.x < 600){
        pushMatrix();
        translate(world.w+pos.x,pos.y);
        fill(255,0,0);
        rect(0,0,10,10);
        popMatrix();
        drawcircle(world.w+pos.x,pos.y);
        drawname(name, world.w+pos.x,pos.y);
      }
      
    }
 
    void drawcircle(float x, float y)
    {
      pushMatrix();
        translate(x,y);
 
        // spot history
        noFill();
        int spotCount = energyList.size();
        
        for(int i=0; i< spotCount-1; i++){
          float e = energyList.get(i);
          int strokeAlpha = 55+(200/spotCount*i);
          stroke(strokeColor, strokeAlpha);
          ellipse(0,0, minSize+e*maxSize, minSize+e*maxSize);
        }
        
        // last spot
        fill(0,255,0, 125);
        currentEnergy += ((energyList.get(energyList.size()-1) - currentEnergy) * 0.1);
        ellipse(0,0, minSize+currentEnergy*maxSize, minSize+currentEnergy*maxSize);
        
      popMatrix();
    }   

    
    void drawname(String name, float x, float y){
      // PosX Line
      stroke(strokeColor);
      line(x, y, x, world.h);      
      // Text mirrored
      fill(strokeColor);
      textAlign(CENTER);
      pushMatrix();  
      scale(1, -1);
      translate(x,-y);
      rotate(radians(180));
      text(name, 0, 0);
      popMatrix();
    }
    
    float getEnergy(){
      float e=0; 
      int count=0;
      
      // Energiemittelwert von den letzten 3 Sichtungen
      int iMax = constrain(energyList.size(), 0, 4);

      for(int i=1; i< iMax ; i++){
          e += energyList.get(energyList.size()-i);
      }

      if(e>0)e = e/(iMax-1);

      return e; 
    }
    
    float getSize(){
      float s = 10+getEnergy()*100;
      return s;
    }
}
