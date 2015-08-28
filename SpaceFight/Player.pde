public class Player {

  Vec3D pos;
  PVector direction;
  float fallVel = 15f;
  boolean isJumping = false;
  boolean jumpTriggered = false;

  double jumpStart;
  double jumpTime = 200;
  double jumpDelta;
  double jumpVel;

  double shotStart;
  double shotTime = 20;
  int score = 0;
  boolean onGround = false;
  boolean playerOne;
  boolean isAlive = true;
  int health = 20;
  int healthy = 0xff36FF0D;
  int dying = 0xffFF0000;
  AABB playerBounds = new AABB(new Vec3D(), new Vec3D(80, 80, 80));
  Vec3D currNormal = Vec3D.Y_AXIS.copy();
  IsectData3D isec;

  AudioPlayer explosion;
  AudioPlayer shotFire;
  String boom = "182429__qubodup__explosion.wav";
  String fire = "268343__julien-matthey__jm-noiz-laser.wav";
  public Player(float x, float y, boolean playerOne) {
    pos = new Vec3D(x, 8000, y);
    this.playerOne = playerOne;
    shotStart = millis();
    shotFire = minim.loadFile(fire);
    shotFire.setGain(-20);
    explosion = minim.loadFile(boom);
  }


  public void P1updatePosition() {
    //if jumping and intersect and player miny < box minY player maxY = box MinY
    //if falling and intersect and player miny >= box maxY playerMinY = box maxY

    shotTime =SHOT_COOLDOWN;
    Platform platformOn = null;
    playerBounds.set(pos);
    boolean onPlatform = false;
    for (Platform p : platforms) {
      if (p.boundingBox.intersectsBox(playerBounds)&& pos.y > p.boundingBox.getMax().y) {
        onPlatform = true;
        platformOn = p;
        fallVel=15;
      }
    }

    if (onPlatform) pos.y = platformOn.boundingBox.getMax().y + 80;

    if ((P1crossPressed && !jumpTriggered) && (onGround|| onPlatform)) {
      jumpTriggered = true;
      isJumping = true;
      jumpStart = millis();
      jumpDelta = millis();
      jumpTime = 600;
      fallVel = 15;
    } 
    if (P1crossPressed && isJumping) {
      jumpDelta = millis() - jumpStart;
      jumpTime = 600 - jumpDelta;
      jumpVel = jumpTime * JUMP_FACTOR;                                                                                                                                                                                         
      jumpVel *= 0.85f;
      jumpVel = Math.max(0, jumpVel);
      pos.y += jumpVel;
      playerBounds.set(pos);
      for (Platform p : platforms) {
        if (p.boundingBox.intersectsBox(playerBounds)) {
          println("TRIGGERED2");

          pos.y = p.boundingBox.getMin().y-80;
          onPlatform = false;
        }
      }

      //if (onGround) 
      //isJumping = false;
    } 
    if (shotTime < millis() - shotStart) {
      if (P1rightStick.magnitude()>0.9f) {
        shotFire.rewind();
        shotFire.play();
        P1shots.add(new Shot(new Vec2D(P1rightStick.copy()), new Vec3D(pos), !onGround));
      }
      shotStart = millis();
    }
    if (!P1crossPressed && (onGround || onPlatform)) jumpTriggered = false;

    if (jumpTime < 0) isJumping = false;
    pos.x -= direction.x*PLAYER_SPEED;
    pos.z += direction.y*PLAYER_SPEED;
    fallVel += 0.5f;
    fallVel = Math.min(fallVel, 80);

    if (!(onGround || onPlatform))pos.y -= fallVel;
    AABB b = mesh.getBoundingBox();
    b.setExtent(b.getExtent().scale(0.88f));
    pos.x = Math.max(b.getMin().x, pos.x);
    pos.x = Math.min(b.getMax().x, pos.x);
    pos.z = Math.max(b.getMin().z, pos.z);
    pos.z = Math.min(b.getMax().z, pos.z);
    isec = terrain.intersectAtPoint(pos.x, pos.z);
    if (isec.isIntersection && pos.y <= isec.pos.y() + 80) {
      // smoothly update normal
      //currNormal.interpolateToSelf(isec.normal, 0.15f);
      // move bot slightly above terrain
      pos = isec.pos.add(0, 80, 0);
      onGround = true;
    } 
    else {
      onGround = false;
    }
    for (Shot shot : P2shots) {
      if (isShot(shot.getLoc())) health -=1;
    }
    if (health < 0) {
      explosion.rewind();
      explosion.play();
      player2.score +=1;
      health = 20;
      pos = new Vec3D(2000, 8000, 2000);
    }
  }

  public void P2updatePosition() {
    shotTime =SHOT_COOLDOWN;

    Platform platformOn = null;
    playerBounds.set(pos);
    boolean onPlatform = false;
    for (Platform p : platforms) {
      if (p.boundingBox.intersectsBox(playerBounds)&& pos.y > p.boundingBox.getMax().y) {
        onPlatform = true;
        platformOn = p;
        fallVel=15;
      }
    }

    if (onPlatform) pos.y = platformOn.boundingBox.getMax().y + 80;

    if ((P2crossPressed && !jumpTriggered) && (onGround || onPlatform)) {
      jumpTriggered = true;
      isJumping = true;
      jumpStart = millis();
      jumpDelta = millis();
      jumpTime = 600;
      fallVel = 15;
    } 
    if (P2crossPressed && isJumping) {
      //if falling and intersect and player miny >= box maxY playerMinY = box maxY
      jumpDelta = millis() - jumpStart;
      jumpTime = 600 - jumpDelta;
      jumpVel = jumpTime * JUMP_FACTOR;                                                                                                                                                                                         
      jumpVel *= 0.85f;
      jumpVel = Math.max(0, jumpVel);
      pos.y += jumpVel;
      playerBounds.set(pos);
      for (Platform p : platforms) {
        if (p.boundingBox.intersectsBox(playerBounds)) {
          println("TRIGGERED2");

          pos.y = p.boundingBox.getMin().y-80;
          onPlatform = false;
        }
      }
    } 
    if (shotTime < millis() - shotStart) {
      if (P2rightStick.magnitude()>0.9f) {
       shotFire.rewind();
       shotFire.play();
       P2shots.add(new Shot(new Vec2D(P2rightStick.copy()), new Vec3D(pos), !onGround));
      }
      shotStart = millis();
      shotTime = SHOT_COOLDOWN;
    }
    if (!P2crossPressed && (onGround || onPlatform)) jumpTriggered = false;

    if (jumpTime < 0) isJumping = false;
    pos.x -= direction.x* PLAYER_SPEED;
    pos.z += direction.y* PLAYER_SPEED;
    fallVel += 0.5f;
    fallVel = Math.min(fallVel, 80);
    if (!(onGround || onPlatform))pos.y -= fallVel;
    AABB b = mesh.getBoundingBox();
    b.setExtent(b.getExtent().scale(0.88f));
    pos.x = Math.max(b.getMin().x, pos.x);
    pos.x = Math.min(b.getMax().x, pos.x);
    pos.z = Math.max(b.getMin().z, pos.z);
    pos.z = Math.min(b.getMax().z, pos.z);
    isec = terrain.intersectAtPoint(pos.x, pos.z);
    if (isec.isIntersection && pos.y <= isec.pos.y() + 80) {
      // smoothly update normal
      //currNormal.interpolateToSelf(isec.normal, 0.15f);
      // move bot slightly above terrain
      pos = isec.pos.add(0, 80, 0);
      onGround = true;
    } 
    else {
      onGround = false;
    }
    for (Shot shot : P1shots) {
      if (isShot(shot.getLoc())) health -=1;
    }
    if (health < 0) { 
      explosion.rewind();
      explosion.play();
      player1.score +=1;

      health = 20;
      pos = new Vec3D(-2000, 8000, -2000);
    }
  }

  public void setVelocity(PVector direction) {
    this.direction = direction;
  }

  public boolean isShot(Vec3D point) {
    if (new AABB(new Vec3D(pos), new Vec3D(80, 80, 80)).containsPoint(point)) return true;
    else return false;
  }

  public void draw() {
    if (isAlive) {
      if (playerOne) {
        int playerCol = lerpColor(healthy, dying, 1 - health/20.0f);
        gameField.fill(playerCol);
        TriangleMesh sp = (TriangleMesh)new AABB(new Vec3D(), new Vec3D(80, 80, 80)).toMesh();
        float atanVal;
        if (ry != 0) atanVal = rx/ry; 
        else atanVal = 0;
        sp.pointTowards(currNormal);
        sp.rotateAroundAxis(currNormal, (atan(atanVal)));
        if (rx !=0 ||  ry !=0) {  
          sp.rotateAroundAxis(currNormal, -P1rotateY);
        }
        sp.translate(pos);
        gfx.mesh(sp);
      } 
      else {
        int playerCol = lerpColor(healthy, dying, 1 - health/20.0f);
        gameField.fill(playerCol);        
        TriangleMesh sp = (TriangleMesh)new AABB(new Vec3D(), new Vec3D(80, 80, 80)).toMesh();
        float atanVal;
        if (P2rightStick.y != 0) atanVal = P2rightStick.x/P2rightStick.y; 
        else atanVal = 0;
        sp.pointTowards(currNormal);
        sp.rotateAroundAxis(currNormal, (atan(atanVal)));
        if (rx !=0 ||  ry !=0) {  
          sp.rotateAroundAxis(currNormal, -P2rotateY);
        }
        sp.translate(pos);
        gfx.mesh(sp);
      }
    }
  }
}

