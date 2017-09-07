int paddleSpeed=15;
int rightPadY=0;
int ballXSpeed=5;
int ballYSpeed=5;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;

boolean leftHit()
{
  //checks if ball is at the say Y as paddle and then at same X
  if(ballY>=mouseY && ballY<=mouseY+100 && ballX-25<=33) //paddle is in space 0-33 wide
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
  if(ballY>=rightPadY && ballY<=rightPadY+100 && ballX+25>=width-33) //paddle is in space 0-33 wide
  {
    return true;
  }
  else
  {
    return false;
  }
}

void setup() {
  //size(1500, 1000); //window size
  /*press esc to quit full screen
    fullscreen(1) launches in screen one is there are multiple screens
    fullscreen(2) launches in screen two and so on */
  fullScreen(); //press esc to quit
  noStroke(); //for mouse
  fill(0); //fill shapes in black
  textSize(64);
}

void draw() {
  background(255); //white
  text(leftScore, 50, 60);
  text(rightScore, width-100, 60);
  ellipseMode(CENTER);
  if(mouseY<height-100) //left paddle
  {
    rect(0, mouseY, 33, 100); 
  }
  else
  {
    rect(0, 800, 33, 100); 
  }
  
  rect(width-33,rightPadY,33,100);
  if ((keyPressed == true) && (key == 'w')) //right paddle
  {
    if(rightPadY>0)
    {
      rightPadY-=paddleSpeed; //go up
    }
    else
    {
      rightPadY=0;
    }
  }
  else if((keyPressed == true) && (key == 's'))
  {
    if(rightPadY<height-100)
    {
      rightPadY+=paddleSpeed; //go down
    }
    else
    {
      rightPadY=height-100;
    }
  }
  
  ////////////////////////////
  //makes right paddle also controled with mouse
  /*if(mouseY<height-100) //right paddle
  {
    rect(967, mouseY, 33, 100); 
  }
  else
  {
    rect(967, 800, 33, 100); 
  }*/
  ////////////////////////////
  
  ellipse(ballX,ballY,50,50);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;
  if(ballY>height-25) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
  }
  else if(ballY<25)
  {
     ballYSpeed=-ballYSpeed; 
  }
  
  if(ballX>width-25) //stay in bounds in X
  {
     ballXSpeed=-ballXSpeed; 
  }
  else if(ballX<25)
  {
     ballXSpeed=-ballXSpeed; 
  }
  
  //scoring
  if(ballX<=25)
  {
    rightScore++;
    ballX=width/2; //reset ball
    ballXSpeed=-ballXSpeed; 
  }
  else if(ballX>=width-25)
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
}
