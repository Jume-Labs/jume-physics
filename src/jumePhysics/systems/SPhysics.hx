package jumePhysics.systems;

import jumePhysics.events.PhysicsEvent;

import jume.ecs.Entity;
import jume.ecs.System;
import jume.ecs.components.CTransform;
import jume.events.EventType;
import jume.events.Events;
import jume.graphics.Color;
import jume.graphics.Graphics;
import jume.math.Rectangle;
import jume.math.Size;
import jume.math.Vec2;
import jume.view.Camera;
import jume.view.View;

import jumePhysics.components.CPhysicsBody;

using jume.math.MathUtils;

typedef SPhysicsOptions = {
  var ?x: Float;
  var ?y: Float;
  var ?width: Float;
  var ?height: Float;
  var ?iterations: Int;
  var ?gravity: { x: Float, y: Float };
}

private typedef DebugRay = {
  var start: Vec2;
  var end: Vec2;
  var hit: Bool;
}

class SPhysics extends System {
  public var debugRenderEnabled: Bool;

  public var drawRays: Bool;

  public var debugLineWidth: Float;

  public var showQuadTree: Bool;

  public var iterations: Int;

  public var gravity: Vec2;

  static final OVERLAP_PADDING = 4;

  final entities: Array<Entity> = [];

  var treeList: Array<CPhysicsBody>;

  var interactionEvents: Array<PhysicsEvent>;

  var bounds: Rectangle;

  var tree: QuadTree;

  var debugRays: Array<DebugRay>;

  var tempPos: Vec2;

  final boundsColor = new Color(110, 110, 110);
  final bodyColor = new Color(0, 110, 220);
  final staticBodyColor = new Color(0, 200, 0);
  final rayColor = new Color(255, 127, 0);
  final rayHitColor = new Color(255, 255, 0);

  @:inject
  var events: Events;

  @:inject
  var view: View;

  public function init(?options: SPhysicsOptions): SPhysics {
    debugRenderEnabled = false;
    drawRays = true;
    debugLineWidth = 1.0;
    showQuadTree = false;
    iterations = 8;
    gravity = new Vec2();
    treeList = [];
    interactionEvents = [];
    bounds = new Rectangle();
    debugRays = [];
    tempPos = new Vec2();

    if (options != null) {
      if (options.gravity != null) {
        gravity.set(options.gravity.x, options.gravity.y);
      }

      if (options.iterations != null) {
        this.iterations = options.iterations;
      }

      bounds.set(options.x ?? 0, options.y ?? 0, options.width ?? view.viewWidth, options.height ?? view.viewHeight);
      tree = new QuadTree(options.x ?? 0, options.y ?? 0, options.width ?? view.viewWidth,
        options.height ?? view.viewHeight);
    } else {
      bounds.set(0, 0, view.viewWidth, view.viewHeight);
      tree = new QuadTree(0, 0, view.viewWidth, view.viewHeight);
    }

    registerList({ entities: entities, components: [CPhysicsBody, CTransform] });
    active = true;

    return this;
  }

  public override function update(dt: Float) {
    if (!active) {
      return;
    }

    if (debugRays.length > 1000) {
      debugRays = [];
    }

    tree.clear();

    for (entity in entities) {
      if (!entity.active) {
        continue;
      }

      final body = entity.getComponent(CPhysicsBody);
      updatePastInteractions(body);
      body.wasTouching = body.touching;
      body.lastPos.set(body.bounds.x, body.bounds.y);
      updateBodyBounds(entity);

      if (!bounds.intersects(body.bounds)) {
        continue;
      }

      if (body.bodyType != STATIC) {
        if (body.bodyType == DYNAMIC) {
          if (body.useGravity) {
            body.velocity.x += (body.acceleration.x + gravity.x);
            body.velocity.y += (body.acceleration.y + gravity.y);
          }

          if (body.velocity.x > 0) {
            body.velocity.x -= body.drag.x;
          } else if (body.velocity.x < 0) {
            body.velocity.x += body.drag.x;
          }

          if (body.velocity.y > 0) {
            body.velocity.y -= body.drag.y;
          } else if (body.velocity.y < 0) {
            body.velocity.y += body.drag.y;
          }

          if (body.maxVelocity.x != 0) {
            body.velocity.x = Math.clamp(body.velocity.x, -body.maxVelocity.x, body.maxVelocity.x);
          }

          if (body.maxVelocity.y != 0) {
            body.velocity.y = Math.clamp(body.velocity.y, -body.maxVelocity.y, body.maxVelocity.y);
          }
        }
        body.bounds.x += body.velocity.x * dt;
        body.bounds.y += body.velocity.y * dt;
      }
      tree.insert(body);
    }

    for (i in 0...iterations) {
      for (entity in entities) {
        final body = entity.getComponent(CPhysicsBody);
        while (treeList.length > 0) {
          treeList.pop();
        }

        tree.getBodyList(body, treeList);

        for (body2 in treeList) {
          checkCollision(body, body2);
        }
      }
    }

    for (entity in entities) {
      updateBodyTransform(entity);
    }

    for (entity in entities) {
      final body = entity.getComponent(CPhysicsBody);
      for (b in body.wasCollidingWith) {
        if (!body.collidingWith.contains(b)) {
          interactionEvents.push(PhysicsEvent.get(PhysicsEvent.COLLISION_END, body, b));
        }
      }

      for (b in body.wasTriggeredBy) {
        if (!body.triggeredBy.contains(b)) {
          interactionEvents.push(PhysicsEvent.get(PhysicsEvent.TRIGGER_END, body, b));
        }
      }
    }

    while (interactionEvents.length > 0) {
      events.sendEvent(interactionEvents.pop());
    }
  }

  public override function debugRender(graphics: Graphics, cameras: Array<Camera>) {
    if (!debugRenderEnabled) {
      return;
    }

    for (camera in cameras) {
      if (camera.active) {
        camera.updateTransform();

        // Use the camera render target and clear it.
        graphics.pushTarget(camera.target);
        graphics.start(false);

        // Apply the camera transform to render the entities in the correct place.
        graphics.pushTransform();
        graphics.applyTransform(camera.transform);

        if (showQuadTree) {
          graphics.color.copyFrom(boundsColor);

          final bounds = this.tree.getTreeBounds();
          for (rect in bounds) {
            graphics.drawRect(rect, debugLineWidth);
          }
        }

        for (entity in entities) {
          final body = entity.getComponent(CPhysicsBody);
          final bounds = body.bounds;
          if (body.bodyType == STATIC) {
            graphics.color.copyFrom(staticBodyColor);
          } else {
            graphics.color.copyFrom(bodyColor);
          }
          graphics.drawRect(bounds, debugLineWidth);
        }

        if (drawRays) {
          for (ray in debugRays) {
            if (ray.hit) {
              graphics.color.copyFrom(rayHitColor);
            } else {
              graphics.color.copyFrom(rayColor);
            }
            graphics.drawLine(ray.start, ray.end, MIDDLE, debugLineWidth);
          }
        }

        graphics.popTransform();
        graphics.present();
        graphics.popTarget();
      }
    }

    graphics.transform.identity();
    graphics.color.set(255, 255, 255, 255);

    graphics.start(false);
    // Render all cameras to the main target.
    for (camera in cameras) {
      tempPos.set(camera.screenBounds.x, camera.screenBounds.y);
      graphics.drawRenderTarget(tempPos, camera.target);
    }
    graphics.present();
  }

  public function raycast(start: Vec2, end: Vec2, ?tags: Array<String>, ?out: RayHitList): RayHitList {
    out = tree.getLineList(start, end, out);

    if (out.count > 0 && tags != null) {
      out.filterOnTags(tags);
    }

    if (drawRays) {
      final ray: DebugRay = {
        start: start,
        end: end,
        hit: out.count > 0
      };
      debugRays.push(ray);
    }

    return out;
  }

  public function getPosition(?out: Vec2): Vec2 {
    if (out == null) {
      out = Vec2.get();
    }
    out.set(bounds.x, bounds.y);

    return out;
  }

  public function setPosition(x: Float, y: Float) {
    bounds.x = x;
    bounds.y = y;
    tree.updatePosition(x, y);
  }

  public function getSize(?out: Size): Size {
    if (out == null) {
      out = new Size();
    }
    out.set(bounds.width, bounds.height);

    return out;
  }

  public function setSize(width: Float, height: Float) {
    this.bounds.width = width;
    this.bounds.height = height;
    this.tree.updateBounds(bounds.x, bounds.y, bounds.width, bounds.height);
  }

  function updatePastInteractions(body: CPhysicsBody) {
    while (body.wasCollidingWith.length > 0) {
      body.wasCollidingWith.pop();
    }

    while (body.wasTriggeredBy.length > 0) {
      body.wasTriggeredBy.pop();
    }

    while (body.collidingWith.length > 0) {
      body.wasCollidingWith.push(body.collidingWith.pop());
    }

    while (body.triggeredBy.length > 0) {
      body.wasTriggeredBy.push(body.triggeredBy.pop());
    }
  }

  function checkCollision(body1: CPhysicsBody, body2: CPhysicsBody) {
    if (body1.mask.has(body2.group) && body2.mask.has(body1.group) && intersects(body1, body2)) {
      if (body1.bodyType == DYNAMIC && !body1.isTrigger && !body2.isTrigger) {
        separate(body1, body2);
        if (!body1.wasCollidingWith.contains(body2)) {
          if (!hasInteraction(PhysicsEvent.COLLISION_START, body1, body2)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.COLLISION_START, body1, body2));
          }
        } else {
          if (!hasInteraction(PhysicsEvent.COLLISION_STAY, body1, body2)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.COLLISION_STAY, body1, body2));
          }
        }

        if (!body1.collidingWith.contains(body2)) {
          body1.collidingWith.push(body2);
        }
      } else if (body1.isTrigger && !body2.isTrigger) {
        if (!body1.wasTriggeredBy.contains(body2)) {
          if (!hasInteraction(PhysicsEvent.TRIGGER_START, body1, body2)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.TRIGGER_START, body1, body2));
          }
        } else {
          if (!hasInteraction(PhysicsEvent.TRIGGER_STAY, body1, body2)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.TRIGGER_STAY, body1, body2));
          }
        }

        if (!body1.triggeredBy.contains(body2)) {
          body1.triggeredBy.push(body2);
        }
      } else if (body2.isTrigger && !body1.isTrigger) {
        if (!body2.wasTriggeredBy.contains(body1)) {
          if (!hasInteraction(PhysicsEvent.TRIGGER_START, body2, body1)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.TRIGGER_START, body2, body1));
          }
        } else {
          if (!hasInteraction(PhysicsEvent.TRIGGER_STAY, body2, body1)) {
            interactionEvents.push(PhysicsEvent.get(PhysicsEvent.TRIGGER_STAY, body2, body1));
          }
        }

        if (!body2.triggeredBy.contains(body1)) {
          body2.triggeredBy.push(body1);
        }
      }
    }
  }

  function hasInteraction(type: EventType<PhysicsEvent>, body1: CPhysicsBody, body2: CPhysicsBody): Bool {
    for (event in interactionEvents) {
      if (event.type == type && event.body1 == body1 && event.body2 == body2) {
        return true;
      }
    }

    return false;
  }

  function separate(body1: CPhysicsBody, body2: CPhysicsBody): Bool {
    if (Math.abs(body1.velocity.x) > Math.abs(body1.velocity.y)) {
      return separateX(body1, body2) || separateY(body1, body2);
    } else {
      return separateY(body1, body2) || separateX(body1, body2);
    }
  }

  function separateX(body1: CPhysicsBody, body2: CPhysicsBody): Bool {
    final bounds1 = body1.bounds;
    final bounds2 = body2.bounds;

    var overlap = Math.min(bounds1.x + bounds1.width, bounds2.x + bounds2.width) - Math.max(bounds1.x, bounds2.x);
    final ov = bounds1.x > bounds2.x ? overlap : -overlap;

    if ((ov < 0 && bounds1.x + bounds1.width * 0.5 > bounds2.x + bounds2.width * 0.5)
      || (ov > 0 && bounds1.x + bounds1.width * 0.5 < bounds2.x + bounds2.width * 0.5)) {
      return false;
    }

    final delta = bounds1.x - body1.lastPos.x;

    if (overlap > Math.abs(delta) + OVERLAP_PADDING && delta != 0) {
      overlap = 0;
    }
    overlap = bounds1.x > bounds2.x ? overlap : -overlap;

    if (overlap == 0) {
      return false;
    }

    if (overlap > 0) {
      if (body1.velocity.x > 0 || !body1.canCollide.has(LEFT) || !body2.canCollide.has(RIGHT)) {
        return false;
      }

      body1.touching.add(LEFT);
      body2.touching.add(RIGHT);
    } else {
      if (body1.velocity.x < 0 || !body1.canCollide.has(RIGHT) || !body2.canCollide.has(LEFT)) {
        return false;
      }

      body1.touching.add(RIGHT);
      body2.touching.add(LEFT);
    }

    if (body2.bodyType != DYNAMIC) {
      bounds1.x += overlap;
      body1.velocity.x = -body1.velocity.x * body1.bounce;
    } else {
      overlap *= 0.5;
      bounds1.x += overlap;
      bounds2.x -= overlap;

      var velocity1 = body2.velocity.x;
      var velocity2 = body1.velocity.x;
      final average = (velocity1 + velocity2) * 0.5;

      velocity1 -= average;
      velocity2 -= average;
      body1.velocity.x = average + velocity1 * body1.bounce;
      body2.velocity.x = average + velocity2 * body2.bounce;
    }

    return true;
  }

  function separateY(body1: CPhysicsBody, body2: CPhysicsBody): Bool {
    final bounds1 = body1.bounds;
    final bounds2 = body2.bounds;

    var overlap = Math.min(bounds1.y + bounds1.height, bounds2.y + bounds2.height) - Math.max(bounds1.y, bounds2.y);
    final ov = bounds1.y > bounds2.y ? overlap : -overlap;

    if ((ov < 0 && bounds1.y + bounds1.height * 0.5 > bounds2.y + bounds2.height * 0.5)
      || (ov > 0 && bounds1.y + bounds1.height * 0.5 < bounds2.y + bounds2.height * 0.5)) {
      return false;
    }

    final delta = bounds1.y - body1.lastPos.y;

    if (overlap > Math.abs(delta) + OVERLAP_PADDING && delta != 0) {
      overlap = 0;
    }
    overlap = bounds1.y > bounds2.y ? overlap : -overlap;

    if (overlap == 0) {
      return false;
    }

    if (overlap > 0) {
      if (body1.velocity.y > 0 || !body1.canCollide.has(TOP) || !body2.canCollide.has(BOTTOM)) {
        return false;
      }

      body1.touching.add(TOP);
      body2.touching.add(BOTTOM);
    } else {
      if (body1.velocity.y < 0 || !body1.canCollide.has(BOTTOM) || !body2.canCollide.has(TOP)) {
        return false;
      }

      body1.touching.add(BOTTOM);
      body2.touching.add(TOP);
    }

    if (body2.bodyType != DYNAMIC) {
      bounds1.y += overlap;
      body1.velocity.y = -body1.velocity.y * body1.bounce;
    } else {
      overlap *= 0.5;
      bounds1.y += overlap;
      bounds2.y -= overlap;

      var velocity1 = body2.velocity.y;
      var velocity2 = body1.velocity.y;
      final average = (velocity1 + velocity2) * 0.5;

      velocity1 -= average;
      velocity2 -= average;
      body1.velocity.y = average + velocity1 * body1.bounce;
      body2.velocity.y = average + velocity2 * body2.bounce;
    }

    return true;
  }

  inline function intersects(body1: CPhysicsBody, body2: CPhysicsBody): Bool {
    return body1.bounds.intersects(body2.bounds);
  }

  function updateBodyBounds(entity: Entity) {
    final body = entity.getComponent(CPhysicsBody);
    final transform = entity.getComponent(CTransform);

    final worldPos = transform.getWorldPosition();
    body.bounds.x = worldPos.x - body.bounds.width * 0.5 + body.offset.x;
    body.bounds.y = worldPos.y - body.bounds.height * 0.5 + body.offset.y;

    body.lastPos.x = body.bounds.x;
    body.lastPos.y = body.bounds.y;
    worldPos.put();
  }

  function updateBodyTransform(entity: Entity) {
    final body = entity.getComponent(CPhysicsBody);
    if (body.bodyType == BodyType.STATIC) {
      return;
    }
    final worldPos = Vec2.get(body.bounds.x + body.bounds.width * 0.5 - body.offset.x,
      body.bounds.y + body.bounds.height * 0.5 - body.offset.y);
    entity.getComponent(CTransform).setWorldPosition(worldPos);
    worldPos.put();
  }
}
