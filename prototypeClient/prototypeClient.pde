import processing.net.*; 

int rightPadY=0;
int rightPadX=0;
int leftPadY=0;
int leftPadX=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;

Client myClient; 
String input;
int[] otherCords={0,0,0,0,0,0}; 

void setup() { 
  fullScreen(1);
  frameRate(60);
  noStroke(); //for mouse
  fill(0); //fill shapes in black
  textSize(64);
  // Connect to the server’s IP address and port
  myClient = new Client(this, "127.0.0.1", 12366); // Replace with your server’s IP and port
} 

void draw() {
  background(255);
  ellipseMode(CENTER);
  input=null;
  leftPadY=mouseY;
  leftPadX=0;
   // Send mouse coords to other person
   myClient.write(leftPadX+" "+leftPadY+"\n");
   
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
  
  if(myClient.available()>0) //available() returns number of bytes available so if it's >0 there is a message
  {
      input=myClient.readString();
      if(input.length()>0)
      {
        input = input.substring(0, input.indexOf("\n"));  // Only up to the newline
        otherCords = int(split(input, ' '));  // Split values into an array
      }
  }
  rightPadX=otherCords[0];
  rightPadY=otherCords[1];
  ballX=otherCords[2];
  ballY=otherCords[3];
  leftScore=otherCords[4];
  rightScore=otherCords[5];
  
  rect(rightPadX,rightPadY,paddleW,paddleH);//right paddle
  ellipse(ballX,ballY,ballS,ballS); //ball
  
  text(leftScore, 50, 60);
  text(rightScore, width-paddleH, 60);
  
  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    myClient.stop();
    exit();
  }
  
}