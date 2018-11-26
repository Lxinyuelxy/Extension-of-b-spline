ArrayList<PVector> controlPoints;
int pointsNum = 8;
int degree = 3;
BSpline b;
BSpline b1;
BSpline newCurve;
Boolean ifDrawBSpline = false;
Boolean ifDrawNewCurve = false;
Boolean ifShowControlPolygon = true;

void setup() {
  size(1400, 800);
  controlPoints = new ArrayList<PVector>();
}

ArrayList<Float> generatesUnclampedKnots(int pointsNum, int degree) {
  ArrayList<Float> knots = new ArrayList<Float>();
  for (float i = 0; i <= pointsNum+degree+1-1; i++) {
    knots.add(i*0.1);
  }
  return knots;
}

ArrayList<Float> generatesClampedKnots(int pointsNum, int degree) {
  ArrayList<Float> knots = new ArrayList<Float>();
  for (float i = 0; i <= pointsNum+degree+1-1; i++) {
    if(i < degree+1) knots.add(0.0);
    else if (i < pointsNum) knots.add(i*0.1);
    else knots.add(1.0);
  }
  return knots;
}


void draw() {
  background(255);
  if (ifShowControlPolygon) {
    drawControlPolygon(controlPoints, color(255, 0, 0));
  }
  if (ifDrawNewCurve == true) {
    drawSpline(newCurve, color(0,255,0));
    drawControlPolygon(newCurve.controlPoints, color(0, 255, 0));
    
    drawSpline(b1, color(0,0,255));
    drawControlPolygon(b1.controlPoints, color(0, 0, 255));
  }
  if (ifDrawBSpline == true) {
    drawSpline(b, color(255,0,0));    //<>//
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
  }
}

void mouseClicked() {
  if (controlPoints.size() < pointsNum) {
    controlPoints.add(new PVector(mouseX, mouseY));
    if (controlPoints.size() == pointsNum) {
      b = new BSpline(controlPoints, degree, generatesClampedKnots(pointsNum, degree)); 
      
      ifDrawBSpline = true;
    } 
  }
  else {
    PVector newp = new PVector(mouseX, mouseY);
    Extension ext = new Extension(b, newp);
    newCurve = ext.getNewCurve();
    ifDrawNewCurve = true;
    
    ArrayList<PVector> points = new ArrayList<PVector>();
    for(PVector p : controlPoints) {
      points.add(p.copy());
    }
    points.add(newp);
    b1 = new BSpline(points, degree, generatesClampedKnots(pointsNum+1, degree)); 
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
