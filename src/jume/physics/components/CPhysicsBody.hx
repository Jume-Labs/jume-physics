package jume.physics.components;

import jume.ecs.Component;
import jume.math.Rectangle;
import jume.math.Vec2;

typedef BodyOptions = {
  var ?bodyType: BodyType;
  var ?active: Bool;
  var ?isTrigger: Bool;
  var ?pos: { x: Float, y: Float };
  var ?width: Float;
  var ?height: Float;
  var ?drag: { x: Float, y: Float };
  var ?velocity: { x: Float, y: Float };
  var ?maxVelocity: { x: Float, y: Float };
  var ?acceleration: { x: Float, y: Float };
  var ?offset: { x: Float, y: Float };
  var ?group: CollisionFilter;
  var ?mask: CollisionFilter;
  var ?canCollide: Collide;
  var ?bounce: Float;
  var ?useGravity: Bool;
  var ?tags: Array<String>;
  var ?userData: Dynamic;
}

class CPhysicsBody extends Component {
  public var bodyType: BodyType;

  public var isTrigger: Bool;

  public var bounce: Float;

  public var useGravity: Bool;

  public var lastPos(default, null): Vec2;

  public var collidingWith(default, null): Array<CPhysicsBody> = [];
  public var wasCollidingWith(default, null): Array<CPhysicsBody> = [];
  public var triggeredBy(default, null): Array<CPhysicsBody> = [];
  public var wasTriggeredBy(default, null): Array<CPhysicsBody> = [];

  public var group: CollisionFilter;

  public var mask: CollisionFilter;

  public var touching: Touching;

  public var wasTouching: Touching;

  public var canCollide: Collide;

  public var bounds(default, null): Rectangle;

  public var drag(default, null): Vec2;

  public var velocity(default, null): Vec2;

  public var maxVelocity(default, null): Vec2;

  public var acceleration(default, null): Vec2;

  public var offset(default, null): Vec2;

  public var tags(default, null): Array<String>;

  public var userData: Dynamic;

  public function init(?options: BodyOptions): CPhysicsBody {
    if (options == null) {
      options = {
        bodyType: DYNAMIC,
        active: true,
        isTrigger: false,
        pos: { x: 0, y: 0 },
        width: 10,
        height: 10,
        bounce: 0,
        drag: { x: 0, y: 0 },
        velocity: { x: 0, y: 0 },
        maxVelocity: { x: 0, y: 0 },
        offset: { x: 0, y: 0 },
        group: GROUP_01,
        mask: GROUP_01,
        canCollide: ALL,
        useGravity: true,
        tags: []
      };
    }

    drag = new Vec2();
    if (options.drag != null) {
      drag.set(options.drag.x, options.drag.y);
    }

    velocity = new Vec2();
    if (options.velocity != null) {
      velocity.set(options.velocity.x, options.velocity.y);
    }

    maxVelocity = new Vec2();
    if (options.maxVelocity != null) {
      maxVelocity.set(options.maxVelocity.x, options.maxVelocity.y);
    }

    acceleration = new Vec2();
    if (options.acceleration != null) {
      acceleration.set(options.acceleration.x, options.acceleration.y);
    }

    offset = new Vec2();
    if (options.offset != null) {
      offset.set(options.offset.x, options.offset.y);
    }

    bodyType = options.bodyType ?? DYNAMIC;
    isTrigger = options.isTrigger ?? false;
    bounce = options.bounce ?? 0;
    useGravity = options.useGravity ?? true;
    lastPos = new Vec2();

    group = options.group ?? GROUP_01;
    mask = options.mask ?? GROUP_01;

    touching = NONE;
    canCollide = options.canCollide ?? ALL;

    bounds = new Rectangle(options.pos?.x ?? 0, options.pos?.y ?? 0, options.width ?? 10, options.height ?? 10);
    tags = options.tags ?? [];
    userData = options.userData;

    return this;
  }
}
