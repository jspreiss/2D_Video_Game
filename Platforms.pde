/*
  Scrolling Platformer Lab:
  
  Add scrolling ability to the player. 
  
  For more detail, see the tutorial: 
  Scrolling: https://www.youtube.com/watch?v=y4smwQ794_M
  
  
  Complete the code as indicated by the comments.
  Do the following:
  1) You'll need implement the method scroll() below. Use the view_x and view_y variables
  already declared and initialized. 
  2) Call scroll() in draw().
  See the comments below for more details. 
 
*/

final static float MOVE_SPEED = 5;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE = 50;
final static float GRAVITY = .6;
final static float JUMP_SPEED = 14; 

final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 60;
final static float VERTICAL_MARGIN = 40;

final static int NEUTRAL_FACING = 0; 
final static int RIGHT_FACING = 1; 
final static int LEFT_FACING = 2; 

final static float WIDTH = SPRITE_SIZE * 16;
final static float HEIGHT = SPRITE_SIZE * 12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

//declare global variables
Player player;
PImage snow, crate, red_brick, brown_brick, gold, p, spider;
ArrayList<Enemy> enemies; 
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
Sprite background;
float view_x;
float view_y;
int score;
boolean isGameOver;

//initialize them in setup().
void setup(){
  size(1366, 768);
  imageMode(CENTER);
  PImage p = loadImage("player.png");
  player = new Player(p, 0.8);
  player.center_x = 100;
  player.center_y = GROUND_LEVEL;
  player.setBottom(GROUND_LEVEL);
  isGameOver = false;
  enemies = new ArrayList<Enemy>();
  platforms = new ArrayList<Sprite>();
  view_x = 0;
  view_y = 0;
  score = 0;
  background = new Sprite("soo4.png", 1, width/2, height/2);
  coins = new ArrayList<Sprite>();
  
  gold = loadImage("gold1.png");
  spider = loadImage("spider_walk_right1.png");
  red_brick = loadImage("red_brick.png");
  brown_brick = loadImage("brown_brick.png");
  crate = loadImage("crate.png");
  snow = loadImage("snow.png");
  createPlatforms("map.csv");
}

// modify and update them in draw().
void draw(){
  background.display();
  scroll();
  displayAll();
  
  if(!isGameOver)
  {
    updateAll();
    collectCoins();
  }
  
}

void displayAll()
{
  for(Sprite s: platforms)
  {
    s.display();
  }
  
  for (Sprite i : coins)
  {
    i.display();
  }
  for(Enemy e: enemies)
  {
    e.display();
  }
  player.display();
  

  
  fill(255, 0 ,0);
  textSize(32);
  text("Coin:" + score, view_x + 50, view_y + 50);
  text("Lives:" + player.lives, view_x + 50, view_y + 100);
  if(isGameOver)
  {
    fill(0,0,255);
    text("GAME OVER!", view_x  + width/2 -100, view_y + height/2);
    if(player.lives ==0)
    {
      text("You lose!", view_x  + width/2 -100, view_y + height/2 + 50);
    }
    else
    {
      text("You win!", view_x  + width/2 -100, view_y + height/2 + 50);
    }
    text("Press SPACE to Restart!", view_x + width/2 -100, view_y + height/2 + 100);
  }
}
void updateAll()
{
  
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  collectCoins();
 
  for (Sprite i : coins)
  {
    ((AnimatedSprite)i).updateAnimation();
  }
  for(Enemy e : enemies )
  {
    ((Enemy)e).updateAnimation();
    e.update();
  }
  if(player.lives == 0)
  {
    isGameOver = true;
  }
  checkDeath();
}

void checkDeath(){
  boolean collideEnemy = false;
  for(Enemy e : enemies)
  {
    if(checkCollision(player,e)) 
      collideEnemy = true;
  }
  boolean fallOffCliff = player.getBottom() > GROUND_LEVEL;
  if (collideEnemy || fallOffCliff ){
    player.lives--;
    if (player.lives == 0){
    isGameOver = true;
  }
  else{
    player.center_x = 100;
    player.setBottom(GROUND_LEVEL);
  }
}
}
void collectCoins()
{
  ArrayList<Sprite> collision_list = checkCollisionList(player,coins); 
  if(collision_list.size() > 0){
    for(Sprite i : collision_list)
    {
      coins.remove(i);
      score++;
    }
  }
  if(coins.size() == 0)
  {
    isGameOver = true;
  }
}
 

 
void scroll(){
  // create and initialize right_boundary variable
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if (player.getRight() > right_boundary)
  {
    view_x += player.getRight() - right_boundary;
  }   
  float left_boundary = view_x + LEFT_MARGIN;
  if (player.getLeft() < left_boundary)
  {
    view_x -= left_boundary - player.getLeft();
  }  

  float top_boundary = view_y + VERTICAL_MARGIN;
  if (player.getTop() < top_boundary)
  {
    view_y -= top_boundary - player.getTop();
  }

  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if (player.getBottom() > bottom_boundary)
  {
    view_y += player.getBottom() - bottom_boundary;
  }

  translate(-view_x, -view_y);


}



// returns true if sprite is one a platform.
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls)
{  
  s.center_y += 5;
  ArrayList<Sprite> collision_list = checkCollisionList(s, walls);
  s.center_y -= 5;
  return collision_list.size() > 0; 
}




public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  s.change_y += GRAVITY;
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
    s.change_y = 0;
  }
  s.center_x += s.change_x;
  
  col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0)
  {
    Sprite collided = col_list.get(0);
    if(s.change_x > 0)
    {
        s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0)
    {
        s.setLeft(collided.getRight());
    }
  }
}

  boolean checkCollision(Sprite s1, Sprite s2)
  {
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
    return true;
  }
}

public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}


void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("a")){
        Sprite s = new Sprite(snow, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("b")){
        Sprite s = new Sprite(brown_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("c")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("d")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("e")){
        Coin c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(c);
      }
      else if(values[col].equals("0")){
        continue; // continue with for loop, i.e do nothing.
      }
      else{
        // use Processing int() method to convert a numeric string to an integer
        // representing the walk length of the spider.
        // for example int a = int("9"); means a = 9.
        int lengthGap = int(values[col]);
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + lengthGap * SPRITE_SIZE;
        Enemy enemy = new Enemy(spider, 50/72.0,bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;      // see cases above.
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        // add enemy to enemies arraylist.
        enemies.add(enemy);
    }
    }
  }
}
 
// called whenever a key is pressed.
void keyPressed()
{
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
  }
  else if(key == ' ' && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;   
  }
  else if(isGameOver && key == ' ')
  {
    setup();
  }

}

// called whenever a key is released.
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x = 0;
  }
  else if(keyCode == LEFT){
    player.change_x = 0;
  }
}
