import SimpleOpenNI.*;
import processing.serial.*;
import processing.net.*;
import java.awt.*;
SimpleOpenNI kinect;
KinectTracker kt;



boolean hit = false;
boolean hit2 = false;
int x2 = 50;
int y2 = 300;
//Right paddle
int r_highX;
int r_highY;
int r_lowX;
int r_lowY;
int l_highx;
int l_highy;
int l_lowX;
int l_lowY;
//Left Paddle
int l_highx2;
int l_highy2;
int l_lowX2;
int l_lowY2;
int r_highX2;
int r_highY2;
int r_lowX2;
int r_lowY2;

int theta = 45;

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
float r_yvel = 0;
float gravity = 9.8; //how fast the paddle falls
float exceed_gravity = 9.8; //volume must exceed this to fall
final float SCALER = -1000; //change how much an affect loudness has
boolean handTrackFlag = false;
boolean hitX = false;
boolean hitY = false;

int rightPadY=0;
int rightPadX=0;//changed in setup
int leftPadY=0;
int leftPadX=100;
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
int[] otherCords={0,0,0,0};
int[] copyCords={0,0,0,0};
int prevLeft = 0;
int prevMapX = 0;
float scaledX;
float scaledY;
int diffX = 0;


boolean checkIntersection(float x1, float y1, float x2, float y2, 
float cx, float cy, float cr ) {
  float dx = x2 - x1;
  float dy = y2 - y1;

  float a = dx*dx + dy*dy;
  float b = (dx*(x1 - cx) + (y1 - cy)*dy) * 2;
  float c = cx*cx + cy*cy;
 
  c += x1*x1 + y1*y1;
  c -= (cx*x1 + cy*y1) * 2;
  c -= cr*cr;
 
  float delta = b*b - 4*a*c;
 
  if (delta < 0)   return false; // Not intersecting
 
  delta = sqrt(delta);
 
  float mu = (-b + delta) / (2*a);
  float ix1 = x1 + mu*dx;
  float iy1 = y1 + mu*dy;
 
  mu = (b + delta) / (-2*a);
  float ix2 = x1 + mu*dx;
  float iy2 = y1 + mu*dy;
 
  // Intersection points
  /*fill(#FF0000);
  ellipse(ix1, iy1, 5, 5);
  ellipse(ix2, iy2, 5, 5);*/
 
  // Figure out which point is closer to the circle
  boolean test = dist(x1, y1, cx, cy) < dist(x2, y2, cx, cy);
 
  float closerX = test? x2:x1;
  float closerY = test? y2:y1;
 
  return dist(closerX, closerY, ix1, iy1) < dist(x1, y1, x2, y2) || 
    dist(closerX, closerY, ix2, iy2) < dist(x1, y1, x2, y2);
}

//
//PFont font;
PVector handVec = new PVector();
PVector mapHandVec = new PVector();
color handPointCol = color(255,0,0);

void setup() {
  size(1200, 650);
 kinect = new SimpleOpenNI(this);
 kt = new KinectTracker();
 frameRate(28);
 rightPadX=(width)-paddleW;
 minim = new Minim(this);
  accessMic = minim.getLineIn(Minim.MONO, 4096, sampleRate);
//  fft = new FFT(accessMic.left.size(), sampleRate);
//  myServer=new Server (this, 12367); // Start a simple server on a port
//  boolean connect=false;
//  while(connect==false) //don't move on to the game until client connects
//  {
//      delay(500); //wait half a second
//      if(myServer.available()!=null) //if available then it connected
//      {
//         connect=true; 
//         
//      }
//  }
  dia = sqrt(((paddleH/2)*(paddleH/2)) + ((paddleW/2)*(paddleW/2)));
  dia_theta =  90 - degrees(acos((paddleH/2)/dia));
  leftPadY = (height/2)-(paddleH/2);
 
} 

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  String prevGest = strGesture;
} 

void onCreateHands(int handId, PVector pos, float time)
{
 handVec = pos;
 handPointCol = color(255, 0, 0);
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
// background(0,0,0);
 kt.display();

 textSize(50);
 fill(0, 102, 153);
 text(leftScore, 50, 60);
  fill(0, 102, 153);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
  
  // Start freq
//  fft.forward(accessMic.left);
//  for (int f=0;f<sampleRate/2;f++) { //analyses the amplitude of each frequency analysed, between 0 and 22050 hertz
//    max[f]=fft.getFreq(float(f)); //each index is correspondent to a frequency and contains the amplitude value 
//  }
//  maximum=max(max);//get the maximum value of the max array in order to find the peak of volume
// 
//  for (int i=0; i<max.length; i++) {// read each frequency in order to compare with the peak of volume
//    if (max[i] == maximum) {//if the value is equal to the amplitude of the peak, get the index of the array, which corresponds to the frequency
//      frequency= i;
//    }
//  }
       if(!handTrackFlag && kinect.isTrackingSkeleton(skeletonid))
         kinect.stopTrackingSkeleton(skeletonid); 

  
//input=null;
//  myClient=myServer.available();
//  if(myClient!=null)
//  {
//      input=myClient.readString();
//      if(input.indexOf("\n") != -1)
//      {
//        input = input.substring(0, input.indexOf("\n"));  // Only up to the newline
//        otherCords = int(split(input, ' '));  // Split values into an array
//      }
//  }
//  try{
//    leftPadY=otherCords[1];
//    leftPadX=otherCords[0];
////    theta2 = otherCords[2];
////    ballXSpeed = otherCords[3];
//    for(int i =0; i < otherCords.length;i++){
//      copyCords[i] = otherCords[i];
//  }
//  }
//  catch(ArrayIndexOutOfBoundsException e){println("F");
//    leftPadY = copyCords[1];
//      leftPadX = copyCords[0];
////      theta2 = copyCords[2];
////      ballXSpeed = copyCords[3];
//}
//      
//  if (leftPadY<0)
//  {
//    rect(leftPadX,0,paddleW,paddleH); //can't go above screen 
//  }
//  else if(leftPadY<height-paddleH) //left paddle
//  {
//    rect(leftPadX, leftPadY, paddleW, paddleH); 
//  }
//  else
//  {
//    rect(leftPadX, height-paddleH, paddleW, paddleH); 
//  }
pushMatrix();
  // move the origin to the pivot point
  translate(leftPadX + (paddleW/2), leftPadY + (paddleH/2)); 
//  theta2++; // to test rotate
  // then pivot the grid
  rotate(radians(theta));
  
  // and draw the square at the origin
  //fill(0);
   fill(#0000FF);
  rect(-paddleW/2, -paddleH/2, paddleW, paddleH);
  popMatrix();

  l_highx2 =(int)( leftPadX+paddleW/2 +(dia * -cos(radians(-theta-dia_theta))));
  l_highy2 = (int)(leftPadY+paddleH/2 +(dia * sin(radians(-theta-dia_theta))));

  l_lowX2 = (int)((leftPadX+paddleW/2) + (dia * -cos(radians(theta-dia_theta))));
  l_lowY2= (int)((leftPadY+paddleH/2 ) + (dia * -sin(radians(theta-dia_theta))));

  r_highX2 = (int)((leftPadX+paddleW/2) + (dia * cos(radians(theta-dia_theta))));
  r_highY2= (int)((leftPadY+paddleH/2) + (dia * sin(radians(theta-dia_theta))));

  r_lowX2 = (int)(leftPadX+paddleW/2 + (dia*cos(radians(-theta-dia_theta))));
  r_lowY2= (int)(leftPadY+paddleH/2 + (dia*-sin(radians(-theta-dia_theta))));

 /*//Draws the points on the corners of the Left paddle
   fill(0,255,0);
  ////top left
  ellipse(l_highx2 ,l_highy2,5,5);
  fill(#FF00FF);
  ////bottom left
  ellipse(l_lowX2,l_lowY2,5,5);
  fill(#4A10B6);
  ////top right
  ellipse(r_highX2,r_highY2,5,5);
  fill(#0000FF);
  ////bottom right
  ellipse(r_lowX2,r_lowY2,5,5);
  fill(#00FF00);*/
  
  
  if(handTrackFlag == true){

   prevMapX = rightPadX;
   rightPadX = (int)(mapHandVec.x * scaledX);
   diffX = rightPadX - prevMapX;
  }
  else
    diffX = 0;

  
  if(rightPadX > width-paddleW)
    rightPadX = width-paddleW;
  else if(rightPadX < (width*2/3) - paddleW){
    rightPadX = (width*2/3) - paddleW;
    diffX = 0;
  }

  float avg = (accessMic.left.level()+accessMic.right.level())/2;
  

  //Right Pad
  
  r_yvel = (alpha * ((avg * SCALER) - rightPadY))+((1-alpha) * rightPadY);
  //println(r_yvel);
  if(abs(r_yvel) < exceed_gravity){
    r_yvel = gravity;
  }
  rightPadY += r_yvel;
  if (rightPadY <= 0){
    rightPadY = 0;
  }
  else if(rightPadY >= height - 100){
    rightPadY = height - 100;
  }
  
 
  
  pushMatrix();
  // move the origin to the pivot point
  translate(rightPadX + (paddleW/2), rightPadY + (paddleH/2)); 
//  translate(rightPadX,rightPadY);   

  // then pivot the grid
  rotate(radians(angles[6]));
//  angles[6]++;
  // and draw the square at the origin
  //fill(0);
   fill(0,0,255);
  
  rect(-paddleW/2, -paddleH/2, paddleW, paddleH);
// rect(0, 0, paddleW, paddleH);
 
  popMatrix();

  l_highx =(int)( rightPadX+paddleW/2 +(dia * -cos(radians(-angles[6]-dia_theta))));
  l_highy = (int)(rightPadY+paddleH/2 +(dia * sin(radians(-angles[6]-dia_theta))));

  l_lowX = (int)((rightPadX+paddleW/2) + (dia * -cos(radians(angles[6]-dia_theta))));
  l_lowY= (int)((rightPadY+paddleH/2 ) + (dia * -sin(radians(angles[6]-dia_theta))));

  r_highX = (int)((rightPadX+paddleW/2) + (dia * cos(radians(angles[6]-dia_theta))));
  r_highY= (int)((rightPadY+paddleH/2) + (dia * sin(radians(angles[6]-dia_theta))));

  r_lowX = (int)(rightPadX+paddleW/2 + (dia*cos(radians(-angles[6]-dia_theta))));
  r_lowY= (int)(rightPadY+paddleH/2 + (dia*-sin(radians(-angles[6]-dia_theta))));

 /*Draws the points on the corners of the right paddle   
   fill(0,255,0);
  ////top left
  ellipse(l_highx ,l_highy,5,5);
  ////bottom left
  ellipse(lowX,lowY,5,5);
  ////top right
  ellipse(r_highX,r_highY,5,5);
  ////bottom right
  ellipse(r_lowX,r_lowY,5,5);*/
  fill(#00FF00);
  ellipse(ballX,ballY,ballS,ballS);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;  
  //scoring
  if(ballX<=ballS/2)
  {
    ballXSpeed=-5;
    rightScore++;
    hit = false;
    hit2 = false;
    ballX=width/2; //reset ball
    ballS=50;
    ballXSpeed=-ballXSpeed; 
  }
  else if(ballX>=width-ballS/2)
  {
   ballXSpeed=5; 
   leftScore++;
  hit = false; 
  hit2 = false;
   ballX=width/2;
   ballS=50;
   ballXSpeed=-ballXSpeed; 
  }
  if(ballY>height-ballS/2 && !hitY) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
     hitY = true;
     hitX = false;
  }
  else if(ballY<ballS/2 && !hitX)
  {
     ballYSpeed=-ballYSpeed;
     hitY = false;
     hitX = true;
  }
  
  //checks bounds
  if(ballX>width-ballS/2) //stay in bounds in X
  {
     ballXSpeed=-ballXSpeed; 
  }
  else if(ballX<ballS/2)
  {
     ballXSpeed=-ballXSpeed; 
  }
  
  // check if ball has hit any side of the right paddle 
if(checkIntersection(l_highx,l_highy, l_lowX, l_lowY, ballX,ballY, ballS/2) && !hit){

  reflect(l_highx,l_highy, l_lowX, l_lowY);

      ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = true;
    hit2=false;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(l_highx,l_highy, r_highX, r_highY, ballX,ballY, ballS/2) && !hit){

     reflect(r_highX,r_highY, l_highx, l_highy);
   ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = true;
    hit2=false;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(l_lowX,l_lowY, r_lowX, r_lowY, ballX,ballY, ballS/2) && !hit){

     reflect(l_lowX,l_lowY, r_lowX, r_lowY);
      ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = true;
    hit2=false;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(r_lowX,r_lowY , r_highX, r_highY, ballX,ballY, ballS/2) && !hit){

  reflect(r_lowX,r_lowY , r_highX, r_highY);
       ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = true;
    hit2=false;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }

// left paddle
if(checkIntersection(l_highx2,l_highy2, l_lowX2, l_lowY2, ballX,ballY, ballS/2) && !hit2){

  reflect(l_highx2,l_highy2, l_lowX2, l_lowY2);

      ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = false;
    hit2=true;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(l_highx2,l_highy2, r_highX2, r_highY2, ballX,ballY, ballS/2) && !hit2){

     reflect(r_highX2,r_highY2, l_highx2, l_highy2);
   ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = false;
    hit2=true;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(l_lowX2,l_lowY2, r_lowX2, r_lowY2, ballX,ballY, ballS/2) && !hit2){

     reflect(l_lowX2,l_lowY2, r_lowX2, r_lowY2);
      ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = false;
    hit2=true;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
   
   else if(checkIntersection(r_lowX2,r_lowY2 , r_highX2, r_highY2, ballX,ballY, ballS/2) && !hit2){

  reflect(r_lowX2,r_lowY2 , r_highX2, r_highY2);
       ballXSpeed=reflect.x;
      
      ballYSpeed=reflect.y;
    hit = false;
    hit2=true;
    hitY = false;
     hitX = false;
     if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    
   }
  
  
  
//  myServer.write(rightPadX+" "+rightPadY+" "+ballX+ " "+ballY+" "+leftScore+" "+rightScore+" "+angles[6]+" "+ballXSpeed+"\n"); //send cords of paddle and ball to show on other client
  theta++;
  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    myServer.stop();
    exit();
  }
  
}

  void reflect(float x1, float y1, float x2, float y2){
    float dx = (x2) - x1;
  float dy = (y2) - y1;

 float fx = -dy;
 float fy = dx;

 
 v = new PVector(ballXSpeed,ballYSpeed);
 normal = new PVector(fx,fy);
 normal.normalize();
 float dots = -2 * PVector.dot(v,normal);
 
 PVector temp=PVector.mult(normal,dots);
 reflect = PVector.add(v,temp);

 // if ball hit a paddle but didnt bounce back, make it bounce
 if(reflect.x * ballXSpeed > 0){
   reflect.x=-reflect.x;
   reflect.y=-reflect.y;
 }
 
 // if the ball hit the back side of the paddle and the user was moving the paddle backwards, then have the ball move in the same x direction
 if((x1+x2)/2 > (rightPadX+paddleW/2) && (rightPadX >= prevMapX)){
   
    
      if(ballYSpeed > 0 && x2 > rightPadX){
      reflect.y =-reflect.y; 
      
     }
     else if(ballYSpeed < 0 && x2 < rightPadX)
       reflect.y=-reflect.y;
       
    reflect.x=-reflect.x;
     

 }
  if((x1+x2)/2 < (leftPadX+paddleW/2) && (lefttPadX <= prevMapX)){
   
    
      if(ballYSpeed > 0 && x2 > leftPadX){
      reflect.y =-reflect.y; 
      
     }
     else if(ballYSpeed < 0 && x2 < leftPadX)
       reflect.y=-reflect.y;
       
 }
 // sets velocity of x to be 1 if it is less than 1 so it cannot get stuck
  if(abs(reflect.x) < 1){
    if(reflect.x < 0)
    reflect.x=-1;
    else
      reflect.x = 1;
  }

  }

// -----------------------------------------------------------------
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
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if (successfull && !kinect.isTrackingSkeleton(skeletonid)) 
  { 
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId); 

  } 
  else if(!kinect.isTrackingSkeleton(skeletonid))
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    kinect.startPoseDetection("Psi",userId);
  }
}
