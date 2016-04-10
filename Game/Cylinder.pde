class Cylinder
{
  private PShape openCylinder;
  private PShape topBase;
  private PShape bottomBase;
  PShape cylinder;
  final float CYLINDER_BASE = 25;
  final float CYLINDER_HEIGHT = 50;
  final int CYLINDER_RESOLUTION = 40;
  float angle;
  float[] x = new float[CYLINDER_RESOLUTION + 1];
  float[] z = new float[CYLINDER_RESOLUTION + 1];
  
  ArrayList<PVector> positions;
  
    Cylinder()
    {
        for(int i = 0; i < x.length; i++) {
        angle = (TWO_PI / CYLINDER_RESOLUTION) * i;
        x[i] = sin(angle) * CYLINDER_BASE;
        z[i] = cos(angle) * CYLINDER_BASE;
}       
        openCylinder = createShape();
        openCylinder.beginShape(QUAD_STRIP);
        
        //drawing the opened cylinder
        for(int i = 0; i < x.length; ++i) {
        openCylinder.stroke(0);
        openCylinder.vertex(x[i], 0, z[i]); //one point up
        openCylinder.vertex(x[i], CYLINDER_HEIGHT, z[i]); // one down and it creates the quad

        }
        
        openCylinder.endShape();
        
        
       topBase = createShape();
       bottomBase = createShape();
       topBase.beginShape(TRIANGLE_FAN);
       bottomBase.beginShape(TRIANGLE_FAN);
       topBase.stroke(0);
       bottomBase.stroke(0);
       
       topBase.vertex(0, 0, 0); //the top center
       bottomBase.vertex(0, CYLINDER_HEIGHT, 0); //the bottom center
      
       
       for(int i = 0; i < x.length; ++i)
       {
           topBase.vertex(x[i], 0, z[i]);
           bottomBase.vertex(x[i], CYLINDER_HEIGHT, z[i]);
       }
       
       topBase.endShape();
       bottomBase.endShape();
       
}

void display()
{
    pushMatrix();
    translate(0, - 10 - CYLINDER_HEIGHT, 0); // (-10 - CYLINDER_HEIGHT) to put the on the plate, where 20 is the height of the plate
    shape(openCylinder);
    shape(topBase);
    shape(bottomBase);
    popMatrix();
}


}

    

    