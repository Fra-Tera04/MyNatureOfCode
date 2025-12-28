Force f;

void setup(){
   size(640,360);
   f = new Force(2,-10);
}


void draw(){
   background(0);
   
   f.update();
   f.edges();
   f.display();
}
