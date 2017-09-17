/* --------------------------------------------------------------------------
 * SimpleOpenNI NITE Hands
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / zhdk / http://iad.zhdk.ch/
 * date:  03/19/2011 (m/d/y)
 * ----------------------------------------------------------------------------
 * This example works with multiple hands, to enable mutliple hand change
 * the ini file in /usr/etc/primesense/XnVHandGenerator/Nite.ini:
 *  [HandTrackerManager]
 *  AllowMultipleHands=1
 *  TrackAdditionalHands=1
 * on Windows you can find the file at:
 *  C:\Program Files (x86)\Prime Sense\NITE\Hands\Data\Nite.ini
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;
import java.util.*;

float initialX = 0;
int paddleSpeed=15;
int rightPadY=0;
int rightPadX=0;//changed in setup
int leftPadY=0;
float leftPadX=0;
int paddleH=100;
int paddleW=33;
int ballS=50; //ball size
int ballXSpeed=5;
int ballYSpeed=5;
float ballX=500;
int ballY=500;
int leftScore=0;
int rightScore=0;
boolean onlyOnce = true;

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


SimpleOpenNI      context;

// NITE
XnVSessionManager sessionManager;
XnVFlowRouter     flowRouter;

PointDrawer       pointDrawer;

void setup()
{
   size(600,600); 
  context = new SimpleOpenNI(this);
   
   fill(0); //fill shapes in black
  textSize(64);
  rightPadX=(width)-paddleW;
  println(width);
   
  // mirror is by default enabled
  context.setMirror(true);
  
  // enable depthMap generation 
  if(context.enableDepth() == false)
  {
     println("Can't open the depthMap, maybe the camera is not connected!"); 
     exit();
     return;
  }
  
  // enable the hands + gesture
  context.enableGesture();
  context.enableHands();
 
  // setup NITE 
  sessionManager = context.createSessionManager("Wave", "RaiseHand");

  pointDrawer = new PointDrawer();
  flowRouter = new XnVFlowRouter();
  flowRouter.SetActive(pointDrawer);
  
  sessionManager.AddListener(flowRouter);
           
  
  smooth();
}

void draw()
{
  background(255);
  // update the cam
  context.update();
  
  // update nite
  context.update(sessionManager);
  
  // draw depthImageMap
  image(context.depthImage(),0,0);
  
  // draw the list
  pointDrawer.draw();
  
  
  
  
}
  

void keyPressed()
{
  switch(key)
  {
  case 'e':
    // end sessions
    sessionManager.EndSession();
    println("end session");
    break;
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
// session callbacks

void onStartSession(PVector pos)
{
  println("onStartSession: " + pos);
}

void onEndSession()
{
  println("onEndSession: ");
}

void onFocusSession(String strFocus,PVector pos,float progress)
{
  println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress);
}


/////////////////////////////////////////////////////////////////////////////////////////////////////
// PointDrawer keeps track of the handpoints

class PointDrawer extends XnVPointControl
{
  HashMap    _pointLists;
  int        _maxPoints;
  color[]    _colorList = { color(255,0,0),color(0,255,0),color(0,0,255),color(255,255,0)};
  
  public PointDrawer()
  {
    _maxPoints = 30;
    _pointLists = new HashMap();
  }
	
  public void OnPointCreate(XnVHandPointContext cxt)
  {
    // create a new list
    addPoint(cxt.getNID(),new PVector(cxt.getPtPosition().getX(),cxt.getPtPosition().getY(),cxt.getPtPosition().getZ()));
    
    println("OnPointCreate, handId: " + cxt.getNID());
  }
  
  public void OnPointUpdate(XnVHandPointContext cxt)
  {
    //println("OnPointUpdate " + cxt.getPtPosition());   
    addPoint(cxt.getNID(),new PVector(cxt.getPtPosition().getX(),cxt.getPtPosition().getY(),cxt.getPtPosition().getZ()));
  }
  
  public void OnPointDestroy(long nID)
  {
    println("OnPointDestroy, handId: " + nID);
    
    // remove list
    if(_pointLists.containsKey(nID))
       _pointLists.remove(nID);
  }
  
  public ArrayList getPointList(long handId)
  {
    ArrayList curList;
    if(_pointLists.containsKey(handId))
      curList = (ArrayList)_pointLists.get(handId);
    else
    {
      curList = new ArrayList(_maxPoints);
      _pointLists.put(handId,curList);
    }
    return curList;  
  }
  
  public void addPoint(long handId,PVector handPoint)
  {
    ArrayList curList = getPointList(handId);
    
    curList.add(0,handPoint);      
    if(curList.size() > _maxPoints)
      curList.remove(curList.size() - 1);
  }
  
  public void draw()
  {
//    if(_pointLists.size() <= 0)
//      return;
      
    pushStyle();
      noFill();
      
      PVector vec;
      PVector firstVec;
      PVector screenPos = new PVector();
      int colorIndex=0;
      strokeWeight(8);
      stroke(_colorList[colorIndex % (_colorList.length - 1)]);
      // draw the hand lists
      Iterator<Map.Entry> itrList = _pointLists.entrySet().iterator();
      while(itrList.hasNext()) 
      {
//        strokeWeight(2);
//        stroke(_colorList[colorIndex % (_colorList.length - 1)]);

        ArrayList curList = (ArrayList)itrList.next().getValue();     
        
        // draw line
        firstVec = null;
        Iterator<PVector> itr = curList.iterator();
        beginShape();
          while (itr.hasNext()) 
          {
            vec = itr.next();
            if(firstVec == null)
              firstVec = vec;
            // calc the screen pos
            context.convertRealWorldToProjective(vec,screenPos);
            vertex(screenPos.x,screenPos.y); 
              
          } 
        endShape();   
  
        // draw current pos of the hand
        if(firstVec != null)
        {
          strokeWeight(8);
          context.convertRealWorldToProjective(firstVec,screenPos);
          point(screenPos.x,screenPos.y);
        }
        colorIndex++;
      }
      fill(0, 102, 153);
      text(leftScore, 50, 60);
      fill(0, 102, 153);
  text(rightScore, width-paddleH, 60);
  ellipseMode(CENTER);
  leftPadY=mouseY;
  
  
  if(onlyOnce ==true && screenPos.x > 0){
    initialX = screenPos.x;
    println(initialX);
    onlyOnce = false;
  }
  leftPadX = (screenPos.x - initialX);
  
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
  
  rect(rightPadX,rightPadY,paddleW,paddleH);
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
    if(rightPadY<height-paddleH)
    {
      rightPadY+=paddleSpeed; //go down
    }
    else
    {
      rightPadY=height-paddleH; //can't go bellow screen
    }
  }
  
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
  
  
  if ((keyPressed == true) && (key == 'o')) //closes the game
  {
    exit();
  }
    popStyle();
  }
  
  

}
