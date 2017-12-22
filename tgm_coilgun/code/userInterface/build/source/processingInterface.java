import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class processingInterface extends PApplet {




ControlP5 controlP5;
Serial serial = new Serial(this, Serial.list()[0], 9600);
PImage logo;


int tmpint;
int counter = 2;      //used to calculate the average score
int time1 = 0;        //
int time2 = 0;        // coil times
int time3 = 0;        //

float dist = 0.03f;
float hs = 14.896f;    //high score
float as = 12.947f;    //average score
float ys = 13.768f;    //user score
float score;

byte[] tmp = new byte[4];

String tmpstring;

public void setup() {
        //print(PFont.list());    //used for testing
        //print(height + "\n");
        //print(width  + "\n");
        //print(Serial.list());

        controlP5 = new ControlP5(this);
        PFont pfont = createFont("Arial",20,true);
        ControlFont cf1 = new ControlFont(pfont, PApplet.parseInt(height*0.0555556f));
        logo = loadImage("tgmlogo.png");

        controlP5.addSlider(" Coil 3")
        .setRange(1,100)
        .setValue(1)
        .setPosition( PApplet.parseInt(width*0.078125f), PApplet.parseInt(height*0.0740741f))
        .setSize( PApplet.parseInt(width*0.3125f),PApplet.parseInt(height*0.0648148f))
        .setFont(cf1);

        controlP5.addSlider(" Coil 2")
        .setRange(1,100)
        .setValue(1)
        .setPosition( PApplet.parseInt(width*0.078125f), PApplet.parseInt(height*0.1666667f))
        .setSize( PApplet.parseInt(width*0.3125f), PApplet.parseInt(height*0.0648148f))
        .setFont(cf1);

        controlP5.addSlider(" Coil 1")
        .setRange(1,100)
        .setValue(1)
        .setPosition( PApplet.parseInt(width*0.078125f), PApplet.parseInt(height*0.2592593f))
        .setSize( PApplet.parseInt(width*0.3125f), PApplet.parseInt(height*0.0648148f))
        .setFont(cf1);

        controlP5.addButton("Engage")
        .setPosition( PApplet.parseInt(width*.15625f), PApplet.parseInt(height*0.3703704f))
        .setSize( PApplet.parseInt(width*0.15625f), PApplet.parseInt(height*0.1296296f))
        .setFont(cf1);

        
        

}

public void draw() {
        if(serial.available() > 0) {
                tmp = serial.readBytes();
                tmpstring = new String(tmp);
                tmpint = Integer.parseInt(trim(tmpstring));
                score = dist/(PApplet.parseFloat(tmpint)/1000000);
                if(score > hs)
                        hs = score;
                counter = counter + 1;
                as = ( (as * (counter -1) + score) / counter);
                ys = score;
        }

        background(0);
        fill(255);

        textAlign(LEFT);
        textFont(createFont("Arial", PApplet.parseInt(height*0.0185185f),true));
        text("HIGHSCORE", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.0416667f));
        text("AVG. SCORE", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.1145833f));
        text("YOUR SCORE", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.1875f));

        textFont(createFont("Arial", PApplet.parseInt(height*0.1111111f),true));
        text(nf(hs, 0, 2) + " m/s", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.09375f));
        text(nf(as, 0, 2) + " m/s", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.1666667f));
        text(nf(ys, 0, 2) + " m/s", PApplet.parseInt(width*0.5989583f), PApplet.parseInt(width * 0.2395833f));

        imageMode(CENTER);
        image(logo, width/2, 3*height/4, logo.width*2, logo.height*2);

}

public void controlEvent(ControlEvent theEvent) {
        if(theEvent.isController()) {

//print("control event from : "+theEvent.getController().getName());
//println(", value : "+theEvent.getController().getValue());

                if(theEvent.getController().getName()==" Coil 1") {
                        time1 = PApplet.parseInt(1000 * controlP5.getController(" Coil 1").getValue());
                }

                if(theEvent.getController().getName()==" Coil 2") {
                        time2 = PApplet.parseInt(1000 * controlP5.getController(" Coil 2").getValue());
                }

                if(theEvent.getController().getName()==" Coil 3") {
                        time3 = PApplet.parseInt(1000 * controlP5.getController(" Coil 3").getValue());
                }

                if(theEvent.getController().getName()=="Engage") {
                        serial.write(time1 + "\n" + time2 + "\n" + time3 + "\n");
                }

        }
}
  public void settings() {  fullScreen();  smooth(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "processingInterface" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
