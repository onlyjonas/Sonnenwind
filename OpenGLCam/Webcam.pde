import javax.media.opengl.*;
import processing.opengl.*;
import java.nio.*;
import com.sun.opengl.util.*;
import processing.video.*;

class Webcam{
    Capture cam;
    boolean BIG_ENDIAN = ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN;
    IntBuffer buf;
    float w, h;
    
    Webcam(PApplet parent, int _camW, int _camH, float _imgW, float _imgH)
    { 
      w = _imgW;
      h = _imgH;
      cam = new Capture(parent, _camW, _camH);
      buf = BufferUtil.newIntBuffer(cam.width*cam.height);
    }
    
    void render(){       
       PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
       GL gl = pgl.beginGL();
       gl.glRasterPos2f(0.01, height-0.01);
       //gl.glPixelZoom(2, 2);
       gl.glDrawPixels(cam.width, cam.height, GL.GL_RGBA, GL.GL_UNSIGNED_BYTE, buf);
       gl.glClear(GL.GL_DEPTH_BUFFER_BIT );
       pgl.endGL();
       
       if (cam.available() == true) {
         cam.read();
         javaToNativeRGB(cam);
         buf.put(cam.pixels);
         buf.rewind();
       }
    }
    
   void javaToNativeRGB(PImage image) {
   int width = image.width;
   int height = image.height;
   int pixels[] = image.pixels;

   int index = 0;
   int yindex = (height - 1) * width;
   for (int y = 0; y < height/2; y++) {
     if (BIG_ENDIAN) {
       // and convert ARGB back to opengl RGBA components (big endian)
       for (int x = 0; x < image.width; x++) {
         int temp = pixels[index];
         pixels[index] = ((pixels[yindex] << 8) & 0xffffff00) | 0xff;
         pixels[yindex] = ((temp << 8) & 0xffffff00) | 0xff;

         index++;
         yindex++;
       }

     } else {
       // convert ARGB back to native little endian ABGR
       for (int x = 0; x < width; x++) {
         int temp = pixels[index];

         pixels[index] = 0xff000000 |
           ((pixels[yindex] << 16) & 0xff0000) |
           (pixels[yindex] & 0xff00) |
           ((pixels[yindex] >> 16) & 0xff);

         pixels[yindex] = 0xff000000 |
           ((temp << 16) & 0xff0000) |
           (temp & 0xff00) |
           ((temp >> 16) & 0xff);

         index++;
         yindex++;
       }
     }
     yindex -= width*2;
   }
 }
}
