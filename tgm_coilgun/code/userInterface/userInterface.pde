/*
userInterface.pde


author: valentin veluppilai
project: tgm_coilgun
version: 0.1
date: 22.12.17

simple ui for the coilgun. only works when an appropriate device is connected

transmission of data in function controlEvent()
order: coil 1 (bottom), coil 2 (middle), coil 3 (top)
*/

import controlP5.*;
import processing.serial.*;


ControlP5 controlP5;
//Serial.list() can be replaced with path to serial device when used on linux
Serial serial = new Serial(this, Serial.list()[1], 9600);
PImage logo;


int tmpint;
int counter = 2;      //used to calculate the average score
int time1 = 0;        //⬎
int time2 = 0;        // coil times
int time3 = 0;        //⬏

float dist = 0.03;    //distance between two light sensors
float hs = 14.896;    //high score
float as = 12.947;    //average score
float us = 13.768;    //user score
float score;          //seems redundant, go check

byte[] tmp = new byte[4];     //temporary storage of serial transmission
byte[] time1b = new byte[4];  //⬎
byte[] time2b = new byte[4];  //stores scores in bytes, needed for transmission
byte[] time3b = new byte[4];  //⬏

String tmpstring;   //used in the processing of the serial transmission

void setup() {
        controlP5 = new ControlP5(this);
        PFont pfont = createFont("Arial",20,true);
        ControlFont cf1 = new ControlFont(pfont, int(height*0.0555556));
        logo = loadImage("tgmlogo.png");

        controlP5.addSlider(" Coil 3")  //top coil
        .setRange(1,100)
        .setValue(1)
        .setPosition( int(width*0.078125), int(height*0.0740741))
        .setSize( int(width*0.3125),int(height*0.0648148))
        .setFont(cf1);

        controlP5.addSlider(" Coil 2")  //middle coil
        .setRange(1,100)
        .setValue(1)
        .setPosition( int(width*0.078125), int(height*0.1666667))
        .setSize( int(width*0.3125), int(height*0.0648148))
        .setFont(cf1);

        controlP5.addSlider(" Coil 1") //bottom coil
        .setRange(1,100)
        .setValue(1)
        .setPosition( int(width*0.078125), int(height*0.2592593))
        .setSize( int(width*0.3125), int(height*0.0648148))
        .setFont(cf1);

        controlP5.addButton("Engage")
        .setPosition( int(width*.15625), int(height*0.3703704))
        .setSize( int(width*0.15625), int(height*0.1296296))
        .setFont(cf1);

        smooth();string
        fullScreen();

}

void draw() {

  background(0);
  fill(255);

  if(serial.available() > 0) {
    tmp = serial.readBytes();
    //redo this
    tmpstring = new String(tmp);    //convert transmission to srting
    tmpint = Integer.parseInt(trim(tmpstring)); // ---"--- to int
    //sometime
    us = dist/(float(tmpint)/1000000);   //convert measured time to speed
    if(score > hs)
        hs = us;
    counter = counter + 1;
    as = ( (as * (counter -1) + us) / counter);
  }

  textAlign(LEFT);
  textFont(createFont("Arial", int(height*0.0185185),true));
  text("HIGHSCORE", int(width*0.5989583), int(width * 0.0416667));
  text("AVG. SCORE", int(width*0.5989583), int(width * 0.1145833));
  text("YOUR SCORE", int(width*0.5989583), int(width * 0.1875));

  textFont(createFont("Arial", int(height*0.1111111),true));
  text(nf(hs, 0, 2) + " m/s", int(width*0.5989583), int(width * 0.09375));
  text(nf(as, 0, 2) + " m/s", int(width*0.5989583), int(width * 0.1666667));
  text(nf(us, 0, 2) + " m/s", int(width*0.5989583), int(width * 0.2395833));

  imageMode(CENTER);
  image(logo, width/2, 3*height/4, logo.width*2, logo.height*2);

}

//cp5 function, is called everytime the user interacts with an cp5 objects
void controlEvent(ControlEvent theEvent) {
  if(theEvent.isController()) {
    if(theEvent.getController().getName()==" Coil 1") {
      time1 = int(1000 * controlP5.getController(" Coil 1").getValue());
      time1b = adjustByteArray(intToByte(time1));
    }

    if(theEvent.getController().getName()==" Coil 2") {
      time2 = int(1000 * controlP5.getController(" Coil 2").getValue());
      time2b = adjustByteArray(intToByte(time2));
    }

    if(theEvent.getController().getName()==" Coil 3") {
      time3 = int(1000 * controlP5.getController(" Coil 3").getValue());
      time3b = adjustByteArray(intToByte(time3));
    }

    if(theEvent.getController().getName()=="Engage") {
      serial.write(time1b);
      serial.write(time2b);
      serial.write(time3b);
    }
  }
}

public static byte[] intToByte(int value) {  //converts an int to byte[4]
  byte[] byteArray = new byte[4];
  int shift = 0;
  for (int i = 0; i < byteArray.length; i++) {
    shift = i * 8; // go through each bit (0,8,16,24)
    byteArray[i] = (byte) (value >>> shift);
  }
  return byteArray;
}

public byte reverseByte(byte x) {   //reverses a byte
  int intSize = 8;
  byte y=0;
  for(int position=intSize-1; position>=0; position--){
    y+=((x&1)<<position);
    x >>= 1;
  }
  return y;
}

public byte[] adjustByteArray(byte[] x) { //reverses every byte in a byte[]
  for(int i = 0; i < x.length; i++) {
    x[i] = reverseByte(x[i]);
  }
  return x;
}
