package jume.physics.components;

import jume.ecs.Component;
import jume.physics.core.Body;

class CPhysicsBody extends Component {
  public var body(default, null): Body;

  public function init(?options: BodyOptions): CPhysicsBody {
    body = new Body(options);
    body.userData.component = this;

    return this;
  }
}
