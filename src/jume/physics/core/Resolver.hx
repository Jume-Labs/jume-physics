package jume.physics.core;

private final OVERLAP_PADDING = 4;

function separate(body1: Body, body2: Body): Bool {
  final bounds1 = body1.bounds;
  final bounds2 = body2.bounds;
  final overlapX = Math.min(bounds1.x + bounds1.width, bounds2.x + bounds2.width) - Math.max(bounds1.x, bounds2.x);
  final overlapY = Math.min(bounds1.y + bounds1.height, bounds2.y + bounds2.height) - Math.max(bounds1.y, bounds2.y);

  if (overlapX > overlapY) {
    return separateY(body1, body2) || separateX(body1, body2);
  } else {
    return separateX(body1, body2) || separateY(body1, body2);
  }
}

function separateX(body1: Body, body2: Body): Bool {
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

function separateY(body1: Body, body2: Body): Bool {
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
