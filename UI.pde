import processing.serial.*;
import org.gicentre.utils.stat.*;
import org.gicentre.utils.colour.*;
import java.util.*;
import controlP5.*;

Serial myPort;

//test sine wave
int xspacing = 16;   // How far apart should each horizontal location be spaced
int w;              // Width of entire wave

float theta = 0.0;  // Start angle at 0
float amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] yvalues = new float[100];  // Using an array to store height values for the wave
float[] xvalues = new float[100];  // Using an array to store height values for the wave... //initial global variables
//
// licking books at a bookstore
//
GUI gui;
Slider slider;
Button button;
DropdownList navList;
BarChart barChart;
color color1;
color color2;
color color3;
String[] navMenuItems;
int userAge;
int maxHeartRate = 220 - userAge;
PFont font;
//flags for modes
boolean fitnessMode = false;
boolean stressMode = false;
boolean meditationMode = false;
boolean customMode = false;

//
// Heart Rate numbers
//
float avgBPM = 69;
int highestBPM = 1;
int restingBPM = 9999;
int currentHeartRate = 0;
int timeInterval = 1000;
int totalTime = 1;
int maximumTime = 1;
int hardTime = 1;
int moderateTime = 1;
int lightTime = 1;
int veryLightTime = 1;
int exerciseTime = maximumTime + hardTime + moderateTime + lightTime + veryLightTime;
//
// fitness mode monitoring
//
//
// lab 2 sensors
//
int forcePressure = 1;
int heartSensor = 1;
int[] ecgX;
int [] ecgY;

ArrayList<Float> heartRateData = new ArrayList<>();
ArrayList<Float> dynamicArray = new ArrayList<>();

float[] heartColors = {0.1, 0.3, 0.6};
XYChart heartRateChart;
ColourTable cTable1,cTable2, cTable3;

//ControlP5 cp5;

// Bar chart specific data and colors
float[] zones = {0.25, 0.35, 0.40, 0.50, 1.0}; // Sample zone data (adjust as needed)
float[] zoneColors = {0.2,0.3,0.6,0.8,1.0};
String[] zoneLabels = {"Maximum", "Peak", "Moderate", "Light", "Very Light"};

void setup() {
  size(1600, 800);
  color1 = color(50, 50, 128);
  color2 = color(50, 50, 128);
  color3 = color(255, 255, 255);
  background(117, 121, 186);

  cTable1 = new ColourTable();
  cTable1.addContinuousColourRule(1.0, 150, 150, 150);  // Grey
  cTable1.addContinuousColourRule(0.80, 0, 0, 200);    // Blue
  cTable1.addContinuousColourRule(0.60, 0, 200, 0);    // Green
  cTable1.addContinuousColourRule(0.30, 200, 200, 0);  // Yellow
  cTable1.addContinuousColourRule(0.20, 200, 0, 0);    // Red
  
  cTable2 = new ColourTable();
  cTable2.addContinuousColourRule(1.0, 150, 150, 150);  // Grey
  cTable2.addContinuousColourRule(0.80, 0, 0, 200);    // Blue
  cTable2.addContinuousColourRule(0.60, 0, 200, 0);    // Green
  cTable2.addContinuousColourRule(0.30, 200, 200, 0);  // Yellow
  cTable2.addContinuousColourRule(0.20, 200, 0, 0);    // Red

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
  navList.addItem("Custom Mode", 3);
  navList.setOpen(false);
  navList.setCaptionLabel("Select Mode");
  navList.setPosition(20, 15).setSize(200, 200);
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
  heartRateChart.setLineWidth(1);
  heartRateChart.setPointSize(5);
  heartRateChart.setLineColour(color3);
  heartRateChart.setPointColour(yvalues, cTable1);
  heartRateChart.setAxisColour(color3);
  heartRateChart.setAxisValuesColour(color3);
  heartRateChart.setXAxisLabel("Minutes");
  heartRateChart.setYAxisLabel("BPM");
  heartRateChart.setAxisLabelColour(color3);

  // Initialize giCentre BarChart with 5 bars

  barChart = new BarChart(this);
  barChart.setData(zones);
  
  //set individual bar colours
  barChart.setBarColour(zoneColors, cTable2);

  // Scaling
  barChart.setMinValue(0);
  barChart.setMaxValue(1);

  // Axis appearance
  textFont(createFont("Arial", 12), 12);
  barChart.setValueFormat("#%");
  barChart.setBarLabels(zoneLabels);
  barChart.showCategoryAxis(true);
  barChart.setBarGap(4);
  barChart.setAxisColour(color3);
  barChart.setAxisValuesColour(color3);
  // Layout
  barChart.transposeAxes(true);
}

void draw() {
  //draw the navBar
  fill(117, 121, 186);
  rect(0, 0, width, height);
  noStroke();
  fill(color2);
  rect(0, 0, width, height/20 + 20);
  fill(255, 255, 255);
  textSize(20);
  text("Your age is: " + userAge, 20, 180);
  //
  //normal heart chart
  //
  textAlign(LEFT);
  textSize(18);
  text("Heart Rate", 20, 200);
  textSize(16);
  text("Avg BPM: " + (int) avgBPM, 20, 220);
  text("Highest BPM: " + (int) highestBPM, 160, 220);

  if (restingBPM >= 9999) {
    text("Resting BPM: Calibrating...", 320, 220);
  } else {
    text("Resting BPM: " + restingBPM, 320, 220);
  }


  float[] floatHeart = new float[heartRateData.size()];
  for (int i = 0; i < heartRateData.size(); i++) {
    floatHeart[i] = heartRateData.get(i);
  }

  int[] intArray = rangeArray(heartRateData.size());
  float[] floatArray = new float[intArray.length];
  for (int i = 0; i < intArray.length; i++) {
    floatArray[i] = (float) intArray[i];
  }

  heartRateChart.setData(yvalues, xvalues);

  float[] yVal = new float[dynamicArray.size()];
  for (int k = 0; k < dynamicArray.size(); k++) {
    yVal[k] = dynamicArray.get(k);
  }

  //yVal is the actual array for the heart monitoring chart
  calcWave();
  heartRateChart.draw(20, 240, width/3, 200);
  if (fitnessMode){
    // Draw the bar chart on the right side of the screen
    barChart.draw(width/2, 200, width / 3 - 50, 200);
  }
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
    dynamicArray.add(0.20);
  } else if (newBPM < maxHeartRate * 0.70) {
    dynamicArray.add(0.3);
    lightTime++;
  } else if (newBPM < maxHeartRate * 0.80) {
    dynamicArray.add(0.6);
    moderateTime++;
  } else if (newBPM < maxHeartRate * 0.90) {
    dynamicArray.add(0.8);
    hardTime++;
  } else {
    dynamicArray.add(1.0);
    maximumTime++;
  }

  if (heartRateData.size() > 50) {
    heartRateData.remove(0);
    dynamicArray.remove(0);
  }

  exerciseTime = maximumTime + hardTime + moderateTime + lightTime + veryLightTime;
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

void calcWave() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 0.02;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*amplitude;
    x+=dx;
    xvalues[i] = dx;
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isController() && theEvent.getController() == navList) {
    int selectedMode = (int)theEvent.getController().getValue();
    switch(selectedMode) {
      case 0:
        println("Switching to Fitness Mode");
        // Add code to switch to Fitness Mode
        fitnessMode = true;
        stressMode = false;
        meditationMode = false;
        customMode = false;
        break;
      case 1:
        println("Switching to Stress Monitoring Mode");
        // Add code to switch to Stress Monitoring Mode
        fitnessMode = false;
        stressMode = true;
        meditationMode = false;
        customMode = false;
        break;
      case 2:
        println("Switching to Meditation Mode");
        // Add code to switch to Meditation Mode
        fitnessMode = false;
        stressMode = false;
        meditationMode = true;
        customMode = false;
        break;
      case 3:
        println("Switching to Custom Mode");
        // Add code to switch to Custom Mode
        fitnessMode = false;
        stressMode = false;
        meditationMode = false;
        customMode = true;
        break;
    }
  }
}
