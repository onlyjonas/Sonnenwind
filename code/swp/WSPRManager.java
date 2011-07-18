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
  boolean autoSave;
  
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

  public WSPRManager(String call, String grid, long interval, boolean autoSave, boolean debug) {
    failCount = 0;
    failMax = 10;
    this.debug = debug;
    this.autoSave = autoSave;
    
    this.interval = interval;
    wsprData = null;
    // first read from file
    try {
      if (debug) System.out.print("trying to load WSPR data...");
      loadFromFile();
      if (debug) System.out.println(" success!");
      if (debug) {
        System.out.print("now at size "+wsprData.getSpotCount()+";");
        if (wsprData.getOldest() != null) System.out.print("oldest is: "+wsprData.getOldest().getDate());
        System.out.println();
      }
    } catch (IOException ioe) {
      if (debug) System.out.println(" failed!");
      wsprData = new WSPRData(call, grid);
    } finally {
      readWSPRNETuntil26hrs();
    }
  }
  
  private void readWSPRNETuntil26hrs() {
      if (debug) System.out.println("Requesting data from WSPRNET...");
      int requestCount = 1;
      try {
        boolean done = false;
        do {
          wsprData.readWSPRNET(50*requestCount);
          requestCount++;
          if (debug) {
            System.out.print("Request #"+requestCount);
            System.out.print(" now at size "+wsprData.getSpotCount()+";");
            if (wsprData.getOldest() != null) System.out.print("oldest is: "+wsprData.getOldest().getDate());
            System.out.println();
          }
          if (wsprData.getOldest() != null) {
            done = wsprData.getOldest().getAge() < 93600000;
          }
        } while (!done && requestCount < 20);  // 26 hrs = 93600000 ms
        if (debug) System.out.println("...done.");
        if (wsprData.getSpotCount()<=0) {
          if (debug) System.out.println("Got no spots for this call ("+getWSPRData().getCall()+").");
          try {
            loadFakeData();
          } catch (Exception ee) {
            if (debug) System.out.println("Could not load fake data, because of an "+ee);
          }          
        }
        if (autoSave) {
          if (debug) System.out.println("saving...");
          try {
            saveToFile();
            if (debug) System.out.println(" done.");
          } catch (IOException ioe) {
            if (debug) System.out.println(" failed: ");
            if (debug) System.out.println(ioe);
          }
        }
      } catch (Exception e) {
        if (debug) System.out.println("Could not read or parse WSPRNET!");
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
        if (debug) System.out.println("Got new spots.");
        if (autoSave) {
          try {
            if (debug) System.out.print("Saving...");
            saveToFile();
            if (debug) System.out.println(" done.");
          } catch (IOException ioe) {
            if (debug) System.out.println(" failed: ");
            if (debug) System.out.println(ioe);
          }
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
  private void relocateSpots(WSPRData fakeSpots) {
    Random r = new Random();
//    if (debug) System.out.println(fakeSpots);
    if (debug) System.out.println(getWSPRData());
    int num = fakeSpots.getSpotCount();
    if (debug) System.out.println("Re-locating all "+num+" spots.");
    LinkedList<WSPRSpot> allSpots = fakeSpots.getSpotList();
    WSPRData newData = new WSPRData(getWSPRData().getCall(), getWSPRData().getGrid());
    for (int i=0; i<num; i++) {
      WSPRSpot s = allSpots.get(i);
      if (debug) System.out.println(s+" reported by "+s.by+" at "+s.loc+" becomes ");
      WSPRSpot newSpot = s.clone();
      //newSpot.spotDate = Calendar.getInstance(TimeZone.getTimeZone("GMT")).getTime();
      newSpot.by = getWSPRData().getCall();
      newSpot.loc = getWSPRData().getGrid();
      newSpot.computeRelativePosition(getWSPRData().getGeoPos());
      // 24 * 60 * 60 * 1000 = 86400000
      while (newSpot.getAge() > 86400000) {
        newSpot.spotDate.setTime(newSpot.spotDate.getTime()+86400000);
      }
      newData.insertSpot(newSpot);
      if (debug) System.out.println(newSpot);
    }
    wsprData = newData;
  }

  
  private void loadFromFile() throws IOException {
    wsprData = load("allSpots.ser");
  }
  public void saveToFile() throws IOException {
    save("allSpots.ser");
  }
  private WSPRData load(String fileName) throws IOException {
    WSPRData out = null;
    try {
      FileInputStream fis = new FileInputStream(fileName);
      ObjectInputStream ois = new ObjectInputStream(fis);
      out = (WSPRData)ois.readObject();
      ois.close();
    }
    catch (ClassNotFoundException ce) {
      System.out.println("ClassNotFoundException");
      System.out.println(ce);
    }
    return out;
  }
  private void save(String fileName) throws IOException {
    FileOutputStream fos = new FileOutputStream(fileName);
    ObjectOutputStream oos = new ObjectOutputStream(fos);
    oos.writeObject(wsprData);
    oos.close();
  }
  public void loadFakeData() throws IOException {
    if (debug) System.out.println("Loading fake data...");
    WSPRData fakeSpots = load("fakeSpots.ser");
    relocateSpots(fakeSpots);
  }
  public void saveFakeData() throws IOException {
    save("fakeSpots.ser");
  }
}