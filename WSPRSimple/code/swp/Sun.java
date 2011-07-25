package swp;

import java.util.Calendar;
import java.util.TimeZone;

/* Derived from code by Martin Nawrath, nawrath@khm.de Thank you! 
   Using concepts explained at http://www.jgiesen.de/elevaz/basics/index.htm and http://de.wikipedia.org/wiki/Sonnenstand
*/
public class Sun extends Thread {
  private final boolean debug = false;
  private int hh, mm, ss;
  private double jDay, T2000, UT;
  private double rektazension_arc, rektazension_deg;
  private double deklination_arc, deklination_deg;
  private double L_deg;
  // decimal degrees!
  private double OrtsBreite_arc, OrtsBreite_deg;
  private double OrtsLaenge_arc, OrtsLaenge_deg;
  private double azimuth_arc, azimuth_deg;
  private double elevation_arc, elevation_deg;
  private double azimuth;
  private double elevation;
  private long interval;

  public Sun(LongLat LocalPos, long interval) {
    OrtsLaenge_deg = LocalPos.lng;
    OrtsBreite_deg = LocalPos.lat;
    this.interval = interval;
  }
  public void run() {
    while (true) {
      updatePosition();
      try {
        sleep(interval);
      } catch (InterruptedException ie) {
        ie.printStackTrace();
      }
    }
  }
  public void updatePosition() {
    /*UT=universalTime(12,38,8);
    jDay=julianDay(16,6,2011,UT);*/
    Calendar now = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
    boolean donow = true;
    int h,m,s,d;
    if (!donow) {
      h = 1; //now.get(Calendar.HOUR_OF_DAY);
      m = 35; //now.get(Calendar.MINUTE);
      s = 00; //now.get(Calendar.SECOND);
    } else {
      h = now.get(Calendar.HOUR_OF_DAY);//-timeZoneOffset;
      m = now.get(Calendar.MINUTE);
      s = now.get(Calendar.SECOND);
    }
    if (debug) System.out.print("HMS: "+h+", "+m+", "+s+" - ");
    if (!donow) {
      d = 17; //now.get(Calendar.DAY_OF_MONTH);
    } else {
      d = now.get(Calendar.DAY_OF_MONTH);
    }
    int mo = now.get(Calendar.MONTH)+1;
    int y = now.get(Calendar.YEAR);
    if (debug) System.out.println("DMY: "+d+", "+mo+", "+y);
    if (debug) System.out.println("-----------");
    UT = universalTime(h, m, s);
    jDay = julianDay(d, mo, y, UT);
    calculate(jDay);
  }
  private void calculate( double JD) {
    /*
   http://www.jgiesen.de/elevaz/basics/index.htm
     */
    if (debug) System.out.println("Berechnung");
    double     Pi2 =   2.0*Math.PI;
    // UT=UniversalTime(19,21,0);
    // JD=JulianDay(10,4,1987,UT);
/*    if (debug) print ("JD : ");
    if (debug) System.out.println(JD);*/
    double T=T2000;
/*    if (debug) print ("T: ");
    if (debug) System.out.println(T);*/
    double k = Math.PI/180.0;
    // double M  = Pi2 * frac(0.993133+99.97361*T);
    //mean anomaly, degree
    double M = 357.52910 + 35999.05030*T - 0.0001559*T*T - 0.00000048*T*T*T;
    while (M > 360.0) M=M-360.0;
    // mean longitude, degree
    double L0 = 280.46645 + 36000.76983*T + 0.0003032*T*T ;
    while (L0 > 360.0) L0=L0-360.0;

    double DL = (1.914600 - 0.004817*T - 0.000014*T*T)*Math.sin(k*M)+ (0.019993 - 0.000101*T)*Math.sin(k*2*M) + 0.000290*Math.sin(k*3*M) ;
    while (DL > 360.0) DL=DL-360.0;  

/*    if (debug) print ("M: ");
    if (debug) System.out.println(M);
    if (debug) print ("T: ");
    if (debug) System.out.println(T);

    if (debug) print ("Lo: ");
    if (debug) System.out.println(L0);

    // double DL = 6893.0 * Math.sin(M) + 72.0*Math.sin(M+M);
    if (debug) print ("DL: ");
    if (debug) System.out.println(DL);
*/

    // mittlere ekliptikale Länge L der Sonne 
    //  double L  = Pi2 * frac(0.7859453 + M/Pi2) + (6191.2*T +DL)/1.296e+6;
    // true longitude, degree
    L_deg = L0 + DL ;
    while (L_deg > 360.0) L_deg=L_deg-360.0;
    while (L_deg < 0.0) L_deg=L_deg+360.0;

/*
    if (debug) print ("L: ");
    if (debug)  System.out.println(L_deg);
    //  txfLong.setText(Double.toString(L_deg));
*/



    double X  = Math.cos(L_deg*k);
    double Y  = 0.91748*Math.sin(L_deg*k);
    double Z  = 0.39778*Math.sin(L_deg*k);

    double r  = Math.sqrt(1.0 - Z*Z);
    deklination_arc   = Math.atan(Z/r); // in Gradmass
    deklination_deg = deklination_arc*180.0/Math.PI;
/*
    if (debug)  print ("Dec: ");
    if (debug)  System.out.println(Double.toString(deklination_deg));
*/



    rektazension_arc =2*Math.atan(Y/(X+r));
//    if (debug) print ("RA: ");
    rektazension_deg= rektazension_arc*180.0/Math.PI;
/*    if ( rektazension_deg < 0 )  rektazension_deg= rektazension_deg+360.0;
    if (debug) System.out.println(Double.toString(rektazension_deg));
*/

    // Stundenwinkel Theta
    double thetaG = 280.46061837 + 360.98564736629*(JD-2451545.0) + ( 0.000387933*T*T) - (T*T*T/38710000.0);


    while (  thetaG > 360.0) thetaG=thetaG -360.0;
    while (  thetaG < 0.0) thetaG=thetaG +360.0;
/*    if (debug) print ("THETA0: ");
    if (debug) System.out.println(thetaG);
*/


    double thetaL = thetaG+OrtsLaenge_deg;
    //  txfLoSidTime.setText(Double.toString(thetaL));


/*
    if (debug) print ("THETAL: ");
    if (debug) System.out.println(Double.toString(thetaL));
    */
    // Stundenwinkel tau der Sonne
    double tau_arc=k*(thetaL-rektazension_deg);

    OrtsBreite_arc=OrtsBreite_deg*k;
    
    double azimuth_arc_nenner = ((Math.cos(tau_arc)*Math.sin(OrtsBreite_arc))-((Math.tan(deklination_arc)*Math.cos(OrtsBreite_arc))));
    azimuth_arc= Math.sin(tau_arc)/(azimuth_arc_nenner);
    azimuth_arc=Math.atan(azimuth_arc);
    azimuth_deg=azimuth_arc*180/Math.PI;
    if (debug) System.out.print ("AZ ");
    if (debug) System.out.println((azimuth_arc*180.0/Math.PI));
    
    double myAz = (azimuth_arc*180.0/Math.PI);
    // http://de.wikipedia.org/wiki/Sonnenstand
    // Hinweis: Falls der Nenner im Argument des Arcustangens einen Wert kleiner Null hat, sind 180° zum Ergebnis zu addieren, um den Winkel in den richtigen Quadranten zu bringen.
    if (azimuth_arc_nenner<0) myAz = myAz+180;
    // Das berechnete Azimut wird von Süden aus gezählt. Soll es von Norden aus gezählt werden, sind 180° zum Ergebnis zu addieren.
    myAz += 180;
    
    while (myAz < 0) myAz += 360;
    while (myAz > 360) myAz -= 360;
    
    if (debug) System.out.println("corrected to "+myAz);

    elevation_arc= Math.cos(deklination_arc) * Math.cos(tau_arc) * Math.cos(OrtsBreite_arc) + Math.sin(deklination_arc) * Math.sin(OrtsBreite_arc);
    elevation_arc=Math.asin( elevation_arc);
    elevation_deg=elevation_arc*180.0/Math.PI;
    if (debug) System.out.print ("EL ");
    if (debug) System.out.print(elevation_arc*180.0/Math.PI);
    
    azimuth = myAz;
    elevation = elevation_deg;
  }
  public synchronized double getAzimuth() {
    return azimuth;
  }
  public synchronized double getElevation() {
    return elevation;
  }
  private double universalTime (int hh, int mm, int ss) {
    double dd;
    dd= hh/1.0;
    dd=dd + mm/60.0;
    dd=dd+ ss/3600.0;
    if (debug) System.out.println("Universal Time");
    if (debug) System.out.println(dd);
    return (dd);
  }
  private double julianDay (int da, int mo, int ye, double UT) {
    double dd;
    if (mo<=2) {
      mo=mo+12; 
      ye=ye-1;
    }
    dd=(int)(365.25*ye);
    dd=dd+(int)(30.6001*(mo+1));
    dd=dd- 15 + 1720996.5 + da + UT/24.0;

    T2000 = (dd - 2451545.0)/36525.0;
    return (dd);
  }
}