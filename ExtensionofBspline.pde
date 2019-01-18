ArrayList<PVector> controlPoints;
ArrayList<PVector> targetPoints;
int pointsNum = 6;
int degree = 3;

BSpline b;
BSpline extendedCur_1;
BSpline extendedCur_2;

Boolean ifDrawBSpline = false;
Boolean ifDrawextendedCur_1 = false;
Boolean ifDrawextendedCur_2 = false;

void setup() {
  size(1400, 800);  
  controlPoints = new ArrayList<PVector>();
  targetPoints = new ArrayList<PVector>();
}

void draw() {
  background(255);
  drawControlPolygon(controlPoints, color(255, 0, 0));
  if (ifDrawBSpline) {
    drawPolyLine(b.getBsplineCurve_bSplineExpression(), color(255,0,0));  
  }
  if (ifDrawextendedCur_1 && extendedCur_1 != null) {
    drawPolyLine(extendedCur_1.getBsplineCurve_deBoorCox(), color(0,255,0));
    drawControlPolygon(extendedCur_1.controlPoints, color(0, 255, 0));
  }
  if (ifDrawextendedCur_2 && extendedCur_2 != null) {
    drawPolyLine(extendedCur_2.getBsplineCurve_deBoorCox(), color(0,0,255));
    drawControlPolygon(extendedCur_2.controlPoints, color(0, 0, 255));
  }
 //<>//
  if(targetPoints != null) {
    for (PVector p : targetPoints) {
      pushStyle();
      fill(color(0, 0, 0));
      ellipse(p.x, p.y, 10, 10);
      popStyle();
    }
  }
}

void drawPolyLine(ArrayList<PVector> points, color c) {
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

void drawControlPolygon(ArrayList<PVector> points, color c) {
  noFill();
  beginShape();
  stroke(c);
  for (PVector p: points) {
    pushStyle();
    if (checkIfDragged(p)) {
      noFill();
      ellipse(p.x, p.y, 20, 20);
    } 
    else {
      noFill();
      ellipse(p.x, p.y, 15, 15);
    }
    popStyle();
    vertex(p.x, p.y);
  }
  endShape();
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) ifDrawBSpline = !ifDrawBSpline;
    else if (keyCode == LEFT) ifDrawextendedCur_1 = !ifDrawextendedCur_1;
    else if(keyCode == RIGHT) ifDrawextendedCur_2 = !ifDrawextendedCur_2;
  }
  if (key == 'e') {
    Extension ext = new Extension(b, targetPoints);
    extendedCur_1 = ext.getNewCurve_1();
    extendedCur_2 = ext.getNewCurve_2();
    ifDrawextendedCur_1 = true;
    ifDrawextendedCur_2 = true;
  }
}

void mouseClicked() {
  if (controlPoints.size() < pointsNum) {
    PVector p = new PVector(mouseX, mouseY);
    controlPoints.add(p);
    if (controlPoints.size() == pointsNum) {
      b = new BSpline(controlPoints, degree, generatesClampedKnots(pointsNum, degree)); 
      ifDrawBSpline = true;
    } 
  }
  else {
    if (ifDrawextendedCur_1 == true) {
      targetPoints = new ArrayList<PVector>();
      ifDrawextendedCur_1 = false;
      ifDrawextendedCur_2 = false;
    }
    PVector target = new PVector(mouseX, mouseY);
    targetPoints.add(target);
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
