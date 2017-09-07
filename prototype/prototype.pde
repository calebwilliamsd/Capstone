int winHeight=900; //maybe delete
int winWide=1000; //maybe delete
int paddleSpeed=15;
int rightPadY=0;
int ballXSpeed=10;
int ballYSpeed=10;
int ballX=50;
int ballY=50;

void setup() {
  size(1000, 900);
  noStroke(); //for mouse
  fill(0); //fill shapes in black
}

void draw() {
  background(255); //white
  ellipseMode(CENTER);
  if(mouseY<winHeight-100) //left paddle
  {
    rect(0, mouseY, 33, 100); 
  }
  else
  {
    rect(0, 800, 33, 100); 
  }
  
  rect(967,rightPadY,33,100);
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
    if(rightPadY<winHeight-100)
    {
      rightPadY+=paddleSpeed; //go down
    }
    else
    {
      rightPadY=winHeight-100;
    }
  }
  
  ////////////////////////////
  //makes right paddle also controled with mouse
  /*if(mouseY<winHeight-100) //right paddle
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
  if(ballY>winHeight-50) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
  }
  else if(ballY<50)
  {
     ballYSpeed=-ballYSpeed; 
  }
  
  if(ballX>winWide-50) //stay in bounds in X
  {
     ballXSpeed=-ballXSpeed; 
  }
  else if(ballX<50)
  {
     ballXSpeed=-ballXSpeed; 
  }
  
}