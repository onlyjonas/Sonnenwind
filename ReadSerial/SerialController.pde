import processing.serial.*;

class SerialController {
  StringBuffer buff;
  int rotation = 0;
  int NEWLINE = 10;
  Serial port;
  
  public SerialController(PApplet parent) {
    try {
      port = new Serial(parent, Serial.list()[0], 9600);
      println("Serial line connected.");
    } catch (Exception e) {
      port = null;
      println("No serial connection. Use Keyboard UP/DOWN to move");
    }
    buff = new StringBuffer();
  }
  
  void serialEvent(int serial) {
    if(serial != NEWLINE) { 
      buff.append(char(serial));
    } else {
      try {
        // Parse the String into an integer
        rotation = Integer.parseInt(buff.substring(0, buff.length()-1));
        buff = new StringBuffer();
      } catch (Exception e) {
        println("Received garbage over serial line!");
      }
    }
  }
  
  int getRotation() {
    return rotation;
  }
}

void serialEvent(int serial) {
  serialController.serialEvent(serial);
}
