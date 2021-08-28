// IMPORTANT INFO:
//  - Day starts/changes at 03:00
//

import java.util.*;

int scroll = 0, yPos;

final String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"};

// Classes
class date {
  int year, month, day;

  date() {
    year = 2021;
    month = 8;
    day = 28;
  }
}

class task {
  int startTime, endTime, importance = 1;
  String title = "";

  task(int s, int e, int i, String t) {
    startTime = s;
    endTime = e;
    importance = i;
    title = t;
  }
}

class dayContents {
  int wakeupTime = 390;
  ArrayList<task> tasks = new ArrayList<task>();

  public void setWakeTime(int w) {
    wakeupTime = w;
  }

  public void newTask() {
    tasks.add(new task(400, 420, 2, "Do japanese!"));
  }
}

Map<date, dayContents> calendar = new HashMap<date, dayContents>();

date currentDate = new date();

// SETUP -------------------------------------------------------------------------------------------
void setup() {
  size(720, 1280);
  //fullScreen();
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(30);
}

void draw() {
  background(20);
  drawUI();
}

void drawUI() {
  // Top bar
  fill(20);
  rect(0, 0, width, height/15);
  fill(250);
  text(currentDate.day+" "+monthNames[currentDate.month], width/2, height/30);

  // Calendar view
  stroke(50);
  line(width/7, height/15, width/7, height);
  yPos = height/15 + (100 - (scroll % height/8));
  while(yPos < height){
    println(yPos);
    line(width/7, yPos, width, yPos);
    yPos += height/8;
  }
  noStroke();

  // Shadows
  setGradient(0, height/15, width, height/13, color(5), color(20,0));
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
