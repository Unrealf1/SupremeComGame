extends Node
class_name ScreenBounds

static func get_half_extents(viewport: Viewport, fallback: Vector2 = Vector2(16.0, 9.0)) -> Vector2:
  if viewport == null:
    return fallback
  var cam := viewport.get_camera_3d()
  if cam == null or cam.projection != Camera3D.PROJECTION_ORTHOGONAL:
    return fallback

  var viewport_size := viewport.get_visible_rect().size
  var aspect: float = float(viewport_size.x) / max(float(viewport_size.y), 1.0)
  var half_height := cam.size * 0.5
  var half_width := half_height * aspect
  return Vector2(half_width, half_height)
