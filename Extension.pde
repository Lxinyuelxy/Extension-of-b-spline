class Extension {
  ArrayList<PVector> controlPoints_new;
  ArrayList<Float> knots_new;
  
  Extension(BSpline originCur, PVector goal) {
    ArrayList<PVector> controlPoints_origin = originCur.controlPoints;
    int cpn_origin = controlPoints_origin.size();
    
    this.controlPoints_new = new ArrayList<PVector>();
    this.knots_new = new ArrayList<Float>();
    
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
    
    _unclampingCurve(originCur, t1);
    controlPoints_new.add(goal);
    
    for (int i = 0; i < controlPoints_new.size(); i++) {
      knots_new.add(originCur.knots.get(i));
    }
    for (int i = controlPoints_new.size(); i < controlPoints_new.size()+originCur.degree+1; i++) {
      knots_new.add(t1);
    }

    for (int i = 0; i < knots_new.size(); i++) {
      knots_new.set(i, knots_new.get(i)/t1);
    }
  }
  
  void _unclampingCurve(BSpline originCur, float t1) {
    ArrayList<Float> knots_origin = originCur.knots;
    ArrayList<PVector> controlPoints_origin = originCur.controlPoints;
    ArrayList<Float> u = new ArrayList<Float>();
    for(float knot : knots_origin) {
      u.add(knot);
    }
    u.set(knots_origin.size()-3, t1);
    u.set(knots_origin.size()-2, t1);
    u.set(knots_origin.size()-1, t1);
    
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
  
  BSpline getNewCurve() {
    BSpline newCur = new BSpline(this.controlPoints_new, degree, this.knots_new);
    return newCur;
  }
}
