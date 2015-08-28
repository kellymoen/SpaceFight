public class Platform {
  AABB boundingBox;
  Vec3D position;
  Vec3D size;

  public Platform (Vec3D position, Vec3D size) {
    boundingBox = new AABB(position, size);
    this.position= position;
    this.size = size;
  }

  public void draw() {
    TriangleMesh sp = (TriangleMesh)new AABB(new Vec3D(), size).toMesh();
    sp.translate(position);
    gameField.fill(0, 0, 255, 80);
    gfx.mesh(sp);
  }
}

