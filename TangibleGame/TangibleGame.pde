import processing.video.*;

//define the background color and the dimension of the sphere and the plate
float bgColor = 240;
float plateLength = 400;
float plateHeight = 20;
float sphereRadius = 10;

//define the coordinate of the 4 side of the plate in adding-cylinders mode
float leftSide, rightSide, topSide, bottomSide;

float pWidth, pHeight;

//define the colors of the elements of the game
color plateColor = #16F217;
color sphereColor = #FC651F;
color cylinderColor = #1EACD6;

//define and initialize the speed, the angles and the rotation of the plate
float speed = 1;
float angleX = 0;
float angleZ = 0;

float rotateX = 0;
float rotateZ = 0;



//define the mover and the sphereLocation
Mover mover;
Cylinder cylinder;
PVector sphereLocation;

ArrayList<PVector> cylinders = new ArrayList<PVector>();

Movie cam;
ImageProcessing imgproc;


void settings() {
  size(1000, 600, P3D);
}
void setup() {
  noStroke();
  mover = new Mover();
  cylinder = new Cylinder();
  
  pWidth = width;
  pHeight = height;
  cam = new Movie(this, "testvideo.mp4"); //Put the video in the same directory
  cam.loop();
  
  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);
  

  //PVector rot = imgproc.getRotation();
  // where getRotation could be a getter
  //for the rotation angles you computed previously

}

void draw() {
      
   
  drawBasics();
  if(keyPressed && keyCode == SHIFT){
    imgproc.cam.pause();
    drawViewMode();
    drawCylinders2D();
  }
  else{
   
    imgproc.cam.play();
    drawGame();
    drawSphere();
    
  }
   
}

void mouseDragged() 
{
  //test if the game is not in adding-cylinders mode
  if(!(keyPressed && keyCode == SHIFT)){
    angleX += speed * (pmouseY - mouseY);
    angleZ += speed * (mouseX - pmouseX);
    
    angleX = bounds(60, -60, angleX);
    angleZ = bounds(60, -60, angleZ);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speed -= e*0.1;
  
  if(speed > 1.5)
  {
    speed = 1.5;
  }
  else if(speed < 0.2)
  {
    speed = 0.2;
  }
}

//bound the angle of the plate(X and Z axis)
float bounds(float upperBound, float lowerBound, float angle){
  if(angle > upperBound){
    return upperBound;
  }
  else if(angle < lowerBound){
    return lowerBound;
  } else {
    return angle;
  }
}

//draw the basics (light and background)
void drawBasics(){  
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(bgColor);
  fill(255);
  textSize(20);
  text("Speed : " + speed, 10, 30);
  text("Angle X : " + angleX + " --- Angle Z : " + angleZ, 10, 50);
  text("Press 'r' to reset the game", 10, 70);
}

//draw the plate
void drawGame(){

  fill(plateColor);
  translate(width/2, height/2, 0);
  
  PVector rot = imgproc.getRotation();
  System.out.println(rot.x + " and " + rot.z);
  //rotateX = radians(angleX);
  //rotateZ = radians(angleZ);
  
  if(!Float.isNaN(rot.x) && !Float.isNaN(rot.z)){
      rotateX = rot.x;
      rotateZ = rot.z;
      
  }
    
    rotateX(rotateX);
    rotateZ(rotateZ);
    System.out.println("When the intersections are not detected, rotateX is " + rotateX + " and rotateZ is + " + rotateZ);
  
  box(plateLength, plateHeight, plateLength);

  
  drawCylinders3D();
  
}

//draw the sphere
void drawSphere(){
  mover.update();
  mover.checkEdges();
  mover.checkCylinderCollision(cylinders);
  mover.display();
}

//draw the rectangle and the ball of the adding-cylinders mode
void drawViewMode(){   
  
  //check if the window has been resized
  if(pWidth != width || pHeight != height){
     for (PVector cylinderVector: cylinders){
       cylinderVector.x = map(cylinderVector.x, leftSide, rightSide, (width-plateLength)/2, (width+plateLength)/2);
       cylinderVector.y = map(cylinderVector.y, topSide, bottomSide, (height-plateLength)/2, (height+plateLength)/2);
       pWidth = width;
       pHeight = height;
     }
  }
  
  //initialize the 4 side of the plate
  //(initialized here in case if the window is resized)
  leftSide = (width-plateLength)/2;
  rightSide = (width+plateLength)/2;
  topSide = (height-plateLength)/2;
  bottomSide = (height+plateLength)/2;
  
  fill(plateColor);
  pushMatrix();  
    //draw the rectangle at the center of the window
    translate(width/2, height/2,0);
    rect(-plateLength/2, -plateLength/2, plateLength, plateLength);
    
    //draw the ball according to the current position of the sphere
    fill(sphereColor);
    ellipse(sphereLocation.x,sphereLocation.z , 2*sphereRadius, 2*sphereRadius);
  popMatrix();
   
  //draw a circle with a radius equals to the cylinder base size around the pointer
  fill(cylinderColor);
  ellipse(mouseX, mouseY , 2*cylinder.getBaseSize(), 2*cylinder.getBaseSize());
}

//draw the cylinders in the adding-cylinders mode
void drawCylinders2D(){
  for(PVector cylinderVector : cylinders){
    cylinder.update(cylinderVector.x, cylinderVector.y);
  }
}

//draws the cylinders on the game
void drawCylinders3D(){
  for(PVector cylinderVector : cylinders){
    pushMatrix();
      translate(map(cylinderVector.x, leftSide, rightSide, -200, 200), -plateHeight/2, map(cylinderVector.y, topSide, bottomSide, -200, 200));
      rotateX(HALF_PI);
      cylinder.update();
    popMatrix();
  }
}

//create a cylinder if the user release the mouse's button
//(we use mouseReleased instead of mouseClicked because it works better if the user make long-click)
void mouseReleased(){
  //check if we are in view mode
  if(keyPressed && keyCode == SHIFT){
    //check if the mouse position is on he plate and if it's not on the ball's position
    if(check() && !overlap(sphereLocation, new PVector(map(mouseX, leftSide, rightSide, -200, 200), -plateHeight/2, map(mouseY, topSide, bottomSide, -200, 200)))){
      cylinders.add(new PVector(mouseX, mouseY));
    }
  }
}

void keyPressed(){
  if(key == 'R' || key == 'r'){
     cylinders = new ArrayList<PVector>();
     mover = new Mover();
     angleX = angleZ = 0;
     speed = 1;
  }
}

//check if the cylinder is on the plate and if he is not on another cylinder or on the ball
boolean check(){
  if(mouseX + cylinder.getBaseSize() <= rightSide && mouseX - cylinder.getBaseSize() >= leftSide
        && mouseY + cylinder.getBaseSize() <= bottomSide && mouseY - cylinder.getBaseSize() >= topSide){
    return true;
  }
  return false;
}

//check if the 2 parameters overlap
boolean overlap(PVector sphere, PVector cylinderVector){
  if(dist(sphere.x, sphere.y, sphere.z, cylinderVector.x, cylinderVector.y, cylinderVector.z) <= sphereRadius + cylinder.getBaseSize()){
    return true;
  }
  return false;
}