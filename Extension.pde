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
  
  BSpline getNewCurve_1() {
    BSpline[] cur = new BSpline[targetPoints.size()+1];
    cur[0] = originCur;
    for (int i = 0; i < targetPoints.size(); i++) {
      cur[i+1] = extendToPoint(cur[i], targetPoints.get(i));
    }
    return cur[targetPoints.size()];
  }
  
  BSpline extendToPoint(BSpline cur, PVector target) {
    int cpn = cur.controlPoints.size() - 1;
    
    ArrayList<Float> knots_new = _unclampingKnotsVec(cur, cur.knots, cur.controlPoints.get(cpn), target);
    ArrayList<PVector> controlP_new = _unclampingControlPoints(cur, knots_new);
    controlP_new.add(target);
    
    knots_new = extendKnotsVec(knots_new);
    knots_new = normalizeKnotsVec(knots_new);
    
    //println("extentedControlP: ", extentedControlP);
    //println("extentedKnots: ", extentedKnots); //<>//
    return new BSpline(controlP_new, degree, knots_new);
  }
  
  BSpline getNewCurve_2() {
    ArrayList<PVector> controlPoints = originCur.controlPoints;
    int cpn = controlPoints.size()-1;
    ArrayList<Float> knots_new = _unclampingKnotsVec(originCur, originCur.knots, controlPoints.get(cpn), targetPoints.get(0));
    for(int i =1; i < targetPoints.size(); i++) {
      knots_new = _unclampingKnotsVec(originCur, knots_new, targetPoints.get(i-1), targetPoints.get(i));
    }
    ArrayList<PVector> controlP_new = _unclampingControlPoints(originCur, knots_new);
    //println("knots_new: ", knots_new);
    return null;
  }
  
  
  ArrayList<Float> _unclampingKnotsVec(BSpline cur, ArrayList<Float> knots_origin, PVector Pn, PVector R) {
    ArrayList<Float> knots_new = new ArrayList<Float>();
    
    int index = knots_origin.size()-1;
    
    while(knots_origin.get(index).equals(knots_origin.get(index-1))) 
      index--;
    float t = calcT2(cur, Pn, R, knots_origin.get(index));
    
    // according to new calculated knots unclamping controlpoints
    for(float knot : knots_origin) {
      knots_new.add(knot);
    }
    for(int i = index+1; i < knots_origin.size(); i++){
      knots_new.set(i, t);
    }
    return knots_new;
  }
  
  ArrayList<PVector> _unclampingControlPoints(BSpline cur, ArrayList<Float> knots_new) {
    ArrayList<PVector> controlPoints_new = new ArrayList<PVector>();
    ArrayList<PVector> controlPoints_origin = cur.controlPoints;
    
    int n = cur.controlPoints.size()-1;
    int p = cur.degree;
    for(int j = 0; j <= n-p; j++) {
      controlPoints_new.add(controlPoints_origin.get(j).copy());
    }
    for(int j = n-p+1; j <= n; j++) {
      controlPoints_new.add(_unclampCtrlP(cur, knots_new, n, p, j, p-2));
    }
    return controlPoints_new;
  }
  
  float calcT1(BSpline cur, PVector Pn, PVector R, float u) {
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
    float t1 = u + dist(Pn.x, Pn.y, R.x, R.y) / _predis;
    return t1;
  }
  
  float calcT2(BSpline cur, PVector Pn, PVector R, float u) {
    int cpn = cur.n;
    int degree = cur.degree;
    ArrayList<Float> knots = cur.knots;
    float _predis = 0.0;
    for(int i = degree; i < cpn; i++) {
      PVector temp1 = cur.BSplineExpression(knots.get(i+1));
      PVector temp2 = cur.BSplineExpression(knots.get(i));
      _predis += dist(temp1.x, temp1.y, temp2.x, temp2.y);
    }
    float t = u + dist(Pn.x, Pn.y, R.x, R.y) / _predis;
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
  
  ArrayList<Float> extendKnotsVec(ArrayList<Float> knots) {
    int n = knots.size() - 1;
    knots.add(knots.get(n));
    return knots;
  }
  
  ArrayList<Float> normalizeKnotsVec(ArrayList<Float> knots) {
    int n = knots.size() - 1;
    for (int i = 0; i < knots.size(); i++) {
      knots.set(i, knots.get(i)/knots.get(n));
    }
    return knots;
  }
}
