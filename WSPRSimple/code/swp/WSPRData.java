package swp;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.Calendar;
import java.util.Date;
import java.util.LinkedList;
import java.lang.StringBuffer;
import org.cyberneko.html.parsers.DOMParser;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.*;

public class WSPRData implements Serializable {
  private LinkedList<WSPRSpot> allSpots;
  private long minTime;
  private WSPRSpot oldest;
  private long maxTime;
  private WSPRSpot youngest;
  private String myCall;
  private String myGrid;
  private LongLat myLongLat;
  private long maxAge;
  
  public WSPRData(String call, String grid) {
    this(call, QTHTools.loc2geo(grid));
    myGrid = grid;
  }
  
  public WSPRData(String call, LongLat longlat) {
    myCall = call;
    myLongLat = longlat;
    allSpots = new LinkedList<WSPRSpot>();
    minTime = Calendar.getInstance().getTime().getTime(); // now
    oldest = null;
    maxTime = 0;
    youngest = null;
  }
  
  public int getSpotCount() {
    return allSpots.size();
  }
  public LinkedList<WSPRSpot> getSpotList() {
    return allSpots;
  }
  public WSPRSpot[] getSpotArray() {
    return (WSPRSpot[])allSpots.toArray(new WSPRSpot[0]);
  }
  public WSPRSpot getYoungest() {
    return youngest;
  }
  public WSPRSpot getOldest() {
    return oldest;
  }
  public void setMaxAgeHours(int hours) {
    maxAge = hours * 3600000;
    ageCheck();
  }
  public int getMaxAgeHours() {
    return (int)(maxAge / 3600000);
  }
  public LongLat getGeoPos() {
    return myLongLat;
  }
  
  /** Attemps to estimate radio wave absorbtion caused by ionization of layer D using the following rationale:
      IF in this direction +/-SOME degress has been more activity at time 24-26 h before the last two hours 
      THEN solar activity is high 
      i.e. activity is number of spots today MINUS yesterday. */
  public int estimateSolarActivity(int angle) {
    long now = Calendar.getInstance(TimeZone.getTimeZone("GMT")).getTime().getTime(); // now
    long twoHours = 7200000;
    long twentyFourHours = 86400000;
    long twentySixHours = 93600000;
    int todayCount = 0;
    int yesterdayCount = 0;
    for (int i=allSpots.size()-1; i>-1; i--) {
      WSPRSpot s = allSpots.get(i);
      // inside +/- 20 deg range?
      if ((s.getAzimuth() > angle-20) && (s.getAzimuth() < angle+20)) {
//        System.out.println(s+"\n...is in range");
//        System.out.println("time: "+s.getDate().getTime()+" ("+s.getDate()+") vs.\n now: "+now+" ("+Calendar.getInstance(TimeZone.getTimeZone("GMT")).getTime()+")\ndiff: "+(now-s.getDate().getTime()));
        if (s.getDate().getTime() > (now - twoHours)) {
          todayCount++;
//          System.out.println(s+"\n is a today hit!");
        } else if ((s.getDate().getTime() > (now - twentySixHours)) && (s.getDate().getTime() < (now - twentyFourHours))) {
          yesterdayCount++;
//          System.out.println(s+"\n is a yesterday hit!");
        } else if (s.getDate().getTime() < (now - twentySixHours)) {
          i = -1;
//          System.out.println("and done");
        }
      }
    }
//    System.out.println("today: "+todayCount+", yesterday: "+yesterdayCount);
    int activityChange;
    activityChange =  todayCount-yesterdayCount;
    return activityChange;
  }
  
  public void readWSPRNET(int number) throws Exception {
    DOMParser parser = new DOMParser();

    parser.parse("http://wsprnet.org/olddb/?mode=html&band=all&limit="+number+"&sort=date&findreporter="+myCall+"&sort=date");
    Document doc = parser.getDocument();
    NodeList nList = doc.getElementsByTagName("tr");
    // skip first 4 table rows -- this is extremely quick and dirty!
    for (int i=4; i<nList.getLength(); i++) {
      WSPRSpot spot = new WSPRSpot();
      Node row = nList.item(i);
      NodeList cols = ((Element)row).getElementsByTagName("td");
      for (int j=0; j<cols.getLength(); j++) {
        Node cell = cols.item(j);
      }
      // extract data
      if (cols.getLength()==12) {
        spot.date =  cols.item(0).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", "");
        spot.call = cols.item(1).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", "");
        spot.frequency = Double.parseDouble(cols.item(2).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        spot.snr = Double.parseDouble(cols.item(3).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        spot.drift = Double.parseDouble(cols.item(4).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        spot.grid = cols.item(5).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", "");
        spot.dBm = Double.parseDouble(cols.item(6).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        spot.w = Double.parseDouble(cols.item(7).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        spot.by = cols.item(8).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", "");
        spot.loc = cols.item(9).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", "");
        spot.km = Integer.parseInt(cols.item(10).getFirstChild().getNodeValue().trim().replaceAll("\u00A0", ""));
        
        spot.createDate();
        
        // is spot already in list?
        // if new: add this spot to the list
        if (!isDoubleSpot(spot)) {
          // derive location
          spot.longlat = QTHTools.loc2geo(spot.grid);
          // add to list at appropriate position
          insertSpot(spot);
          // then update min/max time
          if (spot.longlat!=null) {
            spot.computeRelativePosition(myLongLat);
            if (spot.spotDate.getTime() <= minTime) {
              minTime = spot.spotDate.getTime();
              oldest = spot;
            }
            if (spot.spotDate.getTime() >= maxTime) {
              maxTime = spot.spotDate.getTime();
              youngest = spot;
            }
          }
        }
      }
    }
  }
  
  protected void ageCheck() {
    for (int i=allSpots.size()-1; i>-1; i--) {
      WSPRSpot s = allSpots.get(i);
      if (s.getAge() > maxAge) {
        allSpots.remove(i);
      } else {
        i = -1;
      }
    }
  }
  
  protected void insertSpot(WSPRSpot spot) {
    for (int i=0; i<allSpots.size(); i++) {
      if (spot.spotDate.getTime() < allSpots.get(i).spotDate.getTime()) {
        allSpots.add(i, spot);
        ageCheck();
        return;
      }
    }
    allSpots.add(spot);
    ageCheck();
  }
  
  protected boolean isDoubleSpot(WSPRSpot s) {
    for (int i=allSpots.size()-1; i>-1; i--) {
      if (allSpots.get(i).call.equals(s.call) && (allSpots.get(i).getDate().getTime()==s.getDate().getTime())) return true;
    }
    return false;
  }
  
  public String toString() {
    StringBuffer out = new StringBuffer("WSPRData for "+myCall+" at "+myGrid+" ("+myLongLat+"):\n");
    for (int i=0; i<allSpots.size(); i++) {
      out.append(allSpots.get(i)+"\n");
    }
    return out+"";
  }
}