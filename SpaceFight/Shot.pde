

class Shot {
  float x, y, z;
  float dirX;
  float dirY;
  float dirZ;
  float fallVel = 15f;
  boolean jumpShot;
  boolean alive = true;
  double spawnTime = millis();
  Vec3D trans;
  TriangleMesh point;
  IsectData3D isec;
  
  public Shot (Vec2D direction, Vec3D position, boolean jumpShot) {
    x = position.x;
    y = position.y + 30;
    z = position.z;
    dirX = -direction.x;
    dirY = 0;
    dirZ = direction.y;
    this.jumpShot = jumpShot;
  }

  public void update() {
    x += dirX * SHOT_SPEED;
    //y += dirY * 40;
    z += dirZ * SHOT_SPEED;
    isec = terrain.intersectAtPoint(x, z);
    if (millis() > spawnTime + 2000) alive = false;
    if (isec.isIntersection) {
      if (!jumpShot) y = isec.pos.y() + 40;
      else {
        fallVel += 0.5f;
        fallVel = Math.min(fallVel, 80);
        y -= fallVel;

        boolean onPlatform = false;
        Platform platformOn = null;
        for (Platform p : platforms) {
          if (p.boundingBox.intersectsSphere(new Sphere(new Vec3D(x, y, z), 25))) {
            onPlatform = true;
            platformOn = p;
            fallVel=15;
          }
        }
        y = Math.max(isec.pos.y() + 40, y);
        if (onPlatform) y = platformOn.boundingBox.getMax().y + 20;
      }
      /*//if (y <= isec.pos.y()){
       Vec3D toReflect = new Vec3D(dirX, 0, dirZ);
       Vec3D reflected = new Vec3D(isec.normal.x(), 0, isec.normal.z());
       reflected.normalizeTo(toReflect.magnitude());
       dirX = reflected.x;
       //dirY = isec.normal.y();
       dirZ = reflected.z;*/
      //
    }
    trans = new Vec3D(x, y, z);
  }

  public Vec3D getLoc() {
    return new Vec3D(x, y, z);
  }

  public void draw() {
    if (alive) {
      point = (TriangleMesh) new Sphere(new Vec3D(), 25).toMesh(2);
      gameField.fill(255, 255, 255, 255);
      gameField.emissive(100);
      gameField.shininess(9.0f); 
      point.translate(trans);
      gfx.mesh(point);
      gameField.shininess(0);
      gameField.emissive(0);
    }
  }
}

