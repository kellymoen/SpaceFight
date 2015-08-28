
public class Pickup {
  Vec3D pos;
  Vec2D direction;
  float fallVel = 15f;
  boolean onGround = false;
  boolean isAlive = true;
  Platform platformOn = null;
  AABB pickupBounds = new AABB(new Vec3D(), new Vec3D(50, 50, 50));

  Vec3D currNormal = Vec3D.Y_AXIS.copy();
  IsectData3D isec;

  public Pickup() {
    pos = new Vec3D(random(-2000, 2000), 10000, random(-2000, 2000));
  }


  public void updatePosition() {

    if (isec.isIntersection) {
      fallVel += 0.5f;
      fallVel = min(fallVel, 80);
      pos.y -= fallVel;
      pickupBounds.set(pos);
      boolean onPlatform = false;
      for (Platform p : platforms) {
        if (p.boundingBox.intersectsBox(pickupBounds)&& pos.y > p.boundingBox.getMax().y) {
          onPlatform = true;
          platformOn = p;
          fallVel=15;
        }
      }
      pos.y = Math.max(isec.pos.y() + 40, pos.y);
      if (onPlatform) { 
        pos.y = platformOn.boundingBox.getMax().y + 50;
      }
      isec = terrain.intersectAtPoint(pos.x, pos.z);
      if (isec.isIntersection && pos.y<=isec.pos.y() + 50) {
        pos = isec.pos.add(0, 40, 0);
        onGround = true;
      } else {
        onGround = false;
      }
      for (Shot shot : P1shots) {
        if (isShot(shot.getLoc())) isAlive = false;
      }
      for (Shot shot : P2shots) {
        if (isShot(shot.getLoc())) isAlive = false;
      }
    }
  }

  public boolean isShot(Vec3D point) {
    if (new AABB(new Vec3D(pos), new Vec3D(50, 50, 50)).containsPoint(point)) return true;
    else return false;
  }

  public void draw() {
    if (isAlive) {
      gameField.fill(255, 255, 0, 255);
      TriangleMesh sp = (TriangleMesh)new AABB(new Vec3D(), new Vec3D(50, 50, 50)).toMesh();
      sp.pointTowards(currNormal);
      sp.translate(pos);
      gfx.mesh(sp);
    }
  }
}

