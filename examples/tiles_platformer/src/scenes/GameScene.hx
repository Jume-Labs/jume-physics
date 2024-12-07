package scenes;

import entities.ETiles;
import entities.EPlayer;

import jume.assets.Assets;
import jume.ecs.Scene;
import jume.ecs.systems.SRender;
import jume.ecs.systems.SUpdate;
import jume.events.Events;
import jume.events.input.KeyboardEvent;
import jume.physics.systems.SPhysics;
import jume.view.View;

class GameScene extends Scene {
  @:inject
  var view: View;

  @:inject
  var assets: Assets;

  @:inject
  var events: Events;

  var player: EPlayer;

  var leftDown: Bool;

  var rightDown: Bool;

  public override function init() {
    addSystem(SUpdate).init();
    addSystem(SPhysics).init({ gravity: { x: 0, y: 20 } });
    addSystem(SRender).init();

    leftDown = false;
    rightDown = false;

    addEntity(ETiles).init();
    player = addEntity(EPlayer).init(40, 240);

    events.addListener({ type: KeyboardEvent.KEY_DOWN, callback: keyDown });
    events.addListener({ type: KeyboardEvent.KEY_UP, callback: keyUp });
  }

  public override function update(dt: Float) {
    super.update(dt);

    if (leftDown) {
      player.moveLeft();
    } else if (rightDown) {
      player.moveRight();
    } else {
      player.stop();
    }
  }

  function keyDown(event: KeyboardEvent) {
    if (event.key == ARROW_LEFT) {
      leftDown = true;
    } else if (event.key == ARROW_RIGHT) {
      rightDown = true;
    } else if (event.key == ARROW_UP) {
      player.jump();
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
