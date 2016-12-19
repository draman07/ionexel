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

int kCameraImageMode = kCameraImage_User; // << Set thie value to one of the kCamerImage constants above

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
int nbSketches = 4;
int nbSwitches = 0;
boolean[] tooFar = new boolean[16]; //one for each user
PImage resultImage;

BonhommeAlumette balum = new BonhommeAlumette();
BonhommeDessin bdessin = new BonhommeDessin();
RemoveBackground rbackground = new RemoveBackground();
DessinPolygone dpolygone = new DessinPolygone();

// --------------------------------------------------------------------------------
//  MAIN PROGRAM
// --------------------------------------------------------------------------------
void setup()
{
    size(640, 480, P3D);
    canvas = createGraphics(640, 480, P3D);

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
    
    //setup buffer image
    resultImage = new PImage(640, 480, RGB);
}

void draw()
{
    // update the cam
    context.update();
    
    //switch sketch if required
    int[] userList = context.getUsers();
    //let's iterate through userList
    for (int i=0; i<userList.length; i++) {
      //let's get the center of mass (com)
      if (context.getCoM(userList[i], com)) {
        //context.convertRealWorldToProjective(com, com2d);
        if (com.z<1000 && com.z>1 && tooFar[userList[i]]) { //le centre masse s'est rapproché alors qu'on était loin : on switche
           tooFar[userList[i]] = !tooFar[userList[i]];
           switchSketch();
        } else {
          tooFar[userList[i]] = (com.z>1000);
        }
      }
      
      //@PP comment faire avec plusieurs utilisateurs ???
      sendOSCSkeleton(userList[i]);
    }
    
    canvas.beginDraw();

    // draw image
    //OpenNI_DrawCameraImage();
    PImage img = createImage(640, 480, RGB);
    canvas.image(img, 0, 0);
    
    switch(currentSketch) {
      case 0:
        bdessin.dessine(userList);
        break;
      case 1:
        balum.dessine(userList);
        break;
      case 2:
        rbackground.dessine();
        break;
      case 3:
        dpolygone.dessine();
        break;
    }

    

    canvas.endDraw();

    image(canvas, 0, 0);

    // send image to syphon
    server.sendImage(canvas);
}

void switchSketch() {
  nbSwitches++;
  currentSketch = nbSwitches % nbSketches;
}




// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
    println("onNewUser - userId: " + userId);
    println("\tstart tracking skeleton");

    curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
    println("onLostUser - userId: " + userId);
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
    }
}  

