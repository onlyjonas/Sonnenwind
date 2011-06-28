class WindCurve {

  PVector start, end; 
  int detail=20;
  float idleStrenght=20.0;
  PVector[] vertexPos;
  PVector[] vertexTarget;
  int pulseIndex=0;

  WindCurve(World world, float _y) {
    start = new PVector(0, _y); 
    end = new PVector(world.w, _y);

    vertexPos = new PVector[detail];
    vertexTarget = new PVector[detail];
    
    float step = (end.x-start.x)/detail;
    for (int i=0; i<detail; i++) {
      vertexPos[i]= new PVector(step*i+start.x, _y) ;
      vertexTarget[i]= new PVector(vertexPos[i].x, 50) ;
    }
  }

  void render() {
    stroke(255);
    noFill();
    beginShape();
    
    curveVertex(vertexPos[0].x-100, vertexPos[0].y); // the first control point

    for (int i=0; i<detail; i++) {
      curveVertex(vertexPos[i].x, vertexPos[i].y);
      println(vertexPos[i].x);
    }

    curveVertex(vertexPos[detail-1].x-100, vertexPos[detail-1].y); // is also the last control point

    endShape();
  }

  void update() {
    for (int i=0; i<detail; i++) {
     vertexPos[i].y += (( vertexTarget[i].y - vertexPos[i].y) * 0.08); 
     stroke(255,0,0);
     line(vertexPos[i].x,vertexPos[i].y-5,vertexPos[i].x,vertexPos[i].y+5);   
    }
  }
  
  void pulse(float pulse) {
        
    print("target: "+ vertexTarget[pulseIndex].y);
    vertexTarget[pulseIndex].y += pulse;
    println(" + " +  vertexTarget[pulseIndex].y);
    
    int prev = pulseIndex-1;
    if(prev<0)prev=detail-1;

    vertexTarget[prev].y =40; // start
    
    if(pulseIndex>=detail-1) pulseIndex=0;
    else pulseIndex++;    
    
  }
}

