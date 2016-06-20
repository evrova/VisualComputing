//defition of the Mover class, which is used to update the sphere location and to display it
class Mover {
  
  //physic contants
  float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  float gravityConstant = 0.2;
  
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  PVector n;
  
  Mover() {
    sphereLocation = new PVector(0, -plateHeight, 0);
    velocity = new PVector();
    gravityForce = new PVector(0, 0, 0);
    friction = new PVector();
  }
  
  //update the sphere location
  void update() {     
    //get the gravity force
    gravityForce.x = sin(rotateZ) * gravityConstant;
    gravityForce.z = -sin(rotateX) * gravityConstant;
    
    velocity.add(gravityForce.add(friction));
  
    //calculate the friction force
    friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    
    sphereLocation.add(velocity);
  }
  
  //display the sphere
  void display() {
    fill(sphereColor);
    translate(sphereLocation.x, sphereLocation.y, sphereLocation.z);
    sphere(sphereRadius);
  }
  
  //check if the sphere hits a wall
  void checkEdges()
{
   if(sphereLocation.x >= plateLength/2 - RADIUS)
   {
       prevLocation = currLocation;
       currLocation = sphereLocation.mag();
       isWall = true;
       newScore(isWall, currLocation - prevLocation);
       sphereLocation.x = plateLength/2 - RADIUS;
       velocity.x = -velocity.x/2;
   }
   if(sphereLocation.x <= -plateLength/2 + RADIUS)
   {
       prevLocation = currLocation;
       currLocation = sphereLocation.mag();
       isWall = true;
       newScore(isWall, currLocation - prevLocation);
       sphereLocation.x = -plateLength/2 + RADIUS;
       velocity.x = velocity.x/(-2);
   }
   if(sphereLocation.z >= plateLength/2 - RADIUS)
   {
     prevLocation = currLocation;
     currLocation = sphereLocation.mag();
     isWall = true;
     newScore(isWall, currLocation - prevLocation);
     sphereLocation.z = plateLength/2 - RADIUS;
     velocity.z = velocity.z/(-2);
   }
   if(sphereLocation.z <= -plateLength/2 + RADIUS)
   {
     prevLocation = currLocation;
     currLocation = sphereLocation.mag();
     isWall = true;
      newScore(isWall, currLocation - prevLocation);
     sphereLocation.z = -plateLength/2 + RADIUS;
     velocity.z = velocity.z/(-2);
   }  
}
  
  void checkCylinderCollision(ArrayList<PVector> positions){
    Cylinder cylinder = new Cylinder();
    PVector normal;
    PVector normalized;
    PVector mappedCylinder = new PVector();
    for(PVector p: positions){
      
      //map the point from the referential of the adding-cylinders mode to the game's one
      mappedCylinder.x = map(p.x, leftSide, rightSide, -plateLength/2, plateLength/2);
      mappedCylinder.y = -plateHeight/2;
      mappedCylinder.z = map(p.y, topSide, bottomSide, -plateLength/2, plateLength/2);
      
      //check if there is a collisin between the ball and the cylinder
      if(overlap(sphereLocation, mappedCylinder)){
        normal = new PVector(sphereLocation.x - mappedCylinder.x, 0, sphereLocation.z - mappedCylinder.z);
        normalized = normal.normalize();
        sphereLocation.x = mappedCylinder.x + normalized.x * (sphereRadius +  cylinder.getBaseSize());
        sphereLocation.z = mappedCylinder.z + normalized.z * (sphereRadius +  cylinder.getBaseSize());
        PVector v = normalized.mult(1.5 * PVector.dot(velocity, normalized));
        velocity = velocity.sub(v);
      }
    }
  }
}