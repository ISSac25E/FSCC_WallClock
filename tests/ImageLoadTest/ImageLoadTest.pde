PImage img;

void setup() {
  fullScreen();
  //size(400, 400);
  img = loadImage("Black-metal-hexagon-hd-wallpaper-53627_edit1.png");
  
  float rw = float(img.width) / float(width);
  float rh = float(img.height) / float(height);
  imageMode(CENTER);

  if (rw < rh)
    img.resize(int(img.width / rw), int(img.height / rw));
  else
    img.resize(int(img.width / rh), int(img.height / rh));
}

void draw() {
  background(0);
  image(img, width / 2, height / 2);
}
