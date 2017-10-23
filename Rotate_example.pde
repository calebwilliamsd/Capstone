int x = 500;
int y = 300;

int theta = 0;

int ballXSpeed=2;
int ballYSpeed=2;
int ballX=100;
int ballY=500;
int ballS=10; //ball size

int rheight = 100;
int rwidth = 33;
int l_hx;
int l_hy;
int lowX;
int lowY;
int r_highX;
int r_highY;
int r_lowX;
int r_lowY;

float dia;

void setup()
{
  size(600, 600);
  background(255);
  smooth();
  fill(192);
  noStroke();
  frameRate(20);
  dia = sqrt(((rheight/2)*(rheight/2)) + ((rwidth/2)*(rwidth/2)));
}

void draw() {
 background(255);
  ellipseMode(CENTER);
  fill(192);
  noStroke();
  //rect(x, y, rwidth, rheight);
  
  pushMatrix();
  // move the origin to the pivot point
  translate(x + rwidth/2, y + rheight/2); 
  
  // then pivot the grid
  rotate(radians(theta));
  
  // and draw the square at the origin
  //fill(0);
   fill(0,0,255);
  rect(-rwidth/2, -rheight/2, rwidth, (rheight));
  popMatrix();
  float dia_theta =  90 - degrees(acos((rheight/2)/dia));
  //green
  l_hx =(int)( x+rwidth/2 +(dia * -cos(radians(-theta-dia_theta))));
  l_hy = (int)(y+rheight/2 +(dia * sin(radians(-theta-dia_theta))));
  
  //yellow
  lowX = (int)( x+rwidth/2 +(dia * -cos(radians(theta-dia_theta))));
  lowY= (int)(y+rheight/2 +(dia * -sin(radians(theta-dia_theta))));
  
  //magenta
  r_highX = (int)( x+rwidth/2 +(dia * cos(radians(theta-dia_theta))));
  r_highY= (int)(y+rheight/2 +(dia * sin(radians(theta-dia_theta))));
  
  //brown
  r_lowX = (int)(x+rwidth/2 +(dia * cos(radians(-theta-dia_theta))));
  r_lowY= (int)(y+rheight/2 +(dia * -sin(radians(-theta-dia_theta))));

  theta++;
  fill(0,255,0);
  //center
  ellipse(x+rwidth/2,y+rheight/2,ballS,ballS);
  
  //top left
  ellipse(l_hx,l_hy,ballS,ballS);
  fill(0,255,255);
  //bottom left
   fill(255,255,0);
  ellipse(lowX,lowY,ballS,ballS);
  //top right
  fill(255,0,255);
  ellipse(r_highX,r_highY,ballS,ballS);
  fill(90,50,60);
  //bottom right
  ellipse(r_lowX,r_lowY,ballS,ballS);
  y = mouseY -rheight/2;
  x = mouseX - rwidth/2;
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