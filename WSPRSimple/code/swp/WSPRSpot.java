package swp;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.TimeZone;
import java.util.Calendar;
import java.util.Date;

public class WSPRSpot implements Serializable, Cloneable {
  // values from the database
  protected String date;
  protected String call;
  protected double frequency;
  protected double snr;
  protected double drift;
  protected String grid;
  protected double dBm;
  protected double w;
  protected String by;
  protected String loc;
  protected int km;
  // derived values
  protected LongLat longlat;
  protected Date spotDate;
  protected double azimuth;
  protected double distance;
//  protected int spotCount;
  
  public WSPRSpot() {
    //spotCount = 1;
  } 
  public WSPRSpot clone() {
    try { 
      return (WSPRSpot)super.clone(); 
    } 
    catch (CloneNotSupportedException e) { 
      throw new InternalError(); 
    } 
  }
  public String getCallsign() {
    return call;
  }
  public float getAzimuth() {
    return (float)azimuth;
  }
  public int getDistance() {
    return (int)distance;
  }
/*  public int getCount() {
    return spotCount;
  }*/
  public float getSNR() {
    return (float)snr;
  }
  public float getPowerdBm() {
    return (float)dBm;
  }
  public Date getDate() {
    return spotDate;
  }
  public long getAge() {http://download.oracle.com/javase/1.4.2/docs/api/resources/inherit.gif
    return Calendar.getInstance().getTime().getTime() - spotDate.getTime();
  }
  
  protected void createDate() {
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd kk:mm");
    df.setCalendar(Calendar.getInstance(TimeZone.getTimeZone("UTC")));
    try {
      spotDate = df.parse(date);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
  
  protected void computeRelativePosition(LongLat myLongLat) {
    azimuth = computeAzimuth(myLongLat.lng, myLongLat.lat, longlat.lng, longlat.lat);
    distance = computeRange(myLongLat.lng, myLongLat.lat, longlat.lng, longlat.lat);
  }
  protected double computeAzimuth(double hlong, double hlat, double dlong, double dlat) {
  //outward azimuth angle
  double dl=720.0-1.0*dlong;
  double hl=720.0-1.0*hlong;
  double dong=dl-hl;
  if (Math.abs(dong)>180) {
    // crosses 180 line in pacific
    if ((dlong<0) && (hlong>0)) dlong=1.0*dlong+360.0;
    if ((hlong<0) && (dlong>0)) dlong=1.0*dlong-360-0;
    dl=720.0-1.0*dlong;
    hl=720.0-1.0*hlong;
    dong=dl-hl;
  }
  double r=Math.acos(Math.cos(dong/57.29577951308)*Math.cos(dlat/57.29577951308)*Math.cos(hlat/57.29577951308)+Math.sin(hlat/57.29577951308)*Math.sin(dlat/57.29577951308));
  double t1=Math.sin(dlat/57.29577951308)-Math.cos(r)*Math.sin(hlat/57.29577951308);
  double b1=Math.sin(r)*Math.cos(hlat/57.29577951308);
  //return t1/b1;
  double t=t1/b1;
  if (t>1) t=1;
  if (t<-1) t=-1;
  double az=Math.acos(t);
  double azd=az*57.29577951308;
  double azi;
  if (hl<dl) azi=360.0-azd;
  else azi=azd;
  return azi;
}
  protected double computeRange(double hlong, double hlat, double dlong, double dlat) {
    double dong=hlong-dlong;
    double r1=57.29577951308*Math.acos(Math.cos(dong/57.29577951308)*Math.cos(dlat/57.29577951308)
      *Math.cos(hlat/57.29577951308)
      +Math.sin(hlat/57.29577951308)*Math.sin(dlat/57.29577951308));
    // 111.15 amended to 111.226264 on 11/9/2004 
    double r2=111.226264*r1;
    return r2;
  }
  public String toString() {
    String out = date+", "+call+", "+frequency+", "+snr+", "+drift+", "+grid+", "+dBm+", "+w+", "+by+", "+loc+", "+km+", "+azimuth+", "+distance;
    return out;
  }

}