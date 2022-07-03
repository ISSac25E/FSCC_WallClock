int newWidth = 100;
int newHeight = 100;
int newScreen = 3;

PWindow win;

void setup() {
  surface.setVisible(false);
  //size(320, 240);
  win = new PWindow(320, 240);
  noLoop();
}

void draw() {
  background(255, 0, 0);
  fill(255);
  rect(10, 10, frameCount, 10);
}

void runNewWin() {
  //if(newWidth == 100)
  //newWidth = 200;
  //else 
  //newWidth = 100;
  //if(newHeight == 100)
  //newHeight = 400;
  //else 
  //newHeight = 100;
  if(newScreen == 3)
  newScreen = 2;
  else 
  newScreen = 3;
  win.exitWin();
  win = new PWindow(200, 500);
}

void mousePressed() {
  println("mousePressed in primary window");
  win.exitWin();
  //win = new PWindow();
}

class PWindow extends PApplet {

  IniParse iniConfig;
  int _width;
  int _height;

  PWindow(int newWidth, int newHeight) {
    super();
    _width = newWidth;
    _height = newHeight;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  }

  void settings() {
    iniConfig = new IniParse("config.ini");

    size(_width, _height);
  }

  void setup() {
    background(150);
  }

  void draw() {
    ellipse(random(width), random(height), random(50), random(50));
  }

  void mousePressed() {
    println("mousePressed in secondary window");
    runNewWin();
  }


  void exitWin() {
    surface.setVisible(false);
  }
}
