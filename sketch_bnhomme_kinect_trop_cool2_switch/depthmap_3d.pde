class DepthMap3D {
  
  DepthMap3D() {
    
  }
  
  void dessine() {
    canvas.background(0,0,0);

    canvas.translate(width/2, height/2, 0);
    canvas.rotateX(rotX);
    canvas.rotateY(rotY);
    canvas.scale(zoomF);
  
    int[]   depthMap = context.depthMap();
    int     steps   = 4;  // to speed up the drawing, draw every third point
    int     index;
    PVector realWorldPoint;
   
    canvas.translate(0,0,-1000);  // set the rotation center of the scene 1000 infront of the camera
  
    canvas.stroke(255);
  
    PVector[] realWorldMap = context.depthMapRealWorld();
    
    // draw pointcloud
    canvas.beginShape(POINTS);
    for(int y=0;y < context.depthHeight();y+=steps)
    {
      for(int x=0;x < context.depthWidth();x+=steps)
      {
        index = x + y * context.depthWidth();
        if(depthMap[index] > 0)
        { 
          // draw the projected point
  //        realWorldPoint = context.depthMapRealWorld()[index];
          realWorldPoint = realWorldMap[index];
          canvas.vertex(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);  // make realworld z negative, in the 3d drawing coordsystem +z points in the direction of the eye
        }
        //println("x: " + x + " y: " + y);
      }
    } 
    canvas.endShape();
    
    // draw the kinect cam
    //context.drawCamFrustum();
  }
}

