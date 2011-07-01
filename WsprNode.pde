class WsprNode{
    
    PVector pos;
    float[] energy = new float[99];
    float newEnergy;
    float currentEnergy;
    float minSize=10;
    float maxSize=200;
    color strokeColor;
    String name; 
    private int history;
    
//    ArrayList<Float> energyList = new ArrayList();
//    Float f = new Float(36);
//    energyList.add(f);
//    print(energyList.get(0));
    
    //TODO Jonas: array energy umwandeln zu object arrayList & die energy history Kreise ausfaden... 
    
    WsprNode(World world, String _name, float _azimuth, float _distance, float _energy)
    {
      name = _name;
      setNodeParam(_azimuth, _distance, _energy);
      
      strokeColor = color(255,255,255);      
      history = 0;
      
      currentEnergy = 0;
    }
    
    void update(float _azimuth, float _distance, float _energy)
    {
      setNodeParam(_azimuth, _distance, _energy);
    }

    void updateEnergy(float _energy)
    {
       // Energy
      energy[history] = _energy;
      newEnergy = _energy;
      
      // History
      if(history<energy.length-1)history++;
      else history = 0;
    }
    
    void setNodeParam(float _azimuth, float _distance, float _energy){
      // Position X, Y
      float x = world.w/360 * _azimuth;
      float y = _distance;
      pos = new PVector(x, y);  
      
      // Energy
      energy[history] = _energy;
      newEnergy = _energy;
      
      // History
      if(history<energy.length-1)history++;
      else history = 0;
      
    }
    
    void render()
    {
      drawcircle();
      drawname(name);
    }
 
    void drawcircle()
    {
      pushMatrix();
        translate(pos.x,pos.y);
 
        // Spot history
        noFill();
        stroke(strokeColor);
        for(int i=0; i< energy.length-1 ; i++){
          if(energy[i]>0)ellipse(0,0, minSize+energy[i]*maxSize, minSize+energy[i]*maxSize);
        }
        
        fill(0,255,0, 125);
        currentEnergy += ((newEnergy - currentEnergy) * 0.1);
        ellipse(0,0, minSize+currentEnergy*maxSize, minSize+currentEnergy*maxSize);
        
      popMatrix();
    }   

    
    void drawname(String name){
      stroke(strokeColor);
      line(pos.x, pos.y, pos.x, world.h);      
      fill(strokeColor);
      textAlign(CENTER);
      text(name, (int)pos.x, (int)pos.y);
    }
    
    float getEnergy(){
//      float e=0; 
//      int count=0;
//      // TODO Jonas: nur von den letzten 3...
//      for(int i=0; i< energy.length-1 ; i++){
//        if (energy[i] != 0){
//          e += energy[i];
//          count++;
//        }  
//      }
//      
//      if(count > 0) e = e/count;
      return newEnergy; 
    }
    
    float getSize(){
      float s = 10+getEnergy()*100;
      return s;
    }
}
