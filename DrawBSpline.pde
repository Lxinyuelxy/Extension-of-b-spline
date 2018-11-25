ArrayList<PVector> controlPoints;
ArrayList<Float> knots1;
ArrayList<Float> knots2;
int pointsNum = 8;
int degree = 3;
BSpline b;
BSpline newCurve;
Boolean ifDrawBSpline = false;
Boolean ifDrawNewCurve = false;
Boolean ifShowControlPolygon = true;

void setup() {
  size(1400, 800);
  
  controlPoints = new ArrayList<PVector>();
  
  // unclamped
  knots1 = new ArrayList<Float>();
  for (float i = 0; i <= pointsNum+degree+1-1; i++) {
    knots1.add(i*0.1);
  }
  //clamped
  knots2 = new ArrayList<Float>();
  for (float i = 0; i <= pointsNum+degree+1-1; i++) {
    if(i < degree+1) knots2.add(0.0);
    else if (i < pointsNum) knots2.add(i*0.1);
    else knots2.add(1.0);
  }
}

void draw() {
  background(255);
  if (ifShowControlPolygon) {
    drawControlPolygon();
  }
  if (ifDrawNewCurve == true) {
    drawSpline(newCurve, color(0,255,0));
  }
  if (ifDrawBSpline == true) {
    drawSpline(b, color(255,0,0));
  }
  
}

void drawSpline(BSpline spline, color c) {
  ArrayList<PVector> points = spline.getBsplineCurve();
  pushStyle();
  beginShape();
  stroke(c);
  strokeWeight(3);
  for (PVector p : points) {
    vertex(p.x, p.y);
  }
  endShape();
  popStyle();
}

void drawControlPolygon() {
  noFill();
  beginShape();
  for (PVector p: controlPoints) {
    pushStyle();
    if (checkIfDragged(p)) {
      fill(color(255, 0, 0));
      ellipse(p.x, p.y, 15, 15);
    } 
    else {
      fill(color(0, 0, 0));
      ellipse(p.x, p.y, 10, 10);
    }
    popStyle();
    vertex(p.x, p.y);
  }
  endShape();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) ifShowControlPolygon = !ifShowControlPolygon;
  }
}

void mouseClicked() {
  if (controlPoints.size() < pointsNum) {
    controlPoints.add(new PVector(mouseX, mouseY));
    if (controlPoints.size() == pointsNum) {
      b = new BSpline(controlPoints, degree, knots2); 
      ifDrawBSpline = true;
    } 
  }
  else {
    Extension ext = new Extension(b, new PVector(mouseX, mouseY));
    newCurve = ext.getNewCurve();
    ifDrawNewCurve = true;
  }
}

void mouseDragged() {
  if (ifDrawBSpline == true)
    for (PVector p : controlPoints) 
      if (checkIfDragged(p)) {
        p.x = mouseX;
        p.y = mouseY;
        break;
      } 
}

Boolean checkIfDragged(PVector p) {
  if (dist(mouseX, mouseY, p.x, p.y) < 10)
    return true;
  else
    return false;
}
