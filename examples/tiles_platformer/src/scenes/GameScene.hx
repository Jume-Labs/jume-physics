package scenes;

import jume.events.Events;
import jume.assets.Assets;
import jume.ecs.Entity;
import jume.ecs.Scene;
import jume.ecs.components.CSprite;
import jume.ecs.components.CTilemap;
import jume.ecs.components.CTransform;
import jume.ecs.systems.SRender;
import jume.ecs.systems.SUpdate;
import jume.events.input.KeyboardEvent;
import jume.graphics.atlas.Atlas;
import jume.physics.components.CPhysicsBody;
import jume.physics.components.CTilemapCollider;
import jume.physics.systems.SPhysics;
import jume.tilemap.Tileset;
import jume.view.View;

import level.Level.LEVEL;

class GameScene extends Scene {
  @:inject
  var view: View;

  @:inject
  var assets: Assets;

  @:inject
  var events: Events;

  var playerBody: CPhysicsBody;

  var leftDown: Bool;

  var rightDown: Bool;

  public override function init() {
    addSystem(SUpdate).init();
    final physics = addSystem(SPhysics).init({ gravity: { x: 0, y: 30 } });
    addSystem(SRender).init();

    leftDown = false;
    rightDown = false;

    physics.debugRenderEnabled = true;
    view.debugRender = true;

    createTiles();
    createPlayer();

    events.addListener({ type: KeyboardEvent.KEY_DOWN, callback: keyDown });
    events.addListener({ type: KeyboardEvent.KEY_UP, callback: keyUp });
  }

  public override function update(dt: Float) {
    super.update(dt);

    if (leftDown) {
      playerBody.body.acceleration.x = -5;
    } else if (rightDown) {
      playerBody.body.acceleration.x = 5;
    } else {
      playerBody.body.acceleration.x = 0;
    }
  }

  function createPlayer() {
    final atlas = assets.get(Atlas, 'sprites');
    final entity = addEntity(Entity);
    entity.addComponent(CTransform).init({ x: 40, y: 240 });
    entity.addComponent(CSprite).init({ atlas: atlas, frameName: 'player' });
    playerBody = entity.addComponent(CPhysicsBody).init({ width: 14, height: 16, drag: { x: 2, y: 2 } });
  }

  function createTiles() {
    final tileset = assets.get(Tileset, 'tiles');
    final entity = addEntity(Entity);
    entity.addComponent(CTransform).init();
    entity.addComponent(CTilemap).init({ grid: LEVEL, tileset: tileset });
    var collider = entity.addComponent(CTilemapCollider).init({ worldX: 0, worldY: 0, tileset: tileset });
    collider.updateColliders(LEVEL, []);
  }

  function keyDown(event: KeyboardEvent) {
    if (event.key == ARROW_LEFT) {
      leftDown = true;
    } else if (event.key == ARROW_RIGHT) {
      rightDown = true;
    }
  }

  function keyUp(event: KeyboardEvent) {
    if (event.key == ARROW_LEFT) {
      leftDown = false;
    } else if (event.key == ARROW_RIGHT) {
      rightDown = false;
    }
  }
}
