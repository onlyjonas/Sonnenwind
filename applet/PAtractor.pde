class PAtractor {

  PVector pos;
  float mySize;
  
  PAtractor(float _x, float _y, float _size) {
    pos = new PVector(_x, _y);
    mySize = _size;
  }

  void render() {
    noFill();
    stroke(255);
    line(pos.x,pos.y-mySize/2, pos.x,pos.y+mySize/2);
    line(pos.x-mySize/2, pos.y,pos.x+mySize/2, pos.y); 
    //ellipse(pos.x, pos.y, mySize, mySize);
  }
}

