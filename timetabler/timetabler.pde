// IMPORTANT INFO:
//  - Day starts/changes at 03:00
//

import java.util.*;

int scroll = 350, yPos, scrollSpeed = 0;
int focus = 0; // Currently focused screen

final String[] monthNames = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"};

// CLASSES
// Task class - with start and end time, importance, name...
class task {
  int startTime, endTime, importance = 1;
  String title = "";
  color col = color(100, 150, 100);

  task(int s, int e, int i, String t, color c) {
    startTime = s;
    endTime = e;
    importance = i;
    title = t;
    col = c;
  }
}

// Daycontents class - parent for tasks in a day as well as wakeup time
class dayContents {
  int wakeupTime = 390;
  ArrayList<task> tasks = new ArrayList<task>();

  public void setWakeTime(int w) {
    wakeupTime = w;
  }

  public void addTask(int s, int e, int p, String n, color c) {
    tasks.add(new task(s, e, p, n, c));
  }
}

//Map of date-daycontents relations
Map<PVector, dayContents> calendar = new HashMap<PVector, dayContents>();


PVector currentDate = new PVector(29, 8, 2021);
dayContents currentDayContents;

// SETUP -------------------------------------------------------------------------------------------
void setup() {
  size(850, 1400);
  //fullScreen();
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(50);

  calendar.put(new PVector(29, 8, 2021), new dayContents());
  calendar.get(new PVector(29, 8, 2021)).addTask(660, 730, 2, "Do japanese!", color(100, 150, 100));
  calendar.get(new PVector(29, 8, 2021)).addTask(900, 930, 2, "Do japanese!", color(150, 100, 100));
  //Load current day onto screen
  loadDate(currentDate);
}

void draw() {
  background(20);
  scrolling();
  drawUI();
}

void drawUI() {
  // Calendar view
  stroke(50);
  line(width/7, height/15, width/7, height);
  yPos = height/15 + int(map(100 - (scroll % 100), 0, 100, 0, height/8));
  int temp = 1;
  while (yPos < height) {
    line(width/7.5, yPos, width, yPos);
    fill(100);
    textSize(35);
    text((scroll/100+3+temp)%24+":00", width/13, yPos);
    yPos += height/16;
    temp++;
    line(width/7, yPos, width/7.5, yPos);
    yPos += height/16;
  }

  // Draw tasks on screen
  for (int i = 0, l = currentDayContents.tasks.size(); i < l; i++) {
    if (currentDayContents.tasks.get(i).endTime > map(scroll, 0, 100, 0, 60)+180  &&  currentDayContents.tasks.get(i).startTime < map(scroll+(height-height/15)/(height/8)*100, 0, 100, 0, 60)+210) {
      fill(currentDayContents.tasks.get(i).col);
      int y = int(height/15+((map(currentDayContents.tasks.get(i).startTime-180, 0, 60, 0, 100)-scroll)/100*(height/8)));
      int h = int(map(currentDayContents.tasks.get(i).endTime-currentDayContents.tasks.get(i).startTime, 0, 60, 0, height/8));
      rect(width/6.5, y, width-width/6, h, 15);
      fill(240);
      textSize(50);
      text(currentDayContents.tasks.get(i).title, (width-width/7)/2+width/7, y+h/2);
    }
  }

  // Top bar
  fill(20);
  rect(0, 0, width, height/15);
  fill(240);
  textSize(60);
  text(int(currentDate.x)+" "+monthNames[int(currentDate.y)], width/2, height/30);
  
  // "+" button
  noStroke();
  fill(23);
  circle(width/1.2+4, height/1.1+4, width/6);
  fill(50);
  circle(width/1.2, height/1.1, width/6);
  fill(240);
  rect(width/1.2-width/20, height/1.1-5, width/10, 10, 4);
  rect(width/1.2-5, height/1.1-width/20, 10, width/10, 4);

  // Shadows
  setGradient(0, height/15, width, height/13, color(5), color(20, 0));
}

// Scroll function - manages scroll position
void scrolling() {
  if (!mousePressed && scrollSpeed > 0) {
    scrollSpeed -= 2;
    if (scrollSpeed < 0)scrollSpeed = 0;
  } else if (!mousePressed && scrollSpeed < 0) {
    scrollSpeed += 2;
    if (scrollSpeed > 0)scrollSpeed = 0;
  }
  if (scroll < 0) {
    scrollSpeed = 0; 
    scroll = 0;
  } else if (scroll > 2400-((height-height/15)/(height/8)*100)) {
    scrollSpeed = 0; 
    scroll = 2400-((height-height/15)/(height/8)*100);
  }

  scroll += scrollSpeed;
}

// Mouse dragged - manages scroll speed when touching screen
void mouseDragged() {
  scrollSpeed = (pmouseY - mouseY)/2;
}

void mousePressed(){
  if(focus == 0 && mouseX > width/1.4 && mouseY > height/1.3){
    
  }
}

// Load date - loads tasks in selected date onto the screen
void loadDate(PVector d) {
  if (calendar.containsKey(d)) {
    currentDayContents = calendar.get(d);
  }
}


// Gradient function
void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
  for (int i = y; i <= h; i++) {
    float inter = map(i, y, h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, w, i);
  }
}
