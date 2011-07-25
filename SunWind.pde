class SunWind {
  PVector start, end; 
  int detail;
  int windLines=5;
  float strength=20.0;
  float[] fieldActivity; // 0 = no activity | 1 = full activity
  ArrayList<WindCurve> windCurves = new ArrayList();
  
  float maxActivity=1;
  float minActivity=0;

  SunWind(float _windY, float _width, float _height ,int _detail) {

    start = new PVector(0, _windY); 
    end = new PVector(_width, _windY);
    detail = _detail;

    fieldActivity = new float[detail];
    for (int i=0; i < detail; i++) fieldActivity[i]=0;

    for (int i = 0;i < windLines; i++) {
      WindCurve wind = new WindCurve(start.x, start.y, end.x, end.y, _height, detail);  
      windCurves.add(wind);
    }
  }

  void render() {
    for (int i = 0;i < windCurves.size(); i++) windCurves.get(i).render();
//    drawFields();
  }

  void update(float _sunX, float _sunY) {
    for (int i = 0;i < windCurves.size(); i++) windCurves.get(i).update(_sunX, _sunY);
  }

  void drawFields() {
    float step = (end.x-start.x)/detail;
    for (int i=0; i<detail; i++) {
      stroke(255, 255, 0, map(fieldActivity[i], 0, 1, 0, 255));
      rect(step*i-step/2, 0, step, start.y+20);
    }
  }

  void setFieldActivity(int index, float activity) {
    print("activity "+activity);
    if (activity > maxActivity) maxActivity = activity;
    if (activity < minActivity) minActivity = activity;
    activity = map(activity, minActivity, maxActivity, 0, 1);
    println(" > "+activity);
    fieldActivity[index] = activity;
//    println(index+" is active "+fieldActivity[index]+" max "+maxActivity+", min "+minActivity);
    for (int i = 0;i < windCurves.size(); i++) {
      windCurves.get(i).setActivityOffset(index, activity*i);
    }
  }
  
  void updateNodeEnergy(float nodeX, float energy) {
    for (int i = 0;i < windCurves.size(); i++) {
      windCurves.get(i).setNodeOffset(nodeX, energy);
    } 
  }
}

