import org.openkinect.*; 
import org.openkinect.processing.*;

// Kinect Library object 
Kinect kinect;
void setup() { 
size(640, 480); 
}
void setup() { 
size(640, 480); 
kinect = new Kinect(this); 
kinect.start();
}
kinect.enableRGB(true);
PImage img = kinect.getVideoImage(); 
image(img,0,0);
import org.openkinect.processing.*;

// Kinect Library object
Kinect kinect;

void setup(){ 
size(640, 480); 
kinect = new Kinect(this); 
kinect.start(); 
kinect.enableRGB(true); 
}

void draw(){ 
PImage img = kinect.getVideoImage(); 
image(img,0,0); 
}
kinect.enableIR(true);
PImage img = kinect.getDepthImage();
kinect.enableDepth(true); int[] depth = kinect.getRawDepth();
int[] depth = kinect.getRawDepth();
println(depth);
   
import org.openkinect.*; 
import org.openkinect.processing.*;

// Instantiate our kinect tracker. It's a separate class that we'll get into in a minute, basically it parses the depth lookup information for us.

KinectTracker tracker; 
// Kinect Library object 
Kinect kinect; 
void setup() { 
size(640,480);

// Along with making our new kinect object reference, we're making a kinect tracker!

kinect = new Kinect(this);
tracker = new KinectTracker(); 
}

void draw() { 
background(255); 

// initialize the tracking analysis

tracker.track(); 

// Shows the depth image so we can see what it's doing

tracker.display();

// Let's draw a circle at the raw location

PVector v1 = tracker.getPos();
fill(50,100,250,200); 
noStroke(); 
ellipse(v1.x,v1.y,20,20);
PVector v2 = tracker.getLerpedPos();
fill(100,250,50,200); 
noStroke(); 
ellipse(v2.x,v2.y,20,20);
} void stop() {
tracker.quit();
super.stop(); 
}
class KinectTracker { 
// Size of kinect 
image int kw = 640;
int kh = 480; 
// this is the depth range, distance past which we will ignore all pixels 
int threshold = 745;
// Raw location 
PVector loc; 
// Interpolated location
PVector lerpedLoc;
// Depth data 
int[] depth; 
PImage display;

/// init constructor 
KinectTracker() { 
kinect.start(); 
kinect.enableDepth(true); 
// We could skip processing the grayscale image for efficiency 
// but this example is just demonstrating everything 
kinect.processDepthImage(true); 
display = createImage(kw,kh,PConstants.RGB); 
loc = new PVector(0,0);
lerpedLoc = new PVector(0,0); 
}

void track() { 
// Get the raw depth as array of integers
depth = kinect.getRawDepth();
// Being overly cautious here, doing a "null" check
if (depth == null) return; 
float sumX = 0;
float sumY = 0; 
float count = 0; 
for(int x = 0; x < kw; x++) { 
for(int y = 0; y < kh; y++) { 
// Mirroring the image 
int offset = kw-x-1+y*kw; 
// Grabbing the raw depth 
int rawDepth = depth[offset]; 
// Testing the raw depth against threshold -- if it's less than the threshold, don't bother!
if (rawDepth < threshold) { 
sumX += x; sumY += y; count++; 
} 
} 
} 
// As long as we found something
if (count != 0) { 
loc = new PVector(sumX/count,sumY/count); 
} 
// Interpolating the location, doing it arbitrarily for now 
lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f); 
lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f); 
} 
PVector getLerpedPos() {
return lerpedLoc; 
} 
PVector getPos() {
return loc; 
}

/// now let's display some data!

void display() { 
PImage img = kinect.getDepthImage(); 
// Being overly cautious here 
if (depth == null || img == null) return; 
// Going to rewrite the depth image to show which pixels are in threshold 
// A lot of this is redundant, but this is just for demonstration purposes 
display.loadPixels();
for(int x = 0; x < kw; x++) { 
for(int y = 0; y < kh; y++) { 
// mirroring image 
int offset = kw-x-1+y*kw; 
// Raw depth 
int rawDepth = depth[offset];
int pix = x+y*display.width;

// if the pixel data falls within the threshold, make them red!

if (rawDepth < threshold) {
display.pixels[pix] = color(150,50,50); 
} else { 
display.pixels[pix] = img.pixels[offset]; 
} 
} 
}

display.updatePixels(); 
// Draw the image
image(display,0,0); 
}
// stop it!

void quit() { 
kinect.quit(); 
} int getThreshold() { 
return threshold; 
}

//// set the depth threshold # 
//// this is abitrary-- but we could make this a function called from the main class... hmm...

void setThreshold(int t) {

threshold = t; 
} 
}
import SimpleOpenNI.*; 
SimpleOpenNI context;

void setup(){ 
context = new SimpleOpenNI(this); 
// enable depthMap generation 
context.enableDepth(); 
// enable camera image generation
context.enableRGB(); 
background(200,0,0); 
// set the size of the canvas to the actual kinect image data
// which is actually 640x480 
size(context.depthWidth() + context.rgbWidth() + 10, context.rgbHeight()); 
}

void draw(){
// update the cam 
context.update();
// draw depthImageMap 
image(context.depthImage(),0,0);
// draw camera 
image(context.rgbImage(),context.depthWidth() + 10,0); 
}
/// first we'll add the libraries
import SimpleOpenNI.*; 
SimpleOpenNI context; 
// add the NITE function
// this handles turning stuff on and off
XnVSessionManager sessionManager; 
XnVFlowRouter flowRouter; 
PointDrawer pointDrawer;

void setup() { 
context = new SimpleOpenNI(this); 
// mirror is by default enabled 
context.setMirror(true); 
// enable depthMap generation 
context.enableDepth(); 
// enable the hands + gesture 
context.enableGesture(); 
context.enableHands(); 
// setup NITE 
sessionManager = context.createSessionManager("Click,Wave", "RaiseHand"); 
pointDrawer = new PointDrawer(); 
flowRouter = new XnVFlowRouter(); 
flowRouter.SetActive(pointDrawer); 
sessionManager.AddListener(flowRouter); 
size(context.depthWidth(), context.depthHeight()); 
smooth(); 
}

void draw() { 
background(200,0,0); 
// update the camera 
context.update(); 
// update nite 
context.update(sessionManager); 
// draw depthImageMap 
image(context.depthImage(),0,0); 
// draw the list 
pointDrawer.draw(); 
}

/// this unloads the session

void keyPressed() { 
switch(key) { 
case 'e': 
// end sessions
sessionManager.EndSession(); 
println("end session"); 
break; 
} 
}
///////////////////////////////////////////////////////////////////////////////////////////////////// 
// session callbacks
void onStartSession(PVector pos) { 
println("onStartSession: " + pos); 
}

void onEndSession() { 
println("onEndSession: "); 
}

void onFocusSession(String strFocus,PVector pos,float progress) { 
println("onFocusSession: focus=" + strFocus + ",pos=" + pos + ",progress=" + progress); 
}

/// end session callbacks ////////////////////////////////////////////////////////////////////////////////////////////////// 
// PointDrawer keeps track of the handpoints 
class PointDrawer extends XnVPointControl { 
HashMap _pointLists; 
int _maxPoints; 
color[] _colorList = { color(255,0,0),color(0,255,0),color(0,0,255),color(255,255,0)
};

public PointDrawer() {
_maxPoints = 30; _pointLists = new HashMap(); 
}

public void OnPointCreate(XnVHandPointContext cxt) { 
// create a new list when it's triggered by the point drawer
addPoint(cxt.getNID(),new PVector(cxt.getPtPosition().getX(),cxt.getPtPosition().getY(),cxt.getPtPosition().getZ()));
println("OnPointCreate, handId: " + cxt.getNID()); 
}
/// update the point

public void OnPointUpdate(XnVHandPointContext cxt) { 
//println("OnPointUpdate " + cxt.getPtPosition());
addPoint(cxt.getNID(),new PVector(cxt.getPtPosition().getX(),cxt.getPtPosition().getY(),cxt.getPtPosition().getZ()));
}


// remove list
public void OnPointDestroy(long nID) { 
println("OnPointDestroy, handId: " + nID); 
if(_pointLists.containsKey(nID)) _pointLists.remove(nID); 
}
//// get the hand points list

public ArrayList getPointList(long handId) { 
ArrayList curList;
if(_pointLists.containsKey(handId)) curList = (ArrayList)_pointLists.get(handId); 
else { 
curList = new ArrayList(_maxPoints); 
_pointLists.put(handId,curList); 
} 
return curList; 
}

// put the hand points in an array list
public void addPoint(long handId,PVector handPoint) {
ArrayList curList = getPointList(handId); 
curList.add(0,handPoint);
if(curList.size() > _maxPoints) curList.remove(curList.size() - 1); 
}

// now that we have our points lists, let's draw them!
public void draw() {
if(_pointLists.size() <= 0) return;
pushStyle(); 
noFill(); 
PVector vec; 
PVector firstVec; 
PVector screenPos = new PVector();
int colorIndex=0; 
// draw the hand lists 
Iterator<Map.Entry> itrList = _pointLists.entrySet().iterator(); 
while(itrList.hasNext()) { 
strokeWeight(2); 
stroke(_colorList[colorIndex % (_colorList.length - 1)]); 
ArrayList curList = (ArrayList)itrList.next().getValue();
// draw line 
firstVec = null; 
Iterator<PVector> itr = curList.iterator();
beginShape(); 
while (itr.hasNext()) { 
vec = itr.next(); 
if(firstVec == null) firstVec = vec; 
// calc the screen position and find the vertex of the hand point
/// notice we only have an x and y-- since we're using DepthField data, we can check for a z position as well! 
context.convertRealWorldToProjective(vec,screenPos); 
vertex(screenPos.x,screenPos.y); 
} 
endShape();

// if we have a vector then put a red dot in it!
if(firstVec != null) { 
strokeWeight(8); 
context.convertRealWorldToProjective(firstVec,screenPos);
point(screenPos.x,screenPos.y); 
} 
colorIndex++; 
} 
popStyle(); 
} 
}
// So, the first thing we want to do is create a shape. Put this code in the top of the document 
// with all the other code that you use to instantiate variables, etc.
Poly theButton;
/// array of x and y co-ordinates: upper left corner, upper right corner, lower right corner, lower left corner
int[]x={ 20,50,50,20,20}; 
int[]y={ 20,20,50,50,20}; 
theButton = new Poly(x,y,5);
/// since we want to be able to see the buttons, let's put them in a function
/// that way we can call them from inside the "draw" function after we draw the kinect data 
/// otherwise the kinect depth data will "cover" the button

void doTargetButtons(){ 
/// to draw the button, just instantiate the button with the "drawMe()" command 
theButton.drawMe();
}
if(theButton.contains(screenPos.x,screenPos.y)) { 
/// do something here
println("YOU HAVE HIT A BUTTON"); 
}
