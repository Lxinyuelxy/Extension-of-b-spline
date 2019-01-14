class Extension {
  ArrayList<PVector> controlPoints_new;
  ArrayList<Float> knots_new;
  ArrayList<PVector> targetPoints;
  BSpline originCur;
  
  Extension(BSpline originCur, ArrayList<PVector> targetPoints) {  
    this.originCur = originCur;
    this.targetPoints = targetPoints;
  }
  
  BSpline getNewCurve() {
    BSpline[] cur = new BSpline[targetPoints.size()+1];
    cur[0] = originCur;
    for (int i = 0; i < targetPoints.size(); i++) {
      cur[i+1] = extendToPoint(cur[i], targetPoints.get(i));
    }
    return cur[targetPoints.size()];
  }
  
  BSpline extendToPoint(BSpline cur, PVector target) {
    this.controlPoints_new = new ArrayList<PVector>();
    this.knots_new = new ArrayList<Float>();
    
    float t = calcT1(cur, target);
    //float t = calcT2(cur, goal);
    
    _unclampingCurve(cur, t);
    controlPoints_new.add(target);
    
    for (int i = 0; i < controlPoints_new.size(); i++) {
      knots_new.add(cur.knots.get(i));
    }
    for (int i = controlPoints_new.size(); i < controlPoints_new.size()+originCur.degree+1; i++) {
      knots_new.add(t);
    }

    for (int i = 0; i < knots_new.size(); i++) {
      knots_new.set(i, knots_new.get(i)/t);
    }
    BSpline newCur = new BSpline(this.controlPoints_new, degree, this.knots_new); //<>//
    return newCur;
  }
  
  float calcT1(BSpline originCur, PVector goal) {
    int cpn_origin = originCur.n;
    ArrayList<PVector> controlPoints_origin = originCur.controlPoints;
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
    float t1 = 1 + dist(goal.x, goal.y, x, y) / _predis;
    return t1;
  }
  
  float calcT2(BSpline originCur, PVector goal) {
    int cpn = originCur.n;
    int degree = originCur.degree;
    ArrayList<Float> knots = originCur.knots;
    float _predis = 0.0;
    for(int i = degree; i < cpn; i++) {
      PVector temp1 = originCur.BSplineExpression(knots.get(i+1));
      PVector temp2 = originCur.BSplineExpression(knots.get(i));
      _predis += dist(temp1.x, temp1.y, temp2.x, temp2.y);
    }
    float x = originCur.controlPoints.get(cpn-1).x;
    float y = originCur.controlPoints.get(cpn-1).y;
    float t1 = 1 + dist(goal.x, goal.y, x, y) / _predis;
    return t1;
  }
  
  void _unclampingCurve(BSpline originCur, float t) {
    ArrayList<Float> knots_origin = originCur.knots;
    ArrayList<PVector> controlPoints_origin = originCur.controlPoints;
    ArrayList<Float> u = new ArrayList<Float>();
    for(float knot : knots_origin) {
      u.add(knot);
    }
    u.set(knots_origin.size()-3, t);
    u.set(knots_origin.size()-2, t);
    u.set(knots_origin.size()-1, t);
    
    int n = originCur.controlPoints.size()-1;
    int p = originCur.degree;
    for(int j = 0; j <= n-p; j++) {
      this.controlPoints_new.add(controlPoints_origin.get(j).copy());
    }
    for(int j = n-p+1; j <= n; j++) {
      this.controlPoints_new.add(_unclampCtrlP(originCur, u, n, p, j, p-2));
    }
  }
  
  PVector _unclampCtrlP(BSpline cur, ArrayList<Float> u, int n, int p, int j, int i) {
    if (i == -1)
      return cur.controlPoints.get(j);
    if (j <= n-i-1)
      return _unclampCtrlP(cur, u, n, p, j, i-1);
    else {
      float alpha = (u.get(n+1) - u.get(j)) / (u.get(i+j+2) - u.get(j));
      PVector temp1 = _unclampCtrlP(cur,u,n,p,j,i-1);
      PVector temp2 = PVector.mult(_unclampCtrlP(cur,u,n,p,j-1,i), (1-alpha));
      return PVector.mult(PVector.sub(temp1, temp2), 1/alpha);
    }
  }
  
}
