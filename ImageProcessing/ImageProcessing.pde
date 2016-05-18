import java.util.Collections;
PImage img;
PImage result;
PImage resIntensity;
PImage edgeImg;

float[][] convolutionKernel = { { 0, 0, 0 }, { 0, 2, 0}, { 0, 0, 0}};
float [][] gaussianKernel = {{9, 12, 9}, {12, 15, 12}, {9, 12, 9}};

int nLines = 10;
QuadGraph quadgraph = new QuadGraph();

//because we draw all the results on one window, we want the lines to be drawn only on the first picture and not to be seen on the next ones
//so we draw them separately on a surface of size of the original picture
PGraphics linesImg;

void settings() {
  size(2000, 600);
}

void setup() {
  
  img = loadImage("board1.jpg");
  result = createImage(img.width, img.height, ALPHA);
  resIntensity = createImage(img.width, img.height, ALPHA);
  edgeImg = createImage(img.width, img.height, ALPHA);
  quadgraph = new QuadGraph();
  linesImg = createGraphics(img.width, img.height);
  noLoop(); // no interactive behaviour: draw() will be called only once.
}

void draw() { 
 
  //HSB thresholding
  HSBMapping(img);
  
  //bluring and then intensity thresholding
  intensityThresholding(convolute(result, gaussianKernel, false));
  
  //edge detection, sobel result in the image 'edgeImg'
  sobel(resIntensity);
  
  //displaying the image
  image(img, 0, 0);
  image(edgeImg, 1200, 0);
  getIntersections(quadgraph.drawQuads(hough(edgeImg, nLines)));
  //drawing the orange lines separately at the end
  image(linesImg, 0, 0);
}

//Function needed for the beggining of the first Image processing assignment
void binaryFilter(PImage original, color c1, color c2, float threshold)
{ 
  for (int i = 0; i < original.width * original.height; ++i) {

    original.loadPixels();
    result.loadPixels();
    if (brightness(original.pixels[i]) < threshold)
    {
      result.pixels[i] = c1;
    } else
    {
      result.pixels[i] = c2;
    }
  }

  result.updatePixels();
}

//Function needed for the beggining of the first Image processing assignment
void invertedBinaryFilter(PImage original, color c1, color c2, float threshold)
{
  binaryFilter(original, c2, c1, threshold); //we just change the colors
}

//Function needed for the beggining of the first Image processing assignment
void hueMapping(PImage original, float lowerBound, float upperBound)
{
  float hueValue;
  result.loadPixels();
  original.loadPixels();

  for (int i = 0; i < original.width * original.height; ++i)
  {
    hueValue = hue(original.pixels[i]);
    if (hueValue >= lowerBound && hueValue <= upperBound)
    {
      result.pixels[i] = original.pixels[i];
    } else
    {
      result.pixels[i] = color(hueValue);
    }
  }
  result.updatePixels();
}


PImage convolute(PImage original, float[][] kernel, boolean blurInColor) {
  // create a greyscale image (type: ALPHA) for output
  PImage resultBlured = createImage(img.width, img.height, ALPHA);
  float weight = kernelWeight(kernel);

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
      if(xPosition >= img.width || xPosition < 0) continue;
      
      int yPosition = y + j - offset;
      if(yPosition >= img.height || yPosition < 0) continue;
      
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

void sobel(PImage img) {

  float[][] hKernel = { { 0, 1, 0 }, { 0, 0, 0 }, { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, { 1, 0, -1 }, { 0, 0, 0 } };

  img.loadPixels();
  edgeImg.loadPixels();

  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    edgeImg.pixels[i] = color(0);
  }

  float max = 0;
  float[] buffer = new float[img.width * img.height];

  float sumH = 0;
  float sumV = 0;
  float compoundSum = 0;

  PImage resultH = convolute(img, hKernel, false);
  PImage resultV = convolute(img, vKernel, false);

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
        edgeImg.pixels[y * img.width + x] = color(255);
      } else {
        edgeImg.pixels[y * img.width + x] = color(0);
      }
    }
  }

  edgeImg.updatePixels();
}

void HSBMapping(PImage img) {

  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width*img.height; ++i) {

    int s = img.pixels[i];
    //filtering the green hue and the small values of the saturation
    if (hue(s) < 70 || hue(s) > 137 || saturation(s) < 60) {
      result.pixels[i] = color(0);
    } else {
      result.pixels[i] = color(255);
    }
  }
  result.updatePixels();
}

void intensityThresholding(PImage img){
  
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
}