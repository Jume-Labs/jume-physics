package components;

import jume.ecs.Component;
import jume.ecs.Updatable;
import jume.ecs.components.CTransform;

class CRotate extends Component implements Updatable {
  public var speed: Float;

  var transform: CTransform;

  public function init(speed: Float): CRotate {
    this.speed = speed;
    transform = getComponent(CTransform);

    return this;
  }

  public function cUpdate(dt: Float) {
    transform.rotation += speed * dt;
  }
}
