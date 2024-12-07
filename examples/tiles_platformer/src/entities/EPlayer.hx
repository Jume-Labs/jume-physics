package entities;

import jume.physics.core.Touching;
import jume.physics.core.Body;
import jume.ecs.components.CSprite;
import jume.graphics.atlas.Atlas;
import jume.assets.Assets;
import jume.ecs.components.CTransform;
import jume.physics.components.CPhysicsBody;
import jume.ecs.Entity;

class EPlayer extends Entity {
  var body: Body;

  var transform: CTransform;

  @:inject
  var assets: Assets;

  final acceleration = 10;

  final jumpSpeed = 480;

  public function init(x: Float, y: Float): EPlayer {
    final atlas = assets.get(Atlas, 'sprites');

    transform = addComponent(CTransform).init({ x: 40, y: 240 });
    body = addComponent(CPhysicsBody).init({
      width: 14,
      height: 16,
      drag: { x: 4, y: 2 },
      maxVelocity: { x: 150, y: 450 }
    }).body;
    addComponent(CSprite).init({ atlas: atlas, frameName: 'player' });

    return this;
  }

  public function moveLeft() {
    body.acceleration.x = -acceleration;
    transform.scale.x = -1;
  }

  public function moveRight() {
    body.acceleration.x = acceleration;
    transform.scale.x = 1;
  }

  public function stop() {
    body.acceleration.x = 0;
  }

  public function jump() {
    if (body.touching.has(Touching.BOTTOM)) {
      body.velocity.y = -jumpSpeed;
    }
  }
}
