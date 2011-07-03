import processing.serial.*;

class SerialController {
  String buff = "";
  int rotation = 0;
  Serial port;

  public SerialController(PApplet parent) {
    try {
      port = new Serial(parent, Serial.list()[1], 9600);
      println("Serial line connected.");
    } 
    catch (Exception e) {
      port = null;
      println("No serial connection. Use Keyboard UP/DOWN to move");
    }
    buff = new StringBuffer();
  }

  void readSerial() { 
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
      print("trying "+buff+" resulting in ");
      rotation = Integer.parseInt(buff.substring(0, buff.length()-1))/10.0;
      println("got: "+rotation);
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
    return rotation/10.0;
  }
}

/*void serialEvent(int serial) {
  serialController.serialEvent(serial);
  world.setRotation(serialController.getRotation());
}*/

