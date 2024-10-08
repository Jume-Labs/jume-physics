package jume.physics.core;

import jume.math.Rectangle;
import jume.math.Vec2;

class QuadTree {
  public var bounds(default, null): Rectangle;

  public var root(default, null): QuadNode;

  final hits = new RayHitList();

  public function new(x: Float, y: Float, width: Float, height: Float) {
    bounds = new Rectangle(x, y, width, height);
    root = new QuadNode(1, x, y, width, height);
  }

  public function insert(body: Body) {
    root.insert(body);
  }

  public function getBodyList(body: Body, ?out: Array<Body>): Array<Body> {
    if (out == null) {
      out = [];
    }

    root.getBodyList(body, out);

    return out;
  }

  public function getLineList(start: Vec2, end: Vec2, ?out: RayHitList): RayHitList {
    if (out == null) {
      out = hits;
    }
    out.clear();

    root.getLineHitList(start, end, out);

    return out;
  }

  public function getTreeBounds(?out: Array<Rectangle>): Array<Rectangle> {
    if (out == null) {
      out = [];
    }

    root.getNodeBounds(out);

    return out;
  }

  public function clear() {
    root.clear();
    root.reset(1, bounds.x, bounds.y, bounds.width, bounds.height);
  }

  public function updateBounds(x: Float, y: Float, width: Float, height: Float) {
    bounds.set(x, y, width, height);
  }

  public function updatePosition(x: Float, y: Float) {
    bounds.x = x;
    bounds.y = y;
  }
}
