

class KinectTracker {
  

int oneTime = 0;
float prevAngle = 0;
float diffAngle = 0;
  // Left Arm Vectors
PVector lHand = new PVector();
PVector lElbow = new PVector();
PVector lShoulder = new PVector();
// Left Leg Vectors
PVector lFoot = new PVector();
PVector lKnee = new PVector();
PVector lHip = new PVector();
// Right Arm Vectors
PVector rHand = new PVector();
PVector rElbow = new PVector();
PVector rShoulder = new PVector();
// Right Leg Vectors
PVector rFoot = new PVector();
PVector rKnee = new PVector();
PVector rHip = new PVector();



boolean       autoCalib=true;

float halfX;
float halfY;
 KinectTracker() {

  kinect.setMirror(true);
 // enable depthMap generation, hands and gestures
 kinect.enableDepth();
 kinect.enableGesture();
 kinect.enableHands();
   kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);

 // add focus gesture to initialise tracking
 kinect.addGesture("Wave");

scaledX = (float)width/kinect.depthWidth();
  scaledY = (float)height/kinect.depthHeight();
  halfX = (float)width/2;
  halfY = (float)height/2;

}  



void display(){
 kinect.update();
 kinect.convertRealWorldToProjective(handVec,mapHandVec); 
 if(!handTrackFlag)
   image(kinect.depthImage(), 0, 0, width, height);
 else
  background(0,0,0);
  
 strokeWeight(30);
 stroke(255,0,0);
 if(handTrackFlag == true){
 point(mapHandVec.x * scaledX, mapHandVec.y * scaledY);
 }
 strokeWeight(10);
 stroke(0,255,0);
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++)
  {

  }    
  
  if (kinect.isTrackingSkeleton(1)) {
    prevAngle = angles[1];

    updateAngles();
    
    drawSkeleton(1);
}
 
 
  
}

float angle(PVector a, PVector b, PVector c) {
float angle01 = atan2(a.y - b.y, a.x - b.x);
float angle02 = atan2(b.y - c.y, b.x - c.x);
float ang = angle02 - angle01;
return ang;
}

float angle(PVector a,PVector b) {
 // angle of left hand to left shoulder
 float angle01 = atan2(a.x - rShoulder.x, rShoulder.y - a.y);
 float deg = (float)(angle01 * (180 / Math.PI));
 return deg; 
}

void updateAngles() {
// Left Arm
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HAND, lHand);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_ELBOW, lElbow);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_SHOULDER, lShoulder);

// Right Arm
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_HAND, rHand);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_ELBOW, rElbow);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_SHOULDER, rShoulder);



angles[0] = atan2(PVector.sub(rShoulder, lShoulder).z,
PVector.sub(rShoulder, lShoulder).x);


kinect.convertRealWorldToProjective(lHand, lHand);
kinect.convertRealWorldToProjective(lElbow, lElbow);
kinect.convertRealWorldToProjective(lShoulder, lShoulder);
kinect.convertRealWorldToProjective(rHand, rHand);
kinect.convertRealWorldToProjective(rElbow, rElbow);


kinect.convertRealWorldToProjective(rShoulder, rShoulder);


// Left-Side Angles
angles[1] = angle(lShoulder, lElbow, lHand);
angles[2] = angle(rShoulder, lShoulder, lElbow);

// Right-Side Angles
angles[5] = angle(rHand, rElbow, rShoulder);

angles[6] = angle(rHand, rHand);

}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
 
//  println(SimpleOpenNI.SKEL_HEAD);
  drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  
  
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  
  
}

void drawLimb(int userId, int jointType1, int jointType2)
{
  PVector jointPos1 = new PVector();
  PVector jointPos2 = new PVector();
  float  confidence;
 
  // draw the joint position
  confidence = kinect.getJointPositionSkeleton(userId, jointType1, jointPos1);
  confidence = kinect.getJointPositionSkeleton(userId, jointType2, jointPos2);
 

  // invert the y values and offset by height/2 and width/2 
  line(jointPos1.x +halfX, (height - jointPos1.y) - halfY, jointPos2.x + halfX, (height - jointPos2.y) - halfY);

}

  
}
