#include <Servo.h>
const int trig = 6;
const int echo = 7;
Servo motor;
bool radar= true;
long sure;
long uzaklik;
int aci;
bool ileri = true;


int uzaklik_olc() {
  digitalWrite(trig, LOW);
  delayMicroseconds(5);
  digitalWrite(trig, HIGH);
  delayMicroseconds(10);
  digitalWrite(trig, LOW);
  sure = pulseIn(echo, HIGH);
  uzaklik = sure/29.1/2;
  if (uzaklik > 500) {
    uzaklik =500;
  }
  return uzaklik;
}

void Serial_kontrol() {
  String veri;
  if (Serial.available()) {
    veri = Serial.readStringUntil('\n');
    aci = veri.toInt();
    if (aci > 180) {
      radar = true;
      aci=0;
    }
    else {
      radar = false;
    }
  }
}

void setup() {
  // put your setup code here, to run once:
  pinMode(trig, OUTPUT);
  pinMode(echo, INPUT);
  Serial.begin(9600);
  motor.attach(9);

}

void loop() {
  // put your main code here, to run repeatedly:
  int uzak;
  int i;
  Serial_kontrol();
  if (radar) {
  motor.write(aci);
  delay(250);
  uzak = uzaklik_olc();
  Serial.println(uzak);
  if (ileri) {
    aci = aci + 10;
    if (aci >180) {
      aci = 180;
      ileri = false;
    }
  }
  else {
    aci = aci - 10;
    if (aci < 0) {
      aci = 0;
      ileri = true;
    }
  }
  
  }
  else {
    motor.write(aci);
    delay(100);
    uzak = uzaklik_olc();
    Serial.println(uzak);
    Serial_kontrol();
  }
  
}
