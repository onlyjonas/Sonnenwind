import processing.video.*;

class Webcam{
    Capture cam;
    int w, h;
    
    Webcam(PApplet parent, int _w, int _h)
    { 
      w = 320;
      h = 240;
      cam = new Capture(parent, w, h);
    }
    
    void render(){
        
        if (cam.available() == true) {
          cam.read();
          image(cam,0,0);
        }
    }
    
    void brightnessControl( int maxBrightness){
      
      // How many pixels to skip in either direction 
      int increment = 10;
      
      int index = 0;
      int rtot = 0;
      int gtot = 0;
      int btot = 0;
      int aBrightness = 0;
       
      for (int j = 0; j < cam.height; j += increment) {
       for (int i = 0; i < cam.width; i += increment) {
       
         int pixelColor = cam.pixels[j*cam.width + i];
         int r = (pixelColor >> 16) & 0xff;
         int g = (pixelColor >> 8) & 0xff;
         int b = pixelColor & 0xff;
         rtot = rtot + r;
         gtot = gtot + g;
         btot = btot + b;
         index++;
       }
     }
     rtot = rtot/index;
     gtot = gtot/index;
     btot = btot/index;
     aBrightness = (rtot+gtot+btot)/3;
     
//     println("r: "+rtot+"g: "+gtot+"b: "+btot+"brightness: "+aBrightness);  

     if (maxBrightness < aBrightness) {
       // -- ???
       int t = 255 + maxBrightness - aBrightness;
//       println(t); 
//       tint(t);
       tint(50);
     }
    }
}
