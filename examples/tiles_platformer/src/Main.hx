package;

import jume.Jume;
import jume.math.Size;

import scenes.LoadScene;

class Main {
  public static function main() {
    final jume = new Jume({
      title: 'Tiles Platformer',
      designSize: new Size(400, 300),
      canvasSize: new Size(800, 600),
      pixelFilter: true
    });
    jume.launch(LoadScene);
  }
}
