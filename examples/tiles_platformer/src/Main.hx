package;

import jume.Jume;

import scenes.LoadScene;

class Main {
  public static function main() {
    final jume = new Jume({
      title: 'Tiles Platformer',
      designSize: { width: 400, height: 300 },
      canvasSize: { width: 800, height: 600 },
      pixelFilter: true
    });
    jume.launch(LoadScene);
  }
}
