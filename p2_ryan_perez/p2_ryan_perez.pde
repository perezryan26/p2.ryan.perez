/**
 * Smart Mirror
 * By: Ryan Perez
 *
 */

Table table, table2, table3;

PImage img;

boolean editMode = false;
boolean calendarWidgetExpanded = false;
boolean newsWidgetExpanded = false;
boolean analysisWidgetExpanded = false;
boolean weatherWidgetExpanded = false;
boolean firstLoop = true;

String weather = "";
String weight = "";
String lastWeight = "";
String avgWeight = "";
String screenOccupied = "none";
String[][] Events;
String[][] News;

int eventRows;
int newsRows;
int weightTime;
int newsRowIndex = 0;
int rotatingWidgetIndex = 0;
int calendarRowIndex = 0;
int wait = 3000;
int wait2 = 4000;
int wait3 = 12000;
int temperature = 0;
int totalTime = 0;
int day = day();

long calendarTextStartTime = 0;
long newsTextStartTime = 0;
long analysisStartTime = 0;
long rotatingWidgetStartTime = 0;

color ledColor = (255);

Button b1 = new Button(645,670,50,20,"Edit", color(213,213,213));
Button b2 = new Button(570,670,20,20,"", color(255,0,0));
Button b3 = new Button(520,670,20,20,"", color(255,128,0));
Button b4 = new Button(470,670,20,20,"", color(255,255,0));
Button b5 = new Button(420,670,20,20,"", color(0,255,0));
Button b6 = new Button(370,670,20,20,"", color(0,128,255));
Button b7 = new Button(320,670,20,20,"", color(127,0,255));

Widget w1 = new Widget(60,310,50,50,"WEATHER", color(213,213,213));
Widget w2 = new Widget(60,420,50,50,"NEWS FEED", color(213,213,213));
Widget w3 = new Widget(60,530,50,50,"CALENDAR", color(213,213,213));
Widget w4 = new Widget(60,640,50,50,"HEALTH", color(213,213,213));

void setup() {
  size(700, 700);
  rectMode(RADIUS);  
  
  img = loadImage("image.jpeg");
  
  PFont font;
  font = loadFont("BanglaMN-48.vlw");
  textFont(font, 128);

  String url = "https://api.openweathermap.org/data/2.5/weather?q=Lubbock&units=imperial&appid=47cb3ac50ba4004ce00ac8d5c61a1eeb";

  JSONObject json = loadJSONObject(url);
  JSONObject main = json.getJSONObject("main");
  temperature = main.getInt("temp");

  weather = json.getJSONArray("weather").getJSONObject(0).getString("description");
  
  weightTime = millis() + 3000;
  
  table = loadTable("calendar_database.csv", "header");
  table2 = loadTable("news_database.csv", "header");
  table3 = loadTable("analysis_database.csv", "header");
  
  int calendarRows = table.getRowCount();
  String[][] totalEvents = new String[table.getRowCount()][6];
  
  int newsTableRows = table2.getRowCount();
  String[][] totalNews = new String[table2.getRowCount()][4];
  
  for (TableRow row : table2.rows()) {
    int id = row.getInt("id");
    String day = row.getString("day");
    String title = row.getString("title");
    String body = row.getString("body");
    
    totalNews[id][0] = day;
    totalNews[id][1] = title;
    totalNews[id][2] = body;
    
  }

  for (TableRow row : table.rows()) {
    int id = row.getInt("id");
    String day = row.getString("day");
    String time = row.getString("time");
    String ampm = row.getString("ampm");
    String name = row.getString("name");
    
    String hour = time.substring(0,2);
    if(hour.contains("12")) {
      hour = "-1";
    }
    
    String min = time.substring(3);
    
    totalEvents[id][0] = day;
    totalEvents[id][1] = hour;
    totalEvents[id][2] = min;
    if(ampm.contains("am")) {
      totalEvents[id][3] = "0";
    } else if(ampm.contains("pm")) {
      totalEvents[id][3] = "1";
    }
    totalEvents[id][4] = name;
    
  }
  
  int dailyCalendarRows = 0;
  int d = day();
  
  String[][] dailyNews = new String[100][4];
  int l = 0;
  
  for(int i = 0; i < newsTableRows; i++) {
    if(Integer.valueOf(totalNews[i][0]) == d) {
      //gets everything from a row
      println("new post");
      for(int j = 0; j < 3; j++) {
        dailyNews[l][j] = totalNews[i][j];
        //print(totalNews[l][j]);
        print(dailyNews[l][j]);
      }
      l++;
    }
  }
  
  News = dailyNews;
  newsRows = newsTableRows;
  
  for(int i = 0; i < calendarRows; i++) {
    if(Integer.valueOf(totalEvents[i][0]) == d) {
      dailyCalendarRows += 1;
    }
  }
  
  
  String[][] dailyEvents = new String[dailyCalendarRows][6];
  
  int k = 0;
  
  for(int i = 0; i < calendarRows; i++) {
    if(Integer.valueOf(totalEvents[i][0]) == d) {
      //gets everything from a row
      for(int j = 0; j < 5; j++) {
        dailyEvents[k][j] = totalEvents[i][j];
      }
      k++;
    }
  }
  
  dailyEvents = bubbleSort(dailyEvents,dailyCalendarRows);
  
  for(int i = 0; i < dailyCalendarRows; i++) {
      if(dailyEvents[i][1].contains("-1")) {
        dailyEvents[i][1] = "12";
      }
      if(dailyEvents[i][3].contains("0")) {
        dailyEvents[i][3] = "AM";
      } else if(dailyEvents[i][3].contains("1")) {
        dailyEvents[i][3] = "PM";
      }
  }
  
  eventRows = dailyCalendarRows;
  Events = dailyEvents;
  
}

void draw() { 
  background(225);
  
  image(img, 0, 0, 700, 700);
  
  fill(ledColor);
  stroke(ledColor);
  rect(0,0,1000,5);
  rect(0,700,1000,5);
  
  fill(255);
  
  if(calendarWidgetExpanded == true && screenOccupied.contains("none")) {
    screenOccupied = "calendar";
  } else if(calendarWidgetExpanded == false && screenOccupied.contains("calendar")) {
    screenOccupied = "none";
  } else if(calendarWidgetExpanded == true && screenOccupied.contains("calendar")) {
    int extra = 0;
    textSize(40);
    text("Calendar", 500, 160);
    textSize(17);
    for(int i = 0; i < eventRows; i++) {
      text(Events[i][1] + ":" + Events[i][2] + " " + Events[i][3] + " " + Events[i][4], 500, 190+extra);
      extra += 30;
    }
  } else if(calendarWidgetExpanded == true && !screenOccupied.contains("calendar")) {
    screenOccupied = "calendar";
    newsWidgetExpanded = false;
    analysisWidgetExpanded = false;
    weatherWidgetExpanded = false;
    //calendarWidgetExpanded = false;
  }
  
  if(newsWidgetExpanded == true && screenOccupied.contains("none")) {
    screenOccupied = "news";
  } else if(newsWidgetExpanded == false && screenOccupied.contains("news")) {
    screenOccupied = "none";
  } else if(newsWidgetExpanded == true && screenOccupied.contains("news")) {
    //text("News Displayed", 400, 450);
    int extra2 = 0;
  
    textSize(40);
    text("News", 500, 160);
    
    for(int i = 0; i < newsRows; i++) {
        if(News[i][1] != null) {
          textSize(28);
          text(News[i][1] + "\n", 500, 200+extra2);
          textSize(15);
          text(News[i][2], 500, 230+extra2);
          
          extra2 +=70;
        }
    }
  } else if(newsWidgetExpanded == true && !screenOccupied.contains("news")) {
    screenOccupied = "news";
    calendarWidgetExpanded = false;
    analysisWidgetExpanded = false;
    weatherWidgetExpanded = false;
  }
  
  if(analysisWidgetExpanded == true && screenOccupied.contains("none")) {
    screenOccupied = "analysis";
  } else if(analysisWidgetExpanded == false && screenOccupied.contains("analysis")) {
    screenOccupied = "none";
  } else if(analysisWidgetExpanded == true && screenOccupied.contains("analysis")) {
    //text("Analysis Displayed", 400, 450);
    textSize(20);
    if(firstLoop) {
      
      TableRow row = table3.getRow(table3.getRowCount()-1);
      weight = row.getString("weight");
      
      weight = str(getCurrentWeight(weight));
      //text("Your currently weigh: " + weight, 250, 70);
      
      TableRow newRow = table3.addRow();
      newRow.setInt("id", table3.getRowCount() - 1);
      newRow.setString("weight", weight);
      saveTable(table3, "analysis_database.csv");
      
      firstLoop = false;
      
    } else {
      textSize(40);
      text("Health", 500, 160);
      
      textSize(28);
    
      weight = nf(float(weight), 0, 2);
      text("Current Weight: " + weight + " lbs", 490, 200);
      
      TableRow row = table3.getRow(table3.getRowCount()-2);
      lastWeight = row.getString("weight");
      lastWeight = nf(float(lastWeight), 0, 2);
      
      text("Last Weight: " + lastWeight + " lbs", 490, 240);
      
      float temp = 0;
      for (TableRow row2 : table3.rows()) {
        temp += float(row2.getString("weight"));
      }
      temp = temp / table3.getRowCount();
      avgWeight = nf(temp,0,2);
      
      text("Average Weight: " + avgWeight + " lbs", 490, 280);
      
    }
  } else if(analysisWidgetExpanded == true && !screenOccupied.contains("analysis")) {
    screenOccupied = "analysis";
    newsWidgetExpanded = false;
    calendarWidgetExpanded = false;
    weatherWidgetExpanded = false;
  }
  
  if(weatherWidgetExpanded == true && screenOccupied.contains("none")) {
    screenOccupied = "weather";
  } else if(weatherWidgetExpanded == false && screenOccupied.contains("weather")) {
    screenOccupied = "none";
  } else if(weatherWidgetExpanded == true && screenOccupied.contains("weather")) {
    //text("Weather Displayed", 400, 450);
    // Display all the stuff we want to display
    textSize(40);
    text("Weather", 500, 160);
    textSize(28);
    text("State: Texas", 500, 200);
    text("City: Lubbock", 500, 240);
    text("Temperature: " + temperature + "° F", 500, 280);
    text("Forecast:\n" + weather, 500, 320);
  } else if(weatherWidgetExpanded == true && !screenOccupied.contains("weather")) {
    screenOccupied = "weather";
    newsWidgetExpanded = false;
    calendarWidgetExpanded = false;
    analysisWidgetExpanded = false;
  }
   
  if(millis() > (rotatingWidgetStartTime + wait3)) {
      rotatingWidgetStartTime = millis();
      rotatingWidgetIndex++;
  } 
  
  if(rotatingWidgetIndex > 1) {
    rotatingWidgetIndex = 0;
  }
  
  if(rotatingWidgetIndex == 0) {
    //println("1");
    textSize(30);
    if(millis() > (calendarTextStartTime + wait)) {
      calendarTextStartTime = millis();
      calendarRowIndex++;
    }
       
   if(calendarRowIndex == Events.length) {
     calendarRowIndex = 0;
   }
   
    if(Events != null && Events.length > 0) {
      textSize(40);
      text(Events[calendarRowIndex][1] + ":" + Events[calendarRowIndex][2] + " " + Events[calendarRowIndex][3], 250, 50);
      textSize(25);
      text(Events[calendarRowIndex][4], 250, 90);
    }
  } else if(rotatingWidgetIndex == 1) {
    //println("2");
    textSize(40);
    if(millis() > (newsTextStartTime + wait)) {
      newsTextStartTime = millis();
      newsRowIndex++;
    }
   
    if(newsRowIndex == newsRows) {
      newsRowIndex = 0;
    }
     
    if(News[newsRowIndex][1] != null) {
       text(News[newsRowIndex][1], 250, 50);
       textSize(14);
       text(News[newsRowIndex][2], 250, 80);
    }
  } 
  
  textSize(40);
  text(temperature + "° F", 600, 120); //Displays the temperature
  
  displayTime(); //Displays the time
  
  //Display the Widgets
  w1.display();
  w2.display();
  w3.display();
  w4.display();
  
  //Display the Buttons
  b1.display();
  b2.display();
  b3.display();
  b4.display();
  b5.display();
  b6.display();
  b7.display();
  
  
}

void displayTime() {
  int sec = second();  
  int min = minute();  
  int hour = hour();    
  int mon = month();
  int day = day();
  int year = year();

  textSize(40);

  if(hour > 12) {
    hour = hour - 12;
  }

  text(hour, 545, 85);
  text(":", 568, 83);
  text(min, 600, 85);
  text(":", 630, 83);
  text(sec, 660, 85);
  
  text(mon, 515, 50);
  text("/", 540, 50);
  text(day, 565, 50);
  text("/", 595, 50);
  text(year, 650, 50);
  
  textSize(13);
}

void mousePressed() {

  if(editMode) {
    w1.onClick();
    w2.onClick();
    w3.onClick();
    w4.onClick();
  }
  
  if(b1.clicked(mouseX, mouseY)) {
    editMode = !editMode;
  } 
  
  if(b2.clicked(mouseX, mouseY)) {
    ledColor = color(255,0,0);
  } 
  
  if(b3.clicked(mouseX, mouseY)) {
    ledColor = color(255,128,0);
  } 
  
  if(b4.clicked(mouseX, mouseY)) {
    ledColor = color(255,255,0);
  } 
  
  if(b5.clicked(mouseX, mouseY)) {
    ledColor = color(0,255,0);
  } 
  
  if(b6.clicked(mouseX, mouseY)) {
    ledColor = color(0,128,255);
  } 
  
  if(b7.clicked(mouseX, mouseY)) {
    ledColor = color(127,0,255);
  } 
  
  if(w1.clicked()) {
    weatherWidgetExpanded = !weatherWidgetExpanded;
  }
  
  if(w2.clicked()) {
    newsWidgetExpanded = !newsWidgetExpanded;
  }
  
  if(w3.clicked()) {
    calendarWidgetExpanded = !calendarWidgetExpanded;
  }
  
  if(w4.clicked()) {
    analysisWidgetExpanded = !analysisWidgetExpanded;
  }
  
}

void mouseDragged() {
  if(editMode) {
    w1.onDrag();
    w2.onDrag();
    w3.onDrag();
    w4.onDrag();
  }
}

void mouseReleased() {
  if(editMode) {
    w1.onRelease();
    w2.onRelease();
    w3.onRelease();
    w4.onRelease();
  }
}


class Widget {
  float bx;
  float by;
  int boxSize;
  float radii;
  String label;
  color c;
  boolean overBox = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0; 
  boolean selected;

  //float height is not utilized rn as this class is only making squares, but it also needs to be adjusted for rectangles
  Widget(float bx, float by, int width, float radii, String label, color c) {
    this.bx = bx;
    this.by = by;
    this.boxSize = width;
    this.radii = radii;
    this.label = label;
    this.c = c;
    selected = false;
  }
  
  void display() {
    if (mouseX > bx-boxSize && mouseX < bx+boxSize && 
        mouseY > by-boxSize && mouseY < by+boxSize) {
      overBox = true;  
    } else {
      overBox = false;
    }
    
    // Draw the box
    stroke(255); 
    fill(213,213,213);
    rect(bx, by, boxSize, boxSize, radii);
    fill(255);
    textAlign(CENTER);
    text(label, bx, by);
  }
  
  void onClick() {
    if(overBox) { 
      locked = true; 
      fill(255, 255, 255);
    } else {
      locked = false;
    }
    xOffset = mouseX-bx; 
    yOffset = mouseY-by; 
  }

  void onDrag() {
    if(locked) {
      bx = mouseX-xOffset; 
      by = mouseY-yOffset; 
    }
  }

  void onRelease() {
    locked = false;
  }
  
  boolean clicked() {
    if(mouseX > bx-boxSize && mouseX < bx+boxSize && 
        mouseY > by-boxSize && mouseY < by+boxSize) {
      selected = !selected;
      return true;
    } else {
      return false;
    }
  }
}

class Button {
  float x,y;
  float width, height;
  boolean selected;
  color c;
  String label;
  float radii = 100;
  
  Button(float x, float y, float width, float height, String label, color c) {
    this.x = x;
    this.y = y;
    this.height = height;
    this.width = width;
    this.label = label;
    this.c = c;
    selected = false;
  }
  
  void display() {
    fill(c);
    stroke(c);
    rect(x, y, width, height, radii);
    fill(255);//black for text
    textAlign(CENTER);
    text(label, x + width/14, y + (height/4));
  }
  
  boolean clicked(int mx, int my) {
    if(mouseX > x-width && mouseX < x+width && 
        mouseY > y-height && mouseY < y+height) {
      selected = !selected;
      return true;
    } else {
      return false;
    }
  }
}

String[][] bubbleSort(String[][] array, int size) {
  String[][] tempArray = new String[10][6];
  for(int loop = 0; loop < size; loop ++) {
    for(int i = 0; i < size-1; i++) {
      if(Integer.valueOf(array[i][1]) > Integer.valueOf(array[i+1][1])) {
        for(int j = 0; j < 6; j++) {
          tempArray[i][j] = array[i][j];
        }
        for(int j = 0; j < 6; j++) {
          array[i][j] = array[i+1][j];
        }
        for(int j = 0; j < 6; j++) {
          array[i+1][j] = tempArray[i][j];
        }
      }
    }
  }
  
  for(int loop = 0; loop < size; loop ++) {
    for(int i = 0; i < size-1; i++) {
      //println(Integer.valueOf(array[i][2]) + "  " + Integer.valueOf(array[i+1][2]));
      if(Integer.valueOf(array[i][1]) == Integer.valueOf(array[i+1][1])) {
        if(Integer.valueOf(array[i][2]) > Integer.valueOf(array[i+1][2])) {
          for(int j = 0; j < 6; j++) {
            tempArray[i][j] = array[i][j];
          }
          for(int j = 0; j < 6; j++) {
            array[i][j] = array[i+1][j];
          }
          for(int j = 0; j < 6; j++) {
            array[i+1][j] = tempArray[i][j];
          }
        }
      }
    }
  }
  
  for(int loop = 0; loop < size; loop ++) {
    for(int i = 0; i < size-1; i++) {
      //println(Integer.valueOf(array[i][3]) + "  " + Integer.valueOf(array[i+1][3]));
      if(Integer.valueOf(array[i][3]) > Integer.valueOf(array[i+1][3])) {
        for(int j = 0; j < 6; j++) {
          tempArray[i][j] = array[i][j];
        }
        for(int j = 0; j < 6; j++) {
          array[i][j] = array[i+1][j];
        }
        for(int j = 0; j < 6; j++) {
          array[i+1][j] = tempArray[i][j];
        }
      }
    }
  }
  return array;
}

float getCurrentWeight(String lastWeight) {
  float fLastWeight = float(lastWeight);
  float weight = -10;
  while(weight <= 0) {
    weight = random(fLastWeight-3,fLastWeight+3);
  }
  
  return weight;
}
