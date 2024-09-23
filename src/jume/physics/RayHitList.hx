package jume.physics;

import jume.math.Vec2;
import jume.physics.components.CPhysicsBody;

class RayHitList {
  public var hits(default, null): Array<RayHit> = [];

  public var count(get, never): Int;

  public var first(get, never): RayHit;

  public var last(get, never): RayHit;

  public function new() {}

  public function insert(target: Vec2, origin: Vec2, ?body: CPhysicsBody) {
    final hit = RayHit.get(target, origin, body);

    if (hits.length > 0) {
      if (hits.length == 1) {
        final first = hits[0];
        if (hit.distance < first.distance) {
          hits.unshift(hit);
        } else {
          hits.push(hit);
        }
      } else {
        // Insert sorted by distance.
        for (i in 0...hits.length) {
          final item = hits[i];
          if (item.distance > hit.distance) {
            if (i == hits.length - 1) {
              hits.push(hit);
            } else {
              hits.insert(i + 1, hit);
            }
          }
        }
      }
    } else {
      hits.push(hit);
    }
  }

  public function filterOnTags(tags: Array<String>) {
    hits = hits.filter((hit) -> {
      for (tag in tags) {
        if (hit.body.tags.contains(tag)) {
          return true;
        }
      }

      return false;
    });
  }

  public function remove(hit: RayHit) {
    hits.remove(hit);
    hit.put();
  }

  public function clear() {
    while (hits.length > 0) {
      hits.pop().put();
    }
  }

  inline function get_count(): Int {
    return hits.length;
  }

  inline function get_first(): RayHit {
    return hits[0];
  }

  inline function get_last(): RayHit {
    return hits[hits.length - 1];
  }
}
