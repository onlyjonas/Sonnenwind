class WsprNode{
    
    PVector pos;
    float[] energy = new float[10];
    float newEnergy;
    float currentEnergy;
    color myColor;
    String name; 
    private int history;
    
    WsprNode(World world, String _name, float _azimuth, float _distance, float _energy)
    {
      name = _name;
      setNodeParam(_azimuth, _distance, _energy);
      
      myColor = color(255,255,255);      
      history = 0;
      
      currentEnergy = 0;
      newEnergy= 0;
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
      float maxDis = 500; 
      float x = world.w/360 * _azimuth;
      float y = world.h - (_distance *(world.h - world.horizon) / maxDis);
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
        noStroke();
        fill(myColor, 30);
        for(int i=0; i< energy.length-1 ; i++){
          if(energy[i]>0)ellipse(0,0, 10+energy[i]*100, 10+energy[i]*100);
        }
        
        fill(myColor, 50*currentEnergy);
        stroke(myColor, 255*currentEnergy);
        currentEnergy += ((newEnergy - currentEnergy) * 0.1);
        ellipse(0,0, 10+currentEnergy*100, 10+currentEnergy*100);
        
        if(currentEnergy >= newEnergy -0.01) newEnergy=0;
      popMatrix();
    }   

    
    void drawname(String name){
      fill(myColor);
      text(name, (int)pos.x, (int)pos.y);
    }
    
    void setColor(int r, int g, int b){
      myColor = color(r,g,b);
    }
    
    float getEnergy(){
      float e=0; 
      int count=0;
      // TODO Jonas: nur von den letzten 3...
      for(int i=0; i< energy.length-1 ; i++){
        if (energy[i] != 0){
          e += energy[i];
          count++;
        }  
      }
      
      if(count > 0) e = e/count;
      return e; 
    }
    
    float getSize(){
      float s = 10+getEnergy()*100;
      return s;
    }
}
