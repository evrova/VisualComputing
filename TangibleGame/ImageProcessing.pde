import processing.video.*;
import java.io.File;
import java.util.Collections;



class ImageProcessing extends PApplet{
Movie cam;
PImage img;

//reference to the new Image in HSBMapping
PImage result;
PImage resIntensity;
PImage edgeImg;

float brightThreshold;
float THRESHOLD_MAX = 270;

float hueLowerBound;
float hueUpperBound;
float[][] convolutionKernel = { { 0, 0, 0 }, { 0, 2, 0}, { 0, 0, 0}};
float [][] gaussianKernel = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};

int nLines = 6;
QuadGraph quad;
List<PVector> lines;

TwoDThreeD projector;
List<PVector> intersectionsQuad;

PGraphics linesImg;
boolean b;

void settings(){
  size(640, 480);
}

void setup() {
  quad = new QuadGraph();
  projector = new TwoDThreeD(640, 480);
  intersectionsQuad = new ArrayList<PVector>();
  intersectionsQuad.add(new PVector(0, 0));
  intersectionsQuad.add(new PVector(0, 0));
  intersectionsQuad.add(new PVector(0, 0));
  intersectionsQuad.add(new PVector(0, 0));
    
  //String[] cameras = Capture.list();
  //if (cameras.length == 0) {
  //    println("There are no cameras available for capture.");
  //    exit();
  //} else {
  //    println("Available cameras:");
  //    for (int i = 0; i < cameras.length; i++) {
  //    println(cameras[i]);
  //}
  //cam = new Capture(this, cameras[0]);
  //cam.start();
  //cam = new Movie(this, "testvideo.mp4"); //Put the video in the same directory
  try{
    File f = new File("testvideo.mp4");
    b = f.exists();
    System.out.println(b);
    if(b){
    cam = new Movie(this, f.getAbsolutePath());
    }
  }catch(Exception e){
    e.printStackTrace();
  }
  cam.loop();
  //edgeImg = createImage(640, 480, ALPHA);
  linesImg = createGraphics(700, 480);
  }



void draw() { 
 
  
  if(b){
  if (cam.available() == true) {
    cam.read();
  }
      img = cam.get();
      img.loadPixels();
      //image(img, 0, 0);
      edgeImg = sobel(intensityThresholding(convolute(HSBMapping(img), gaussianKernel, false)));
      lines = hough(edgeImg, nLines);
      
      image(edgeImg, 0, 0);
      //drawing the orange lines separately
      //image(linesImg, 0, 0);
      //linesImg.clear();

      intersectionsQuad = getIntersections((quad.drawQuads(lines)));
     
  }
}

//TODO
List<PVector> getCorners(){
      
 List<PVector> sortedCorners = null;
 
 
     sortedCorners = sortCorners(intersectionsQuad);
 
      return sortedCorners;

}

PVector getRotation(){
    
    List<PVector> sortedCorners = getCorners();
    PVector rot = null;
    if(sortedCorners.size() >= 4){
     rot = projector.get3DRotations(sortedCorners);
    
    }
    return rot;
}

PImage convolute(PImage original, float[][] kernel, boolean blurInColor) {
  // create a greyscale image (type: ALPHA) for output
  PImage resultBlured = createImage(img.width, img.height, ALPHA);
  float weight = kernelWeight(kernel);

  original.loadPixels();
  resultBlured.loadPixels();

  // for each (x,y) pixel in the image
  for (int x = 0; x < original.width; ++x)
  {
    for (int y = 0; y < original.height; ++y)
    {
      // - set result.pixels[y * img.width + x] to the value
      resultBlured.pixels[y*original.width + x] = convolutionValue(original, x, y, kernel, weight, blurInColor);
    }
  }

  resultBlured.updatePixels();

  return resultBlured;
}

color convolutionValue(PImage original, int x, int y, float[][] kernel, float weight, boolean blurInColor)
{ 
  int N = 3;
  int offset = N/2;
  float red = 0f;
  float green = 0f;
  float blue = 0f;
  float brightness = 0f;

  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix

   original.loadPixels();
   
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {

      int xPosition = x + i - offset;
      int yPosition = y + j - offset;
      int pixelPosition = xPosition + original.width*yPosition;

      pixelPosition = constrain(pixelPosition, 0, original.pixels.length - 1);

      // - sum all these intensities

      if (blurInColor) {
        red += (red(original.pixels[pixelPosition]) * kernel[i][j]);
        green += (green(original.pixels[pixelPosition]) * kernel[i][j]);
        blue += (blue(original.pixels[pixelPosition]) * kernel[i][j]);
      } else { 
        brightness += (brightness(original.pixels[pixelPosition]) * kernel[i][j]);
      }
    }
  }

  if (blurInColor)
  {
    red = Math.abs(red)/weight;
    green = Math.abs(green)/weight;
    blue = Math.abs(blue)/weight;
    //- and divide them by the weight
    return color(red, green, blue);
  }
  //if grayscale
  brightness = Math.abs(brightness)/weight;
  brightness = constrain(brightness, 0, 255);
  return color(brightness);
}

float kernelWeight(float [][] kernel)
{
  float sum = 0;
  for (int i = 0; i < kernel.length; i++) {
    for (int j = 0; j < kernel[0].length; j++) {
      sum += Math.abs(kernel[i][j]);
    }
  }
  return sum;
}

PImage sobel(PImage img) {

  float[][] hKernel = { { 0, 1, 0 }, { 0, 0, 0 }, { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, { 1, 0, -1 }, { 0, 0, 0 } };

  PImage res = createImage(img.width, img.height, ALPHA);

  img.loadPixels();

  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    res.pixels[i] = color(0);
  }

  float max = 0;
  float[] buffer = new float[img.width * img.height];

  float sumH = 0;
  float sumV = 0;
  float compoundSum = 0;

  PImage resultH = convolute(img, hKernel, false);
  PImage resultV = convolute(img, vKernel, false);

  resultH.loadPixels();
  resultV.loadPixels();

  for (int x = 0; x < img.width; x++) { 
    for (int y = 0; y < img.height; y++) {

      sumH =  brightness(resultH.pixels[x + y*img.width]);
      sumV = brightness(resultV.pixels[x + y*img.width]);

      compoundSum = sqrt(pow(sumH, 2) + pow(sumV, 2));

      buffer[x + y*img.width] = compoundSum;

      if (max < compoundSum) {
        max = compoundSum;
      }
    }
  }

  for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges
    for (int x = 1; x < img.width - 1; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        res.pixels[y * img.width + x] = color(255);
      } else {
        res.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return res;
}

PImage HSBMapping(PImage img) {
  img.loadPixels();
  result = createImage(img.width, img.height, ALPHA);
  result.loadPixels();
  for (int i = 0; i < img.width*img.height; ++i) {

    int s = img.pixels[i];
    //filtering the green hue and the small values for the saturation
    if (hue(s) < 80 || hue(s) > 137 || saturation(s) < 90 || brightness(s) < 35) {
      result.pixels[i] = color(0);
    } else {
      result.pixels[i] = color(255);
    }
  }
  result.updatePixels();
  return result;
}

PImage intensityThresholding(PImage img){
  
  resIntensity = createImage(img.width, img.height, ALPHA);
  
  img.loadPixels();
  resIntensity.loadPixels();
  
  for(int i = 0; i < img.width*img.height; ++i){
    if(brightness(img.pixels[i]) < 253){
      resIntensity.pixels[i] = color(0);
    }
    else{
      resIntensity.pixels[i] = color(255);
    }
  }
 resIntensity.updatePixels();
 return resIntensity;
}

List<PVector> hough(PImage edgeImg, int nLines) {
  
  List<PVector> lines = new ArrayList<PVector>();
  
  //we decrease it to 150 because after the intensity thesholding we will have less lines detected
  int minVotes = 100;
  
  //changed the discretization values
  float discretizationStepsPhi = 0.03f;
  float discretizationStepsR = 1f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  
  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;
  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
  // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
  tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
  tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
}
  
  edgeImg.loadPixels();
  
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        // ...determine here all the lines (r, phi) passing through pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
      float r = 0;
      
      for (int accPhi = 0; accPhi < phiDim; accPhi++) {

      r = (x*tabCos[accPhi] + y*tabSin[accPhi]);
      // Be careful: r may be negative, so you may want to center onto
      // the accumulator with something like: r += (rDim - 1) / 2
      int accR = (int)r + (rDim - 1)/2;
      //accPhi + 1 because n starts from 0
      accumulator[(accPhi+1)*(rDim + 2) + accR + 1] += 1;
    }   
   }
 }
}

  List<Integer> bestCandidates = new ArrayList<Integer>();
 
 //Extract the maximum of the local lines
 
   // size of the region we search for a local maximum
  int neighbourhood = 10;
  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {
    // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;
      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;
    // iterate over the neighbourhood
        for(int dPhi=-neighbourhood/2; dPhi < neighbourhood/2+1; dPhi++) {
            // check we are not outside the image
        if( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
            for(int dR=-neighbourhood/2; dR < neighbourhood/2 +1; dR++) {
              
              // check we are not outside the image
            if(accR+dR < 0 || accR+dR >= rDim) continue;
            int neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;
            if(accumulator[idx] < accumulator[neighbourIdx]) {
            // the current idx is not a local maximum!
            bestCandidate=false;
            break;
            }
            }
            if(!bestCandidate) break;
   }
    if(bestCandidate) {
    // the current idx *is* a local maximum
    bestCandidates.add(idx);
    }
    }
  }
}
  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  
  for (int n = 0; n < min(nLines, bestCandidates.size()); n++) {
    
    // first, compute back the (r, phi) polar coordinates:
    
      int accPhi = (int) (bestCandidates.get(n) / (rDim + 2)) - 1;
      int accR = bestCandidates.get(n) - (accPhi + 1) * (rDim + 2) - 1;
      
      
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      
      // compute the intersection of this line with the 4 borders of
      // the image
      
      //int x0 = 0;
      //int y0 = (int) (r / tabSin[accPhi]);
      //int x1 = (int) (r / tabCos[accPhi]);
      //int y1 = 0;
      //int x2 = edgeImg.width;
      //int y2 = (int) (-tabCos[accPhi] / tabSin[accPhi] * x2 + r / tabSin[accPhi]);
      //int y3 = edgeImg.width;
      //int x3 = (int) (-(y3 - r / tabSin[accPhi]) * (tabSin[accPhi]) / tabCos[accPhi]);
      
      // Finally, plot the lines
      
      //we add the definitive lines in the array to be returned
      lines.add(new PVector(r, phi));
   
      //stroke(204,102,0);
      //if (y0 > 0) {
      //if (x1 > 0)
      //line(x0, y0, x1, y1);
      //else if (y2 > 0)
      //line(x0, y0, x2, y2);
      //else
      //line(x0, y0, x3, y3);
      //}
      //else {
      //if (x1 > 0) {
      //if (y2 > 0)
      //line(x1, y1, x2, y2);
      //else
      //line(x1, y1, x3, y3);
      //}
      //else
      //line(x2, y2, x3, y3);
      //}
      
  houghAccumulator(accumulator, rDim, phiDim);
    
  
}
return lines;
}
//visualization of the Accumulator, to see it change return type of the hough method to PImage and set the draw accordingly
void houghAccumulator(int[] accumulator, int rDim, int phiDim){
  
  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
  houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(400, 480);
  houghImg.updatePixels();

  image(houghImg, 640, 0);
}

ArrayList<PVector> getIntersections(List<PVector> lines) {
  
 
  ArrayList<PVector> intersections = new ArrayList<PVector>();

  for (int i = 0; i < lines.size() - 1; i++) {
    PVector line1 = lines.get(i);
    for (int j = i + 1; j < lines.size(); j++) {
      PVector line2 = lines.get(j);
      
      PVector inter = intersection(line1, line2);
      
      fill(255, 128, 0);
      //we add the condition to avoid drawing the intersection far away from the picture
      if(inter.x < 800 && inter.y < 600 && inter.x > 0 && inter.y > 0){
        intersections.add(inter);
        ellipse(inter.x, inter.y, 10, 10);
      }
    }
  }
  return intersections;
}
}