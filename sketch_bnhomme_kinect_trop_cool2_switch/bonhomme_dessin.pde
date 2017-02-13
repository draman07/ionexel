class BonhommeDessin {
  
  BonhommeDessin() {
    
  }
  
  void dessine(int[] users) {
    background(235,215,182);
    //h.setFillGap(50);
    h.setOverrideFillColour(true);
  h.setOverrideStrokeColour(true);
  h.setBackgroundColour(color(0));
  h.setFillColour(0);
  h.setStrokeColour(color(255));
  h.setSeed(1234);
  
  //h.rect(75,50,150,100);
    for (int i=0; i<users.length; i++) {
      if (context.isTrackingSkeleton(users[i])) {
            drawSkeletonHandy(users[i]);
            pushMatrix();
            translate(width/4, height/4);
            rotate(PI/3.0);
            scale(0.5, 1.3);
            drawSkeletonHandy(users[i]);
            
            popMatrix();
      }  
    }
  }
  
  // draw the skeleton with the selected joints
  private void drawSkeletonHandy(int userId)
  {
      canvas.stroke(255, 255, 255, 255);
      canvas.strokeWeight(5);
  
      
      canvas.noFill();
      h.setRoughness(3);
      h.setFillWeight(0);
      h.setHachurePerturbationAngle(50);
      h.beginShape();
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      //drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      //drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      drawJointH(userId, SimpleOpenNI.SKEL_HEAD);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_HAND);
      drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      
      h.endShape();
      
      h.beginShape();
      //drawJointH(userId, SimpleOpenNI.SKEL_HEAD);
      //drawJointH(userId, SimpleOpenNI.SKEL_HEAD);
      drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      //drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_HIP);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
      //drawJointH(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
      //h.endShape();
      
      //h.beginShape();
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
      drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      //drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      //drawJointH(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
      h.endShape();
      
      
  }

  private void drawJointH(int userId, int jointType)
  {
      float  confidence;
  
      // draw the joint position
      PVector a_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointType, a_3d);
      
      PVector a_2d = new PVector();
      context.convertRealWorldToProjective(a_3d, a_2d);
      
      h.vertex(a_2d.x, a_2d.y);
  }

  private void drawLimbH(int userId, int jointType1, int jointType2)
  {
      float  confidence;
  
      // draw the joint position
      PVector a_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointType1, a_3d);
      PVector b_3d = new PVector();
      confidence = context.getJointPositionSkeleton(userId, jointType2, b_3d);
  
      PVector a_2d = new PVector();
      context.convertRealWorldToProjective(a_3d, a_2d);
      PVector b_2d = new PVector();
      context.convertRealWorldToProjective(b_3d, b_2d);
  
      h.line(a_2d.x, a_2d.y, b_2d.x, b_2d.y);
  }
 
}


  
  

