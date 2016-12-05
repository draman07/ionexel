class BonhommeDessin {
  
  BonhommeDessin() {
    
  }
  
  void dessine(int[] users) {
    for (int i=0; i<users.length; i++) {
      if (context.isTrackingSkeleton(users[i])) {
            drawSkeletonAlumette(users[i]);
      }  
    }
  }
  
  // draw the skeleton with the selected joints
  private void drawSkeletonHandy(int userId)
  {
      canvas.stroke(255, 255, 255, 255);
      canvas.strokeWeight(3);
  
      
      canvas.noFill();
      h.setRoughness(3);
      h.setFillWeight(2);
      h.beginShape();
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
      drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_HAND);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_HAND);
      h.endShape();
      
      h.beginShape();
      drawJointH(userId, SimpleOpenNI.SKEL_HEAD);
      drawJointH(userId, SimpleOpenNI.SKEL_HEAD);
      drawJointH(userId, SimpleOpenNI.SKEL_NECK);
      drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_HIP);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
      drawJointH(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
      h.endShape();
      
      h.beginShape();
      drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      drawJointH(userId, SimpleOpenNI.SKEL_TORSO);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
      drawJointH(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
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


  
  

