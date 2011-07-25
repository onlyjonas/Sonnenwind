package swp;
import java.io.Serializable;

public class LongLat implements Serializable {
  public double lng;
  public double lat;
  public String toString() {
    return "long: "+lng+", lat: "+lat;
  }
  /** Azimuth from this to other. */
  public double azimuth(LongLat other) {
    double hlong = this.lng;
    double hlat = this.lat;
    double dlong = other.lng;
    double dlat = other.lat;
    
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
    double r=Math.acos(Math.cos(dong/57.29577951308)*Math.cos(dlat/57.29577951308)*Math.cos(hlat/57.29577951308)
      +Math.sin(hlat/57.29577951308)*Math.sin(dlat/57.29577951308));
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
  /** Distance between this and other. */
  public double range(LongLat other) {
    double hlong = this.lng;
    double hlat = this.lat;
    double dlong = other.lng;
    double dlat = other.lat;
    double dong=hlong-dlong;
    double r1=57.29577951308*Math.acos(Math.cos(dong/57.29577951308)*Math.cos(dlat/57.29577951308)
      *Math.cos(hlat/57.29577951308)
      +Math.sin(hlat/57.29577951308)*Math.sin(dlat/57.29577951308));
    // 111.15 amended to 111.226264 on 11/9/2004 
    double r2=111.226264*r1;
    return r2;
  }
}