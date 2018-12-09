class BSpline {
  ArrayList<PVector> controlPoints;
  ArrayList<Float> knots;
  ArrayList<Float> weights;
  int degree;
  int n;
  
  BSpline (ArrayList<PVector> controlPoints, int degree, ArrayList<Float> knots) {
    this. controlPoints = controlPoints;
    this.n = controlPoints.size();
    this.degree = degree;
    this.knots = knots;
    
    if (this.degree < 1)
      throw new IllegalArgumentException("degree must be at least 1 (linear)");
    if (knots.size() != controlPoints.size() + degree + 1) {
      throw new IllegalArgumentException("knots'size must be equal to points'size + degree + 1");
    }    
  }
  
  BSpline (ArrayList<PVector> controlPoints, int degree, ArrayList<Float> knots, ArrayList<Float> weights) {  
  }
  
  ArrayList<PVector> getBsplineCurve_deBoorCox() {
    
    ArrayList<PVector> points = new ArrayList<PVector>();
    
    float low = this.knots.get(this.degree);
    float high = this.knots.get(this.n);
    float deltat = (high - low) / 200.0;
    
    int j = this.degree;
    for (float t = low; t <= high; t += deltat) {
      while (t > this.knots.get(j+1)) j++;
      PVector p = deBoorCox(t, j);
      points.add(p);
    }
    return points;
  }
  
  /**
  use deBoor-Cox algorithm to calculate P(t)
  t is in [knots(j), knots(j+1)]
  **/
  PVector deBoorCox (float t, int j) {

    PVector[] V = new PVector[this.n];
    int index = 0;
    for (PVector p : this.controlPoints) {
      V[index] = p.copy();
      index++;
    }
    int i = j;
    for (int r = 1; r <= degree+1; r++) {
      for (i = j; i > j-degree-1+r; i--) {
        float alpha = (t - this.knots.get(i)) / (this.knots.get(i+degree+1-r) - this.knots.get(i));
        
        V[i] = PVector.add(PVector.mult(V[i], alpha), PVector.mult(V[i-1], (1-alpha)));
      }
    }
    return V[i];
  }
  
  ArrayList<PVector> getBsplineCurve_bSplineExpression() {
    
    ArrayList<PVector> points = new ArrayList<PVector>();
    
    float low = this.knots.get(this.degree);
    float high = this.knots.get(this.n);
    float deltat = (high - low) / 200.0;
    
    for (float t = low; t <= high; t += deltat) {
      PVector p = BSplineExpression(t);
      points.add(p);
    }
    return points;
  }
  
  PVector BSplineExpression(float t) {
    PVector res = new PVector();
    for(int i = 0; i < n; i++) {
      PVector p = this.controlPoints.get(i).copy();
      res = PVector.add(res, PVector.mult(p, basisFunc(i, this.degree, t)));
    }
    return res;
  }
  
  float basisFunc(int i, int degree, float t) {
    if (degree == 0) {
      if (t >= this.knots.get(i) && t < this.knots.get(i+1)) return 1;
      else return 0;
    }
    else {
      float temp1;
      if ((this.knots.get(i+degree) - this.knots.get(i)) == 0) 
        temp1 = 0.0;
      else
        temp1 = (t - this.knots.get(i)) / (this.knots.get(i+degree) - this.knots.get(i));
        
      float temp2;
      if ((this.knots.get(i+degree+1) - this.knots.get(i+1)) == 0)
        temp2 = 0.0;
      else
        temp2 = (this.knots.get(i+degree+1) - t) / (this.knots.get(i+degree+1) - this.knots.get(i+1));
      return temp1*basisFunc(i, degree-1, t) + temp2*basisFunc(i+1, degree-1, t);
    }
  }
}
