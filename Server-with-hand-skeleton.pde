
import SimpleOpenNI.*;
import processing.serial.*;
import processing.net.*;
SimpleOpenNI kinect;
KinectTracker kt;

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioInput  accessMic;
FFT         fft;
int sampleRate= 44100;//sapleRate of 44100
float [] max= new float [sampleRate/2];//array that contains the half of the sampleRate size, because FFT only reads the half of the sampleRate frequency. This array will be filled with amplitude values.
float maximum;//the maximum amplitude of the max array
float frequency;//the frequency in hertz


float boxSize;
float alpha = 0.5;
float r_yvel = 0;
float gravity = 9.8; //how fast the paddle falls
float exceed_gravity = 9.8; //volume must exceed this to fall
final float SCALER = -1000; //change how much an affect loudness has
boolean handTrackFlag = false;
float initialX = 0;
int paddleSpeed=15;
int rightPadY=0;
int rightPadX=0;//changed in setup
int leftPadY=0;
int leftPadX=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
int ballXSpeed=5;
int ballYSpeed=5;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;
boolean onlyOnce = true;
//networking
Server myServer;
Client myClient;
String input;
int[] otherCords={0,0};
int prevLeft = 0;
int prevMapX = 0;
float scaledX;
float scaledY;
int diffX = 0;


boolean leftHit()
{
  //checks if ball is at the say Y as paddle and then at same X
  if(ballY>=leftPadY && ballY<=leftPadY+paddleH && ballX-ballS/2<=leftPadX+paddleW) //paddle is in space 0-paddleW wide
  {
    ballX=leftPadX+paddleW+ballS/2+1; //puts ball just off paddle when hit
    return true;
  }
  else if(ballY+ballS>=leftPadY && ballY<=leftPadY+paddleH &&  ballX-ballS/2<=leftPadX+paddleW) //detect if slightly bellow paddle
  {
    ballX=leftPadX+paddleW+ballS/2+1;
    return true;
  }
  else if(ballY>=leftPadY && ballY-ballS<=leftPadY+paddleH &&  ballX-ballS/2<=leftPadX+paddleW) //detect if slightly above paddle
  {
    ballX=leftPadX+paddleW+ballS/2+1;
     return true; 
  }
  else
  {
    return false;
  }
}

boolean rightHit()
{
  //checks if ball is at the say Y as paddle and then at same X
  if(ballY>=rightPadY && ballY<=rightPadY+paddleH && ballX+ballS/2>=rightPadX) //paddle is in space 0-paddleW wide
  {
    ballX=rightPadX-ballS/2-1; //puts ball just off paddle when hit
    
    return true;
  }
  else if(ballY+ballS>=rightPadY && ballY<=rightPadY+paddleH && ballX+ballS/2>=rightPadX) //detect if slightly bellow paddle
  {
    ballX=rightPadX-ballS/2-1;
    
    return true;
  }
  else if(ballY>=rightPadY && ballY-ballS<=rightPadY+paddleH && ballX+ballS/2>=rightPadX) //detect if slightly above paddle
  {
    ballX=rightPadX-ballS/2-1;
    
    return true;
  }
  else
  {
    return false;
  }
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
 frameRate(60);
 rightPadX=(width)-paddleW;
 minim = new Minim(this);
  accessMic = minim.getLineIn(Minim.MONO, 4096, sampleRate);
  fft = new FFT(accessMic.left.size(), sampleRate);
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

 
} 

void onRecognizeGesture(String strGesture, PVector idPosition, PVector endPosition)
{
  String prevGest = strGesture;
   

} 

void onCreateHands(int handId, PVector pos, float time)
{
 handVec = pos;
 handPointCol = color(0, 255, 0);
    kinect.requestCalibrationSkeleton(1, true);

} 

void onDestroyHands( int handId, float time ) {
//  println( "onDestroyHands - handId: " + handId + ", time: " + time );
  handTrackFlag=false;
  onlyOnce = true;


}

void onUpdateHands(int handId, PVector pos, float time)
{
 handVec = pos;
} 


void onProgressGesture(String strGesture, PVector position,float progress){
  println("onProgressGesture - strGesture: " + strGesture + ", position: " + position + ", progress:" + progress);
  kinect.startTrackingHands(position);
  if(!kinect.isTrackingSkeleton(1)){
   kinect.requestCalibrationSkeleton(1, true); 
  }
 
 handTrackFlag=true;
}

void draw() {
 background(255,0,0);
 kt.display();

 textSize(50);
 fill(0, 102, 153);
 text(leftScore, 50, 60);
  fill(0, 102, 153);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
  
  // Start freq
  fft.forward(accessMic.left);
  for (int f=0;f<sampleRate/2;f++) { //analyses the amplitude of each frequency analysed, between 0 and 22050 hertz
    max[f]=fft.getFreq(float(f)); //each index is correspondent to a frequency and contains the amplitude value 
  }
  maximum=max(max);//get the maximum value of the max array in order to find the peak of volume
 
  for (int i=0; i<max.length; i++) {// read each frequency in order to compare with the peak of volume
    if (max[i] == maximum) {//if the value is equal to the amplitude of the peak, get the index of the array, which corresponds to the frequency
      frequency= i;
    }
  }
  
  
  
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
//    prevLeft = otherCords[1];
//  }
//  catch(ArrayIndexOutOfBoundsException e){println("F");
//    leftPadY = prevLeft;}

  if (leftPadY<0)
  {
    rect(leftPadX,0,paddleW,paddleH); //can't go above screen 
  }
  else if(leftPadY<height-paddleH) //left paddle
  {
    rect(leftPadX, leftPadY, paddleW, paddleH); 
  }
  else
  {
    rect(leftPadX, height-paddleH, paddleW, paddleH); 
  }
  
  
  if(onlyOnce ==true && handTrackFlag == true){

   prevMapX = rightPadX;
   rightPadX = (int)(mapHandVec.x * scaledX);
   diffX = rightPadX - prevMapX;
   

  }
  


  
  if(rightPadX > width-paddleW)
    rightPadX = width-paddleW;
  else if(rightPadX < (width*2/3) - paddleW)
    rightPadX = (width*2/3) - paddleW;
  

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
  
  
  rect(rightPadX,rightPadY,paddleW,paddleH);

  
  ellipse(ballX,ballY,ballS,ballS);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;  
  //scoring
  if(ballX<=ballS/2)
  {
    ballXSpeed=-5;
    rightScore++;
    ballX=width/2; //reset ball
    ballS=50;
    ballXSpeed=-ballXSpeed; 
  }
  else if(ballX>=width-ballS/2)
  {
   ballXSpeed=5; 
   leftScore++; 
   ballX=width/2;
   ballS=50;
   ballXSpeed=-ballXSpeed; 
  }
  if(ballY>height-ballS/2) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
  }
  else if(ballY<ballS/2)
  {
     ballYSpeed=-ballYSpeed;
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
  
  
  if(leftHit())
  {
    ballXSpeed=-ballXSpeed;

  }
  else if(rightHit())
  {
    if(ballXSpeed < 0)
      ballXSpeed-=abs(diffX/10);
    else
      ballXSpeed+=abs(diffX/10);
    ballXSpeed=-ballXSpeed;
   
  }
  
  
  
//  myServer.write(rightPadX+" "+rightPadY+" "+ballX+ " "+ballY+" "+leftScore+" "+rightScore+"\n"); //send cords of paddle and ball to show on other client

  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    myServer.stop();
    exit();
  }
  
}



// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");
  

//    kinect.requestCalibrationSkeleton(userId,true);

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
