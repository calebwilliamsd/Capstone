import processing.sound.*;


final float SCALER = -800; //change how much an affect loudness has
float alpha = 0.5;
float r_amp = 0;
float l_amp = 0;
int r_freq = 1;
int l_freq = 1;
float r_yvel = 0;
float l_yvel = 0;
float max;
float gravity = 9.8; //how fast the paddle falls
float exceed_gravity = 9.8; //volume must exceed this to fall
Amplitude amp;
FFT fft;
int bands = 4096;
float[] spectrum = new float[bands];
AudioIn in; //input for amplitude
AudioIn in2; //input for frequency

int toggle = -1;


int paddleSpeed=15;
int paddleH=100;
int rightPadY;
int rightPadX=0;//changed in setup
int leftPadY=0;
int leftPadX=0;
int paddleW= 33;
int ballS=50; //ball size
int ballXSpeed=5;
int ballYSpeed=5;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;

void setup() {
  size(600, 600); //window size
  /*press esc to quit full screen
    fullscreen(1) launches in screen one is there are multiple screens
    fullscreen(2) launches in screen two and so on */
  //fullScreen(); //press esc to quit
  noStroke(); //for mouse
  fill(0); //fill shapes in black
  textSize(64);
  
  rightPadX=width-paddleW;
  in = new AudioIn(this,0);
  in2 = new AudioIn(this,0);
  in.start();
  in2.start();
  fft = new FFT(this, bands);
  amp = new Amplitude(this);
  
  fft.input(in2);
  amp.input(in);
 
  rightPadY = height/2;
  leftPadY = height/2;
 // rect(rightPadX,rightPadY,paddleW,paddleH);
 // rect(leftPadX,leftPadY,paddleW,paddleH);
  //println(width);
}

void draw() {
  background(225,0,0); //white
  if(toggle > 0) 
    game();
   else
     text("Press enter to start",width/4, height/4, width/2, height/2);
}
void game(){
  text(leftScore, 50, 60);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
   /*fft.analyze(spectrum);
   max = 0;
   for (int i = 0; i < bands; i++){
     if(spectrum[i] > max)
      {
         max = spectrum[i];
         l_freq = i;
      }
   }//*/
  // println(l_freq);
  
  //Left Pad
  l_amp = amp.analyze();
  l_yvel = (alpha * ((l_amp * SCALER) - leftPadY))+((1-alpha) * leftPadY);
  //println(r_yvel);
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
  if(keyPressed == true && key == 'd'){
    if(leftPadX <= (width/4)-paddleW)
      leftPadX+=gravity;
  }
  else if(keyPressed == true && key == 'a'){
    if (leftPadX > 0)
      leftPadX-=gravity;
  }
  rect(leftPadX,leftPadY,paddleW,paddleH);
  //Right Pad
  r_amp = amp.analyze();
  //println(r_amp);
  r_yvel = (alpha * ((r_amp * SCALER) - rightPadY))+((1-alpha) * rightPadY);
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
  if(keyPressed == true && key == 'j'){
    if(rightPadX >= (width - width/4))
      rightPadX-=gravity;
  }
  else if(keyPressed == true && key == 'l'){
    if (rightPadX < width - paddleW)
      rightPadX+=gravity;
  }
  rect(rightPadX,rightPadY,paddleW,paddleH);

  ellipse(ballX,ballY,ballS,ballS);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;  
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
    ballXSpeed=-ballXSpeed; 
  } 
}

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
void keyPressed() {
  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    exit();
  }
  else if ((keyPressed == true) && (key == ENTER)) //sets the toggle
  {  
    toggle *= -1;
  }
}