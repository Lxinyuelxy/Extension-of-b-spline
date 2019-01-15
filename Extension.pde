class Extension {
  
  ArrayList<PVector> targetPoints;
  BSpline originCur;
  
  Extension(BSpline originCur, ArrayList<PVector> targetPoints) {  
    this.originCur = originCur;
    this.targetPoints = targetPoints;   
    if (targetPoints.size() > 3) {
      throw new IllegalArgumentException("the target points are too many.");
    } 
  }
  
  BSpline getNewCurve_2() {
    for(int i = 0; i < targetPoints.size(); i++) {
      
    }
    return null;
  }
  
  BSpline getNewCurve_1() {
    BSpline[] cur = new BSpline[targetPoints.size()+1];
    cur[0] = originCur;
    for (int i = 0; i < targetPoints.size(); i++) {
      cur[i+1] = extendToPoint(cur[i], targetPoints.get(i));
    }
    return cur[targetPoints.size()];
  }
  
  BSpline extendToPoint(BSpline cur, PVector target) {
    ArrayList<PVector> extentedControlP =  new ArrayList<PVector>();
    ArrayList<Float> extentedKnots =  new ArrayList<Float>();
    
    BSpline unClampedCur = _unclampingCurve(cur, target);
    for(PVector p : unClampedCur.controlPoints) {
      extentedControlP.add(p);
    }
    extentedControlP.add(target);
    
    int n = unClampedCur.knots.size();
    for(float knot : unClampedCur.knots) {
      extentedKnots.add(knot);
    }
    extentedKnots.add(unClampedCur.knots.get(n-1));

    for (int i = 0; i < extentedKnots.size(); i++) {
      extentedKnots.set(i, extentedKnots.get(i)/extentedKnots.get(n));
    }
    //println("extentedControlP: ", extentedControlP);
    //println("extentedKnots: ", extentedKnots); //<>//
    return new BSpline(extentedControlP, degree, extentedKnots);
  }
  
  BSpline _unclampingCurve(BSpline cur, PVector target) {
    ArrayList<PVector> controlPoints_new = new ArrayList<PVector>();
    ArrayList<Float> knots_new = new ArrayList<Float>();
    ArrayList<Float> knots_origin = cur.knots;
    ArrayList<PVector> controlPoints_origin = cur.controlPoints;
    
    int index = knots_origin.size()-1;
    while(knots_origin.get(index).equals(knots_origin.get(index-1))) index--;
    float t = calcT2(cur, target, knots_origin.get(index));
    
    //println("knots_origin: ", knots_origin);
    //println("index: ", index);
    //println("t: ", t);
    
    // according to new calculated knots unclamping controlpoints
    for(float knot : knots_origin) {
      knots_new.add(knot);
    }
    for(int i = index+1; i < knots_origin.size(); i++){
      knots_new.set(i, t);
    }
    //println("knots_new: ", knots_new);
    
    int n = cur.controlPoints.size()-1;
    int p = cur.degree;
    for(int j = 0; j <= n-p; j++) {
      controlPoints_new.add(controlPoints_origin.get(j).copy());
    }
    for(int j = n-p+1; j <= n; j++) {
      controlPoints_new.add(_unclampCtrlP(cur, knots_new, n, p, j, p-2));
    }
    return new BSpline(controlPoints_new, degree, knots_new);
  }
  
  float calcT1(BSpline cur, PVector goal, float u) {
    int cpn_origin = cur.n;
    ArrayList<PVector> controlPoints_origin = cur.controlPoints;
    float _predis = 0.0;
    for(int i = 0; i < cpn_origin-1; i++) {
      float x1 = controlPoints_origin.get(i).x;
      float y1 = controlPoints_origin.get(i).y;
      float x2 = controlPoints_origin.get(i+1).x;
      float y2 = controlPoints_origin.get(i+1).y;
      _predis += dist(x1, y1, x2, y2);
    }
    float x = controlPoints_origin.get(cpn_origin-1).x;
    float y = controlPoints_origin.get(cpn_origin-1).y;
    float t1 = u + dist(goal.x, goal.y, x, y) / _predis;
    return t1;
  }
  
  float calcT2(BSpline cur, PVector goal, float u) {
    int cpn = cur.n;
    int degree = cur.degree;
    ArrayList<Float> knots = cur.knots;
    float _predis = 0.0;
    for(int i = degree; i < cpn; i++) {
      PVector temp1 = cur.BSplineExpression(knots.get(i+1));
      PVector temp2 = cur.BSplineExpression(knots.get(i));
      _predis += dist(temp1.x, temp1.y, temp2.x, temp2.y);
    }
    float x = cur.controlPoints.get(cpn-1).x;
    float y = cur.controlPoints.get(cpn-1).y;
    float t = u + dist(goal.x, goal.y, x, y) / _predis;
    return t;
  }
  
  PVector _unclampCtrlP(BSpline cur, ArrayList<Float> u, int n, int p, int j, int i) {
    if (i == -1)
      return cur.controlPoints.get(j);
    if (j <= n-i-1)
      return _unclampCtrlP(cur, u, n, p, j, i-1);
    else {
      float alpha = (u.get(n+1) - u.get(j)) / (u.get(i+j+2) - u.get(j));
      PVector temp1 = _unclampCtrlP(cur, u, n, p, j, i-1);
      PVector temp2 = PVector.mult(_unclampCtrlP(cur, u, n, p, j-1, i), (1-alpha));
      return PVector.mult(PVector.sub(temp1, temp2), 1/alpha);
    }
  }
  
}
