class WindParticle{
  
  PVector origin;
  PVector pos;
  PVector posHist;
  PVector target;  
  float stepX;
  
  color myColor;
  int delayLength = 10;
  float[] delayLine;
  int delayPos;
  
  WindParticle (World _world, float _x, float _y) {
    world = _world;
    origin = new PVector(_x, _y);
    pos = origin;
    posHist = pos;
    target = new PVector(_x, _y);
    myColor = color(255,255,0);
    stepX = 3;
    delayLine = new float[delayLength];
    delayPos=0;
 }
  
  
  void render(){
    update();
    stroke(myColor);
    line(pos.x, pos.y,posHist.x ,posHist.y);    
  }
  
  void update(){
    
    posHist.x = pos.x;
    posHist.y = pos.y;
    
    pos.x += ((target.x - pos.x) * 0.05);
    
      
    delayLine[delayPos] = pos.y;
    if(delayPos < delayLength-1) delayPos++;
    else delayPos=0;
    
    float ty = target.y;
    
    for (int i=0; i < world.nodes.size(); i++){
      if (pos.x > world.nodes.get(i).pos.x-15 &&
        pos.x < world.nodes.get(i).pos.x+15) {
          ty= target.y- world.nodes.get(i).getEnergy()*100; 
      }
    }
    
    pos.y += ((ty - delayLine[(delayPos+1)%delayLine.length]) * 0.1);
     
    // Reset origin position 
    if (pos.x < 0 || pos.x > world.w) {
     // println("RESET to: ");//+ origin);
      pos.x = origin.x;
      pos.y = origin.y;
      posHist = pos;
    }
 
  } 
  
  void setTarget(float _x, float _y){
    target.x = _x; 
    target.y = _y;
  }

}
