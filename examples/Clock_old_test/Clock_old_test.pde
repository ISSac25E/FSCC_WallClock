

import hypermedia.net.*;
int PORT_RX=5005;
String HOST_IP = "192.168.86.138";//IP Address of the PC in which this App is running
UDP udp;//Create UDP object for recieving

import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.util.Calendar;

GraphicsEnvironment GraphicsDevices = GraphicsEnvironment.getLocalGraphicsEnvironment();

int M;      //month
int D;        //day
int Y;       //year
int Hr;      //hour          
int Min;   //minute
int Sec;   //second 
PFont Large;
PFont Medium;
PFont Small;

boolean WindowToggle = false;

Calendar cal = Calendar.getInstance();

void setup() {
  surface.setVisible(true);
  udp = new UDP(this, PORT_RX);
  udp.log(false);
  udp.listen(true);
  if (udp.port() == -1) {
    exit();
  }

  printArray(GraphicsDevices.getScreenDevices().length);
  fullScreen();
  surface.setAlwaysOnTop(true);
  noCursor();
  //size(1920, 1080);
  background(0);
  Large = createFont("digital-7.ttf", 300);
  Medium = createFont("digital-7.ttf", 100);
  Small = createFont("digital-7.ttf", 55);
}

void draw() {
  if (udp.port() == -1) {
    udp.close();
    udp = new UDP(this, PORT_RX);
    print("Error");
  }
  background(0);
  updateValues();
  displayDate();
  displayTime();
  textAlign(CENTER);
}

void updateValues() {
  M = month();      //month
  D = day();        //day
  Y = year();       //year
  Hr = hour();      //hour          
  Min = minute();   //minute
  Sec = second();   //second
  Min += 6;
}
//-----------------------------------------------------------
void displayDate() {
  String Ms = str(M);
  String Ds = str(D);
  String Ys = str(Y);
  String DayOfWeek = "";
  String Month = "";
  switch(cal.get(Calendar.DAY_OF_WEEK)) {
  case 1:
    DayOfWeek = "SUNDAY";
    break;
  case 2:
    DayOfWeek = "MONDAY";
    break;
  case 3:
    DayOfWeek = "TUESDAY";
    break;
  case 4:
    DayOfWeek = "WEDNESDAY";
    break;
  case 5:
    DayOfWeek = "THURDAY";
    break;
  case 6:
    DayOfWeek = "FRIDAY";
    break;
  case 7:
    DayOfWeek = "SATURDAY";
    break;
  };

  switch (M) {
  case 1:
    Month = "JANUARY";
    break;
  case 2:
    Month = "FEBUARY";
    break;
  case 3:
    Month = "MARCH";
    break;
  case 4:
    Month = "APRIL";
    break;
  case 5:
    Month = "MAY";
    break;
  case 6:
    Month = "JUNE";
    break;
  case 7:
    Month = "JULY";
    break;
  case 8:
    Month = "AUGUST";
    break;
  case 9:
    Month = "SEPTEMBER";
    break;
  case 10:
    Month = "OCTOBER";
    break;
  case 11:
    Month = "NOVEMBER";
    break;
  case 12:
    Month = "DECEMBER";
    break;
  }

  String MDY = DayOfWeek + ", " + Month + " " + Ds + ", " + Ys;

  textFont(Small);
  text(MDY, (width/2) + 0, (height/2) + 145);
}

//------------------------------------------------------------
void displayTime() {
  String AM_PM = "";
  if (Hr >= 12) {
    AM_PM = "PM";
    if (Hr != 12) 
      Hr -= 12;
  } else {
    AM_PM = "AM";
    if (Hr == 0) 
      Hr = 12;
  }
  String Hrs = str(Hr);
  String Mins = str(minute());
  //if (Mins.length() < 2) {
  //  Mins = "0" + Mins;
  //}
  //String Secs = str(Sec);
  //if (Secs.length() < 2) {
  //  Secs = "0" + Secs;
  //}
  //String HMS = Hrs + ":" + Mins + ":" + Secs;
  String HMS = Hrs + ":" + Mins;
  //stroke(255);
  //int LineH = 150;
  //int LineW = 0;
  //line((width/2) - (textWidth(HMS) * 3)/2, (height/2) - LineH, (width/2) + (textWidth(HMS) * 3)/2, (height/2) - LineH);
  textFont(Large);
  float HMS_Width = textWidth(HMS);
  text(HMS, (width/2) + 0, (height/2) + 0);
  textFont(Medium);
  float AM_PM_Width = textWidth(AM_PM);
  text(AM_PM, (width/2) + ((HMS_Width)/2) +((AM_PM_Width/2)) + 40, (height/2) + 0);
}




void receive(byte[] data, String HOST_IP, int PORT_RX) {
  char[] Exit = {'E', 'X', 'I', 'T'};
  char[] Open = {'O', 'P', 'E', 'N'};
  char[] Toggle = {'T', 'O', 'G', 'G', 'L', 'E'};
  char[] value = new char [data.length];
  for (int X = 0; X < data.length; X++) value[X] = char(data[X]);
  boolean ExitWindow = true;
  boolean OpenWindow = true;
  boolean ToggleWindow = true;
  if (value.length == Exit.length) {
    for (int X = 0; X < Exit.length; X++) if (value[X] != Exit[X]) ExitWindow = false;
  } else ExitWindow = false;
  if (ExitWindow == true) {
    surface.setVisible(false);
    WindowToggle = false;
  }

  if (value.length == Open.length) {
    for (int X = 0; X < Open.length; X++) if (value[X] != Open[X]) OpenWindow = false;
  } else OpenWindow = false;
  if (OpenWindow == true) {
    surface.setVisible(true);
    WindowToggle = true;
  }

  if (value.length == Toggle.length) {
    for (int X = 0; X < Toggle.length; X++) if (value[X] != Toggle[X]) ToggleWindow = false;
  } else ToggleWindow = false;
  if (ToggleWindow == true) {
    if (WindowToggle == true) {
      surface.setVisible(false);
      WindowToggle = false;
    } else {
      surface.setVisible(true);
      WindowToggle = true;
    }
  }
  //printArray(value);
}

void mouseClicked() {
 surface.setVisible(false);
 delay(1000);
 surface.setVisible(true);
}


//void keyPressed() {
//  if (key == ESC) {
//    key = 0; 
//  }
//}
