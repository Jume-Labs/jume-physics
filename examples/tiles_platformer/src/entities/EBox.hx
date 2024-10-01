package entities;

import components.CRotate;

import jume.ecs.Entity;
import jume.ecs.components.CBoxShape;
import jume.ecs.components.CTransform;
import jume.graphics.Color;

class EBox extends Entity {
  public function init(x: Float, y: Float, speed: Float, color: Color): EBox {
    addComponent(CTransform).init({ x: x, y: y });
    addComponent(CBoxShape).init({
      width: 80,
      height: 80,
      filled: true,
      fillColor: color
    });
    addComponent(CRotate).init(speed);

    return this;
  }
}
