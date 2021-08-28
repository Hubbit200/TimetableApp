final String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"};
class date {
  int year, month, day;

  date() {
    year = 2021;
    month = 8;
    day = 28;
  }
}

class dayContents {
  int wakeupTime = 390;
}

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
  fill(20);
  rect(0, 0, width, height/15);
  setGradient(0, height/15, width, height/13, color(5), color(20));
  fill(250);
  text(currentDate.day+" "+monthNames[currentDate.month], width/2, height/30);
}



void setGradient(int x, int y, float w, float h, color c1, color c2) {
  noFill();
  for (int i = y; i <= h; i++) {
    float inter = map(i, y, h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, w, i);
  }
}
