int x = 500;
int y = 300;
float x_vel = 2;
float y_vel = 2;
int theta = 0;
int ballXSpeed=2;
int ballYSpeed=2;
int ballX=100;
int ballY=500;
int ballS=10; //ball size

boolean angle =false;

boolean hit = false;
boolean hit2 = false;
int rheight = 100;
int rwidth = 33;
int lowX;
int lowY;

int x2 = 50;
int y2 = 300;
int r_highX;
int r_highY;
int r_lowX;
int r_lowY;

int lowX2;
int lowY2;

int r_highX2;
int r_highY2;
int r_lowX2;
int r_lowY2;
int theta2 = 0;

void setup()
{
  size(600, 600);
  background(255);
  smooth();
  fill(192);
  noStroke();
  frameRate(20);
}

void draw() {
 background(255);
  ellipseMode(CENTER);
  fill(192);
  noStroke();
  //rect(x, y, rwidth, rheight);
  
  pushMatrix();
  // move the origin to the pivot point
  translate(x, y); 
  
  // then pivot the grid
  rotate(radians(theta));
  
  // and draw the square at the origin
  //fill(0);
   fill(0,0,255);
  rect(0, 0, rwidth, (rheight));
  popMatrix();

  lowX = (int)((x) + (rheight * -cos(radians(90-theta))));
  lowY= (int)((y) + (rheight * sin(radians(90-theta))));

  r_highX = (int)((x) + (rwidth * cos(radians(theta))));
  r_highY= (int)((y) + (rwidth * sin(radians(theta))));

  r_lowX = (int)(sin(radians(theta)) * (rheight*sin(radians(90))));
  r_lowY= (int)(-cos(radians(theta)) * (rheight*sin(radians(90))));

  fill(0,255,0);
  //top left
  ellipse(x,y,ballS,ballS);
  //bottom left
  ellipse(lowX,lowY,ballS,ballS);
  //top right
  ellipse(r_highX,r_highY,ballS,ballS);
  //bottom right
  ellipse(r_highX - r_lowX,-r_lowY + r_highY,ballS,ballS);

  fill(0);
  ellipse(ballX,ballY,ballS,ballS);
  ballX+=ballXSpeed;
  ballY+=ballYSpeed;
    if(ballX>width-ballS/2) //stay in bounds in X
  {
     ballXSpeed=-ballXSpeed;
     hit2 = false;
  }
  else if(ballX<ballS/2)
  {
     ballXSpeed=-ballXSpeed;
     hit = false;
  }
  
  if(ballY>height-ballS/2) //stay in bounds in Y
  {
     ballYSpeed=-ballYSpeed; 
  }
  else if(ballY<ballS/2)
  {
     ballYSpeed=-ballYSpeed;
  }
  
  
     fill(192);
  noStroke();
  //rect(x2, y2, rwidth, rheight);
  
  pushMatrix();
  // move the origin to the pivot point
  translate(x2, y2); 
  
  // then pivot the grid
  rotate(radians(theta2));
  
  // and draw the square at the origin
  //fill(0);
   fill(#0000FF);
  rect(0, 0, rwidth, (rheight));
  popMatrix();

  lowX2 = (int)((x2) + (rheight * -cos(radians(90-theta2))));
  lowY2= (int)((y2) + (rheight * sin(radians(90-theta2))));

  r_highX2 = (int)((x2) + (rwidth * cos(radians(theta2))));
  r_highY2= (int)((y2) + (rwidth * sin(radians(theta2))));
  //top line
 // line(r_highX,r_highY, x,y);
  r_lowX2 = (int)(sin(radians(theta2)) * (rheight*sin(radians(90))));
  r_lowY2= (int)(-cos(radians(theta2)) * (rheight*sin(radians(90))));

  fill(0,255,0);
  //top left
  ellipse(x2,y2,ballS,ballS);
  //bottom left
  ellipse(lowX2,lowY2,ballS,ballS);
  //top right
  ellipse(r_highX2,r_highY2,ballS,ballS);
  //bottom right
  ellipse(r_highX2 - r_lowX2,-r_lowY2 + r_highY2,ballS,ballS);
  y2= mouseY;
  x2= mouseX;
  //theta2--;
  if(checkIntersection(x,y, lowX, lowY, ballX,ballY, ballS) && !hit){
    ballXSpeed *=-1;
    hit = true;
    hit2=false;
    if(theta != 0 && ((theta < 0 && ballYSpeed < 0) || (theta > 0 && ballYSpeed > 0)))
      ballYSpeed *= -1;
  }
  if(checkIntersection(r_highX2,r_highY2, r_highX2 - r_lowX2,-r_lowY2 + r_highY2, ballX,ballY, ballS) && !hit2){
    ballXSpeed *=-1;
    hit2 = true;
    hit = false;
    if(theta != 0 && ((theta > 0 && ballYSpeed < 0) || (theta < 0 && ballYSpeed > 0)))
      ballYSpeed *= -1;
  }
  if(!angle){
    theta++;
    theta2--;
    angle = theta == 45;
  }
  else{
    theta--;
    theta2++;
    angle = !(theta == -45);
  }
}


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
  fill(#FF0000);
  ellipse(ix1, iy1, 5, 5);
  ellipse(ix2, iy2, 5, 5);
 
  // Figure out which point is closer to the circle
  boolean test = dist(x1, y1, cx, cy) < dist(x2, y2, cx, cy);
 
  float closerX = test? x2:x1;
  float closerY = test? y2:y1;
 
  return dist(closerX, closerY, ix1, iy1) < dist(x1, y1, x2, y2) || 
    dist(closerX, closerY, ix2, iy2) < dist(x1, y1, x2, y2);
}