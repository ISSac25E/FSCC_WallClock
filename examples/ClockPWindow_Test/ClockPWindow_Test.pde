import java.util.Calendar;

ClockWindow newClock;

void setup() {
  surface.setVisible(false);
  noLoop();
  newClock = new ClockWindow(2);
  newClock.clockFont_date = createFont("digital-7.ttf", 80);
  newClock.clockFont_ampm = createFont("digital-7.ttf", 200);
  newClock.clockFont_time = createFont("digital-7.ttf", 500);

  newClock.setVisible(true);
}

void SwitchWindow() {
  newClock.exit();
  //newClock = new ClockWindow(1);
  //newClock.clockFont_date = createFont("digital-7.ttf", 80);
  //newClock.clockFont_ampm = createFont("digital-7.ttf", 200);
  //newClock.clockFont_time = createFont("digital-7.ttf", 500);
  
ErrorScreenWindow exitScreen = new ErrorScreenWindow("NULL FONT", "null_font:4456");
  //newClock.setVisible(true);
}

class ClockWindow extends PApplet {

  private int _screenNum;
  private boolean _vis = false;

  // public fonts. these need to be set before running clock
  PFont clockFont_date;
  PFont clockFont_ampm;
  PFont clockFont_time;

  //vars to keep track of date and time:
  private int _monthInt;
  private int _dayInt;
  private int _yearInt;

  private int _hourInt;
  private int _minuteInt;
  private int _secondInt;

  int timeOffset_X = 0;
  int timeOffset_Y = 0;

  int dateOffset_X = 0;
  int dateOffset_Y = 0;

  int ampmOffset_X = 0;
  int ampmOffset_Y = 0;

  // final absolutes(only for development):
  private final int _absPositionOffset_X = 0;
  private final int _absPositionOffset_Y = -11;

  ClockWindow(int screenNum) {
    super();
    _screenNum = screenNum;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    fullScreen(_screenNum);
  }

  void setup() {
    surface.setVisible(false);
    surface.setAlwaysOnTop(true);
    noCursor();
  }

  void draw() {
    if (_vis)
    {
      //reset background:
      background(0);

      _updateCalendarValues();
      _drawDateTime();
    }
  }

  void setVisible(boolean vis) {
    _vis = vis;
    if (_vis)
      redraw();
    surface.setVisible(_vis);
  }

  boolean visible() {
    return _vis;
  }

  void exit() {
    _vis = false;
    surface.setVisible(false);
  }

  private void _updateCalendarValues() {
    _monthInt = month();
    _dayInt = day();
    _yearInt = year();
    _hourInt = hour();
    _minuteInt = minute();
    _secondInt = second();
  }


  private void _drawDateTime() {
    String yearStr = str(_yearInt);
    String dayStr = str(_dayInt);

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

    switch(_monthInt) {
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
    };

    String dateFullStr = dayOfTheWeek + ", " + monthStr + " " + dayStr + ", " + yearStr;

    /*---------------------------------------------------------- */

    String AM_PM = "";
    if (_hourInt >= 12) {
      AM_PM = "PM";
      if (_hourInt != 12)
        _hourInt -= 12;
    } else {
      AM_PM = "AM";
      if (_hourInt == 0)
        _hourInt = 12;
    }

    String hourStr = str(_hourInt);
    String minuteStr = str(_minuteInt);

    String timeFullStr = hourStr + ":" + minuteStr;

    textFont(clockFont_date);
    float dateFullStrWidth = textWidth(dateFullStr);
    float dateFullStrAscent = textAscent() * 0.4;
    float dateFullStrDescent = -textDescent() * 2.02;


    textFont(clockFont_ampm);
    float AM_PM_width = textWidth(AM_PM);
    float AM_PM_Ascent = textAscent() * 0.4;
    float AM_PM_Descent = -textDescent() * 2.02;
    float AM_PM_Height = AM_PM_Ascent + AM_PM_Descent;


    textFont(clockFont_time);
    float timeFullStrWidth = textWidth(timeFullStr);
    float timeFullStrAscent = textAscent() * 0.4;
    float timeFullStrDescent = -textDescent() * 2.02;
    float timeFullStrHeight = timeFullStrAscent + timeFullStrDescent;

    stroke(255);
    //line(0, height / 2, width, height / 2);
    //line(0,(height / 2) - timeFullStrAscent, width,(height / 2) - timeFullStrAscent);
    //line(0,(height / 2) + timeFullStrDescent, width,(height / 2) + timeFullStrDescent);



    textFont(clockFont_date);
    textAlign(CENTER, CENTER);
    text(dateFullStr, (width / 2) + _absPositionOffset_X, (height / 2) + timeFullStrDescent + dateFullStrDescent + 33 + _absPositionOffset_Y);

    textFont(clockFont_ampm);
    textAlign(CENTER, CENTER);
    text(AM_PM, (width / 2) + (timeFullStrWidth / 2) + (AM_PM_width / 2) + 10 + _absPositionOffset_X, (height / 2) + timeFullStrDescent - (AM_PM_Descent) + _absPositionOffset_Y);

    textFont(clockFont_time);
    textAlign(CENTER, CENTER);
    text(timeFullStr, (width / 2) + _absPositionOffset_X, (height / 2) + _absPositionOffset_Y);
  }

  void keyPressed() {
    if (key == ESC) {
      key = 0;  // Empêche d'utiliser la touche ESC
    }
  }

  void mousePressed() {
    SwitchWindow();
  }
}


class ErrorScreenWindow extends PApplet {

  String _errorMessage = null;
  String _errorCode = null;

  ErrorScreenWindow() {
    super();
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  ErrorScreenWindow(String errorMessage) {
    super();
    _errorMessage = errorMessage;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  ErrorScreenWindow(String errorMessage, String errorCode) {
    super();
    _errorMessage = errorMessage;
    _errorCode = errorCode;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    size(500, 300);
  }

  void setup() {
    if (_errorCode != null)
      surface.setTitle(_errorCode);
    else
      surface.setTitle("ERROR");

    if (_errorMessage != null)
    {
      background(0, 0, 0);
      textFont(createFont("Arial", 60));
      textAlign(CENTER, CENTER);
      fill(255, 0, 0);

      text("ERROR", width / 2, 100);
      textFont(createFont("Arial", 30));
      textAlign(CENTER, CENTER);
      fill(255, 255, 255);
      text(_errorMessage, width / 2, (height / 2) + (height / 8));
    } else {
      background(0, 0, 0);
      textFont(createFont("Arial", 60));
      textAlign(CENTER, CENTER);
      fill(255, 0, 0);

      text("ERROR", width / 2, 100);
      textFont(createFont("Arial", 33));
      textAlign(CENTER, CENTER);
      fill(255, 255, 255);
      text("UNKNOWN", width / 2, (height / 2) + (height / 4));
    }
    surface.setAlwaysOnTop(true);
    noLoop();
  }

  void mousePressed() {
    exit();
  }
}
