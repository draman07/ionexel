

/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */
import processing.opengl.*; // opengl
import SimpleOpenNI.*;
/* handy : librairie pour donner une impression de dessin "naturel"
//http://www.gicentre.net/handy/using
*/
import org.gicentre.handy.*;
HandyRenderer h;

PGraphics    canvas;
color[]      userClr = new color[]
{
    color(255, 0, 0), 
    color(0, 255, 0), 
    color(0, 0, 255), 
    color(255, 255, 0), 
    color(255, 0, 255), 
    color(0, 255, 255)
};

//center of mass
PVector com = new PVector();                                   
PVector com2d = new PVector();


// --------------------------------------------------------------------------------
//  CAMERA IMAGE SENT VIA SYPHON
// --------------------------------------------------------------------------------
int kCameraImage_RGB = 1;                // rgb camera image
int kCameraImage_IR = 2;                 // infra red camera image
int kCameraImage_Depth = 3;              // depth without colored bodies of tracked bodies
int kCameraImage_User = 4;               // depth image with colored bodies of tracked bodies

int kCameraImageMode = kCameraImage_Depth; // << Set the value to one of the kCamerImage constants above

// --------------------------------------------------------------------------------
//  SKELETON DRAWING
// --------------------------------------------------------------------------------
boolean kDrawSkeleton = true; // << set to true to draw skeleton, false to not draw the skeleton

// --------------------------------------------------------------------------------
//  OPENNI (KINECT) SUPPORT
// --------------------------------------------------------------------------------

import SimpleOpenNI.*;           // import SimpleOpenNI library

SimpleOpenNI     context;

private void setupOpenNI()
{
    context = new SimpleOpenNI(this);
    if (context.isInit() == false) {
        println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
        exit();
        return;
    }   

    // enable depthMap generation 
    context.enableDepth();
    context.enableUser();

    // disable mirror
    context.setMirror(false);
}

private void setupOpenNI_CameraImageMode()
{
    println("kCameraImageMode " + kCameraImageMode);

    switch (kCameraImageMode) {
    case 1: // kCameraImage_RGB:
        context.enableRGB();
        println("enable RGB");
        break;
    case 2: // kCameraImage_IR:
        context.enableIR();
        println("enable IR");
        break;
    case 3: // kCameraImage_Depth:
        context.enableDepth();
        println("enable Depth");
        break;
    case 4: // kCameraImage_User:
        context.enableUser();
        println("enable User");
        break;
    }
}

private void OpenNI_DrawCameraImage()
{
    switch (kCameraImageMode) {
    case 1: // kCameraImage_RGB:
        canvas.image(context.rgbImage(), 0, 0);
        // println("draw RGB");
        break;
    case 2: // kCameraImage_IR:
        canvas.image(context.irImage(), 0, 0);
        // println("draw IR");
        break;
    case 3: // kCameraImage_Depth:
        canvas.image(context.depthImage(), 0, 0);
        // println("draw DEPTH");
        break;
    case 4: // kCameraImage_User:
        canvas.image(context.userImage(), 0, 0);
        // println("draw DEPTH");
        break;
    }
}

// --------------------------------------------------------------------------------
//  OSC SUPPORT
// --------------------------------------------------------------------------------

import oscP5.*;                  // import OSC library
import netP5.*;                  // import net library for OSC

OscP5            oscP5;                     // OSC input/output object
NetAddress       oscDestinationAddress;     // the destination IP address - 127.0.0.1 to send locally
int              oscTransmitPort = 1234;    // OSC send target port; 1234 is default for Isadora
int              oscListenPort = 9000;      // OSC receive port number

private void setupOSC()
{
    // init OSC support, lisenting on port oscTransmitPort
    oscP5 = new OscP5(this, oscListenPort);
    oscDestinationAddress = new NetAddress("127.0.0.1", oscTransmitPort);
}

private void sendOSCSketchId(int index)
{
    // create the OSC message with target address
    OscMessage msg = new OscMessage("/sketch_id");

    // add the sketch id to the message
    msg.add(index);
    
    // send the message
    oscP5.send(msg, oscDestinationAddress);
}

private void sendOSC(boolean hasChanged)
{
    // create the OSC message with target address
    OscMessage msg = new OscMessage("/hasChanged");

    int message = (hasChanged)? 1 : 0;
    // add the flag to the message
    msg.add(message);
    
    // send the message
    oscP5.send(msg, oscDestinationAddress);
}


private void sendOSCSkeletonPosition(String inAddress, int inUserID, int inJointType)
{
    // create the OSC message with target address
    OscMessage msg = new OscMessage(inAddress);

    PVector p = new PVector();
    float confidence = context.getJointPositionSkeleton(inUserID, inJointType, p);

    // add the three vector coordinates to the message
    msg.add(p.x);
    msg.add(p.y);
    msg.add(p.z);

    // send the message
    oscP5.send(msg, oscDestinationAddress);
}

private void sendOSCSkeleton(int inUserID)
{
    sendOSCSkeletonPosition("/head", inUserID, SimpleOpenNI.SKEL_HEAD);
    sendOSCSkeletonPosition("/neck", inUserID, SimpleOpenNI.SKEL_NECK);
    sendOSCSkeletonPosition("/torso", inUserID, SimpleOpenNI.SKEL_TORSO);

    sendOSCSkeletonPosition("/left_shoulder", inUserID, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    sendOSCSkeletonPosition("/left_elbow", inUserID, SimpleOpenNI.SKEL_LEFT_ELBOW);
    sendOSCSkeletonPosition("/left_hand", inUserID, SimpleOpenNI.SKEL_LEFT_HAND);

    sendOSCSkeletonPosition("/right_shoulder", inUserID, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    sendOSCSkeletonPosition("/right_elbow", inUserID, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    sendOSCSkeletonPosition("/right_hand", inUserID, SimpleOpenNI.SKEL_RIGHT_HAND);

    sendOSCSkeletonPosition("/left_hip", inUserID, SimpleOpenNI.SKEL_LEFT_HIP);
    sendOSCSkeletonPosition("/left_knee", inUserID, SimpleOpenNI.SKEL_LEFT_KNEE);
    sendOSCSkeletonPosition("/left_foot", inUserID, SimpleOpenNI.SKEL_LEFT_FOOT);

    sendOSCSkeletonPosition("/right_hip", inUserID, SimpleOpenNI.SKEL_RIGHT_HIP);
    sendOSCSkeletonPosition("/right_knee", inUserID, SimpleOpenNI.SKEL_RIGHT_KNEE);
    sendOSCSkeletonPosition("/right_foot", inUserID, SimpleOpenNI.SKEL_RIGHT_FOOT);
    
    sendOSCSketchId(currentSketch);
}

// --------------------------------------------------------------------------------
//  SYPHON SUPPORT
// --------------------------------------------------------------------------------

import codeanticode.syphon.*;    // import syphon library

SyphonServer     server;     

private void setupSyphonServer(String inServerName)
{
    // Create syhpon server to send frames out.
    server = new SyphonServer(this, inServerName);
}

// --------------------------------------------------------------------------------
//  BLOB DETECTION
// from Kinect Flow Example by Amon Owed (15/09/12)
// --------------------------------------------------------------------------------
// this is a regular java import so we can use and extend the polygon class (see PolygonBlob)
import java.awt.Polygon;

import blobDetection.*;
// declare BlobDetection object
BlobDetection theBlobDetection;
// declare custom PolygonBlob object (see class for more info)
PolygonBlob poly = new PolygonBlob();

// PImage to hold incoming imagery and smaller one for blob detection
PImage blobs;
// the kinect's dimensions to be used later on for calculations
int kinectWidth = 640;
int kinectHeight = 480;
// to center and rescale from 640x480 to higher custom resolutions
float reScale;

// background color
color bgColor;
// three color palettes (artifact from me storing many interesting color palettes as strings in an external data file ;-)
String[] palettes = {
  "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634", 
  "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031", 
  "-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
};

// an array called flow of 2250 Particle objects (see Particle class)
Particle[] flow = new Particle[2250];
// global variables to influence the movement of all particles
float globalX, globalY;


// --------------------------------------------------------------------------------
//  EXIT HANDLER
// --------------------------------------------------------------------------------
// called on exit to gracefully shutdown the Syphon server
private void prepareExitHandler()
{
    Runtime.getRuntime().addShutdownHook(
    new Thread(
    new Runnable()
    {
        public void run () {
            try {
                if (server.hasClients()) {
                    server.stop();
                }
            } 
            catch (Exception ex) {
                ex.printStackTrace(); // not much else to do at this point
            }
        }
    }
    )
        );
}

//switch between sketches
int currentSketch = 0;
int nbSketches = 5;
int nbSwitches = 0;
boolean[] tooFar = new boolean[16]; //one for each user
boolean switchOverride = true;
boolean dflux = false;
PImage resultImage;
boolean isTransitioning = false;
int beginTransitioningFrameNumber = 0;
int switchFlux = 0;

BonhommeAlumette balum = new BonhommeAlumette();
BonhommeDessin bdessin = new BonhommeDessin();
RemoveBackground rbackground = new RemoveBackground();
DessinPolygone dpolygone = new DessinPolygone();
DepthMap3D depthmap = new DepthMap3D();

//Keep coordinates
ArrayList<ArrayList<PVector>> listeCoords = new ArrayList<ArrayList<PVector>>();
int usersBitSet = 0;
int activeUser = 0;
int nbUsers = 0;

//3dmap
float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);

// --------------------------------------------------------------------------------
//  MAIN PROGRAM
// --------------------------------------------------------------------------------
void setup()
{
    size(640, 480, OPENGL);
    canvas = createGraphics(640, 480, OPENGL);

    println("Setup Canvas");

    // canvas.background(200, 0, 0);
    canvas.stroke(0, 0, 255);
    canvas.strokeWeight(3);
    canvas.smooth();
    println("-- Canvas Setup Complete");

    // setup Syphon server
    println("Setup Syphon");
    setupSyphonServer("Depth");

    // setup Kinect tracking
    println("Setup OpenNI");
    setupOpenNI();
    setupOpenNI_CameraImageMode();

    // setup OSC
    println("Setup OSC");
    setupOSC();

    // setup the exit handler
    println("Setup Exit Handerl");
    prepareExitHandler();
    
    //setup the handy renderer
    h = new HandyRenderer(this);
    
    // calculate the reScale value
    // currently it's rescaled to fill the complete width (cuts of top-bottom)
    // it's also possible to fill the complete height (leaves empty sides)
    reScale = (float) width / kinectWidth;
    // create a smaller blob image for speed and efficiency
    blobs = createImage(kinectWidth/3, kinectHeight/3, RGB);
    // initialize blob detection object to the blob image dimensions
    theBlobDetection = new BlobDetection(blobs.width, blobs.height);
    theBlobDetection.setThreshold(0.3);
    setupFlowfield();
    
    //setup buffer image
    resultImage = createImage(640, 480, RGB);
}

void draw()
{
    // update the cam
    context.update();
    int bufferCurrentSketch = currentSketch;
    
    //switch sketch if required
    int[] userList = context.getUsers();
    //let's iterate through userList
    for (int i=0; i<userList.length; i++) {
      if (!switchOverride) {
        //let's get the center of mass (com)
        if (context.getCoM(userList[i], com)) {
          //context.convertRealWorldToProjective(com, com2d);
          //resultImage = context.depthImage();
          //println("center of mass: " + com.z + " intensity: " + brightness(resultImage.pixels[int(com2d.x + com2d.y*640)]));
          if (com.z<1000 && com.z>1 && tooFar[userList[i]]) { //le centre masse s'est rapproché alors qu'on était loin : on switche
             tooFar[userList[i]] = !tooFar[userList[i]];
             switchSketch();
          } else {
            tooFar[userList[i]] = (com.z>1000);
          }
        }
      }
      //@PP comment faire avec plusieurs utilisateurs ???
      if (userList[i]==activeUser  || userList.length==1) {
                  Boolean hasChanged = storeCoordinates(userList[i]);
                  sendOSCSkeleton(userList[i]);
                  sendOSC(hasChanged);
      }
      
    }
    canvas.beginDraw();

    if (false) {
      canvas.pushMatrix();
      canvas.translate(0, height/2);
      canvas.rotateX(HALF_PI * (frameCount - beginTransitioningFrameNumber ) / 100);
      canvas.translate(0, -height/2);
      bufferCurrentSketch--;
    }
    //canvas.beginDraw();

    // draw image
    //OpenNI_DrawCameraImage();
    PImage img = createImage(640, 480, RGB);
    canvas.image(img, 0, 0);
    
    switch(bufferCurrentSketch) {
      case 0:
        background(0);
        break;
      case 1:
        bdessin.dessine(userList);
        break;
      case 2:
      
        balum.dessine(userList);
        break;
      /* case 3:
        rbackground.dessine();
        break; /* */
      case 3:
        dflux = (nbSwitches > switchFlux);
        dpolygone.dessine();
        break;
      /*case 4:
        dflux = true;
        dpolygone.dessine();
        break; /* */
      case 4:
        depthmap.dessine();
        break;
    }

    if (false) {
      canvas.popMatrix();
      if (frameCount >= beginTransitioningFrameNumber + 100) {
         isTransitioning = false; 
      }
    }

    canvas.endDraw();

    image(canvas, 0, 0);

    // send image to syphon
    server.sendImage(canvas);
}

void switchSketch() {
  nbSwitches++;
  //  currentSketch = nbSwitches % nbSketches;
}

void setupFlowfield() {
  // set stroke weight (for particle display) to 2.5
  strokeWeight(1);
  // initialize all particles in the flow
  for(int i=0; i<flow.length; i++) {
    flow[i] = new Particle(i/10000.0);
  }
  // set all colors randomly now
  setRandomColors(1);
}

void drawFlowfield() {
  // center and reScale from Kinect to custom dimensions
  translate(0, (height-kinectHeight*reScale)/2);
  scale(reScale);
  // set global variables that influence the particle flow's movement
  globalX = noise(frameCount * 0.01) * width/2 + width/4;
  globalY = noise(frameCount * 0.005 + 5) * height;
  // update and display all particles in the flow
  for (Particle p : flow) {
    p.updateAndDisplay();
  }
  // set the colors randomly every 240th frame
  setRandomColors(240);
}

// sets the colors every nth frame
void setRandomColors(int nthFrame) {
  if (frameCount % nthFrame == 0) {
    // turn a palette into a series of strings
    String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");
    // turn strings into colors
    color[] colorPalette = new color[paletteStrings.length];
    for (int i=0; i<paletteStrings.length; i++) {
      colorPalette[i] = int(paletteStrings[i]);
    }
    // set background color to first color from palette
    bgColor = colorPalette[0];
    // set all particle colors randomly to color from palette (excluding first aka background color)
    for (int i=0; i<flow.length; i++) {
      flow[i].col = colorPalette[int(random(1, colorPalette.length))];
    }
  }
}

Boolean storeCoordinates(int userId) {
  Boolean trigger = false;
  ArrayList<PVector> coords = new ArrayList<PVector>();
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_HEAD));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_NECK));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_ELBOW));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_HAND));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_HAND));
  coords.add(getCoords(userId, SimpleOpenNI.SKEL_TORSO));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_HIP));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_KNEE));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_LEFT_FOOT));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_HIP));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_KNEE));
  //coords.add(getCoords(userId, SimpleOpenNI.SKEL_RIGHT_FOOT));
  listeCoords.add(coords);
  if (listeCoords.size()>3) {
    // let's compare movements
    ArrayList<PVector> coords_0 = listeCoords.get(0);
    for (int i=0; i<coords_0.size(); i++) {
      float d = coords_0.get(i).dist(coords.get(i));
      if (d>200) {
        trigger = true;
        i = 50;
      }  
    }
    //remove first element of arraylist
    listeCoords.remove(0);
  }
  return trigger;
}

PVector getCoords(int userId, int jointType) {
    float  confidence;
    PVector a_3d = new PVector();
    confidence = context.getJointPositionSkeleton(userId, jointType, a_3d);
    return a_3d;
}

void setActiveUser(String lateralPosition)
{
  int[] userList = context.getUsers();
  PVector com = new PVector();
  int xmin = -10000;
  int xmax = 10000;
  int user=-1;
  for (int i=0; i<userList.length; i++)
  {
    if(context.getCoM(userList[i],com))
    {
      if(lateralPosition=="left") {
        if (com.x < xmax) {
           user = userList[i];
           xmax = int(com.x);
        }
      } else {
        if (com.x > xmin) {
           user = userList[i];
           xmin = int(com.x);
        }
      }
    }
  }
  if (user != activeUser) {
    listeCoords.clear();
  }
  activeUser = user;
  println("Active user on "+lateralPosition+": "+activeUser);  
}
// -----------------------------------------------------------------
// SimpleOpenNI events
void onNewUser(SimpleOpenNI curContext, int userId)
{
    println("onNewUser - userId: " + userId);
    println("\tstart tracking skeleton");

    curContext.startTrackingSkeleton(userId);
    usersBitSet += (1 << userId);
    nbUsers ++;
    if (nbUsers==1) {
      activeUser = userId;
    }
    println("Active user: "+activeUser);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
    println("onLostUser - userId: " + userId);
    usersBitSet -= (1<<userId);
    nbUsers--;
    if (nbUsers>0 && activeUser==userId) {
      for (int i=0; i<8; i++) {
        if ((usersBitSet & (1 << i))==(1<<i)) {
          activeUser = i;
        } 
      }
    }
    if (nbUsers>0) {
      println("Active user: " + activeUser); 
    } else {
      println("No active user"); 
    }
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
    //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
    switch(key)
    {
    case ' ':
        context.setMirror(!context.mirror());
        println("Switch Mirroring");
        break;
    case '0': //noir
        currentSketch = 0;
        println("Sketch 0");
        switchOverride = true;
        break;
    case '1': //forme informe
        currentSketch = 1;
        println("Sketch 1");
        switchOverride = true;
        break;
    case '2': //bonhomme allumette
        isTransitioning = true;
        beginTransitioningFrameNumber = frameCount;
        currentSketch = 2;
        println("Sketch 2");
        // we need to switch between representations
        switchOverride = false;
        break;
    case '3': //handy silhouette
        isTransitioning = true;
        beginTransitioningFrameNumber = frameCount;
        switchFlux = nbSwitches;
        currentSketch = 3;
        println("Sketch 3");
        switchOverride = false;
        break;
    /*case '4': //flux silhouette
        currentSketch = 4;
        println("Sketch 4");
        switchOverride = true;
        break;/**/
    case '4': //3DMap
        currentSketch = 4;
        println("Sketch 4");
        switchOverride = true;
        break;
    case ESC:
        switchOverride = !switchOverride;
        key = 0;
        break;
    case 'd':
      rotY += 0.1f;
      break;
    case 'g':
        rotY -= 0.1f;
        break;
    case 'r':
      rotX += 0.1f;
      break;
    case 'v':
      rotX -= 0.1f;
      break;
    case 'e':
      zoomF += 0.02f;
      break;
    case 'c':
      zoomF -= 0.02f;
      if(zoomF < 0.01)
        zoomF = 0.01;
      break;
    }
}  

