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
    if (port == null) return;
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
    if (serialDebug) print("trying to parse "+buff+", resulting in: ");
    try {
      rotation = Integer.parseInt(buff.substring(0, buff.length()-1))/10.0;
      if (serialDebug) println(rotation);
      // Clear the value of "buff"
      buff = "";
    }
    catch (Exception e) {
      if (serialDebug) println("error.");
      buff = "";
      //    port.clear();
    }
  } 
  float getRotation() {
    return rotation;
  }
}

class RotationCorrection {
  float north = 0;
  public RotationCorrection() {
    north = 0;
  }
  float normalizeRotation(float rot) {
    float nRot = rot-north;
    while (nRot < 0) nRot += 360;
    while (nRot > 360) nRot -= 360;
//    println("rot from "+rot+" to "+nRot+" (north is "+north+").");
    return nRot;
  }
  void loadNorth() {
    String[] northStrings = loadStrings("north.dat");
    if (northStrings != null) {
      if (northStrings.length > 0) {
        try {
          north = Float.parseFloat(northStrings[0]);
        } 
        catch (Exception e) {
          north = 0;
        }
      }
    }
  }
  void calibrateNorth(float newNorth) {
    north = newNorth;
    String[] out = new String[1];
    out[0] = ""+north;
    saveStrings("north.dat", out);
  }
}
