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
    boolean noNeck = (userId%2 == nbSwitches%2);
    
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
    if (!noNeck) {
      drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
      drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
    } else {
      drawJoint(userId, SimpleOpenNI.SKEL_NECK);
    }
    drawJoint(userId, SimpleOpenNI.SKEL_NECK);
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawBetweenJoints(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawBetweenJoints(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
    //drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
    drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
    canvas.endShape();
    
    canvas.beginShape();
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
    drawBetweenJoints(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawBetweenJoints(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_HIP);
    //drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
    drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
    canvas.endShape();
    
    canvas.beginShape();
    drawHead(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK, noNeck);
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
  
  private void drawBetweenJoints(int userId, int jointTypeA, int jointTypeB)
  {
      float  confidence;
  
      // draw the joint position
      PVector a_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointTypeA, a_3d);
      PVector b_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointTypeB, b_3d);
      
      PVector a_2d = new PVector();
      context.convertRealWorldToProjective(a_3d, a_2d);
      PVector b_2d = new PVector();
      context.convertRealWorldToProjective(b_3d, b_2d);
      
      PVector between = new PVector();
      between = a_2d;
      between.add(b_2d);
      between.div(2);
      
      canvas.curveVertex(between.x, between.y);
  }
  
  private void drawHead(int userId, int head, int neck, boolean noNeck)
  {
      float  confidence;
  
      // draw the joint position
      PVector a_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, head, a_3d);
      PVector b_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, neck, b_3d);
      
      PVector a_2d = new PVector();
      context.convertRealWorldToProjective(a_3d, a_2d);
      PVector b_2d = new PVector();
      context.convertRealWorldToProjective(b_3d, b_2d);
      
      PVector between = new PVector();
      between = PVector.sub(a_2d,b_2d);
      //between.sub(b_2d);
      
      PVector cg = new PVector();
      cg = PVector.add(a_2d, between);
      //cg.add(between);
      PVector vcg = new PVector();
      vcg.set(between);
      vcg.rotate(HALF_PI);
      
      cg.add(PVector.div(vcg, 2));
      
      PVector cd = new PVector();
      cd = PVector.sub(cg, vcg);
      //cd.sub(vcg);
      //canvas.stroke(255, 0, 0, 255);
      if (noNeck) {
        a_2d.add(between);
        cd.sub(between);
        cg.sub(between);
      }
      canvas.triangle(a_2d.x, a_2d.y, cd.x, cd.y, cg.x, cg.y);
      
      
  }
  
}


  
  

