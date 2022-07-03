import hypermedia.net.*;
import java.awt.GraphicsEnvironment;
import java.awt.GraphicsDevice;
import java.util.Calendar;

GraphicsEnvironment GraphicsDevices = GraphicsEnvironment.getLocalGraphicsEnvironment();

String CompanionIP;
String ClockIP;
int CompanionPage;
int CompanionButton;
int NetworkPort;
int Screen;

final int CompanionSendInterval_ms = 1000;

IniParse iniConfig;

UDP udp;//Create UDP object for recieving

PFont clockFont_small;
PFont clockFont_Medium;
PFont clockFont_large;

//vars to keep track of date and time:
int monthInt;
int dayInt;
int yearInt;

int hourInt;
int minuteInt;
int secondInt;

final int absPositionOffset_X = 0;
final int absPositionOffset_Y = -11;

boolean WindowToggle = true;

void setup() {
  surface.setVisible(false);

  {
    byte[] fileBytes = loadBytes("config.ini");
    //println(fileBytes);
    if (fileBytes != null)
    {
      println("file found");
      iniConfig = new IniParse("config.ini");

      CompanionIP = iniConfig.getVal("network", "companion_ip");
      NetworkPort = int(iniConfig.getVal("network", "clock_port"));
      CompanionPage = int(iniConfig.getVal("companion", "page"));
      CompanionButton = int(iniConfig.getVal("companion", "button"));
      Screen = int(iniConfig.getVal("graphics", "screen"));
    } else {
      println("file not found");
      exit();
    }
  }

  println("Companion IP: ", CompanionIP);
  println("Clock IP: ", ClockIP);
  println("NetworkPort: ", NetworkPort);
  println("CompanionPage: ", CompanionPage);
  println("CompanionButton: ", CompanionButton);
  println("screen: ", Screen);

  udp = new UDP(this, NetworkPort);
  udp.log(false);
  udp.listen(true);
  if (udp.port() == -1) {
    exit();
  }
  println(GraphicsDevices.getScreenDevices().length);

  fullScreen(Screen);
  surface.setAlwaysOnTop(true);
  noCursor();

  //create fonts:
  clockFont_small = createFont("digital-7.ttf", 80);
  clockFont_Medium = createFont("digital-7.ttf", 200);
  clockFont_large = createFont("digital-7.ttf", 500);
  surface.setVisible(true);
}

void draw() {
  if (udp.port() == -1) {
    udp.close();
    print("Udp Error");
    exit();
  }
  //reset background:
  background(0);

  updateCalendarValues();
  drawDateTime();
}

void updateCalendarValues() {
  monthInt = month();
  dayInt = day();
  yearInt = year();
  hourInt = hour();
  minuteInt = minute();
  secondInt = second();
}


void drawDateTime() {
  String yearStr = str(yearInt);
  String dayStr = str(dayInt);

  String dayOfTheWeek = "";
  String monthStr = "";

  switch(Calendar.getInstance().get(Calendar.DAY_OF_WEEK)) {
  case 1:
    dayOfTheWeek = "SUNDAY";
    break;
  case 2:
    dayOfTheWeek = "MONDAY";
    break;
  case 3:
    dayOfTheWeek = "TUESDAY";
    break;
  case 4:
    dayOfTheWeek = "WEDNESDAY";
    break;
  case 5:
    dayOfTheWeek = "THURSDAY";
    break;
  case 6:
    dayOfTheWeek = "FRIDAY";
    break;
  case 7:
    dayOfTheWeek = "SATURDAY";
    break;
  };

  switch(monthInt) {
  case 1:
    monthStr = "JANUARY";
    break;
  case 2:
    monthStr = "FEBUARY";
    break;
  case 3:
    monthStr = "MARCH";
    break;
  case 4:
    monthStr = "APRIL";
    break;
  case 5:
    monthStr = "MAY";
    break;
  case 6:
    monthStr = "JUNE";
    break;
  case 7:
    monthStr = "JULY";
    break;
  case 8:
    monthStr = "AUGUST";
    break;
  case 9:
    monthStr = "SEPTEMBER";
    break;
  case 10:
    monthStr = "OCTOBER";
    break;
  case 11:
    monthStr = "NOVEMBER";
    break;
  case 12:
    monthStr = "DECEMBER";
    break;
  }

  String dateFullStr = dayOfTheWeek + ", " + monthStr + " " + dayStr + ", " + yearStr;

  /*---------------------------------------------------------- */

  String AM_PM = "";
  if (hourInt >= 12) {
    AM_PM = "PM";
    if (hourInt != 12)
      hourInt -= 12;
  } else {
    AM_PM = "AM";
    if (hourInt == 0)
      hourInt = 12;
  }

  String hourStr = str(hourInt);
  String minuteStr = str(minuteInt);

  String timeFullStr = hourStr + ":" + minuteStr;

  textFont(clockFont_small);
  float dateFullStrWidth = textWidth(dateFullStr);
  float dateFullStrAscent = textAscent() * 0.4;
  float dateFullStrDescent = -textDescent() * 2.02;


  textFont(clockFont_Medium);
  float AM_PM_width = textWidth(AM_PM);
  float AM_PM_Ascent = textAscent() * 0.4;
  float AM_PM_Descent = -textDescent() * 2.02;
  float AM_PM_Height = AM_PM_Ascent + AM_PM_Descent;


  textFont(clockFont_large);
  float timeFullStrWidth = textWidth(timeFullStr);
  float timeFullStrAscent = textAscent() * 0.4;
  float timeFullStrDescent = -textDescent() * 2.02;
  float timeFullStrHeight = timeFullStrAscent + timeFullStrDescent;

  stroke(255);
  //line(0, height / 2, width, height / 2);
  //line(0, (height / 2) - timeFullStrAscent, width, (height / 2) - timeFullStrAscent);
  //line(0, (height / 2) + timeFullStrDescent, width, (height / 2) + timeFullStrDescent);



  textFont(clockFont_small);
  textAlign(CENTER, CENTER);
  text(dateFullStr, (width / 2) + absPositionOffset_X, (height / 2) + timeFullStrDescent + dateFullStrDescent + 33 + absPositionOffset_Y);

  textFont(clockFont_Medium);
  textAlign(CENTER, CENTER);
  text(AM_PM, (width / 2) + (timeFullStrWidth / 2) + (AM_PM_width / 2) + 10 + absPositionOffset_X, (height / 2) + timeFullStrDescent - (AM_PM_Descent) + absPositionOffset_Y);

  textFont(clockFont_large);
  textAlign(CENTER, CENTER);
  text(timeFullStr, (width / 2) + absPositionOffset_X, (height / 2) + absPositionOffset_Y);
}

int screen = 3;


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
