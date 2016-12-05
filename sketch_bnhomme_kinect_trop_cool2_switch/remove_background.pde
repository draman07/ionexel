class RemoveBackground {
  
  int[] userMap;
  
  RemoveBackground() {
    
  }
  
  void dessine() {
    //ask kinect for bitmap of user pixels
    loadPixels();
    userMap = context.userMap();
    for (int i =0; i < userMap.length; i++) {
      // if the pixel is part of the user
      if (userMap[i] != 0) {
        // set the pixel to the color pixel
        resultImage.pixels[i] = color(255,255,255);//rgbImage.pixels[i];
      }
      else {
        //set it to the background
        resultImage.pixels[i] = color (0, 0, 0);//backgroundImage.pixels[i];
      }
    }
    
    //update the pixel from the inner array to image
     resultImage.updatePixels();
     
     //copy the image in a smaller blob image
     /*blobs.copy(resultImage, 0, 0, resultImage.width, resultImage.height, 0, 0, blobs.width, blobs.height);
     
     bs.imageFindBlobs(blobs);
     bs.loadBlobsFeatures();
   
     //For each blob
     for (int i = 0; i < bs.getBlobsNumber (); i++) {
   
       //gets the edge's pixels coordinates  
       edge  = bs.getEdgePoints(i);
       if (edge.length < 100) {
        continue;
       } 
       canvas.stroke(0, 255, 0); 
         
       for (int k = 0; k < edge .length; k++) {
         canvas.point(edge[k] .x*3, edge[k] .y*3 );
       }
       //and sends to the std. output an ok. 
       println("Tile " + (i+1) + " size " + edge .length +" --OK");
   
     }*/
    canvas.image(resultImage, 0, 0);
  }
  
  
 
}

