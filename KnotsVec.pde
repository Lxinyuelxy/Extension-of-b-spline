ArrayList<Float> generatesUnclampedKnots(int pointsNum, int degree) {
  ArrayList<Float> knots = new ArrayList<Float>();
  for (float i = 0; i <= pointsNum+degree+1-1; i++) {
    knots.add(i*0.1);
  }
  return knots;
}

ArrayList<Float> generatesClampedKnots(int pointsNum, int degree) {
  ArrayList<Float> knots = new ArrayList<Float>();
  float delta = 1.0 / (pointsNum-degree);
  for(int i = 0; i < pointsNum+degree+1; i++) {
    if (i < degree+1)
      knots.add(0.0);
    else if (i < pointsNum)
      knots.add(knots.get(i-1) + delta);
    else
      knots.add(1.0);
  }
  return knots;
}
