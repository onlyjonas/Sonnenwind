/* 
 * Segelwinde
 *
 * PLUS:
 *
 * MLX90316 Rotary Position Sensor
 * KHM 2010 /  Martin Nawrath
 * Kunsthochschule fuer Medien Koeln
 * Academy of Media Arts Cologne
 
 Calibration
 - end-to-end is ~202 to ~298
 - north = 298 - 30 = 268?
 */
// import sensor aktor library for pin mapping
#include <SensorAktor.h>
#include "Metro.h"     //Include Metro library
#include "MLX90316.h"  // Include MLX90316 library

// calibration
#include "WProgram.h"
void setup();
void loop();
void Servo360(int deg);
int north = 298;

// setup sensor
int pinSS = 5;
int pinSCK = 3;
int pinMOSI = 4;
int ii;
Metro mlxMetro = Metro(40);  // 25 Hz update freq, mirite?
MLX90316 mlx_1  = MLX90316();

// sensor values
int a1,v1,v1a;

void setup(){
  pinMode(12,OUTPUT);
  Serial.begin(9600);
  mlx_1.attach(pinSS,pinSCK, pinMOSI );
}

void loop(){
  if (mlxMetro.check() == 1) {
    int sens = mlx_1.readAngle();
    Serial.print(sens);
    Serial.println();
    if (sens>=0) ii = sens/10 - north;
    while (ii<0) ii+=360;
//    Serial.print(ii);
//    Serial.println("");
  }
  delay(3);
  a1 = ii;  // set servo angle from rot. sensor
  if (v1 < a1 ) v1++;
  if (v1 > a1 ) v1--;
  if ( v1-v1a == 0) {
    Servo360(v1);
  }
  v1a=v1;
}
//**************************************************+
void Servo360(int deg) {

  static int deg_alt;
  int diff;
  long pls;
  if (deg > 359) deg = 359;  // Winkelbegrenzung .. 359 Grad
  deg = 359-deg;
  
  pls = deg * 63; // Pulsbreite skalieren 0,63 us = 1 Grad
//  pls = deg * 85; // Pulsbreite skalieren 0,85 us = 1 Grad
  pls = pls / 100;
  pls = pls + 1500; // Servo Mittelstellung

//     Serial.println(pls);  
      digitalWrite(12,1);
      delayMicroseconds(pls);
      digitalWrite(12,0);      
      delay(10);
}
int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

