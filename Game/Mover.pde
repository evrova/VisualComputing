class Mover{

 PVector location;
 PVector gravity;
 PVector friction;
 PVector velocity;

final float BOX_WIDTH = box.getWidth();
final float BOX_HEIGHT = box.getHeight();
final float BOX_DEPTH = box.getDepth();
final float RADIUS = 20;
final float gravityConst = 1;
final float normalForce = 1;
final float MU = 0.01;
float frictionMagnitude = normalForce*MU;
  
Mover()
{
   location = new PVector(0, 0, 0);
   gravity = new PVector(0, 0, 0);
   friction = new PVector(0, 0, 0);
   velocity = new PVector(0, 0, 0);
   
   friction = velocity.get();
      
   friction.mult(-1);
   friction.normalize();
   friction.mult(frictionMagnitude);
     

}
void update()
{  
    gravity.x = sin(radians(rotX))*gravityConst;
    gravity.z = -sin(radians(rotZ))*gravityConst;
    location.add(velocity.add(gravity.add(friction)));
}

void display()
{
  noStroke();
  fill(120);
   
  pushMatrix(); 
  translate(location.x, -RADIUS - 10, location.z);
  sphere(RADIUS);
  popMatrix();
 

}

void checkEdges()
{
   if(location.x >= BOX_WIDTH/2 - RADIUS)
   {
       location.x = BOX_WIDTH/2 - RADIUS;
       velocity.x = -velocity.x/2;
   }
   if(location.x <= -BOX_WIDTH/2 + RADIUS)
   {
       location.x = -BOX_WIDTH/2 + RADIUS;
       velocity.x = velocity.x/(-2);
   }
   if(location.z >= BOX_DEPTH/2 - RADIUS)
   {
     location.z = BOX_DEPTH/2 - RADIUS;
     velocity.z = velocity.z/(-2);
   }
   if(location.z <= -BOX_DEPTH/2 + RADIUS)
   {
     location.z = -BOX_DEPTH/2 + RADIUS;
     velocity.z = velocity.z/(-2);
   }  
}

void checkCylinderCollision()
{
 //distance between the cylinder and the ball
 float distance;
  
 PVector normal; 
  
 for(PVector position: cylinder.positions)
 {
   distance = position.dist(new PVector(location.x, location.z));
    
   if(distance <= RADIUS + cylinder.CYLINDER_BASE)
   {
       normal = new PVector(location.x - position.x, 0, location.z - position.y).normalize();
       location.x = position.x + normal.x * (RADIUS +  cylinder.CYLINDER_BASE);
       location.z = position.y + normal.z * (RADIUS +  cylinder.CYLINDER_BASE);
       velocity = velocity.sub(normal.mult(2*PVector.dot(velocity, normal))).div(-2);
   }
 }
  
}





}