import SimpleOpenNI.*;
import processing.serial.*;
import processing.net.*;
import java.awt.*;
SimpleOpenNI kinect;
KinectTracker kt;

int lowX;
int lowY;
boolean hit = false;
boolean hit2 = false;
int x2 = 50;
int y2 = 300;
int r_highX;
int r_highY;
int r_lowX;
int r_lowY;
boolean hitX = false;
boolean hitY = false;
int lowX2;
int lowY2;

int r_highX2;
int r_highY2;
int r_lowX2;
int r_lowY2;
int l_highx2;
int l_highy2;
int l_highx;
int l_highy;
int theta2 = 0;
int toggle = -1;
float dia;
float dia_theta;
int reflectX;
int reflectY;
PVector normal;
PVector v;
PVector reflect;
PVector reflect2;

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioInput  accessMic;
FFT         fft;
int sampleRate= 44100;//sapleRate of 44100
float [] max= new float [sampleRate/2];//array that contains the half of the sampleRate size, because FFT only reads the half of the sampleRate frequency. This array will be filled with amplitude values.
float maximum;//the maximum amplitude of the max array
float frequency;//the frequency in hertz

float[] angles = new float[9];
int skeletonid = 1;

float alpha = 0.5;
float l_yvel = 0;
float gravity = 10; //how fast the paddle falls
float exceed_gravity = 9.8; //volume must exceed this to fall
final float SCALER = -2000; //change how much an affect loudness has
boolean handTrackFlag = false;


int rightPadY=0;
int rightPadX=0;//changed in setup
int leftPadY=0;
int leftPadX=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
float ballXSpeed=5;
float ballYSpeed=5;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;

//networking
Server myServer;
Client myClient;
String input;
int[] otherCords={0,0,0,0,0,0,0}; 
int[] copy_cords={0,0,0,0,0,0,0};
int prevLeft = 0;
int prevMapX = 0;
float scaledX;
float scaledY;
int diffX = 0;




//
//PFont font;
PVector handVec = new PVector();
PVector mapHandVec = new PVector();
color handPointCol = color(255,0,0);

void setup() {
  size(1200, 650);
 kinect = new SimpleOpenNI(this);
 kt = new KinectTracker();
 frameRate(25);
 rightPadX=(width)-paddleW;
 minim = new Minim(this);
  accessMic = minim.getLineIn(Minim.MONO, 4096, sampleRate);

  myClient = new Client(this, "10.0.0.2", 12367); // Replace with your server’s IP and port

  dia = sqrt(((paddleH/2)*(paddleH/2)) + ((paddleW/2)*(paddleW/2)));
  dia_theta =  90 - degrees(acos((paddleH/2)/dia));
 
} 

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  String prevGest = strGesture;
} 

void onCreateHands(int handId, PVector pos, float time)
{
 handVec = pos;
 handPointCol = color(0, 255, 0);
} 

void onDestroyHands( int handId, float time ) {
  handTrackFlag=false;
}

void onUpdateHands(int handId, PVector pos, float time)
{
 handVec = pos;
} 


void onProgressGesture(String strGesture, PVector position,float progress){
   if(!handTrackFlag){
    kinect.startTrackingHands(position);
    
  }
  if(!kinect.isTrackingSkeleton(skeletonid) ){
   kinect.requestCalibrationSkeleton(skeletonid, true);
   
  }
 
 handTrackFlag=true;
  
}

void draw() {

    game();

}

 void game(){ 
   
  input=null;
  
  

 kt.display();
strokeWeight(0);
 textSize(50);
 fill(0, 102, 153);
 text(leftScore, 50, 60);
  fill(0, 102, 153);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
  
  if(!handTrackFlag && kinect.isTrackingSkeleton(skeletonid))
         kinect.stopTrackingSkeleton(skeletonid);
  
  
  float avg = (accessMic.left.level()+accessMic.right.level())/2;
  //Left Pad
  
  l_yvel = (alpha * ((avg * SCALER) - leftPadY))+((1-alpha) * leftPadY);
  
  if(abs(l_yvel) < exceed_gravity){
    l_yvel = gravity;
  }
  
  leftPadY += l_yvel;
  
  if (leftPadY <= 0){
    leftPadY = 0;
  }
  else if(leftPadY >= height - 100){
    leftPadY = height - 100;
  }
  
  if(handTrackFlag == true){

   prevMapX = leftPadX;
   leftPadX = (int)(mapHandVec.x * scaledX);
   diffX = leftPadX - prevMapX;
  }
  else
    diffX = 0;

  
  if(leftPadX < 0)
    leftPadX = 0;
  else if(leftPadX > (width*1/3) - paddleW){
    leftPadX = (width*1/3) - paddleW;
    diffX = 0;
  }
  
  
  myClient.write(leftPadX+" "+leftPadY+" "+(int)angles[6]+" "+diffX+"\n");

   if(myClient.available()> 0) //available() returns number of bytes available so if it's >0 there is a message
  {
      input=myClient.readString();
      if(input.indexOf("\n") != -1)
      {
        input = input.substring(0, input.indexOf("\n"));  // Only up to the newline
        if(input.length() < 6)
          println(input.length());
        otherCords = int(split(input, ' '));  // Split values into an array
        if(otherCords.length < 6)
          println(otherCords.length);
    }
  }
  try{
  rightPadX=otherCords[0];
  rightPadY=otherCords[1];
  ballX=otherCords[2];
  ballY=otherCords[3];
  leftScore=otherCords[4];
  rightScore=otherCords[5];
  theta2 = otherCords[6];

  for(int i =0; i < otherCords.length;i++){
    copy_cords[i] = otherCords[i];
  }
  }
  catch(ArrayIndexOutOfBoundsException e){
  rightPadX = copy_cords[0];
  rightPadY= copy_cords[1];
  ballX= copy_cords[2];
  ballY= copy_cords[3];
  leftScore = copy_cords[4];
  rightScore= copy_cords[5];
  theta2 = copy_cords[6];

  println("Size: " + otherCords.length + "\n" + e.toString());
}


pushMatrix();
  // move the origin to the pivot point
  translate(leftPadX + paddleW/2, leftPadY + paddleH/2); 
  
  // then pivot the grid
  rotate(radians(angles[6]));

  
   fill(#0000FF);
  rect(-paddleW/2, -paddleH/2, paddleW, paddleH);
  popMatrix();

  l_highx2 =(int)( leftPadX+paddleW/2 +(dia * -cos(radians(-angles[6]-dia_theta))));
  l_highy2 = (int)(leftPadY+paddleH/2 +(dia * sin(radians(-angles[6]-dia_theta))));

  lowX2 = (int)((leftPadX+paddleW/2) + (dia * -cos(radians(angles[6]-dia_theta))));
  lowY2 = (int)((leftPadY+paddleH/2 ) + (dia * -sin(radians(angles[6]-dia_theta))));

  r_highX2 = (int)((leftPadX+paddleW/2) + (dia * cos(radians(angles[6]-dia_theta))));
  r_highY2 = (int)((leftPadY+paddleH/2) + (dia * sin(radians(angles[6]-dia_theta))));

  r_lowX2 = (int)(leftPadX+paddleW/2 + (dia*cos(radians(-angles[6]-dia_theta))));
  r_lowY2 = (int)(leftPadY+paddleH/2 + (dia*-sin(radians(-angles[6]-dia_theta))));

  fill(0,255,0);


 //Right pad
  pushMatrix();
  // move the origin to the pivot point

  translate(rightPadX + paddleW/2,rightPadY + paddleH/2);   

  // then pivot the grid
  rotate(radians(theta2));
  
  // and draw the square at the origin
  //fill(0);
   fill(0,0,255);

 rect(-paddleW/2, -paddleH/2, paddleW, paddleH);
   popMatrix();

 l_highx =(int)( rightPadX+paddleW/2 +(dia * -cos(radians(-theta2-dia_theta))));
  l_highy = (int)(rightPadY+paddleH/2 +(dia * sin(radians(-theta2-dia_theta))));

  lowX = (int)((rightPadX+paddleW/2) + (dia * -cos(radians(theta2-dia_theta))));
  lowY= (int)((rightPadY+paddleH/2 ) + (dia * -sin(radians(theta2-dia_theta))));

  r_highX = (int)((rightPadX+paddleW/2) + (dia * cos(radians(theta2-dia_theta))));
  r_highY= (int)((rightPadY+paddleH/2) + (dia * sin(radians(theta2-dia_theta))));

  r_lowX = (int)(rightPadX+paddleW/2 + (dia*cos(radians(-theta2-dia_theta))));
  r_lowY= (int)(rightPadY+paddleH/2 + (dia*-sin(radians(-theta2-dia_theta))));
  
    fill(0,255,0);
 
  ellipse(ballX,ballY,ballS,ballS);

}
 
  
//---------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  skeletonid = userId;  
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
  skeletonid = userId;
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull) 
  { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId); 

  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    kinect.startPoseDetection("Psi",userId);
  }
}
