package jume.physics.components;

import jume.tilemap.TilemapColliders.generateFromIntGrid;
import jume.physics.core.CollisionFilter;
import jume.tilemap.Tileset;
import jume.physics.core.Body;
import jume.ecs.Component;

typedef CTilemapColliderOptions = {
  var worldX: Int;
  var worldY: Int;
  var tileset: Tileset;
}

class CTilemapCollider extends Component {
  public var bodies: Array<Body>;

  public var worldX: Int;

  public var worldY: Int;

  public var tileset: Tileset;

  public var group: CollisionFilter;

  public var mask: CollisionFilter;

  public var tags: Array<String>;

  public function init(params: CTilemapColliderOptions): CTilemapCollider {
    bodies = [];

    worldX = params.worldX;
    worldY = params.worldY;
    tileset = params.tileset;
    group = GROUP_01;
    mask = GROUP_01;
    tags = [];

    return this;
  }

  public function updateColliders(grid: Array<Array<Int>>, collisionIds: Array<Int>) {
    bodies = [];
    final rects = generateFromIntGrid({
      grid: grid,
      collisionIds: collisionIds,
      worldX: worldX,
      worldY: worldY,
      tileWidth: tileset.tileWidth,
      tileHeight: tileset.tileHeight
    });

    trace(tileset);

    for (rect in rects) {
      final body = new Body({
        group: group,
        mask: mask,
        tags: tags,
        bodyType: STATIC
      });
      body.bounds.set(worldX + rect.x, worldY + rect.y, rect.width, rect.height);
      bodies.push(body);
    }
  }
}
