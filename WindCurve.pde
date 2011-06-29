class WindCurve {

  PVector start, end; 
  int detail;
  float h, w, fieldWidth;
  PVector[] vertexPos;
  PVector[] vertexTarget;
  ArrayList<WindVertex> windVertices = new ArrayList();
  int time=0;

  WindCurve(float _startX, float _startY, float _endX, float _endY, float _height, int _detail) {
    start = new PVector(_startX, _startY); 
    end = new PVector(_endX, _endY);
    detail = _detail;
    h = _height;
    w = end.x-start.x;
    fieldWidth = w/detail;

    vertexPos = new PVector[detail];
    vertexTarget = new PVector[detail];

    for (int i=0; i<detail; i++) {
      WindVertex windVertex = new WindVertex(fieldWidth*i+start.x, end.y);
      windVertices.add(windVertex);
    }
  }

  void render() {
    stroke(255);
    noFill();
    beginShape();

    curveVertex(windVertices.get(0).pos.x-100, windVertices.get(0).pos.y); // the first control point

    for (int i=0; i<detail; i++) {
      curveVertex(windVertices.get(i).pos.x, windVertices.get(i).pos.y);
    }

    curveVertex(windVertices.get(detail-1).pos.x-100, windVertices.get(detail-1).pos.y); // is also the last control point

    endShape();
  }

  void update(float _sunX, float _sunY) {
    
    for (int i=0; i<detail; i++) {

      // check sun position, if sun is close to vertex
      if (_sunX > i*fieldWidth-fieldWidth/2 && _sunX < i*fieldWidth+fieldWidth/2) {
        windVertices.get(i).target.x = _sunX;  
        windVertices.get(i).target.y = _sunY;
      }
      else {
        windVertices.get(i).target.x = windVertices.get(i).startPos.x;  
        windVertices.get(i).target.y = windVertices.get(i).startPos.y 
                                     + windVertices.get(i).acivityOffset
                                     + windVertices.get(i).nodeOffset;
      }

      // pulse / wind effect
      if (floor(random(50))==i) windVertices.get(i).updatePulse();

      // move to target (easing)
      windVertices.get(i).pos.x += (( windVertices.get(i).target.x - windVertices.get(i).pos.x) * 0.1); 
      windVertices.get(i).pos.y += (( windVertices.get(i).target.y - windVertices.get(i).pos.y) * 0.08); 
      
      // draw debug line
      stroke(255, 0, 0); 
      line(windVertices.get(i).pos.x, windVertices.get(i).pos.y-5, windVertices.get(i).pos.x, windVertices.get(i).pos.y+5);
    }
    
    //Timer
//    if(time<windVertices.size())time++;
//    else time=0;
    
  }

  void setActivityOffset(int i, float offset) {
    offset = offset * h/5; // h/5 = 20 (max offset)
    windVertices.get(i).acivityOffset = offset;
  }
  
  void setNodeOffset(float nodeX, float energy) {
    
    int i =floor(nodeX/fieldWidth) ;
    float offset = energy * h/2 *-1;
    windVertices.get(i).nodeOffset = offset;
  }

  class WindVertex {
    PVector pos, target, startPos;
    float acivityOffset=0;
    float nodeOffset=0;
    float pulse=0;
    WindVertex(float _posX, float _posY) {
      pos = new PVector(_posX, _posY);
      target = new PVector(_posX, _posY); 
      startPos = new PVector(_posX, _posY);
    }
    
    void updatePulse(){
      if (pulse > 0) pulse=0;
      else pulse=20;
      
      target.y += pulse;    
    }
  }
}

