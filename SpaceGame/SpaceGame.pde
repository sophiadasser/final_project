PImage bgImage;
PImage rocketImage;
PImage coinImg;
ArrayList<Planet> planets;
Rocket rocket;
ArrayList<Coin> coins;
int score;
boolean dead;

void setup() {
  size(1000, 667);
  bgImage = loadImage("space_background.jpg");
  rocketImage = loadImage("rocket.png");
  coinImg = loadImage("coin.png");
  
  planets = new ArrayList<Planet>();
  rocket = new Rocket();
  coins = new ArrayList<Coin>();
  
  score = 0;
  dead = false;
  
  // Creating initial set of planets
  for (int i = 0; i < 3; i++) {
    planets.add(new Planet(i * width / 2 + width, random(height)));
  }
  
  // Creating Space Gold:
  
  for (int i = 0; i < 6; i++) {
    float x = width + i * 200;
    float y = random(height + 40);
    Coin coin = new Coin(x, y);
    coins.add(coin);
  }
}

void draw() {
  background(0);
  image(bgImage, 0, 0, width, height);
  
  if (!dead) {
    rocket.update();
    
    // Move and draw planets
    for (int i = planets.size() - 1; i >= 0; i--) {
      Planet planet = planets.get(i);
      planet.update();
      planet.display();
      
      if (planet.hits(rocket)) {
        dead = true;
      }
      
      if (rocket.isOffscreen()){
        dead = true;
      }
      
      
      if (planet.isOffscreen()) {
        planets.remove(i);
      }
    }
    
    rocket.display();
      
    // Generate new planets
    if (frameCount % 50 == 0) {
      planets.add(new Planet(width, random(height)));
    }
  } else {
    dead();
  }
  
   // Update and draw coins
  for (int i = coins.size() - 1; i >= 0; i--) {
    Coin coin = coins.get(i);
    coin.update();
    coin.draw();
    
    // Check collision with rocket
    if (coin.collectedBy(rocket)) {
      coins.remove(i);
      score++;
    }
    
    // Remove coin if off-screen
    if (coin.isOffscreen()) {
      coins.remove(i);
    }
  }
  
  //Generate new coins
  
  if (frameCount % 300 == 0) {
      coins.add(new Coin(width, random(height)));
    }
  
  fill(255);
  textSize(24);
  text("Score: " + score, 60, 40);
}

void keyPressed() {
  if (key == ' ' && !dead) {
    rocket.jump();
  } else if (key == 'r' && dead) {
    restart();
  }
}

void dead() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  text("Game Over", width / 2, height / 2 - 50);
  textSize(24);
  text("Press 'R' to restart", width / 2, height / 2 + 50);
}

void restart() {
  rocket = new Rocket();
  planets.clear();
  coins.clear();
  score = 0;
  dead = false;
}

class Rocket {
  PVector position;
  PVector velocity;
  PVector acceleration;
  
  Rocket() {
    position = new PVector(width / 2, height / 2);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    score = 0;
  }
  
  void update() {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
    
    // Gravity
    applyForce(new PVector(0, 0.6));
    
    // Limit vertical speed
    velocity.y = constrain(velocity.y, -10, 10);
  }
  
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  void jump() {
    applyForce(new PVector(0, -10));
  }
  
  void display() {
    image(rocketImage, position.x - rocketImage.width / 2, position.y - rocketImage.height / 2);
  }
  
   boolean isOffscreen() {
    if (position.y > 667 || position.y < 0) {
      return true;
    }
    
    return false;
  }
}

class Planet {
  // If you would like a simulation without the lag due to the images being loaded comment out lines 149 to 160, 175, and 191 and uncomment the commented lines
  PVector position;
  PVector velocity = new PVector(-10, 0);
  PVector smallSpeed = new PVector (-1,0);
  float size;
  float speed;
  
  //Here is the option if you want actual planet graphics, this runs best on a desktop:
  //int planetIndex = 0;
  //PImage[] planetImages = {loadImage("planet1.png"), 
  //                          loadImage("planet2.png"),
  //                          loadImage("planet3.png"),
  //                          loadImage("planet4.png"),
  //                          loadImage("planet6.png"),
  //                          loadImage("planet7.png"),
  //                          loadImage("planet8.png"),
  //                          loadImage("planet9.png"),
  //                          loadImage("planet10.png"),
  //                          loadImage("planet11.png"),
  //                          loadImage("planet12.png"),
  //                          loadImage("planet13.png")};
                        
  // Here is the option if you just want colored circles, this code will run faster on a laptop.                        
  int[] strokeColorArr = {0, 225};
  int strokeColor;
  int red;
  int green;
  int blue;
  
  Planet(float x, float y) {
    position = new PVector(x, y);
    size = random(75, 100);
    speed = 2;
    
    //Here is the option for graphics set up:
    //planetIndex = int(random(0,12));
    
    //Here is the option for colored circle setup:
    strokeColor = strokeColorArr[int( random(0,2) )];
    red = int(random(0, 226));
    blue = int(random(0, 226));
    green = int(random(0,226));
    
  }
  
  void update() {
    position.add(this.velocity);
    
    if (frameCount % 100 == 0) {
      this.velocity.add(smallSpeed);
    }
  }
  
  void display() {
    
    // here is the option for colored circles display:
    stroke(strokeColor);
    fill(red, green, blue);
    circle(position.x, position.y, size);
    
    //Here is the option for graphics display:
    //image(planetImages[planetIndex], position.x, position.y - size/2, size, size);
  }
  
  boolean hits(Rocket rocket) {
    float rocketRadius = rocketImage.width / 2;
    float planetRadius = size / 2;
    
    if (dist(position.x, position.y, rocket.position.x, rocket.position.y) < rocketRadius + planetRadius) {
      return true;
    }
    
    return false;
  }
  
  boolean passed(Rocket rocket) {
    if (position.x == rocket.position.x && !dead) {
      return true;
    }
    
    return false;
  }
  
  boolean isOffscreen() {
    if (position.x + size / 2 < 0) {
      return true;
    }
    
    return false;
  }
}

class Coin {
  float x;
  float y;
  float sizex;
  float sizey;
  float speed;
  
  Coin(float x, float y) {
    this.x = x;
    this.y = y;
    sizex = 60;
    sizey = 65;
    speed = 4;
  }
  
  void update() {
    x -= speed;
  }
  
  void draw() {
    image(coinImg, x, y, sizex, sizey);  // Adjust the size of the coin image as needed
  }
  
  boolean collectedBy(Rocket rocket) {
    if (rocket.position.x + 50 > x && rocket.position.x < x + sizex) {
      if (rocket.position.y + 50 > y && rocket.position.y < y + sizey) {
        return true;
      }
    }
    return false;
  }
  
  boolean isOffscreen() {
    if (x + sizex / 2 < 0) {
      return true;
    }
    
    return false;
  }
}
