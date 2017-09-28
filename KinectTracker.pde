

class KinectTracker {
  
//  boolean handTrackFlag = false;
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

float[] angles = new float[9];

boolean       autoCalib=true;

//float scaledX;
//float scaledY;
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
//  println(scaledX);
//  println(kinect.depthWidth());
}  



void display(){
 kinect.update();
 kinect.convertRealWorldToProjective(handVec,mapHandVec); 
 println(mapHandVec.x);
 image(kinect.depthImage(), 0, 0, width, height);
 strokeWeight(10);
 stroke(handPointCol);
 if(handTrackFlag == true){
 point(mapHandVec.x * scaledX, mapHandVec.y * scaledY);
 }
  // draw the skeleton if it's available
  int[] userList = kinect.getUsers();
  for(int i=0;i<userList.length;i++)
  {
    if(kinect.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);
  }    
  
  if (kinect.isTrackingSkeleton(1)) {
    updateAngles();
    println(angles[1]);
    drawSkeleton(1);
}
 
 
  
}

float angle(PVector a, PVector b, PVector c) {
float angle01 = atan2(a.y - b.y, a.x - b.x);
float angle02 = atan2(b.y - c.y, b.x - c.x);
float ang = angle02 - angle01;
return ang;
}

void updateAngles() {
// Left Arm
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HAND, lHand);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_ELBOW, lElbow);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_SHOULDER, lShoulder);
// Left Leg
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_FOOT, lFoot);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_KNEE, lKnee);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_LEFT_HIP, lHip);
// Right Arm
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_HAND, rHand);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_ELBOW, rElbow);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_SHOULDER, rShoulder);
// Right Leg
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_FOOT, rFoot);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_KNEE, rKnee);
kinect.getJointPositionSkeleton(1,SimpleOpenNI.SKEL_RIGHT_HIP, rHip);


angles[0] = atan2(PVector.sub(rShoulder, lShoulder).z,
PVector.sub(rShoulder, lShoulder).x);

kinect.convertRealWorldToProjective(rFoot, rFoot);
kinect.convertRealWorldToProjective(rKnee, rKnee);
kinect.convertRealWorldToProjective(rHip, rHip);
kinect.convertRealWorldToProjective(lFoot, lFoot);
kinect.convertRealWorldToProjective(lKnee, lKnee);
kinect.convertRealWorldToProjective(lHip, lHip);
kinect.convertRealWorldToProjective(lHand, lHand);
kinect.convertRealWorldToProjective(lElbow, lElbow);
kinect.convertRealWorldToProjective(lShoulder, lShoulder);
kinect.convertRealWorldToProjective(rHand, rHand);
kinect.convertRealWorldToProjective(rElbow, rElbow);
kinect.convertRealWorldToProjective(rShoulder, rShoulder);

// Left-Side Angles
angles[1] = angle(lShoulder, lElbow, lHand);
angles[2] = angle(rShoulder, lShoulder, lElbow);
angles[3] = angle(lHip, lKnee, lFoot);
angles[4] = angle(new PVector(lHip.x, 0), lHip, lKnee);
// Right-Side Angles
angles[5] = angle(rHand, rElbow, rShoulder);
angles[6] = angle(rElbow, rShoulder, lShoulder );
angles[7] = angle(rFoot, rKnee, rHip);
angles[8] = angle(rKnee, rHip, new PVector(rHip.x, 0));
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */
  
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

  
}
