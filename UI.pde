import processing.serial.*;
import org.gicentre.utils.stat.*;
import org.gicentre.utils.colour.*;
import java.util.*;
import controlP5.*;
Serial myPort;

//initial global variables
GUI gui;
Slider slider;
Button button;
DropdownList navList;
color color1;
color color2;
String[] navMenuItems;
int userAge;
int maxHeartRate = 220 - userAge;
PFont font;

float avgBPM = 69; 
int highestBPM = 1;
int restingBPM = 9999;  
int currentHeartRate = 0;
int timeInterval = 1000;
int totalTime = 1;
int peakTime = 1;
int cardioTime = 1;
int fatBurnTime = 1;
int exerciseTime = peakTime + cardioTime + fatBurnTime;

ArrayList<Float> heartRateData = new ArrayList<>();
ArrayList<Float> dynamicArray = new ArrayList<>(); 

float[] heartColors = {0.1, 0.3, 0.6};
XYChart heartRateChart;
ColourTable cTable1, cTable2, cTable3;

//ControlP5 cp5;

void setup() {
  size(800,800);
  color1 = color(50,50,128);
  color2 = color(50,50,128);
  background(117, 121, 186);
  
  cTable1 = new ColourTable();
  cTable1.addContinuousColourRule(0.25, 75, 163, 85);
  cTable1.addContinuousColourRule(0.5, 230, 189, 41);
  cTable1.addContinuousColourRule(0.9, 227, 82, 82);
  
  gui = new GUI(this);
  font = createFont("Arial", 12);
  gui.cp5.setFont(font);
  
  //
  //submitAge
  //
  gui.cp5.addTextfield("ageInput")
     .setPosition(20, 80)
     .setSize(40, 40)
     .setFont(createFont("arial", 18))
     .setAutoClear(false)
     .setLabel("Enter your age")
     .setText("");
     
  gui.cp5.addButton("submitAge")
     .setPosition(80, 80)
     .setSize(100, 40)
     .setLabel("Submit");
  //
  //navBar
  //
  navList = gui.cp5.addDropdownList("navList")
    .setItemHeight(30)
    .setBarHeight(30)
    .setColorBackground(color(60))
    .setColorActive(color(255, 128))
    .setColorForeground(color(100));
  navList.addItem("Fitness Mode", 0);
  navList.addItem("Stress Monitoring Mode", 1);
  navList.addItem("Meditation Mode", 2);
  navList.setOpen(false);
  navList.setCaptionLabel("Select Mode");
  navList.setPosition(20,15).setSize(200,200);
  //
  //heart rate tracker
  //
  heartRateChart = new XYChart(this);
  heartRateChart.setMinX(0);
  heartRateChart.setMaxX(50);
  heartRateChart.setMinY(0);
  heartRateChart.setMaxY(200);
  heartRateChart.showXAxis(true);
  heartRateChart.showYAxis(true);
  heartRateChart.setPointColour(heartColors, cTable1);
  heartRateChart.setLineWidth(1);
  heartRateChart.setPointSize(5);

}

void draw() {
  //draw the navBar
  fill(117, 121, 186);
  rect(0, 0,width, height);
  noStroke();
  fill(color2);
  rect(0, 0,width, height/20 + 20);
  fill(255,255,255);
  textSize(20);
  text("Your age is: " + userAge, 20, 180);
  
  //
  //normal heart chart
  //
  textAlign(LEFT);
  textSize(18);
  text("Heart Rate", 20, 400);
  textSize(16);
  text("Avg BPM: " + (int) avgBPM, 20, 420);
  text("Highest BPM: " + (int) highestBPM, 160, 420);

  if (restingBPM >= 9999) {
    text("Resting BPM: Calibrating...", 20, 440); 
  } else {
    text("Resting BPM: " + restingBPM, 320, 420);
  }
  
  updateHeartRate();
  
  float[] floatHeart = new float[heartRateData.size()];
  for (int i = 0; i < heartRateData.size(); i++) {
    floatHeart[i] = heartRateData.get(i);
  }
  
  int[] intArray = rangeArray(heartRateData.size());
  float[] floatArray = new float[intArray.length];
  for (int i = 0; i < intArray.length; i++) {
    floatArray[i] = (float) intArray[i];
  }
  
  heartRateChart.setData(floatArray, floatHeart);
  
  float[] yVal = new float[dynamicArray.size()];
  for (int k = 0; k < dynamicArray.size(); k++) {
    yVal[k] = dynamicArray.get(k);
  }
  heartRateChart.setPointColour(yVal, cTable2);
  fill(color(255,255,255));
  heartRateChart.draw(50, 450, width - 100, 200);
  
  totalTime++;

  
}


class GUI {
  ControlP5 cp5;
  GUI(PApplet thePApplet) {
    cp5 = new ControlP5(thePApplet);
  }
}

void submitAge() {
  String input = gui.cp5.get(Textfield.class, "ageInput").getText();
  try {
    userAge = Integer.parseInt(input);
    println("Age updated to: " + userAge);
  } catch (NumberFormatException e) {
    println("Please enter a valid number");
  }
}


void updateHeartRate() {
  float newBPM = (float) currentHeartRate;
  if (newBPM <= 5) {
    return; 
  }
  heartRateData.add(newBPM);
  float sum = 0;
  for (float bpm : heartRateData) {
    sum += bpm;
  }
  avgBPM = sum / heartRateData.size();
  if (newBPM > highestBPM) {
    highestBPM = (int)newBPM;
  }
  if (newBPM < restingBPM) {
    restingBPM = (int)newBPM;
  }
  if (newBPM < maxHeartRate * 0.50) {
    dynamicArray.add(0.25);
  } else if (newBPM < maxHeartRate * 0.70) {
    dynamicArray.add(0.5);
    fatBurnTime++;
  } else if (newBPM < maxHeartRate * 0.90) {
    dynamicArray.add(0.75);
    cardioTime++;
  } else {
    dynamicArray.add(0.9);
    peakTime++;
  }
  
  if (heartRateData.size() > 50) {
    heartRateData.remove(0);
    dynamicArray.remove(0);
  }
  
  exerciseTime = peakTime + cardioTime + fatBurnTime;
}

int findHighestHeartRate() {
  int maxVal = 0;
  int index = 0;
  for (int i = 0; i < heartRateData.size(); i++) {
    if (heartRateData.get(i) > maxVal) {
      maxVal = (int)(float)heartRateData.get(i);
      index = i;
    }
  }
  return index;
}

int[] rangeArray(int size) {
  int[] range = new int[size];
  for (int i = 0; i < size; i++) {
    range[i] = i * 50 / size;
  }
  return range;
}

String formatTime(int seconds) {
  int mins = seconds / 60;
  int secs = seconds % 60;
  return nf(mins, 2) + ":" + nf(secs, 2) + " mins";
}



void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController() && theEvent.getController() == navList) {
    int selectedMode = (int)theEvent.getController().getValue();
    switch(selectedMode) {
      case 0:
        println("Switching to Fitness Mode");
        // Add code to switch to Fitness Mode
        break;
      case 1:
        println("Switching to Stress Monitoring Mode");
        // Add code to switch to Stress Monitoring Mode
        break;
      case 2:
        println("Switching to Meditation Mode");
        // Add code to switch to Meditation Mode
        break;
    }
  }
}
