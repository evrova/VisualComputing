void settings() {
size(1000, 1000, P2D);
}
void setup() {
}

float scaleValue = 1;
float rotateAngleX = 0;
float rotateAngleY = 0;


void draw() {
background(255);
My3DPoint eye = new My3DPoint(-100, -100, -5000);
My3DPoint origin = new My3DPoint(10, 0, 0); //The first vertex of your cuboid
My3DBox input3DBox = new My3DBox(origin, 100,150,300);
float [][] scale = scaleMatrix(scaleValue, scaleValue, scaleValue);
float [][] rotateX = rotateXMatrix(rotateAngleX);
float [][] rotateY = rotateYMatrix(rotateAngleY);


if(keyPressed == true)
    {
       if(keyCode == UP)
       {
           rotateAngleX += PI/20;
       }
       else if(keyCode == DOWN)
       {
           rotateAngleX -= PI/20;
       }
       
       if(keyCode == RIGHT)
       {
           rotateAngleY += PI/20;
       }
       else if(keyCode == LEFT)
       {
           rotateAngleY -= PI/20;
       }
       
    }

My3DBox intermidiate3DBox = transformBox(input3DBox, rotateX);
My3DBox intermidiate3DBox2 = transformBox(intermidiate3DBox, scale);
projectBox(eye, transformBox(intermidiate3DBox2, rotateY)).render();




//background(255, 255, 255);
//My3DPoint eye = new My3DPoint(0, 0, -5000);
//My3DPoint origin = new My3DPoint(0, 0, 0);

//My3DBox input3DBox = new My3DBox(origin, 100, 150, 300);

////rotated around x
//float[][] transform1 = rotateXMatrix(PI/8);
//input3DBox = transformBox(input3DBox, transform1);
//projectBox(eye, input3DBox).render();

////rotated and translated
//float[][] transform2 = translationMatrix(200, 200, 0);
//input3DBox = transformBox(input3DBox, transform2);
//projectBox(eye, input3DBox).render();

////rotated, translated, and scaled
//float[][] transform3 = scaleMatrix(2, 2, 2);
//input3DBox = transformBox(input3DBox, transform3);
//projectBox(eye, input3DBox).render();

}




void mouseDragged(){
  
  if((mouseY - pmouseY) > 0)
  {
      scaleValue += 0.1;
  }
  else if((mouseY - pmouseY) < 0){
  
      scaleValue -= 0.1;
  }

}

//void keyPressed(){ 
    
//    if(key == CODED)
//    {
//       if(keyCode == UP)
//       {
//           rotateAngle += PI/20;
//       }
//       else if(keyCode == DOWN)
//       {
//           rotateAngle -= PI/20;
//       }
   
//}

class My2DPoint{

    float x;
    float y;
    My2DPoint(float x, float y)
    {
        this.x = x;
        this.y = y;
     }


}

class My3DPoint {
float x;
float y;
float z;
My3DPoint(float x, float y, float z) {
this.x = x;
this.y = y;
this.z = z;
}
}

My2DPoint projectPoint(My3DPoint eye, My3DPoint p){
    
    float xp = (eye.z*(p.x - eye.x))/(eye.z - p.z);
    float yp = (eye.z*(p.y - eye.y))/(eye.z - p.z);
    
    return new My2DPoint(xp, yp); 
    
    }


class My2DBox {
My2DPoint[] s;
My2DBox(My2DPoint[] s) {
this.s = s;
}
void render(){
    
    line(s[0].x, s[0].y, s[3].x, s[3].y);
    line(s[0].x, s[0].y, s[4].x, s[4].y);
    line(s[3].x, s[3].y, s[7].x, s[7].y);
    line(s[3].x, s[3].y, s[2].x, s[2].y);
    line(s[2].x, s[2].y, s[1].x, s[1].y);
    line(s[2].x, s[2].y, s[6].x, s[6].y);
    line(s[6].x, s[6].y, s[7].x, s[7].y);
    line(s[1].x, s[1].y, s[5].x, s[5].y);
    line(s[5].x, s[5].y, s[4].x, s[4].y);
    line(s[5].x, s[5].y, s[6].x, s[6].y);
    line(s[1].x, s[1].y, s[0].x, s[0].y);
    line(s[4].x, s[4].y, s[7].x, s[7].y);
}
}

class My3DBox {
My3DPoint[] p;
My3DBox(My3DPoint origin, float dimX, float dimY, float dimZ){
float x = origin.x;
float y = origin.y;
float z = origin.z;
this.p = new My3DPoint[]{new My3DPoint(x,y+dimY,z+dimZ),
new My3DPoint(x,y,z+dimZ),
new My3DPoint(x+dimX,y,z+dimZ),
new My3DPoint(x+dimX,y+dimY,z+dimZ),
new My3DPoint(x,y+dimY,z),
origin,
new My3DPoint(x+dimX,y,z),
new My3DPoint(x+dimX,y+dimY,z)
};
}
My3DBox(My3DPoint[] p) {
this.p = p;
}
}

My2DBox projectBox (My3DPoint eye, My3DBox box) {
 
  My2DPoint[] projection = new My2DPoint[box.p.length];
  
  for(int i = 0; i<box.p.length; ++i)
  {
      projection[i] = projectPoint(eye, box.p[i]);
  }
  return new My2DBox(projection);
  
}

// adds a final coordinate of 1, returning a 1x4 matrix
float[] homogeneous3DPoint (My3DPoint p) {   
float[] result = {p.x, p.y, p.z , 1};
return result;
}

float[][] rotateXMatrix(float angle) {
    
    return(new float[][] {{1, 0 , 0 , 0},
                          {0, cos(angle), sin(angle) , 0},
                          {0, -sin(angle) , cos(angle) , 0},
                          {0, 0 , 0 , 1}});
}

float[][] rotateYMatrix(float angle) {
  
  return(new float[][] {{cos(angle), 0 , -sin(angle) , 0},
                        {0, 1, 0, 0},
                        {sin(angle), 0 , cos(angle) , 0},
                        {0, 0 , 0 , 1}});
  
}
float[][] rotateZMatrix(float angle) {

     return(new float[][] {{cos(angle), sin(angle), 0 , 0},
                        {-sin(angle), cos(angle), 0, 0},
                        {0, 0 , 1, 0},
                        {0, 0 , 1, 1}});
}
float[][] scaleMatrix(float x, float y, float z) {

    return(new float[][]{{x, 0, 0, 0},
                          {0, y, 0, 0},
                           {0, 0, z, 0},
                           {0, 0, 0, 1} });
  
  
}
float[][] translationMatrix(float x, float y, float z) {

  return(new float[][]{{1, 0, 0, x},
                       {0, 1, 0, y},
                       {0, 0, 1, z},
                       {0, 0, 0, 1} });
  
}

float[] matrixProduct(float[][] a, float[] b) {

  float[] result = new float[a.length];
  float sum = 0;
  
  for(int i = 0; i<a.length; ++i)
  {
     for(int j = 0; j< a[0].length; ++j)
     {
          sum += a[i][j]*b[j];
     }
     
     result[i] = sum;
     sum = 0;
  }
  
  return result;
  
}

My3DPoint euclidian3DPoint (float[] a) {
My3DPoint result = new My3DPoint(a[0]/a[3], a[1]/a[3], a[2]/a[3]);
return result;
}

My3DBox transformBox(My3DBox box, float[][] transformMatrix) {
  
  My3DPoint[] result = new My3DPoint[box.p.length];
  
  for(int i = 0; i<box.p.length; ++i)
  {
      result[i] = euclidian3DPoint(matrixProduct(transformMatrix, homogeneous3DPoint(box.p[i])));
  }
  
  return new My3DBox(result);
  
}