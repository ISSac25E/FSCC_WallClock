void setup() {
  surface.setVisible(false);
  //byte[] nums = {-2,58,34,4};
  //saveBytes("num_cache.dat", nums);
  
  byte[] newnums = loadBytes("num_cache.dat");
  println(newnums);
  
}
