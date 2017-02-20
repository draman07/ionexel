class DessinPolygone {
  
  int[] userMap;
  
  DessinPolygone() {
    
  }
  
  void dessine() {
    // fading background : fill with 65% opacity
    //noStroke();
    canvas.fill(0, 65);
    canvas.rect(0, 0, width, height);
    
    // put the image into a PImage
    //resultImage = context.depthImage();
    userMap = context.userMap();
    //resultImage = loadPixels();
    for (int pic = 0; pic<userMap.length; pic ++) {
     if (userMap[pic] > 0) {
      resultImage.pixels[pic] = color(255);
     } else {
      resultImage.pixels[pic] = color(0); 
     }
    }
    resultImage.updatePixels();
    
    // copy the image into the smaller blob image
    blobs.copy(resultImage, 0, 0, resultImage.width, resultImage.height, 0, 0, blobs.width, blobs.height);
    // blur the blob image
    //blobs.filter(THRESHOLD, 0.7);
    blobs.filter(BLUR);
    // detect the blobs
    theBlobDetection.computeBlobs(blobs.pixels);
    // clear the polygon (original functionality)
    poly.reset();
    // create the polygon from the blobs (custom functionality, see class)
    poly.createPolygon();
    if (dflux) {
      drawFlowfield();
    }
    
    h.setRoughness(3);
      h.setFillWeight(2);
      h.setFillGap(5);
    h.setOverrideFillColour(true);
  h.setOverrideStrokeColour(true);
  h.setBackgroundColour(color(0));
  h.setFillColour(color(255));
  h.setStrokeColour(color(255));
  h.setSeed(1234);
      
      
    if (poly.npoints>1) {
      h.beginShape();
      for (int i=0; i<poly.npoints; i++) {
        //canvas.line(poly.xpoints[i-1], poly.ypoints[i-1], poly.xpoints[i], poly.ypoints[i]);
        h.vertex(poly.xpoints[i], poly.ypoints[i]);
      }
      h.endShape();
    }
     
     
    //canvas.image(resultImage, 0, 0);
  }
  
  
 
}
