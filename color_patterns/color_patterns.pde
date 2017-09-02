// screen dimensions
float s_x = 750; // width
float s_y = 500; // height

float t = 0; // t = time position on screen, so it resets when the graph resets
float time = 0; // time = time, as in real time
float cycles = 0; // cycles = the number of times the graph has been displayed
float speed = 2; // the speed at  which time is incremented

// Figure 1:
// overall color that fluxuates with time, dimensions and location
float f1x = 0.05*s_x;
float f1y = 0.05*s_y;
float f1w = 0.425*s_x;
float f1h = 0.50*s_y;

// Figure 2:
// r,g,b bar chart that fluxuates with time, dimensions and location
float f2x = 0.525*s_x;
float f2y = 0.05*s_y;
float f2w = 0.425*s_x;
float f2h = 0.50*s_y;

// Figure 3:
// sum color vs t graph, dimensions and location
float f3x = 0.05*s_x;
float f3y = 0.60*s_y;
float f3w = 0.90*s_x;
float f3h = 0.15*s_y;

// Figure 4:
// r,g,b vs t graph, dimensions and location
float f4x = 0.05*s_x;
float f4y = 0.80*s_y;
float f4w = 0.90*s_x;
float f4h = 0.15*s_y;

// actual wavelengths: scale of 400 nm - 750 nm
int red_wavelength = 400+2*(750-400)/3; //620;
int green_wavelength = 400+(750-400)/3; //495;
int blue_wavelength = 400; //450;
int r = int(map(red_wavelength,400,750,0,255));
int g = int(map(green_wavelength,400,750,0,255));
int b = int(map(blue_wavelength,400,750,0,255));
int rgb [] = {r,g,b};
int phase [] = {r,g,b};
int index [] = {0,1,2};

float T1 = f4w/2;
float T2 = T1/12;
int a = 0;

void setup() { // this method sets up the Processing GUI and is always the first method run by the program
  size (750, 500); // windown size (width,height)
  background(0); // initial black background
  windows(); // set up the windows to display the figures in
}

void windows(){ // this method sets up each window
  window(f1x, f1y, f1w, f1h); // window 1
  window(f2x, f2y, f2w, f2h); // window 2
  window(f3x, f3y, f3w, f3h); // window 3
  window(f4x, f4y, f4w, f4h); // window 4
}

void window(float x, float y, float w, float h) { // this method creates a window (which displays a figure)
  strokeWeight(1); // border with thickness of 1
  stroke(255); // border with color of white
  fill(255); // initially set window to be white
  rect(x, y, w, h); // create window
}

void draw () { // this method is run over and over again after the setup method
 for (int i = 0; i < rgb.length; i++) { // for each color: red, green, and blue
   rgb[i] = sine(rgb[i],phase[i],time); // fluctuate it over time according to the sine equation
   //rgb[i] = invert(rgb[i],time); // 
   f2(rgb[i],index[i]); // display the 
   f4(rgb[i],index[i],t);
 }
 f1(rgb[0],rgb[1],rgb[2]);
 f3(rgb[0],rgb[1],rgb[2],t);

 time = time + speed;
 t = t + speed;
 if (floor(time/f4w) > cycles) {
   cycles++;
   t = 0;
   background(0,0,0);
   windows();
 }
}



int linear(int x, int i, float time) { 
 int slope = 3;
   x = x + slope; 
   if (x >= 255) {
      x = 0;
      if (i == 0) { fill(255,0,0); }
      else if (i == 1) { fill(0,255,0); }
      else { fill(0,0,255); }
      rect( f4x+t-2, f4y, 3, f4h );
   }
 return x;
}

int sine(int x, int p, float t) { // 
  float p_rad = map(p,0,255,0,TWO_PI);
  float t_rad = map(t,0,f4w,0,TWO_PI);
  int b = int(255/2*0.5*(1+sin((map(t%T1,0,T1,0,TWO_PI)))));
  int max = 255/2 + b;
  int min = 255/2 - b;
  int A = (max-min)/2; // Amplitude
  float N = 10; //int(5*0.5*(1+sin((map(t%T1,0,T1,0,TWO_PI))))); // + 3*sin(t_rad); // N = number of cycles per screen
  int axis = int(min + A); 
  x = axis + int(A*sin(N*t_rad+p_rad));
  return x;
}  

int bellcurve(int x, int i, float t) {
 float mu;
 float sig = 2000;
 if(i == 0) { mu = 580; }
 else if (i == 1) { mu = 540; }
 else { mu = 440; }
 x = int(639*exp(-sq(t-mu)/(2*sig))/sqrt(TWO_PI));
 return x;
}

float off = 0.5*T2*(1+sin((map(t%T1,0,T1,0,TWO_PI))));
int invert(int x, float t) { // its alliasing! float off should only change w/ T not w/ t
  //float on = 0.50*T1;
  if (t/T2 > a) {
    a++;
    off = T2*0.5*(1+sin((map(t%T1,0,T1,0,TWO_PI))));
    //println(off, "      ", T2);
  }
  if (t%T2 > off) { x = 255 - x; } // invert 
  return x;
}

void f1(int r, int g, int b) {
 strokeWeight(1);
 stroke(r,g,b);
 fill(r,g,b);
 rect(f1x, f1y, f1w, f1h);
}

void f2(int x, int i) {
 float bar_x;
 float bar_y = f2y+f2h-(float(x)/255)*f2h;
 float bar_w = 0.20*f2w;
 float bar_h = f2h*(float(x)/255);
 float inv_bar_x;
 float inv_bar_y = f2y;
 float inv_bar_w = bar_w;
 float inv_bar_h = f2h*(1-float(x)/255);
 strokeWeight(1);
 if (i == 0) {
   stroke(255,0,0);
   fill(255,0,0);
   bar_x = f2x+0.18*f2w;
   inv_bar_x = f2x+0.18*f2w;
 } else if (i == 1) {
   stroke(0,255,0);
   fill(0,255,0);
   bar_x = f2x+0.40*f2w;
   inv_bar_x = f2x+0.40*f2w;
 } else {
   stroke(0,0,255);
   fill(0,0,255);
   bar_x = f2x+0.62*f2w;
   inv_bar_x = f2x+0.62*f2w;
 }
 rect( bar_x, bar_y, bar_w, bar_h );
 stroke(255,255,255);
 fill(255,255,255);
 rect( inv_bar_x, inv_bar_y, inv_bar_w, inv_bar_h );
}

void f3(int r,int g,int b, float t) {
  stroke(r,g,b); 
  fill(r,g,b);
  rect(f3x+t, f3y+0.10*f3h, speed, 0.80*f3h );
}

void f4(int x, int i, float t) {
 strokeWeight(0);
 if (i == 0) { fill(255,0,0); }
 else if (i == 1) { fill(0,255,0); }
 else { fill(0,0,255); }
 ellipse(f4x+t, f4y+f4h-(float(x)/255)*f4h, speed,3); 
}

void keyPressed() {
  final int k = keyCode;
  if (k == ' ')
    if (looping)  noLoop();
    else          loop();
}
