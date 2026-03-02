
public class Settings
{

  private boolean statoVisibilita;
  private int sWidth, sHeight;

  Settings()
  {
    statoVisibilita = false;
    sWidth = width/3;
    sHeight = height;
  }

  void menuOn()
  {
    statoVisibilita = true;
  }
  void menuOff()
  {
    statoVisibilita = false;
  }
  void display()
  {
    fill(150);
    noStroke();
    rect(0,0, sWidth,sHeight);
    
    
  }
}
