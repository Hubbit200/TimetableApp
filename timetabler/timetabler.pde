// IMPORTANT INFO:
//  - Day starts/changes at 03:00
//

import java.util.*;

int scroll = 350, yPos, scrollSpeed = 0;
int focus = 0, activeInput = 0; // Currently focused screen
String tempText;

final String[] monthNames = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"};


// CLASSES
// Task classes - with start and end time, importance, name...
class Task {
  int startTime, endTime, importance = 1;
  int[] repeating;

  String title = "";
  color col = color(100, 150, 100);

  Task(int s, int e, int i, String t, color c) {
    startTime = s;
    endTime = e;
    importance = i;
    title = t;
    col = c;
  }
}
class RepTask {
  int defStartTime, defEndTime, importance = 1;
  Map<PVector, PVector> reps = new HashMap<PVector, PVector>();

  String title = "";
  color col = color(150, 100, 100);
  
  RepTask(int s, int e, int i, String t, color c) {
    defStartTime = s;
    defEndTime = e;
    importance = i;
    title = t;
    col = c;
  }
}

// Daycontents class - parent for tasks in a day as well as wakeup time
class DayContents {
  int wakeupTime = 390;
  ArrayList<Task> tasks = new ArrayList<Task>();
  IntList repTasks = new IntList();
}

//Map of date-daycontents relations
Map<PVector, ArrayList<Task>> taskList = new HashMap<PVector, ArrayList<Task>>();
Map<Integer, RepTask> repTaskList = new HashMap<Integer, RepTask>();
DayContents[] defDays = new DayContents[7];


PVector currentDate = new PVector(29, 8, 2021);
DayContents currentDayContents;
Calendar calendar;


// SETUP -------------------------------------------------------------------------------------------
void setup() {
  orientation(PORTRAIT);
  size(850, 1400);
  //fullScreen();
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(50);
  
  calendar = Calendar.getInstance();

  //Load current day onto screen
  loadDate(currentDate);
}


// UI DRAW  -------------------------------------------------------------------------------------------
void draw() {
  background(20);
  scrolling();
  drawUI();
}

void drawUI() {
  if (focus == 0) {
    // Calendar view
    stroke(50);
    line(width/7, height/15, width/7, height);
    yPos = height/15 + int(map(100 - (scroll % 100), 0, 100, 0, height/8));
    int temp = 1;
    while (yPos < height) {
      fill(100);
      line(width/7.5, yPos, width, yPos);
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

    // "+" button
    noStroke();
    fill(23);
    circle(width/1.2+4, height/1.1+4, width/6);
    fill(50);
    circle(width/1.2, height/1.1, width/6);
    fill(240);
    rect(width/1.2-width/20, height/1.1-5, width/10, 10, 4);
    rect(width/1.2-5, height/1.1-width/20, 10, width/10, 4);
  } else if (focus == 1) {
    // Add task
    stroke(100);
    line(50, height/15+150, width-50, height/15+150);
    if (tempText.equals("Title"))fill(100);
    else fill(240);
    text(tempText, width/2, height/15+110);
  }

  // Top bar
  fill(20);
  rect(0, 0, width, height/15);
  fill(240);
  textSize(60);
  text(int(currentDate.x)+" "+monthNames[int(currentDate.y)], width/2, height/30);
  // Shadow
  setGradient(0, height/15, width, height/13, color(5), color(20, 0));
}


// INTERACTION  -------------------------------------------------------------------------------------------
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
  if (focus == 0)scrollSpeed = (pmouseY - mouseY)/2;
}

// Mouse pressed actions: new task button, focus text field...
void mousePressed() {
  if (focus == 0 && mouseX > width/1.4 && mouseY > height/1.3) {
    focus = 1;
    tempText = "Title";
  } else if (focus == 1) {
    if (mouseY < height/15+150 && mouseY > height/15) {
      //openKeyboard();                                                            !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      activeInput = 1;
      if (tempText.equals("Title"))tempText = "";
    } else {
      //closeKeyboard();                                                           !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      activeInput = 0;
      if (tempText.equals(""))tempText = "Title";
    }
  }
}

// Keyboard input
void keyPressed() {
  if (activeInput == 1 && tempText.length() < 24)tempText += key;
}

// Load date - loads tasks in selected date onto the screen
void loadDate(PVector d) {
  currentDayContents.tasks = taskList.get(d);
  currentDayContents.repTasks = defDays[calendar.get(Calendar.DAY_OF_WEEK)].repTasks;
  currentDayContents.wakeupTime = defDays[calendar.get(Calendar.DAY_OF_WEEK)].wakeupTime;
}

// Create new standard task and add it to the relevant date
void newTask(int s, int e, int p, String n, color c, PVector d) {
  taskList.get(d).add(new Task(s, e, p, n, c));
  loadDate(currentDate);
}
// Create new repeating task, add to repeating task list, and put ID in relevant days
void newRepTask(int s, int e, int p, String n, color c, int i, int[] days) {
  repTaskList.put(i, new RepTask(s, e, p, n, c));
  for(int x: days){
    defDays[x].repTasks.append(i);
  }
  loadDate(currentDate);
}

// OTHER FUNCTIONS  -------------------------------------------------------------------------------------------
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
