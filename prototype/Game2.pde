import processing.sound.*;

final float SCALER = 10; //change how much an affect loudness has
Amplitude amp;
AudioIn in;

int paddleSpeed=15;
int rightPadY=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
int ballXSpeed=5;
int ballYSpeed=5;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;

boolean leftHit()
{
  //checks if ball is at the say Y as paddle and then at same X
  if(ballY>=mouseY && ballY<=mouseY+paddleH && ballX-ballS/2<=paddleW) //paddle is in space 0-paddleW wide
  {
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
  if(ballY>=rightPadY && ballY<=rightPadY+paddleH && ballX+ballS/2>=width-paddleW) //paddle is in space 0-paddleW wide
  {
    return true;
  }
  else
  {
    return false;
  }
}

void setup() {
  //size(1500, paddleH0); //window size
  /*press esc to quit full screen
    fullscreen(1) launches in screen one is there are multiple screens
    fullscreen(2) launches in screen two and so on */
  fullScreen(); //press esc to quit
  noStroke(); //for mouse
  fill(0); //fill shapes in black
  textSize(64);
  in = new AudioIn(this,0);
  in.start();
  amp = new Amplitude(this);
  amp.input(in);
}

void draw() {
  background(255); //white
  text(leftScore, 50, 60);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
  if (mouseY<0)
  {
    rect(0,0,paddleW,paddleH); //can't go above screen 
  }
  else if(mouseY<height-paddleH) //left paddle
  {
    rect(0, mouseY, paddleW, paddleH); 
  }
  else
  {
    rect(0, height-paddleH, paddleW, paddleH); 
  }
  //Right Pad
  rightPadY = (int)(height - (height * (amp.analyze() * SCALER)) - paddleH);
  if (rightPadY <= 0){
    rightPadY = 0;
  }
  rect(width-paddleW,rightPadY,paddleW,paddleH);
  
  
  ////////////////////////////
  //makes right paddle also controled with mouse
  /*if(mouseY<height-paddleH) //right paddle
  {
    rect(967, mouseY, paddleW, paddleH); 
  }
  else
  {
    rect(967, 800, paddleW, paddleH); 
  }*/
  ////////////////////////////
  
  ellipse(ballX,ballY,ballS,ballS);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;
  if(ballY>height-ballS/2) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
  }
  else if(ballY<ballS/2)
  {
     ballYSpeed=-ballYSpeed; 
  }
  
  if(ballX>width-ballS/2) //stay in bounds in X
  {
     ballXSpeed=-ballXSpeed; 
  }
  else if(ballX<ballS/2)
  {
     ballXSpeed=-ballXSpeed; 
  }
  
  //scoring
  if(ballX<=ballS/2)
  {
    rightScore++;
    ballX=width/2; //reset ball
    ballXSpeed=-ballXSpeed; 
  }
  else if(ballX>=width-ballS/2)
  {
   leftScore++; 
   ballX=width/2;
   ballXSpeed=-ballXSpeed; 
  }
  
  if(leftHit())
  {
    ballXSpeed=-ballXSpeed;
  }
  else if(rightHit())
  {
    ballXSpeed=-ballXSpeed; 
  }
  
  
  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    exit();
  }
  
  
}