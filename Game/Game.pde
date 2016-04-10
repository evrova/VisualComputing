PShape box;
Mover mover;
Cylinder cylinder;
boolean shift;

void settings(){

    //fullScreen(P3D);
    size(1000,1000, P3D);
}

void setup(){
  noStroke();
  box = createShape(BOX, width/3, 20, height/2);
  box.setFill(color(100));
  mover = new Mover();
  cylinder = new Cylinder();
  cylinder.positions = new ArrayList<PVector>();
  shift = false;
}

void draw(){

  if(!shift)
  {
    background(255); //We set a white background
    lights(); //we set up the default ambient, directional and falloff ligths and specular values
    pointLight(100, 400, 800, width/3, 0, -width/6); //we position a point light above the left back corner of the plate
     
    fill(0);
    textSize(11);
    textAlign(LEFT, TOP);
    text("RotationX: " + rotX + "\nRotationZ" + rotZ + "\nSpeed: " + speed, 0, 0);
    
    pushMatrix();
    
    translate(width/2, height/2, 0); //we go to the middle
   
    rotateX(radians(rotZ));
    rotateZ(radians(rotX));
    
    shape(box);
       
    mover.update();
    mover.checkEdges();
    mover.checkCylinderCollision();
    mover.display();
    
    for(PVector position : cylinder.positions)
    {
        pushMatrix();
        translate(position.x, 0, position.y); 
        cylinder.display();
        popMatrix();
    }
    
   
    popMatrix();
    
  }
  
  else{
    
    pushMatrix();
    translate(width/2, height/2, 0);
    noStroke();
    background(255);
    fill(120);
    rect(-box.width/2, -box.depth/2, box.width, box.depth);
    noStroke();
    fill(0);
    ellipse(mover.location.x, mover.location.z, 2*mover.RADIUS, 2*mover.RADIUS);
    fill(80);
    textSize(18);
    text("SHIFT", 200, 200);
    drawRestartButton();
    
   
    for(PVector position : cylinder.positions)
    {
        pushMatrix();
        translate(position.x, position.y);
        pushMatrix();
        rotateX(-PI/2);
        cylinder.display();
        popMatrix();
        popMatrix();
    }
   
   popMatrix();
   
  }
   
   
}

float bounds(float value, float upperBound, float lowerBound)
{
  if(value > upperBound) value = upperBound;
  if(value < lowerBound) value = lowerBound;
  return value;
}

private float speed = 1;
private float rotX = 0f; //angle of rotation around X axis in degrees
private float rotZ = 0f; //angle of rotation around Z axis in degrees

void mouseDragged() 
{
     rotX += speed*(mouseX - pmouseX);
     rotZ += speed*(pmouseY - mouseY); 
     
     rotX = bounds(rotX, 60, -60);
     rotZ = bounds(rotZ, 60, -60);
     
     circlePointer();
    
        
}

/**
The effect of a circle around the mouse poiner
*/
void circlePointer()
{
     pushMatrix();
     noFill();
     stroke(0);
     ellipse(mouseX, mouseY, 2*cylinder.CYLINDER_BASE, 2*cylinder.CYLINDER_BASE);
     popMatrix();
}


void mouseWheel(MouseEvent event) {
 
  int i = event.getCount();
  
  if(i > 0)
  {
    if(speed > 0.2)
    speed -= 0.1;
  }
  else {
    if(speed < 1.5)
    speed += 0.1;
  }
}

void keyPressed()
{
  if(keyCode == SHIFT) shift = true;
  
}
void keyReleased()
{
  if(shift) 
  shift = false;
  
}

void mouseClicked()
{
  
  if(shift)
  {
    //if (x, x) is the center, we set their values to be (0, 0)
    float x = mouseX - width/2;
    float y = mouseY - height/2;
   
    //For the cylinder not to overlap with the ball, the distance between them has to be at least the ball's radius + the cylinder's radius
    //The balls coordinates location.x and location.z are (0, 0) in the center
    //That's why we add half of the plates width and height to them
    float dist = PVector.dist( new PVector(x, y), new PVector(mover.location.x, mover.location.z));
    
    if(((x - cylinder.CYLINDER_BASE) >= -box.getWidth()/2) && ((x + cylinder.CYLINDER_BASE) <= box.getWidth()/2) && ((y - cylinder.CYLINDER_BASE) >= -box.getDepth()/2) && ((y + cylinder.CYLINDER_BASE <= box.getDepth()/2)) && dist >= mover.RADIUS + cylinder.CYLINDER_BASE)
    {
      cylinder.positions.add(new PVector(x, y)); //we substract because of the translate in draw
    }
    
    boolean restart = ((x >= 200) && (x <= 277) && (y >= 170) && ( y<= 190));
    
    if(restart)
    {
     cylinder.positions = new ArrayList<PVector>();
    }
  
  }
  
    
    
}

void drawRestartButton()
{
    pushMatrix();
    translate(200, 170);
    stroke(0);
    fill(190);
    rect(0, 0, 77, 20);
    fill(0);
    text("RESTART", 0, 0);
    popMatrix();
}