// IMPORTANT INFO:
//  - Day starts/changes at 03:00
//

import java.util.*;
import java.time.LocalDate;
import java.time.DayOfWeek;

int maxId = 1;

int scroll = 350, yPos, scrollSpeed = 0, swipe = 0;
int focus = 0, activeInput = 0; // Currently focused screen
String tempText, tempDate;
boolean newRep = false, dayHasActs, kbOpen = false;
boolean[] tempBoolArray = new boolean[7];
String[] tempTimes = new String[2];

final String[] monthNames = {"", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"};
final String[] dayNames = {"", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "M", "Tu", "W", "Th", "F", "Sa", "Su"};


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
  int dayName;
}

//Map of date-daycontents relations
Map<PVector, ArrayList<Task>> taskList = new HashMap<PVector, ArrayList<Task>>();
Map<Integer, RepTask> repTaskList = new HashMap<Integer, RepTask>();
DayContents[] defDays = new DayContents[7];


PVector currentDate;
DayContents currentDayContents = new DayContents();



// SETUP -------------------------------------------------------------------------------------------
void setup() {
  orientation(PORTRAIT);
  //size(850, 1400);                 !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  fullScreen();
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(50);
  for (int i = 0; i < 7; i++) {
    defDays[i] = new DayContents();
  }
  currentDate = new PVector(LocalDate.now().getDayOfMonth(), LocalDate.now().getMonthValue(), LocalDate.now().getYear());

  //Load current day onto screen
  loadDate(currentDate);
}

// UI DRAW  -------------------------------------------------------------------------------------------
void draw(){
  background(20);
  scrolling();
  drawUI();
}

void drawUI() {
  if (focus == 0) {
    // Date change by swiping
    if (swipe > 7) {
      if (currentDate.x >= LocalDate.of(int(currentDate.z), int(currentDate.y), int(currentDate.x)).lengthOfMonth()) {
        if (currentDate.y == 12) {
          currentDate.x = 1;
          currentDate.y = 1;
          currentDate.z++;
          ;
        } else {
          currentDate.x = 1;
          currentDate.y++;
        }
      } else currentDate.x++;
      swipe = 0;
      loadDate(currentDate);
    } else if (swipe < -7) {
      if (currentDate.x <= 1) {
        if (currentDate.y == 1) {
          currentDate.x = LocalDate.of(int(currentDate.z - 1), 12, 1).lengthOfMonth();
          currentDate.y = 12;
          currentDate.z--;
          ;
        } else {
          currentDate.x = LocalDate.of(int(currentDate.z), int(currentDate.y - 1), 1).lengthOfMonth();
          currentDate.y--;
        }
      } else currentDate.x--;
      swipe = 0;
      loadDate(currentDate);
    }
    // Calendar view
    stroke(80);
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
    if (dayHasActs) {
      for (int i = 0, l = currentDayContents.tasks.size(); i < l; i++) {
        if (currentDayContents.tasks.get(i).endTime > map(scroll, 0, 100, 0, 60)+180  &&  currentDayContents.tasks.get(i).startTime < map(scroll+(height-height/15)/(height/8)*100, 0, 100, 0, 60)+210) {
          fill(currentDayContents.tasks.get(i).col);
          int y = int(height/15+((map(currentDayContents.tasks.get(i).startTime-180, 0, 60, 0, 100)-scroll)/100*(height/8))-2);
          int h = int(map(currentDayContents.tasks.get(i).endTime-currentDayContents.tasks.get(i).startTime, 0, 60, 0, height/8)-2);
          rect(width/6.5, y, width-width/6, h, 15);
          fill(240);
          textSize(50);
          text(currentDayContents.tasks.get(i).title, (width-width/7)/2+width/7, y+h/2);
        }
      }
    }
    for (int i = 0; i < currentDayContents.repTasks.size(); i++) {
      RepTask tempRepTask = repTaskList.get(currentDayContents.repTasks.get(i));
      if (tempRepTask.defEndTime > map(scroll, 0, 100, 0, 60)+180  &&  tempRepTask.defStartTime < map(scroll+(height-height/15)/(height/8)*100, 0, 100, 0, 60)+210) {
        fill(tempRepTask.col);
        int y = int(height/15+((map(tempRepTask.defStartTime-180, 0, 60, 0, 100)-scroll)/100*(height/8))-2);
        int h = int(map(tempRepTask.defEndTime-tempRepTask.defStartTime, 0, 60, 0, height/8)-2);
        rect(width/6.5, y, width-width/6, h, 15);
        fill(240);
        if (h < 100)textSize(30);
        else textSize(50);
        text(tempRepTask.title, (width-width/7)/2+width/7, y+h/2);
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
    // Add task screen ---------------------------------------
    stroke(100);
    line(50, height/15+150, width-50, height/15+150);
    if (tempText.equals("Title"))fill(100);
    else fill(240);
    text(tempText, width/2, height/15+110);

    fill(#5672E0);
    rect(50, height-200, width-100, 100, 5);
    if (!newRep)fill(#7A819D);
    rect(width-170, height/15+200, 120, 120, 5);
    fill(240);
    text("REP", width-110, height/15+255);
    text("DONE", width/2, height-155);
    // Set date or rep days
    if (newRep) {
      textSize(40);
      for (int i = 0; i < 7; i++) {
        if (tempBoolArray[i])fill(#898ABF);
        else noFill();
        rect(50+(width-240)/7*i, height/15+213, 100, 100, 5);
        fill(240);
        text(dayNames[i+8], 89+(width-240)/7*i, height/15+260);
      }
    } else {
      line(50, height/15+305, width-200, height/15+305);
      text(tempDate, width/2.4, height/15+260);
    }
    // Set times
    line(50, height/15+500, width/2-50, height/15+500);
    line(width/2+50, height/15+500, width-50, height/15+500);
    textSize(60);
    text(tempTimes[0], 130, height/15+460);
    text(tempTimes[1], width/2+130, height/15+460);
    textSize(40);
    text("From:", 105, height/15+400);
    text("Until:", width/2+100, height/15+400);

    textSize(50);
  }

  // Top bar
  fill(20);
  noStroke();
  rect(0, 0, width, height/15);
  fill(240);
  textSize(60);
  text(dayNames[currentDayContents.dayName]+" "+int(currentDate.x)+" "+monthNames[int(currentDate.y)], width/2, height/30);
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
  if (focus == 0) {
    if (1.5*abs(pmouseY - mouseY) > abs(pmouseX - mouseX)) {
      // Vertical swipe
      scrollSpeed = (pmouseY - mouseY)/2;
      swipe = 0;
    } else {
      // Sideways swipe
      if (pmouseX < mouseX)swipe--;
      else swipe++;
    }
  }
}

// Mouse pressed actions: new task button, focus text field...
void mousePressed() {
  if (focus == 0) {
    // "+" button -------------------------------------------------
    if (mouseX > width/1.4 && mouseY > height/1.3) {
      focus = 1;
      tempBoolArray = new boolean[7];
      tempTimes[0] = "--:--";
      tempTimes[1] = "--:--";
      tempDate = "--/--/----";
      tempText = "Title";
      //Reset date to current ------------------------------------------------
    } else if (mouseY < height/15) {
      currentDate = new PVector(LocalDate.now().getDayOfMonth(), LocalDate.now().getMonthValue(), LocalDate.now().getYear());
      loadDate(currentDate);
    }
    // Task add screen
  } else if (focus == 1) {
    // Name bar ------------------------------------------------
    if (mouseY < height/15+150 && mouseY > height/15) {
      if (!kbOpen) {
        openKeyboard();
        kbOpen = true;
      }
      activeInput = 1;
      if (tempText.equals("Title"))tempText = "";
      // Done button ------------------------------------------------
    } else if (mouseY > height-200 && tempTimes[0] != "--:--" && tempTimes[1] != "--:--" && tempText.length() > 0 && int(tempTimes[0].substring(0, 2)) < 24 && int(tempTimes[0].substring(3)) < 60 && int(tempTimes[1].substring(0, 2)) < 24 && int(tempTimes[1].substring(3)) < 60) {
      if (newRep && (tempBoolArray[0] == true || tempBoolArray[1] == true || tempBoolArray[2] == true || tempBoolArray[3] == true || tempBoolArray[4] == true || tempBoolArray[5] == true || tempBoolArray[6] == true)) {
        newRepTask(int(tempTimes[0].substring(0, 2))*60+int(tempTimes[0].substring(3)), int(tempTimes[1].substring(0, 2))*60+int(tempTimes[1].substring(3)), 5, tempText, color(150, 100, 100), maxId+1, tempBoolArray);
      } else if (!newRep && int(tempDate.substring(0, 2)) < 32 && int(tempDate.substring(0, 2)) > 0 && int(tempDate.substring(3, 5)) < 13 && int(tempDate.substring(3, 5)) > 0) {
        newTask(int(tempTimes[0].substring(0, 2))*60+int(tempTimes[0].substring(3)), int(tempTimes[1].substring(0, 2))*60+int(tempTimes[1].substring(3)), 5, tempText, color(100, 150, 100), new PVector(int(tempDate.substring(0, 2)), int(tempDate.substring(3, 5)), int(tempDate.substring(6))));
      }
      activeInput = 0;
      focus = 0;
      if (kbOpen) {
        closeKeyboard();
        kbOpen = false;
      }
      maxId++;
    } else if (mouseY > height/15+150 && mouseY < height/15+330) {
      // Repeating button --------------------------------------------------
      if (mouseX > width-190) {
        newRep = !newRep;
        activeInput = 0;
      }
      // Day buttons ------------------------------------------------------------
      else if (newRep) {
        if (mouseX < 50+(width-240)/7)tempBoolArray[0] = !tempBoolArray[0];
        else if (mouseX < 50+(width-240)/7*2)tempBoolArray[1] = !tempBoolArray[1];
        else if (mouseX < 50+(width-240)/7*3)tempBoolArray[2] = !tempBoolArray[2];
        else if (mouseX < 50+(width-240)/7*4)tempBoolArray[3] = !tempBoolArray[3];
        else if (mouseX < 50+(width-240)/7*5)tempBoolArray[4] = !tempBoolArray[4];
        else if (mouseX < 50+(width-240)/7*6)tempBoolArray[5] = !tempBoolArray[5];
        else tempBoolArray[6] = !tempBoolArray[6];
        activeInput = 0;
        // Date text field ---------------------------------------------
      } else if (!newRep) {
        if (!kbOpen) {
          openKeyboard();
          kbOpen = true;
        }
        activeInput = 2;
        tempDate = "";
      }
      // Time fields ----------------------------------------------------
    } else if (mouseY > height/15+340 && mouseY < height/15+520) {
      if (!kbOpen) {
        openKeyboard(); 
        kbOpen = true;
      }
      if (mouseX < width/2) {
        activeInput = 3;
        tempTimes[0] = "";
      } else {
        activeInput = 4;
        tempTimes[1] = "";
      }
    }
  }
  resetTextFields();
}

// Keyboard input
void keyPressed() {
  // Backspace
  if (key == BACKSPACE || keyCode == 67) {
    if (activeInput == 1 && tempText.length() > 0)tempText = tempText.substring(0, tempText.length()-1);
    else if (activeInput == 3 && tempTimes[0].length() > 0) {
      if (tempTimes[0].length() == 3)tempTimes[0] = tempTimes[0].substring(0, tempTimes[0].length()-2);
      else tempTimes[0] = tempTimes[0].substring(0, tempTimes[0].length()-1);
    } else if (activeInput == 4 && tempTimes[1].length() > 0) {
      if (tempTimes[1].length() == 3)tempTimes[1] = tempTimes[1].substring(0, tempTimes[1].length()-2);
      else tempTimes[1] = tempTimes[1].substring(0, tempTimes[1].length()-1);
    } else if (activeInput == 2 && tempDate.length() > 0) {
      if (tempDate.length() == 3 || tempDate.length() == 6)tempDate = tempDate.substring(0, tempDate.length()-2);
      else tempDate = tempDate.substring(0, tempDate.length()-1);
    }
    // Inputs
  } else if (activeInput == 1 && tempText.length() < 24 && ((key >= 'a' && key <= 'z') || (key >= 'A' && key <= 'Z'))) {
    tempText += key;
  } else if (activeInput == 2 && key >= '0' && key <= '9') {
    if (tempDate.length() == 0 || tempDate.length() == 3 || (tempDate.length() > 5 && tempDate.length() < 11))tempDate += key;
    else if (tempDate.length() == 1 || tempDate.length() == 4)tempDate += key + "/";
  } else if (activeInput == 3 && key >= '0' && key <= '9') {
    if (tempTimes[0].length() == 0 || tempTimes[0].length() == 3 || tempTimes[0].length() == 4)tempTimes[0] += key;
    else if (tempTimes[0].length() == 1)tempTimes[0] += key + ":";
  } else if (activeInput == 4 && key >= '0' && key <= '9') {
    if (tempTimes[1].length() == 0 || tempTimes[1].length() == 3 || tempTimes[1].length() == 4)tempTimes[1] += key;
    else if (tempTimes[1].length() == 1)tempTimes[1] += key + ":";
  }
}

// Load date - loads tasks in selected date onto the screen
void loadDate(PVector d) {
  if (taskList.containsKey(d)) {
    currentDayContents.tasks = taskList.get(d);
    dayHasActs = true;
  } else dayHasActs = false;
  currentDayContents.repTasks = defDays[LocalDate.of(int(d.z), int(d.y), int(d.x)).getDayOfWeek().getValue()-1].repTasks;
  currentDayContents.wakeupTime = defDays[LocalDate.of(int(d.z), int(d.y), int(d.x)).getDayOfWeek().getValue()-1].wakeupTime;
  currentDayContents.dayName = LocalDate.of(int(d.z), int(d.y), int(d.x)).getDayOfWeek().getValue();
}

// Create new standard task and add it to the relevant date
void newTask(int s, int e, int p, String n, color c, PVector d) {
  if (taskList.containsKey(d))taskList.get(d).add(new Task(s, e, p, n, c));
  else {
    taskList.put(d, new ArrayList<Task>());
    taskList.get(d).add(new Task(s, e, p, n, c));
  }
  loadDate(currentDate);
}
// Create new repeating task, add to repeating task list, and put ID in relevant days
void newRepTask(int s, int e, int p, String n, color c, int id, boolean[] days) {
  repTaskList.put(id, new RepTask(s, e, p, n, c));
  for (int i = 0; i < 7; i++) {
    if (days[i])defDays[i].repTasks.append(id);
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

void onPause() {
  kbOpen = false;
  activeInput = 0;
  resetTextFields();
}

void backPressed() {
  activeInput = 0;
  focus = 0;
  if (kbOpen) {
    closeKeyboard();
    kbOpen = false;
  }
  resetTextFields();
}



void resetTextFields() {
  if (activeInput != 1 && tempText == "")tempText = "Title";
  if (activeInput != 2 && (tempDate == "" || tempDate.length() != 10))tempDate = "--/--/----";
  if (activeInput != 3 && (tempTimes[0] == "" || tempTimes[0].length() != 5))tempTimes[0] = "--:--";
  if (activeInput != 4 && (tempTimes[1] == "" || tempTimes[1].length() != 5))tempTimes[1] = "--:--";
}
