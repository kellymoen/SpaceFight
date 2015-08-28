
ControlP5 cp5;

ToxiclibsSupport gfx;

float PLAYER_SPEED, SHOT_COOLDOWN, JUMP_FACTOR, SHOT_SPEED;

import ddf.minim.*;

Minim minim;

AudioPlayer player;
String fire = "268343__julien-matthey__jm-noiz-laser.wav";
PImage instructions;
PImage doc;

PGraphics overlay;
PGraphics gameField;
PFont font = createFont("DIN", 50, true);
PFont fontMid = createFont("DIN", 100, true);
PFont fontBig = createFont("DIN", 200, true);
ControlIO control;
ControlDevice stick1; //INPUTS
ControlDevice stick2;
float lx, ly, rx, ry, P2rx, P2ry;
float P1rotateY, P1rotateX;
float P2rotateY, P2rotateX;
PVector P1leftStick;
Vec2D P1rightStick;
PVector P2leftStick;
Vec2D P2rightStick;
boolean P1crossPressed;
boolean P2crossPressed;
boolean xPressed = false;
boolean startPressed = false;
boolean stickReleased =false;
boolean stickLock = false;


color titleCol = #FF8C2B;
color darkerCol = #9c551a;

float NOISE_SCALE = 0.24f; // ENVIRONMENT
int DIM = 50;
PImage backdrop;
Terrain terrain;
Mesh3D mesh;

Player player1;    
Player player2;
ArrayList<Shot> P1shots;
ArrayList<Shot> P2shots;
ArrayList<Platform> platforms;
ArrayList<Pickup> pickups;

Vec3D camOffset = new Vec3D(0, 1000, 1800);
Vec3D eyePos = new Vec3D(0, 0, 00);
Vec3D lazyCam = new Vec3D(0, 10, 50);

boolean gamePlaying = false;
boolean splashMode = true;
boolean splashDisplay = true;
boolean instructionMode = false;
boolean docMode = false;

boolean newSelected = true;
boolean docSelected = false;
boolean instructSelected = false;
int mode = 0;



/* 
 * Copyright (c) 2010 Karsten Schmidt
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * http://creativecommons.org/licenses/LGPL/2.1/
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

public void setup() {
  size(displayWidth, displayHeight, P3D);
  frameRate(60);

  backdrop = loadImage("galaxy-wallpaper-4.jpg");
  instructions = loadImage("instructions.png");
  doc = loadImage("doc.png");
  //smooth(8);
  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  stick1 = control.getMatchedDevice("ps3controlpc");
  stick2 = control.getMatchedDevice("ps3controlpc_2");
  //stick2 = stick1;
  if (stick1 == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
  terrain = new Terrain(DIM, DIM, 400);
  float[] el = new float[DIM*DIM];
  noiseSeed(23);
  for (int z = 0, i = 0; z < DIM; z++) {
    for (int x = 0; x < DIM; x++) {
      el[i++] = noise(x * NOISE_SCALE, z * NOISE_SCALE) * 2000;
    }
  }
  terrain.setElevation(el);
  // create mesh
  mesh = terrain.toMesh();

  overlay = createGraphics(displayWidth, displayHeight, P2D);
  gameField = createGraphics(displayWidth, displayHeight, P3D);
  //  gameField.smooth(8);
  gfx = new ToxiclibsSupport(this, gameField);

  minim = new Minim(this);
  player = minim.loadFile(fire);
  player.play();

  /*cp5 = new ControlP5(this);
   cp5.addSlider("PLAYER_SPEED")
   .setPosition(0, 0)
   .setSize(20, 100)
   .setRange(0, 40)
   .setValue(30)
   .setNumberOfTickMarks(255)
   ;
   cp5.addSlider("SHOT_COOLDOWN")
   .setPosition(100, 0)
   .setSize(20, 100)
   .setRange(50, 250)
   .setNumberOfTickMarks(255)
   .setValue(200);
   ;
   cp5.addSlider("JUMP_FACTOR")
   .setPosition(200, 0)
   .setSize(20, 100)
   .setRange(0, 0.4f)
   .setValue(0.305f)
   .setNumberOfTickMarks(255)
   ;
   cp5.addSlider("SHOT_SPEED")
   .setPosition(300, 0)
   .setSize(20, 100)
   .setRange(40, 180)
   .setValue(90)
   .setNumberOfTickMarks(255)*/
  PLAYER_SPEED = 25;
  SHOT_COOLDOWN = 150;
  JUMP_FACTOR = 0.26;
  SHOT_SPEED = 70;
  platforms = new ArrayList<Platform>();
  platforms.add(new Platform(new Vec3D(0, 2000, 0), new Vec3D(3000, 10, 3000)));
  platforms.add(new Platform(new Vec3D(2000, 3000, 2000), new Vec3D(1000, 10, 1000)));
  platforms.add(new Platform(new Vec3D(2000, 4000, 2000), new Vec3D(500, 10, 500)));
  platforms.add(new Platform(new Vec3D(-2000, 3000, -2000), new Vec3D(1000, 10, 1000)));
  platforms.add(new Platform(new Vec3D(-2000, 4000, -2000), new Vec3D(500, 10, 500)));

  startGame();
}

public void startGame() {
  player1 = new Player(2000, 2000, true);
  player2 = new Player(-2000, -2000, false);
  P1shots = new ArrayList<Shot>();
  P2shots = new ArrayList<Shot>();
  pickups = new ArrayList<Pickup>();
  for (int i =0; i < 10; i++){
    pickups.add(new Pickup());
  }
}

// Poll for user input called from the draw() method.
public void getUserInput() {
  lx = stick1.getSlider("LeftX").getValue();
  ly = stick1.getSlider("LeftY").getValue();
  if (abs(lx) < 0.1f) lx = 0;
  if (abs(ly) < 0.1f) ly = 0;

  P1leftStick =new PVector(lx, ly);
  rx = stick1.getSlider("RightX").getValue();
  ry = stick1.getSlider("RightY").getValue();

  if (abs(rx) < 0.05f) rx = 0;
  if (abs(ry) < 0.05f) ry = 0;
  P1rightStick = new Vec2D(rx, ry);
  P1crossPressed = (stick1.getSlider("L2R2").getValue() > 0.1f || stick1.getSlider("L2R2").getValue() < -0.1f);
 // P1crossPressed = (stick1.getButton("R2").pressed() ||stick1.getButton("L2").pressed());

  lx = stick2.getSlider("LeftX").getValue();
  ly = stick2.getSlider("LeftY").getValue();
  if (abs(lx) < 0.1f) lx = 0;
  if (abs(ly) < 0.1f) ly = 0;

  P2leftStick =new PVector(lx, ly);
  P2rx = stick2.getSlider("RightX").getValue();
  P2ry = stick2.getSlider("RightY").getValue();

  if (abs(P2rx) < 0.05f) P2rx = 0;
  if (abs(P2ry) < 0.05f) P2ry = 0;
  P2rightStick = new Vec2D(P2rx, P2ry);
   P2crossPressed = (stick2.getSlider("L2R2").getValue() > 0.1f || stick2.getSlider("L2R2").getValue() < -0.1f);
//  P2crossPressed = (stick2.getButton("R2").pressed() ||stick2.getButton("L2").pressed());

  if (stick1.getButton("Start").pressed() && !startPressed) {
    splashMode = !splashMode;
    splashDisplay =!splashDisplay;
    gamePlaying = !gamePlaying;
    startPressed = true;
  } else
    if (!stick1.getButton("Start").pressed())
    startPressed = false;
  //P2crossPressed = stick2.getButton("R2").pressed();
}

public void draw() {
  gameField.beginDraw();
  gameField.clear();

  /*CAMERA WORK*/
  float zoomFactor = player1.pos.distanceTo(player2.pos)/1000.0f;
  float yOffset = max(1200, 700 * zoomFactor);
  float zOffset = max(1800, 1000 * zoomFactor);
  camOffset = new Vec3D(0, yOffset, zOffset);
  Vec3D focalPoint = midPoint(player1.pos, player2.pos);
  if (splashMode) focalPoint = new Vec3D(0, 1900, 5900);
  Vec3D camPos = focalPoint.add(camOffset);
  float y = terrain.getHeightAtPoint(camPos.x, camPos.z);
  if (!Float.isNaN(y)) {
    camPos.y = max(camPos.y, y + 200);
  }
  //camPos = camPos.getRotatedY(rotateY);
  eyePos.interpolateToSelf(camPos, 0.12f);     
  gameField.camera(eyePos.x, eyePos.y, eyePos.z, lazyCam.x, lazyCam.y, lazyCam.z, 0, -1, 0);
  float fov = PI/3.0f;
  float cameraZ = (height/2.0f) / tan(fov/2.0f);
  gameField.perspective(fov, PApplet.parseFloat(width)/PApplet.parseFloat(height), 
  cameraZ/10.0f, cameraZ*100.0f);
  gameField.directionalLight(192, 160, 128, 0, -1000, -0.5f);
  gameField.directionalLight(255, 64, 0, 0.5f, -0.1f, 0.5f);
  gameField.ambientLight(50, 50, 50);


  /*DRAW GAME FIELD*/
  gameField.fill(155, 64, 64);
  gameField.noStroke();
  gfx.mesh(mesh, false);


  getUserInput(); // Polling

  if (splashMode) {
    if (P1leftStick.y < -0.5 && stickReleased && !stickLock) {
      mode -= 1;
      stickReleased = false;
    } else if (P1leftStick.y > 0.5 && stickReleased && !stickLock) { 
      mode += 1;
      stickReleased = false;
    } 
    if (abs(P1leftStick.y) < 0.1) stickReleased = true;
    mode = constrain(mode, 0, 2);
    if (mode == 0) {
      newSelected = true;
      docSelected = false;
      instructSelected = false;
      if (stick1.getButton("Cross").pressed() && !xPressed) {
        splashDisplay = !splashDisplay;
        splashMode = !splashMode;
        gamePlaying = !gamePlaying;
        startGame();
        xPressed = true;
      }
    } else if (mode == 2) {
      newSelected = false;
      docSelected = true;
      instructSelected = false;
      if (stick1.getButton("Cross").pressed() && !xPressed) {
        splashDisplay = !splashDisplay;
        docMode = !docMode;
        stickLock = !stickLock;
        xPressed = true;
      }
    } else if (mode ==1) {
      newSelected = false;
      docSelected = false;
      instructSelected = true;
      if (stick1.getButton("Cross").pressed() && !xPressed) {
        splashDisplay = !splashDisplay;
        stickLock = !stickLock;
        instructionMode = !instructionMode;
        xPressed = true;
      }
    }
    if (!stick1.getButton("Cross").pressed()) xPressed = false;
  }

  if (gamePlaying) {
    player1.setVelocity(P1leftStick);
    if (player1.isAlive) player1.P1updatePosition();
    player2.setVelocity(P2leftStick);
    if (player2.isAlive) player2.P2updatePosition();
    lazyCam.interpolateToSelf(focalPoint, 0.19f);

    for (Shot shot : P1shots) {
      shot.update();
      shot.draw();
    }
    for (Shot shot : P2shots) {
      shot.update();
      shot.draw();
    }

    ArrayList<Shot> shotRemove = new ArrayList<Shot>();
    for (Shot shot : P1shots) {
      if (shot.alive) shotRemove.add(shot);
    }
    P1shots = shotRemove;
    shotRemove = new ArrayList<Shot>();
    for (Shot shot : P2shots) {
      if (shot.alive) shotRemove.add(shot);
    }
    P2shots = shotRemove;
  }
  player1.draw();
  player2.draw();
  for (Platform p : platforms) {
    p.draw();
  }

  gameField.endDraw();


  camera();

  /*UI WORK*/

  overlay.beginDraw();
  overlay.clear();
  if (splashDisplay) {
    overlay.textFont(fontBig);
    overlay.textSize(200);
    overlay.fill(titleCol);
    overlay.textAlign(CENTER);
    overlay.text(new String("SPACEFIGHT"), width/2, height/4);
    overlay.textFont(fontMid);
    overlay.textSize(100);
    if (newSelected) {
      overlay.fill(darkerCol);
    } else { 
      overlay.fill(titleCol);
    }
    overlay.text(new String("NEW GAME"), width/2, height/2 );
    if (instructSelected) {
      overlay.fill(darkerCol);
    } else {
      overlay.fill(titleCol);
    }
    overlay.text(new String("INSTRUCTIONS"), width/2, height/2 + 150 );
    if (docSelected) {
      overlay.fill(darkerCol);
    } else { 
      overlay.fill(titleCol);
    }
    overlay.text(new String("DOCUMENTATION"), width/2, height/2 +300);
  }
  if (docMode) overlay.image(doc, 0, 0, width, height);
  if (instructionMode) overlay.image(instructions, 0, 0, width, height);
  if (gamePlaying) {
    overlay.textFont(font);
    overlay.textSize(50);
    overlay.textAlign(LEFT);
    strokeText(new String(""+player1.score), 100, height/4);
    overlay.textAlign(RIGHT);
    strokeText(new String(""+player2.score), width - 100, height/4);
  }
  image(backdrop, 0, 0, width, height);
  image(gameField, 0, 0);
  image(overlay, 0, 0);
  overlay.endDraw();
}

public Vec3D midPoint(Vec3D a, Vec3D b) {
  float ax = a.x;
  float ay = a.y;
  float az = a.z;
  float bx = b.x;
  float by = b.y;
  float bz = b.z;
  float midx = (ax + bx)/2.0f;
  float midy = (ay + by)/2.0f;
  float midz = (az + bz)/2.0f;
  return new Vec3D(midx, midy, midz);
}

void strokeText(String message, int x, int y) 
{ 
  overlay.fill(0); 
  overlay.text(message, x-2, y); 
  overlay.text(message, x, y-2); 
  overlay.text(message, x+2, y); 
  overlay.text(message, x, y+2); 
  overlay.fill(255); 
  overlay.text(message, x, y);
} 