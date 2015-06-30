import controlP5.*; //<>// //<>//
import processing.pdf.*;
PGraphics pdf;
PFont myFont;
float margin = 50;
float paperWidthIn = 8.5; //inches
float paperHeightIn = 11; //inches
int desiredDPI = 300; //pixels per inch
int paperWidthPx = int(paperWidthIn * desiredDPI);
int paperHeightPx = int(paperHeightIn * desiredDPI);
// how many folds you want to create for your zine
int widthFolds = 1;
int heightFolds = 1;
int pageWidthPx = paperWidthPx / (int)Math.pow(2, widthFolds);
int pageHeightPx = paperHeightPx / (int)Math.pow(2, heightFolds);
int compWidthPx = pageWidthPx * 2;
int compHeightPx = pageHeightPx;
//how many pages you plan to print on, 
//so for a quarter size book each printer page represents 8 of the book pages
int printerPages = 2; // double sided
int numPages = (int)Math.pow(2, widthFolds) * (int)Math.pow(2, heightFolds) * 2 * printerPages;
int numCompositions = numPages/2 + 1;//front and back covers are only 1 page

int topMargin = 200;
int bottomMargin = 300;
int centerLeft = 50;
int centerRight = 50;
String bookTitle = "Sensory Aesthetics";
Composition[] pages = new Composition[numCompositions];

/*
 *  SensoryZine001.pde
 *  
 *  SUMMARY: A first attempt at a generative zine creation tool.
 *
 *  DESCRIPTION: Define a size, dpi, and number of folds and the 
 *  program will output a pdf. 
 * 
 *  Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php 
 */

/* NOTES AND TODO

Define the data model and then it puts itself together right? right?!? ;-(
  paper width 8.5
  paper height 11 
  desired dpi 300
  size 0.5 (half size), 0.25 (quarter size), 0.0833 (one twelfth), 0.0625 (one sixteenth)
  top margin
  bottom margin
  centerleft margin
  centerright margin
  number of pages (dependent on size)

Take the parameters and generate the first page which 
is just some summary info and each of the spreads.

Then paginate and layout the book for printing in the subsequent pages.

Eventually we can use the processing window to show the controls

Lets special case the cover

We should make textbox class - the one in controlP5 has rendering problems
*/


void setup() {
  size(400, 400);
  noLoop();
  pdf = createGraphics(paperWidthPx, paperHeightPx, PDF, "sensory.pdf");
  
  println ("Your zine will have "+numPages+" pages");
  //// CHECK WHAT FONTS ARE ON THE SYSTEM
  //String[] fontList = PFont.list();
  //println(fontList);
  
  pdf.beginDraw();
  PGraphicsPDF pdfg = (PGraphicsPDF) pdf; // Get the renderer

  // Create a set of Compositions
  pages[0] = new Composition(1, pageWidthPx, pageHeightPx);
  pages[numCompositions - 1] = new Composition(numCompositions, pageWidthPx, pageHeightPx);
  for (int k=2; k < numCompositions; k++) {
    pages[k-1] = new Composition(k, pageWidthPx * 2, pageHeightPx); 
  }
  println("---------------------");
  
  
  coverPage();
  
  ZinePageLayout[][][] zpl = getLayout(heightFolds, widthFolds, printerPages*2);
  printLayout(zpl);
  for(int page = 0; page < zpl.length; page++){
    pdfg.nextPage();  // Tell it to go to the next page
    pdfg.endDraw();
    PGraphics paperg = createGraphics(paperWidthPx, paperHeightPx);
    paperg.beginDraw();
    for(int row = 0; row < zpl[0].length; row++){
      for(int cell = 0; cell < zpl[0][0].length; cell++){
        ZinePageLayout cpg = zpl[page][row][cell];
        int compI = cpg.getNumber()/2;
        boolean leftComp = (compI == 0 || cpg.getNumber()%2 == 0);
        Composition comp = pages[compI];
        if (cpg.getHFlip()){
          paperg.copy(comp.getPage(),
            leftComp ? pageWidthPx : (pageWidthPx*2), pageHeightPx, -pageWidthPx, -pageHeightPx,
            pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
        } else {
          paperg.copy(comp.getPage(), 
            leftComp ? 0 : pageWidthPx, 0, pageWidthPx, pageHeightPx, 
            pageWidthPx * cell, pageHeightPx * row, pageWidthPx, pageHeightPx);
        }
      }
    }
    paperg.endDraw();
    pdf.beginDraw();
    pdf.image(paperg, 0, 0);
  }
  
  myFont = createFont("DINPro-Black", 48);
  textFont(myFont);
  textAlign(CENTER, CENTER);
  
  pdf.dispose();
  pdf.endDraw();
  
  println("PDF output");

}

void coverPage() {
  // Create the cover page
  pdf.background(255);
  myFont = createFont("DINPro-Black", 48);
  pdf.textFont(myFont);
  textAlign(CENTER, CENTER);
  pdf.fill(0);
  pdf.textSize(48);
  int reportHeight = 100;
  int reportSpace = 100;
  int reportX = 100;
  int column2 = reportX+1500;
  pdf.text(bookTitle, 100, reportHeight);
  reportHeight += reportSpace;
  pdf.text("This book is "+paperWidthIn+" in. wide x "+paperHeightIn+" in. height", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("Targeting a DPI of: " + desiredDPI, reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("It should be folded "+widthFolds+" time on the width and "+heightFolds+" on the height.", reportX, reportHeight);
  reportHeight += reportSpace;
  pdf.text("In order to bind the "+numPages+" pages using "+printerPages+" printer pages.", reportX, reportHeight);
  
  pdf.noFill();
  
  float tXPos = 0;
  float tYPos = 50;
  for (int k=0; k<numCompositions; k++) { // this repeats for each spread
      
    // even or odd to set the x
    if (k == 0){
      tXPos = column2 + pages[k].getWidth()/10;
    } else {
      tXPos = column2;
    }
    
    pdf.image(pages[k].getPage(), tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
    pdf.rect(tXPos, tYPos, pages[k].getWidth()/10, pages[k].getHeight()/10);
    tYPos += 300;
    
  }
  
}

void draw() {}