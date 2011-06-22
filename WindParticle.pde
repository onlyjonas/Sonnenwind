class WindParticle{
  
  PVector origin;
  PVector pos;
  PVector posHist;
  PVector target;  
  
  color myColor;
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
    myColor = color(255,255,0);
    delayLine = new float[delayLength];
    delayPos=0;
    speed = random(2,5);
 }
  
  
  void render(){
    update();
    stroke(myColor);
    line(pos.x, pos.y,posHist.x ,posHist.y);    
  }
  
  void update(){
    
    // posHist to create lines
    if(random(10)>8){
      posHist.x = pos.x;
      posHist.y = pos.y;
    }
    
    // pos.x 
    //if(pos.x < target.x) pos.x += speed;
    //else pos.x -= speed;
    
    pos.x +=constrain(((target.x - pos.x) * 0.01), -6, 6);
    
    // pos.y bounce easing  
    delayLine[delayPos] = pos.y;
    if(delayPos < delayLength-1) delayPos++;
    else delayPos=0;
    
    // influence pos.y easing by WsprNodes
    float ty = target.y;
    for (int i=0; i < world.nodes.size(); i++){
      
      if (pos.x > world.nodes.get(i).pos.x-world.nodes.get(i).getSize()/2 &&
        pos.x < world.nodes.get(i).pos.x+world.nodes.get(i).getSize()/2) {
          ty= target.y- world.nodes.get(i).getEnergy()*100; 
      }
    }
    
    pos.y += ((ty - delayLine[(delayPos+1)%delayLine.length]) * 0.08);
     
    // Reset origin position 
    if (pos.dist(target)<50) {
      resetToOrigin();
    }
 
  } 
  
  void setTarget(float _x, float _y){
    target.x = _x; 
    target.y = _y;
  }
  
  void resetToOrigin(){
      pos.x = origin.x;
      pos.y = origin.y;
      posHist.x = origin.x;
      posHist.y = origin.y;
  }

}
