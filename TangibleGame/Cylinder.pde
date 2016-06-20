//definition of the cylinder class, which is used to display cylinders
class Cylinder {
  
  private float cylinderBaseSize = 20;
  private float cylinderHeight = 100;
  private int cylinderResolution = 40;
  
  ArrayList<PVector> positions;
  
  PShape cylinderShape, openCylinder, topCylinder, bottomCylinder;
  
  Cylinder(){
    float angle;
    int mid = 0;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];
    
    //get the x and y position on a circle for all the sides
    for(int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    mid = x.length / 2;
    float centerx = (x[mid] + x[0]) / 2;
    float centery = (y[mid] + y[0]) / 2;
    
    fill(cylinderColor);
    
    cylinderShape = createShape(GROUP);
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    topCylinder = createShape();
    bottomCylinder = createShape();
    topCylinder.beginShape(TRIANGLE_FAN);
    bottomCylinder.beginShape(TRIANGLE_FAN);
    
    topCylinder.vertex(centerx, centery, cylinderHeight);
    bottomCylinder.vertex(centerx, centery, 0);
    
    //draws the border of the cylinder
    for(int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i] , 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
      topCylinder.vertex(x[i], y[i], cylinderHeight);
      bottomCylinder.vertex(x[i], y[i], 0);
    }
    
    openCylinder.endShape();
    topCylinder.endShape();
    bottomCylinder.endShape();
    
    cylinderShape.addChild(topCylinder);
    cylinderShape.addChild(openCylinder);
    cylinderShape.addChild(bottomCylinder);
    
    }
    
    void update(){
      shape(cylinderShape);
    }
    
    void update(float x, float y){
      shape(cylinderShape, x, y);
    }
    
    float getBaseSize(){
      return cylinderBaseSize;
    }
}