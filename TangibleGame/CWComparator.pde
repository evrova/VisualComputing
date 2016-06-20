import java.util.Collections;
import java.util.Comparator;

//added static
static class CWComparator implements Comparator<PVector> {

    PVector center;
    
    public CWComparator(PVector center) {
    this.center = center;
    }
    
    @Override
    public int compare(PVector b, PVector d) {
    if(Math.atan2(b.y-center.y,b.x-center.x)<Math.atan2(d.y-center.y,d.x-center.x))
      return -1;
    else return 1;
    }
  }
    public static List<PVector> sortCorners(List<PVector> quad){
    // Sort corners so that they are ordered clockwise
    
    
     try{
    PVector a = quad.get(0);
    PVector b = quad.get(2);
    PVector center = new PVector((a.x+b.x)/2,(a.y+b.y)/2);
    Collections.sort(quad, new CWComparator(center));
   
    // TODO:   
    // Re-order the corners so that the first one is the closest to the
    // origin (0,0) of the image.
    //
    // You can use Collections.rotate to shift the corners inside the quad.
    
    float dist = Float.MAX_VALUE;
    int index = 0;
    float currDist;
    float xPos;
    float yPos;
    for(int i = 0; i < 4; i++){
      
      xPos = quad.get(i).x;
      yPos = quad.get(i).y;
      
      currDist = xPos*xPos + yPos*yPos;
      if(currDist < dist){
          dist = currDist;
          index = i;
      }
    }
    
    Collections.rotate(quad, -index);
    }
    catch(IndexOutOfBoundsException e){
      System.out.println("The quad does not contain intersections yet");
      List<PVector> zeroes = new ArrayList<PVector>();
      
      for(int i = 0; i < 4; i++){
        zeroes.add(new PVector(0, 0));
      }
      return zeroes;
      
    }
    return quad;
    
    }