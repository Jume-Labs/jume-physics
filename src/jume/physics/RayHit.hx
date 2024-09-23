package jume.physics;

import jume.math.Vec2;
import jume.physics.components.CPhysicsBody;

using jume.math.MathUtils;

class RayHit {
  public var distance: Float;

  public var x: Float;

  public var y: Float;

  public var body: CPhysicsBody;

  static var pool: Array<RayHit> = [];

  public static function get(target: Vec2, origin: Vec2, ?body: CPhysicsBody): RayHit {
    if (pool.length > 0) {
      final hit = pool.pop();
      hit.x = target.x;
      hit.y = target.y;
      hit.body = body;

      hit.distance = Math.distance(origin, target);

      return hit;
    } else {
      return new RayHit(target, origin, body);
    }
  }

  public function new(target: Vec2, origin: Vec2, ?body: CPhysicsBody) {
    this.x = target.x;
    this.y = target.y;
    this.body = body;
    distance = Math.distance(origin, target);
  }

  public function put() {
    pool.push(this);
  }
}
