package swp;

import swp.LongLat;

/** 
Maidenhead Locator
http://de.wikipedia.org/wiki/QTH-Locator
ported from: http://klaus-diemer.info/themen/locatorberechnung/index.html
*/
public class QTHTools {
  private static boolean check(char BS, char last) {
    if ((BS > last) || (BS < 'A')) {
      //println ("Im Locator ist ein ungültiger Buchstabe vorhanden!");
      return true;
    }
    return false;
  }
  public static LongLat loc2geo(String locator) {
    String abc = "ABCDEFGHIJKLMNOPQRSTUVWX";
    //p = new Array()
    int[] p = new int[6];
    locator = locator.toUpperCase();
    if (locator.length() != 6) {
      //println("Die Länge des eingegebenen Locators ("+locator+") muss 6 sein!");
      return null;
    }

    char l = locator.charAt(0);
    if (check(l, 'R')) return null;
    p[0] = abc.indexOf(l);

    l = locator.charAt(1);
    if (check(l, 'R')) return null;
    p[1] = abc.indexOf(l);

    p[2] = Integer.parseInt(locator.substring(2, 3));

    p[3] = Integer.parseInt(locator.substring(3, 4));

    l = locator.charAt(4);
    if (check(l, 'X')) return null;
    p[4] = abc.indexOf(l);

    l = locator.charAt(5);
    if (check(l, 'X')) return null;
    p[5] = abc.indexOf(l);

    double laenge1 = (p[0] * 20.0 + p[2] * 2.0 + p[4] / 12.0 - 180.0);
    double laenge2 = (laenge1 + (1.0 / 12.0));
    double breite1 = (p[1] * 10.0 + p[3] + p[5] / 24.0 - 90.0);
    double breite2 = (breite1 + (1.0 / 24.0));

    //Laengengrad-Berechnung: Winkelsekunden sind immer Null

    double grad1 = (p[0]*20.0 + p[2]*2.0 + Math.floor(p[4]/12.0) - 180.0);
    double min1 = ((p[4]*5)%60);
    if (grad1 < 0) {
      if (min1!=0) {
        min1 = 60-min1;
        grad1 = -grad1-1;
      }
      else grad1 = -grad1;
    }
    double grad2 = (p[0]*20.0 + p[2]*2.0 + Math.floor((p[4]+1)/12) - 180.0);
    double min2 = (((p[4]+1)*5)%60);
    if (grad2 < 0) {
      if (min2!=0) {
        min2 = 60-min2;
        grad2 = -grad2-1;
      }
      else grad2 = -grad2;
    }
    double laenge_grad = grad1;
    double laenge_grad1 = grad2;
    double laenge_min = min1;
    double laenge_min1 = min2;
    double laenge_sec = 0;
    double laenge_sec1 = 0;
    // println(laenge_grad+", "+laenge_grad1+", "+laenge_min+", "+laenge_min1+", "+laenge_sec+", "+laenge_sec1);

    //Breitengrad-Berechnung: Winkelsekunden können 0 und 30" annehmen
    grad1 = (p[1]*10.0 + p[3] - 90.0);
    min1 = Math.floor(p[5]*2.5);
    double sec1 = ((p[5]%2)*30);
    if (grad1<0) {
      if (sec1!=0) {
        sec1 = 60-sec1;
        min1++;
      }
      if (min1!=0) {
        min1 = 60-min1;
        grad1++;
      }
      grad1 = -grad1;
    }
    double breite_grad = grad1;
    double breite_min = min1;
    double breite_sec = sec1;
    // println(breite_grad+", "+breite_min+", "+breite_sec+", ");

    grad2 = (p[1]*10.0 + p[3] - 90.0);
    min2 = Math.floor((p[5]+1)*2.5);
    double sec2 = (((p[5]+1)%2)*30);
    // kommentar übernommen...
    //if (sec2 >= 60)
    //{
    //    min2++
    //    sec2 = sec2 - 60
    //    }
    if (min2 >= 60) {
      grad2++;
      min2 = min2 - 60;
    }
    if (grad2<0) {
      if (sec2!=0) {
        sec2 = 60-sec2;
        min2++;
      }
      if (min2!=0) {
        min2 = 60-min2;
        grad2++;
      }
      grad2 = -grad2;
    }
    double breite_grad1 = grad2;
    double breite_min1 = min2;
    double breite_sec1 = sec2;
    // println(breite_grad1+", "+breite_min1+", "+breite_sec1+", ");

    String pp = "";
    if (laenge1 < 0) pp = " West";
    else pp = " Ost";
    String WO1 = pp;
    //double laenge = Math.abs(laenge1);
    double laenge = laenge1;
    if (breite1 < 0) pp = " Süd";
    else pp = " Nord";
    String NS1  = pp;
    //double breite = Math.abs(breite1);
    double breite =breite1;
    if (laenge2 < 0) pp = " West";
    else pp = " Ost";
    String WO2 = pp;
    double laenge_2 = Math.abs(laenge2);
    if (breite2 < 0) pp = " Süd";
    else pp = " Nord";
    String NS2 = pp;
    double breite_2 = Math.abs(breite2);
    // println(locator+": "+laenge+", "+breite+", "+laenge_2+", "+breite_2);
    // println(WO1+", "+NS1+", "+WO2+", "+NS2);

    LongLat ll = new LongLat();
    ll.lng = laenge;
    ll.lat = breite;
    return ll;
  }
}