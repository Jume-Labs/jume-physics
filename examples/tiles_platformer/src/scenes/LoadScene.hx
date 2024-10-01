package scenes;

import jume.tilemap.Tileset;
import jume.view.View;
import jume.events.SceneEvent;
import jume.graphics.atlas.Atlas;
import jume.assets.Assets;
import jume.ecs.Scene;

class LoadScene extends Scene {
  @:inject
  var assets: Assets;

  @:inject
  var view: View;

  public override function init() {
    final items: Array<AssetItem> = [
      {
        type: Atlas,
        id: 'sprites',
        path: 'assets/atlases/sprites'
      },
      {
        type: Tileset,
        id: 'tiles',
        path: 'assets/atlases/tiles.png',
        props: {
          tileWidth: 20,
          tileHeight: 20,
          margin: 1,
          spacing: 2
        }
      }
    ];

    assets.loadAll(items, () -> {
      SceneEvent.send(SceneEvent.CHANGE, GameScene);
    });
  }
}
