package swp;

import java.io.FileOutputStream;
import java.io.ObjectOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.FileInputStream;
import java.util.Random;
import java.util.Calendar;
import java.util.TimeZone;
import java.util.LinkedList;

public class WSPRManager extends Thread {
  private WSPRData wsprData;
  private long interval;
  private int failCount;
  private int failMax;
  
  private boolean debug;
  
  public synchronized int getFailMax() {
    return failMax;
  }
  public synchronized void setFailMax(int failMax) {
    this.failMax = failMax;
  }
  public synchronized int getFailCount() {
    return failCount;
  }
  public synchronized void setDebug(boolean onOff) {
    debug = onOff;
  }
  public synchronized boolean getDebug() {
    return debug;
  }
  public synchronized WSPRData getWSPRData() {
    return wsprData;
  }

  public WSPRManager(String call, String grid, long interval, int maxAgeHours, boolean debug) {
    failCount = 0;
    failMax = 10;
    this.debug = debug;
    
    this.interval = interval;
    wsprData = null;
    // first read from file
    try {
      if (debug) System.out.print("trying to load WSPR data...");
      loadFromFile();
      if (debug) System.out.println(" success!");
      if (debug) System.out.println("now at size "+wsprData.getSpotCount()+"; oldest is: "+wsprData.getOldest().getDate());
    } catch (IOException ioe) {
      if (debug) System.out.println(" failed!");
      wsprData = new WSPRData(call, grid);
      wsprData.setMaxAgeHours(maxAgeHours);
    } finally {
      readWSPRNETuntil26hrs();
    }
  }
  
  private void readWSPRNETuntil26hrs() {
      if (debug) System.out.println("Requesting data from WSPRNET...");
      int requestCount = 1;
      try {
        do {
          wsprData.readWSPRNET(50*requestCount);
          requestCount++;
          if (debug) System.out.print("Request #"+requestCount);
          if (debug) System.out.println(". Now at size "+wsprData.getSpotCount()+", oldest is: "+wsprData.getOldest().getDate());
        } while (wsprData.getOldest().getAge() < 93600000);  // 26 hrs = 93600000 ms
        if (debug) System.out.print("...done.\nsaving...");
        try {
          saveToFile();
          if (debug) System.out.println(" done.");
        } catch (IOException ioe) {
          if (debug) System.out.println(" failed: ");
          if (debug) System.out.println(ioe);
        }
      } catch (Exception e) {
        if (debug) System.out.println("Could not read or parse WSPRNET!");
        // TODO: MACH WAS!!!
      }
  }
  
  private void updateWSPRNET() {
    if (debug) System.out.print("updating WSPRNET data...");
    try {
      long oldYoungestAge = wsprData.getYoungest().getAge();
      wsprData.readWSPRNET(50);
      if (debug) System.out.println(" done. New spotcount is "+wsprData.getSpotCount());
      failCount = 0;
//      if (debug) System.out.println("Youngest spot "+wsprData.getYoungest().getDate()+" is age "+ wsprData.getYoungest().getAge());
      if (wsprData.getYoungest().getAge()<oldYoungestAge) {
        try {
          if (debug) System.out.print("Got new spots. Saving...");
          saveToFile();
          if (debug) System.out.println(" done.");
        } catch (IOException ioe) {
          if (debug) System.out.println(" failed: ");
          if (debug) System.out.println(ioe);
        }
      }
    } catch (Exception e) {
      if (debug) System.out.println(" failed.");
      if (debug) System.out.print("Could not read or parse WSPRNET!");
      failCount++;
      if (debug) System.out.println(" Fail count is "+failCount);
      if (failCount > failMax) {
        rearrangeSpots();
      }
    }
  }
  
  public void run() {
    while(true) {
      try {
        updateWSPRNET();
        sleep(interval);
      } catch (InterruptedException ie) {
        ie.printStackTrace();
      }
    }
  }
  
  private void rearrangeSpots() {
    Random r = new Random();
    if (debug) System.out.println(wsprData);
    int num = wsprData.getSpotCount() / 24 + (r.nextInt(5) - 2);
    if (debug) System.out.println("Re-arranging "+num+" spots.");
    LinkedList<WSPRSpot> allSpots = wsprData.getSpotList();
    for (int i=0; i<num; i++) {
      WSPRSpot s = allSpots.get(i);
      if (debug) System.out.println(s+" at "+s.getDate()+" becomes ");
      WSPRSpot newSpot = s.clone();
      newSpot.spotDate = Calendar.getInstance(TimeZone.getTimeZone("GMT")).getTime();
      newSpot.date = newSpot.getDate()+"";
      wsprData.insertSpot(newSpot);
      if (debug) System.out.println(newSpot);
    }
  }
  
  private void loadFromFile() throws IOException {
    try {
      FileInputStream fis = new FileInputStream("allSpots.ser");
      ObjectInputStream ois = new ObjectInputStream(fis);
      wsprData = (WSPRData)ois.readObject();
      ois.close();
    }
    catch (ClassNotFoundException ce) {
      System.out.println("ClassNotFoundException");
      System.out.println(ce);
    }
  }
  public void saveToFile() throws IOException {
    FileOutputStream fos = new FileOutputStream("allSpots.ser");
    ObjectOutputStream oos = new ObjectOutputStream(fos);
    oos.writeObject(wsprData);
    oos.close();
  }
}