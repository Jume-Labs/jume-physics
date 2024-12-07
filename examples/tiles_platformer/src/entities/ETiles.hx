package entities;

import jume.assets.Assets;
import jume.ecs.Entity;
import jume.ecs.components.CTilemap;
import jume.ecs.components.CTransform;
import jume.physics.components.CTilemapCollider;
import jume.tilemap.Tileset;

import level.Level.LEVEL;

class ETiles extends Entity {
  @:inject
  var assets: Assets;

  public function init(): ETiles {
    final tileset = assets.get(Tileset, 'tiles');

    addComponent(CTransform).init();
    addComponent(CTilemap).init({ grid: LEVEL, tileset: tileset });
    final collider = addComponent(CTilemapCollider).init({ worldX: 0, worldY: 0, tileset: tileset });
    collider.updateColliders(LEVEL, []);

    return this;
  }
}
