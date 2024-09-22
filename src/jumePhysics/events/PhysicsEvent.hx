package jumePhysics.events;

import jumePhysics.components.CPhysicsBody;

import jume.events.EventType;
import jume.events.Event;

class PhysicsEvent extends Event {
  public static final TRIGGER_START: EventType<PhysicsEvent> = 'jume_basic_trigger_start';

  public static final TRIGGER_STAY: EventType<PhysicsEvent> = 'jume_basic_trigger_stay';

  public static final TRIGGER_END: EventType<PhysicsEvent> = 'jume_basic_trigger_end';

  public static final COLLISION_START: EventType<PhysicsEvent> = 'jume_basic_collision_start';

  public static final COLLISION_STAY: EventType<PhysicsEvent> = 'jume_basic_collision_stay';

  public static final COLLISION_END: EventType<PhysicsEvent> = 'jume_basic_collision_end';

  var body1: CPhysicsBody;

  var body2: CPhysicsBody;
}
