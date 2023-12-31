import processing.javafx.*;
import processing.video.*;
Movie myMovie;

void setup() {
  fullScreen(FX2D);
  myMovie = new Movie(this, "1502072864.mp4");
  myMovie.play();
  myMovie.loop();
  imageMode(CENTER);
}

void draw() {
  println(frameRate);
  //myMovie.resize(width, height);
  //background(myMovie);
  if(myMovie.available()){
      myMovie.read();
      image(myMovie, width / 2, height / 2, width, height);
  }
}

//void movieEvent(Movie m) {
//  m.read();
//}
