class Extension {
  
  ArrayList<PVector> targetPoints;
  BSpline originCur;
  int k;
  
  Extension(BSpline originCur, ArrayList<PVector> targetPoints) {  
    this.originCur = originCur;
    this.targetPoints = targetPoints; 
    this.k = originCur.degree + 1;
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
    ArrayList<PVector> controlPs_new = _unclampingControlPoints(cur, knots_new);
    controlPs_new.add(target);
    
    knots_new = extendKnotsVec(knots_new);
    knots_new = normalizeKnotsVec(knots_new);
 //<>//
    return new BSpline(controlPs_new, degree, knots_new);
  }
  
  BSpline getNewCurve_2() {
    ArrayList<PVector> controlPoints = originCur.controlPoints;
    int cpn = controlPoints.size()-1;
    
    ArrayList<Float> knots_new = _unclampingKnotsVec(originCur, originCur.knots, controlPoints.get(cpn), targetPoints.get(0));
    for(int i =1; i < targetPoints.size(); i++) {
      knots_new = _unclampingKnotsVec(originCur, knots_new, targetPoints.get(i-1), targetPoints.get(i));
    }
    
    ArrayList<PVector> controlPs_new = _unclampingControlPoints(originCur, knots_new);
    
    for(int i = 0; i < targetPoints.size(); i++) {
      knots_new = extendKnotsVec(knots_new);
      if (i == targetPoints.size()-1) {
        controlPs_new.add(targetPoints.get(i));
      }
      else {
        PVector controlP = inverseDeBoor(0, controlPs_new.size(), knots_new.get(controlPs_new.size()+1), controlPs_new, knots_new, targetPoints.get(i));
        controlPs_new.add(controlP);
      } 
    }
    return new BSpline(controlPs_new, degree, normalizeKnotsVec(knots_new));
  }
  
  PVector inverseDeBoor(int r, int i, float t, ArrayList<PVector> points, ArrayList<Float> knots, PVector target) {
    if (r == k-1 && i == originCur.controlPoints.size()-k+1)
      return target;
    else if(i < originCur.controlPoints.size()-k+1) {
      return null;
    }
    else {
      float temp1 = (knots.get(i+k) - knots.get(i+r)) / (t - knots.get(i+r));
      float temp2 = (knots.get(i+k) - t) / (t - knots.get(i+r));
      PVector p1 = inverseDeBoor(r+1, i-1, t, points, knots, target);
      PVector p2 = inverseDeBoor(r, i-1, t, points, knots, target);
      if (p1 == null || p2 == null)
        return deBoor(r, i, t, points, knots);
      else
        return PVector.sub(PVector.mult(p1, temp1), PVector.mult(p2, temp2));
    }  
  }
  
  PVector deBoor(int r, int i, float t, ArrayList<PVector> points, ArrayList<Float> knots) {
    if (r == 0) {
      return points.get(i);
    }
    else {   
      float temp1 = (knots.get(i+k) - t) / (knots.get(i+k) - knots.get(i+r));
      float temp2 = (t - knots.get(i+r)) / (knots.get(i+k) - knots.get(i+1));
      return PVector.add(PVector.mult(deBoor(r-1, i, t, points, knots), temp1), PVector.mult(deBoor(r-1, i+1, t, points, knots), temp2));
    }
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
