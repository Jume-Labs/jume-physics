package jume.physics.core;

import jume.math.Rectangle;
import jume.math.Vec2;

class QuadNode {
  static final MAX_BODIES = 6;

  static final MAX_DEPTH = 8;

  var depth: Int;

  final bodies: Array<Body> = [];

  final nodes: Array<QuadNode> = [];

  final indexList: Array<Int> = [];

  final bounds: Rectangle;

  static final pool: Array<QuadNode> = [];

  public static function get(depth: Int, x: Float, y: Float, width: Float, height: Float): QuadNode {
    if (pool.length > 0) {
      final node = pool.pop();
      node.reset(depth, x, y, width, height);

      return node;
    } else {
      return new QuadNode(depth, x, y, width, height);
    }
  }

  public function new(depth: Int, x: Float, y: Float, width: Float, height: Float) {
    this.depth = depth;
    bounds = new Rectangle(x, y, width, height);
  }

  public function clear() {
    while (bodies.length > 0) {
      bodies.pop();
    }

    while (nodes.length > 0) {
      final node = nodes.pop();
      node.clear();
      node.put();
    }
  }

  public function reset(depth: Int, x: Float, y: Float, width: Float, height: Float) {
    this.depth = depth;
    bounds.set(x, y, width, height);
  }

  public function put() {
    pool.push(this);
  }

  public function getNodeBounds(list: Array<Rectangle>) {
    for (node in nodes) {
      node.getNodeBounds(list);
    }
    list.push(bounds);
  }

  public function insert(body: Body) {
    if (nodes.length > 0) {
      final index = getIndex(body.bounds);
      if (index == -1) {
        getIndexes(body.bounds, indexList);
        for (i in indexList) {
          nodes[i].insert(body);
        }
      } else {
        nodes[index].insert(body);
      }

      return;
    }

    bodies.push(body);

    if (bodies.length > MAX_BODIES && depth < MAX_DEPTH) {
      split();

      while (bodies.length > 0) {
        final b = bodies.pop();
        final index = getIndex(b.bounds);
        if (index == -1) {
          getIndexes(b.bounds, indexList);
          for (i in indexList) {
            nodes[i].insert(b);
          }
        } else {
          nodes[index].insert(b);
        }
      }
    }
  }

  public function getBodyList(body: Body, list: Array<Body>) {
    final index = getIndex(body.bounds);
    if (nodes.length > 0) {
      if (index == -1) {
        getIndexes(body.bounds, indexList);
        for (i in indexList) {
          nodes[i].getBodyList(body, list);
        }
      } else {
        nodes[index].getBodyList(body, list);
      }
    } else {
      for (b in bodies) {
        if (b != body && !list.contains(b)) {
          list.push(b);
        }
      }
    }
  }

  public function getLineHitList(start: Vec2, end: Vec2, results: RayHitList) {
    if (nodes.length > 0) {
      getLineIndexes(start, end, indexList);
      for (index in indexList) {
        nodes[index].getLineHitList(start, end, results);
      }
    } else {
      final hitPos = Vec2.get();
      for (body in bodies) {
        if (body.bounds.intersectsLine(start, end, hitPos)) {
          results.insert(hitPos, start, body);
        }
      }
      hitPos.put();
    }
  }

  function split() {
    final subWidth = bounds.width * 0.5;
    final subHeight = bounds.height * 0.5;
    final x = bounds.x;
    final y = bounds.y;
    final newDepth = depth + 1;

    nodes.push(QuadNode.get(newDepth, x, y, subWidth, subHeight));
    nodes.push(QuadNode.get(newDepth, x + subWidth, y, subWidth, subHeight));
    nodes.push(QuadNode.get(newDepth, x, y + subHeight, subWidth, subHeight));
    nodes.push(QuadNode.get(newDepth, x + subWidth, y + subHeight, subWidth, subHeight));
  }

  function getLineIndexes(start: Vec2, end: Vec2, list: Array<Int>) {
    while (list.length > 0) {
      list.pop();
    }

    for (i in 0...nodes.length) {
      final nodeBounds = nodes[i].bounds;
      if (nodeBounds.intersectsLine(start, end) || nodeBounds.hasPosition(start.x, start.y)
        || nodeBounds.hasPosition(end.x, end.y)) {
        list.push(i);
      }
    }
  }

  function getIndexes(colliderBounds: Rectangle, list: Array<Int>) {
    while (list.length > 0) {
      list.pop();
    }

    for (i in 0...nodes.length) {
      final nodeBounds = nodes[i].bounds;
      if (nodeBounds.intersects(colliderBounds)) {
        list.push(i);
      }
    }
  }

  function getIndex(colliderBounds: Rectangle): Int {
    var index = -1;
    final middleX = bounds.x + bounds.width * 0.5;
    final middleY = bounds.y + bounds.height * 0.5;

    final top = colliderBounds.y + colliderBounds.height < middleY;
    final bottom = colliderBounds.y > middleY;
    final left = colliderBounds.x + colliderBounds.width < middleX;
    final right = colliderBounds.x > middleX;

    if (left) {
      if (top) {
        index = 0;
      } else if (bottom) {
        index = 2;
      }
    } else if (right) {
      if (top) {
        index = 1;
      } else if (bottom) {
        index = 3;
      }
    }

    return index;
  }
}
