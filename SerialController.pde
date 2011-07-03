import processing.serial.*;

class SerialController {
  String buff = "";
  float rotation = 0;
  Serial port;
  boolean serialDebug = false;

  public SerialController(PApplet parent) {
    try {
      port = new Serial(parent, Serial.list()[0], 9600);
      println("Serial line connected.");
    } 
    catch (Exception e) {
      port = null;
      println("No serial connection. Use Keyboard UP/DOWN to move");
    }
    buff = "";
  }

  void readSerial() {
    if (port==null) return;
    while (port.available () > 0) {
      int in = port.read();
      if (in==10) {
        parseData();
      } 
      else {
        buff += char(in);
      }
    }
  }

  void parseData() {
    try {
      if (serialDebug) print("trying to parse "+buff+" resulting in ");
      rotation = Integer.parseInt(buff.substring(0, buff.length()-1))/10.0;
      if (serialDebug) println("got: "+rotation);
      // Clear the value of "buff"
      buff = "";
    } 
    catch (Exception e) {
      println("error.");
      buff = "";
      //    port.clear();
    }
  } 
  float getRotation() {
    return rotation;
  }
}

/*void serialEvent(int serial) {
  serialController.serialEvent(serial);
  world.setRotation(serialController.getRotation());
}*/

