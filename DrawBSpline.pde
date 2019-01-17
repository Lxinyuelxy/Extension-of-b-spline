ArrayList<PVector> controlPoints;
ArrayList<PVector> targetPoints;
int pointsNum = 6;
int degree = 3;

BSpline b;
BSpline newCurve;

Boolean ifDrawBSpline = false;
Boolean ifDrawNewCurve = false;
Boolean ifShowControlPolygon = true;

void setup() {
  size(1400, 800);
  
  controlPoints = new ArrayList<PVector>();
  targetPoints = new ArrayList<PVector>();
}

void draw() {
  background(255);
  if (ifShowControlPolygon) {
    drawControlPolygon(controlPoints, color(255, 0, 0));
  }
  if (ifDrawBSpline) {
    drawPolyLine(b.getBsplineCurve_bSplineExpression(), color(255,0,0));   
  }
  if (ifDrawNewCurve && newCurve != null) {
    drawPolyLine(newCurve.getBsplineCurve_deBoorCox(), color(0,255,0));
    drawControlPolygon(newCurve.controlPoints, color(0, 255, 0));
  }

   //<>//
  if(targetPoints != null) {
    for (PVector p : targetPoints) {
      pushStyle();
      fill(color(0, 0, 0));
      ellipse(p.x, p.y, 15, 15);
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
    else if (keyCode == LEFT) ifDrawNewCurve = !ifDrawNewCurve;  
  }
  if (key == 'e') {
    Extension ext = new Extension(b, targetPoints);
    newCurve = ext.getNewCurve_2();
    ifDrawNewCurve = true;
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
