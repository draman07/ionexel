class BonhommeAlumette {
  
  BonhommeAlumette() {
    
  }
  
  void dessine(int[] users) {
    for (int i=0; i<users.length; i++) {
      if (context.isTrackingSkeleton(users[i])) {
            drawSkeletonAlumette(users[i]);
      }  
    }
  }
  
  private void drawSkeletonAlumette(int userId)
  {
    canvas.stroke(255, 255, 255, 255);
    canvas.strokeWeight(3);
    
    canvas.noFill();
    canvas.beginShape();
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    drawJoint(userId, SimpleOpenNI.SKEL_NECK);
    drawJoint(userId, SimpleOpenNI.SKEL_NECK);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
    canvas.endShape();
    
    canvas.beginShape();
    drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
    drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
    drawJoint(userId, SimpleOpenNI.SKEL_NECK);
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
    canvas.endShape();
    
    canvas.beginShape();
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
    canvas.endShape();    
  }
  
  private void drawJoint(int userId, int jointType)
  {
      float  confidence;
  
      // draw the joint position
      PVector a_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointType, a_3d);
      
      PVector a_2d = new PVector();
      context.convertRealWorldToProjective(a_3d, a_2d);
      
      canvas.curveVertex(a_2d.x, a_2d.y);
  }
  
}


  
  
