import processing.net.*;
import processing.sound.*;


final float SCALER = -800; //change how much an affect loudness has
final float alpha = 0.5;
final int frames = 60;
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
int bands = 128;
float[] spectrum = new float[bands];
AudioIn in; //input for amplitude
AudioIn in2; //input for frequency
int ave = 0;
int count = 0;

int toggle = -1;

int paddleSpeed=15;
int rightPadY=0;
int rightPadX=0;//changed in setup
int leftPadY=0;
int leftPadX=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
int ballXSpeed=10;
int ballYSpeed=10;
int ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;
String leftName="Left";
String rightName="Right";
String[] leaderNames={"none","none","none","none","none","none","none","none","none","none"};
int[] leaderScores={0,0,0,0,0,0,0,0,0,0};
boolean endGame=false;
int nameEnter=0;
//networking

 boolean connect=false;
Client myClient;
String input;
int[] otherCords={0,0};
int[] copy_cords={0,0};
Server myServer;

void setup() {
  size(600, 600); //window size
  /*press esc to quit full screen
    fullscreen(1) launches in screen one is there are multiple screens
    fullscreen(2) launches in screen two and so on */
 // fullScreen(); //press esc to quit
  frameRate(60);
  noStroke(); //for mouse
  fill(0); //fill shapes in black
  textSize(64);
  in = new AudioIn(this,0);
  in2 = new AudioIn(this,0);
  in.start();
  in2.start();
  fft = new FFT(this, bands);
  amp = new Amplitude(this);
  
  fft.input(in2);
  amp.input(in);
  rightPadX=width-paddleW;
  myServer=new Server (this, 12366); // Start a simple server on a port
  
  leaderNames=loadStrings("names.txt");
  leaderScores=int(loadStrings("scores.txt"));
}

void draw() {
  background(255); //white
  textSize(36);
  text("Press 'L' to view the full Leaderboard, '=' to edit team names, or 'Enter' on the Client to begin",20,50,width-20,height-50); //x y width height of text box
  for(int i=0;i<leaderScores.length && i<5;i++)
  {
    text(i+1+": "+leaderNames[i]+" "+leaderScores[i],20,300+36*i);
  }
  if(myServer.available()!=null) //if available then it connected
  {
    connect=true; 
  }
  if(endGame){
    GameEnd();
  }
  else if(connect){
    Game();
  }
  else if(toggle > 0){
    Leaderboard();
  }
  else if(nameEnter>0){
    enterName();
  }
}
void enterName()
{
  background(255);
  if(nameEnter==1)
  {
   text("Press '=' to edit right side's name",20,100,width-20,height/2);
    text(leftName,20,height/2);
  }
  else if (nameEnter==2)
  {
     text("Press '=' to return to the main menu",20,100,width-20,height/2);
     text(rightName,20,height/2); 
  }
  else
  {
    nameEnter=0;
  }
}
void GameEnd(){
  background(255);
  if(leftScore>rightScore){
    text(leftName+" won!\nPress 'R' to restart the game or 'O' to quit",20,50,width-20,height-50); //x y width height of text box
  }
  else{
    text(rightName+" won!\nPress 'R' to restart the game or 'O' to quit",20,50,width-20,height-50); //x y width height of text box
  }
  delay(500);
}
void Leaderboard(){
  background(255);
  for(int i=0;i<leaderScores.length && i<10;i++)
  {
    text(i+1+": "+leaderNames[i]+" "+leaderScores[i],20,36+36*i);
  }
  text("Press 'L' to return to the main menu",20,400,width-20,height);
}
void Game(){
  background(255);
  textSize(64);
  text(leftScore, 50, 60);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
   fft.analyze(spectrum);
   max = 0;
   for (int i = 0; i < bands; i++){
     if(spectrum[i] > max)
      {
         max = spectrum[i];
         l_freq = i;
      }
   }//*/
   ave+=l_freq;
   if(count == frames){
     ave = ave/frames;
     count = 0;
     println(ave);
     if(ave > 30)
       ballX += width/8;//*ave;
    // println("Balls" + ballXSpeed);
     ave = 0;
   }
   count++;
  input=null;
  myClient=myServer.available();
  if(myClient!=null)
  {
      input=myClient.readString();
      if(input.indexOf("\n") != -1)
      {
        input = input.substring(0, input.indexOf("\n"));  // Only up to the newline
        otherCords = int(split(input, ' '));  // Split values into an array
      }
  }
  try{
    leftPadX=otherCords[0];
    leftPadY=otherCords[1];
    copy_cords[0] = otherCords[0];
    copy_cords[1] = otherCords[1];
  }
  catch(ArrayIndexOutOfBoundsException e){
  leftPadX=copy_cords[0];
   leftPadY=copy_cords[1];
  
  println("Size: " + otherCords.length + "\n" + e.toString());}
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
  
  myServer.write(rightPadX+" "+rightPadY+" "+ballX+ " "+ballY+" "+leftScore+" "+rightScore+"\n"); //send cords of paddle and ball to show on other client
  
  if(rightScore>9 || leftScore>9){ //when side gets to 10 they win
     endGame=true;
     String tempName;
     int tempScore;
     int pos=0;
     if(leftScore>rightScore)
     {
       
       for(int i=0;i<leaderScores.length;i++)
       {
         if(leaderNames[i].equals(leftName)) //gain point and maybe move up
         {
           leaderScores[i]++;
           leftScore=0;
           pos=i;
           while(pos!=0 && leaderScores[pos]>leaderScores[pos-1])
           {
             tempScore=leaderScores[pos-1];
             leaderScores[pos-1]=leaderScores[pos];
             leaderScores[pos]=tempScore;
             tempName=leaderNames[pos-1];
             leaderNames[pos-1]=leaderNames[pos];
             leaderNames[pos]=tempName;
             pos--;
           }
         }
         if(leaderNames[i].equals(rightName)&&leaderScores[i]>0) //lose point and maybe move down
         {
           leaderScores[i]--;
           pos=i;
           while(pos+1!=leaderScores.length && leaderScores[pos]<leaderScores[pos+1])
           {
             tempScore=leaderScores[pos+1];
             leaderScores[pos+1]=leaderScores[pos];
             leaderScores[pos]=tempScore;
             tempName=leaderNames[pos+1];
             leaderNames[pos+1]=leaderNames[pos];
             leaderNames[pos]=tempName;
             pos++;
           }
         }
       }
       if(leftScore>0) //new entry in leaderboard
       {
         String[] tempLeaderNames=new String[leaderNames.length+1]; //<>//
         System.arraycopy(leaderNames,0,tempLeaderNames,0,leaderNames.length); //(source array, starting pos, destination array, starting pos, num elements cpied to dest array)
         leaderNames=new String[leaderNames.length+1]; //make new array that is one larger for new entry
         System.arraycopy(tempLeaderNames,0,leaderNames,0,tempLeaderNames.length); //put contents back into array
         leaderNames[leaderNames.length-1]=leftName;
         int[] tempLeaderScores=new int[leaderScores.length+1];
         System.arraycopy(leaderScores,0,tempLeaderScores,0,leaderScores.length);
         leaderScores=new int[leaderScores.length+1];
         System.arraycopy(tempLeaderScores,0,leaderScores,0,tempLeaderScores.length);
         leaderScores[leaderScores.length-1]=1;
       }
       leftScore=rightScore+1; //make sure endgame screen to work
     }
     else //right won
     {
       for(int i=0;i<leaderScores.length;i++)
       {
         if(leaderNames[i].equals(rightName))
         {
           leaderScores[i]++;
           rightScore=0;
           pos=i; //<>//
           while(pos!=0 && leaderScores[pos]>leaderScores[pos-1])
           {
             tempScore=leaderScores[pos-1];
             leaderScores[pos-1]=leaderScores[pos];
             leaderScores[pos]=tempScore;
             tempName=leaderNames[pos-1];
             leaderNames[pos-1]=leaderNames[pos];
             leaderNames[pos]=tempName;
             pos--;
           }
         }
         if(leaderNames[i].equals(leftName)&&leaderScores[i]>0)
         {
           leaderScores[i]--;
           pos=i;
           while(pos+1!=leaderScores.length && leaderScores[pos]<leaderScores[pos+1])
           {
             tempScore=leaderScores[pos+1];
             leaderScores[pos+1]=leaderScores[pos];
             leaderScores[pos]=tempScore;
             tempName=leaderNames[pos+1];
             leaderNames[pos+1]=leaderNames[pos];
             leaderNames[pos]=tempName;
             pos++;
           }
         }
       }
         if(rightScore>0) //new entry in leaderboard
         {
           String[] tempLeaderNames=new String[leaderNames.length+1];
           System.arraycopy(leaderNames,0,tempLeaderNames,0,leaderNames.length); //(source array, starting pos, destination array, starting pos, num elements cpied to dest array)
           leaderNames=new String[leaderNames.length+1]; //make new array that is one larger for new entry
           System.arraycopy(tempLeaderNames,0,leaderNames,0,tempLeaderNames.length); //put contents back into array
           leaderNames[leaderNames.length-1]=rightName;
           int[] tempLeaderScores=new int[leaderScores.length+1];
           System.arraycopy(leaderScores,0,tempLeaderScores,0,leaderScores.length);
           leaderScores=new int[leaderScores.length+1];
           System.arraycopy(tempLeaderScores,0,leaderScores,0,tempLeaderScores.length);
           leaderScores[leaderScores.length-1]=1;
         }
         rightScore=leftScore+1;
       }
  }
}
void keyPressed() {
  
  if(nameEnter==0) //not entering names
  {
    if ((keyPressed == true) && (key == 'l')) //sets the toggle
    {  
      toggle *= -1;
    }
    else if ((keyPressed == true) && (key == 'r')) //reset game
    {  
      endGame=false;
      leftScore=0;
      rightScore=0;
      ballX=500;
      ballY=500;
    }
    else if ((keyPressed == true) && (key == 'o')) //saves leader board and closes the game
    {
      String[] saveTemp= new String[leaderScores.length];
      for(int i=0;i<saveTemp.length;i++)
      {
        saveTemp[i]=Integer.toString(leaderScores[i]);  
      }
      saveStrings("names.txt",leaderNames);
      saveStrings("scores.txt",saveTemp);
      myServer.stop();
      exit();
    }
  }
  else //entering team names
  {
    if(nameEnter==1)
    {
      if (keyCode == BACKSPACE) {
        if (leftName.length() > 0) {
          leftName = leftName.substring(0, leftName.length()-1);
        }
      } 
      else if (keyCode == DELETE) {
        leftName = "";
      } 
      else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT && keyCode!= ENTER) {
        leftName = leftName + key;
      }
    }
    else if(nameEnter==2)
    {
      if (keyCode == BACKSPACE) {
        if (rightName.length() > 0) {
          rightName = rightName.substring(0, rightName.length()-1);
        }
      } 
      else if (keyCode == DELETE) {
        rightName = "";
      } 
      else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT && keyCode!= ENTER) {
        rightName = rightName + key;
      }
    }
  }
  if ((keyPressed == true) && (key == '=') && toggle<0) //switches name enter mode
  {
    if(nameEnter==1)//the '=' to switch screens is added to the string so remove it
    {
      if (leftName.length() > 0) 
      {
        leftName = leftName.substring(0, leftName.length()-1);
      }
    }
    else if (nameEnter==2)
    {
      if (rightName.length() > 0) 
      {
        rightName = rightName.substring(0, rightName.length()-1);
      }
    }
    nameEnter++;
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