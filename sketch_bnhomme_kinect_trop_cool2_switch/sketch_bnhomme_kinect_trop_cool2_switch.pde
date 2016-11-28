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

PVector com = new PVector();                                   
PVector com2d = new PVector();
HandyRenderer h;

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
int nbSketches = 2;
int nbSwitches = 0;
boolean[] tooClose = new boolean[16]; //one for each user

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
    
    h = new HandyRenderer(this);
}

void draw()
{
    // update the cam
    context.update();

    canvas.beginDraw();

    // draw image
    //OpenNI_DrawCameraImage();
    PImage img = createImage(640, 480, RGB);
    canvas.image(img, 0, 0);

    // draw the skeleton if it's available
    if (kDrawSkeleton) {

        int[] userList = context.getUsers();
        for (int i=0; i<userList.length; i++)
        {
            if (context.isTrackingSkeleton(userList[i]))
            {
                canvas.stroke(userClr[ (userList[i] - 1) % userClr.length ] );
                
                switch(currentSketch) {
                  case 0:
                    drawSkeletonHandy(userList[i]);
                    break;
                  case 1:
                    drawSkeletonAlumette(userList[i]);
                    break;
                }
                
                

                if (userList.length == 1) {
                    sendOSCSkeleton(userList[i]);
                }
            }      

            // draw the center of mass
            if (context.getCoM(userList[i], com))
            {
                context.convertRealWorldToProjective(com, com2d);
                
                
                
                canvas.stroke(100, 255, 0);
                canvas.strokeWeight(1);
                canvas.beginShape(LINES);
                canvas.vertex(com2d.x, com2d.y - 5);
                canvas.vertex(com2d.x, com2d.y + 5);
                canvas.vertex(com2d.x - 5, com2d.y);
                canvas.vertex(com2d.x + 5, com2d.y);
                canvas.endShape();

                canvas.fill(0, 255, 100);
                canvas.text(Integer.toString(userList[i]), com2d.x, com2d.y);
                
                if (com.z>1000 && tooClose[i]) { //le centre masse s'est éloigné alors qu'on était près : on switche
                  tooClose[i] = !tooClose[i];
                  switchSketch();
                } else {
                  tooClose[i] = (com.z<1000);
                }
            }
        }
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


// draw the skeleton with the selected joints
void drawSkeletonHandy(int userId)
{
    canvas.stroke(255, 255, 255, 255);
    canvas.strokeWeight(3);

    /*drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
    drawHead(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

    //drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    //drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
    //drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

    //drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
    */
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
void drawJointH(int userId, int jointType)
{
    float  confidence;

    // draw the joint position
    PVector a_3d = new PVector();
    confidence = context.getJointPositionSkeleton(userId, jointType, a_3d);
    
    PVector a_2d = new PVector();
    context.convertRealWorldToProjective(a_3d, a_2d);
    
    h.vertex(a_2d.x, a_2d.y);
}

void drawLimbH(int userId, int jointType1, int jointType2)
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

// draw the skeleton with the selected joints
void drawSkeletonAlumette(int userId)
{
    canvas.stroke(255, 255, 255, 255);
    canvas.strokeWeight(3);

    /*drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
    drawHead(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

    drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

    //drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
    //drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_HIP);
    //drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

    //drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
    drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
    */
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
void drawJoint(int userId, int jointType)
{
    float  confidence;

    // draw the joint position
    PVector a_3d = new PVector();
    confidence = context.getJointPositionSkeleton(userId, jointType, a_3d);
    
    PVector a_2d = new PVector();
    context.convertRealWorldToProjective(a_3d, a_2d);
    
    canvas.curveVertex(a_2d.x, a_2d.y);
}

void drawLimb(int userId, int jointType1, int jointType2)
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

    canvas.line(a_2d.x, a_2d.y, b_2d.x, b_2d.y);
}

void drawHead(int userId, int jointType1, int jointType2)
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
    
    PVector artCou = new PVector();
    
    float distHeadNeck = a_2d.y-b_2d.y;
    
    canvas.line(a_2d.x, a_2d.y-distHeadNeck/2, a_2d.x+3*distHeadNeck/4, b_2d.y+3*distHeadNeck/4);
    
    //canvas.line(a_2d.x, a_2d.y, b_2d.x, b_2d.y);
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

