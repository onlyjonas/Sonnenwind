class WindCurve {

  PVector start, end; 
  int detail;
  float h, w, fieldWidth;
  ArrayList<WindVertex> windVertices = new ArrayList();
  color myColor;

  WindCurve(float _startX, float _startY, float _endX, float _endY, float _height, int _detail) {
    start = new PVector(_startX, _startY); 
    end = new PVector(_endX, _endY);
    detail = _detail;
    h = _height;
    w = end.x-start.x;
    fieldWidth = w/detail;
    myColor = color(255, 255, 0);

    for (int i=0; i<detail; i++) {
      WindVertex windVertex = new WindVertex(i, fieldWidth*i+start.x, end.y);
      windVertices.add(windVertex);
    }
  }

  void render() {
    stroke(myColor);
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
      windVertices.get(i).update( _sunX,  _sunY);
    }
   
    
  }

  void setActivityOffset(int i, float offset) {
    offset = offset * h/4; // h/4 = 25 (max offset)
    windVertices.get(i).acivityOffset = offset;
  }
  
  void setNodeOffset(float nodeX, float energy) {  
    int i =floor(nodeX/fieldWidth) ;
    float offset = energy * h/1.4 *-1;
    windVertices.get(i).nodeOffset = offset;
  }

  class WindVertex {
    int index;
    PVector pos, target, startPos;
    float acivityOffset=0;
    float nodeOffset=0;
    float pulseOffset=0;
    long starttime, interval;
    
    WindVertex(int _index, float _posX, float _posY) {
      pos = new PVector(_posX, _posY);
      target = new PVector(_posX, _posY); 
      startPos = new PVector(_posX, _posY);
      index = _index;
      interval = 1000;
      starttime = millis()-interval;
    }
    
    void update(float _sunX, float _sunY){
      
      // check sun position, if sun is close to vertex
      if (_sunX > index*fieldWidth-fieldWidth/2 && _sunX < index*fieldWidth+fieldWidth/2) {
        target.x = _sunX;  
        target.y = _sunY;
      }
      else {
        target.x = startPos.x;  
        target.y = startPos.y + acivityOffset + nodeOffset + pulseOffset;
      }
      // FEHLER in nodeOffset 

      // pulse / wind effect
      if (millis() - starttime > interval + random(100*index)) {
         if (pulseOffset>0) pulseOffset = 0;
         else pulseOffset = 10;
         starttime = millis();
      }


      // move to target (easing)
      pos.x += (( target.x - pos.x) * 0.1); 
      pos.y += (( target.y - pos.y) * 0.08); 
      
      // draw debug line
      stroke(255, 0, 0); 
      line(pos.x, pos.y-5, pos.x, pos.y+5);
    }
  }
}

