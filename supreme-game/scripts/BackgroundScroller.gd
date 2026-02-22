extends Node3D

@export var texture: Texture2D
@export var parallax_factor := 0.25
@export var z_depth := -10.0
@export var fit_texture_height_to_screen := true
@export var tint: Color = Color(0.8, 0.85, 0.9, 1.0)

@onready var tile_a: MeshInstance3D = $TileA
@onready var tile_b: MeshInstance3D = $TileB

var _screen_half_extents := Vector2(16.0, 9.0)
var _tile_size := Vector2(32.0, 18.0)
var _material: StandardMaterial3D
var _scroll_x := 0.0

func _ready() -> void:
  _setup_material()
  _update_layout()

func _process(delta: float) -> void:
  _update_layout()
  _scroll_tiles(delta)

func _setup_material() -> void:
  _material = StandardMaterial3D.new()
  _material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  _material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
  _material.albedo_color = Color(tint.r, tint.g, tint.b, 1.0)
  _material.cull_mode = BaseMaterial3D.CULL_DISABLED
  if texture != null:
    _material.albedo_texture = texture
  tile_a.material_override = _material
  tile_b.material_override = _material

func _update_layout() -> void:
  _screen_half_extents = ScreenBounds.get_half_extents(get_viewport(), _screen_half_extents)
  var screen_size := _screen_half_extents * 2.0
  _tile_size = screen_size

  if texture != null and fit_texture_height_to_screen:
    var tex_size := texture.get_size()
    if tex_size.y > 0:
      var tex_aspect: float = tex_size.x / tex_size.y
      _tile_size.y = screen_size.y
      _tile_size.x = max(screen_size.x, screen_size.y * tex_aspect)

  var plane_a := tile_a.mesh as PlaneMesh
  var plane_b := tile_b.mesh as PlaneMesh
  if plane_a != null:
    plane_a.size = _tile_size
  if plane_b != null:
    plane_b.size = _tile_size

  tile_a.global_position.y = 0.0
  tile_b.global_position.y = 0.0
  tile_a.global_position.z = z_depth
  tile_b.global_position.z = z_depth

  _apply_tile_positions()

func _scroll_tiles(delta: float) -> void:
  var offset := GameState.scroll_speed * parallax_factor * delta * 1.0
  _scroll_x = fposmod(_scroll_x + offset, _tile_size.x)
  _apply_tile_positions()

func _apply_tile_positions() -> void:
  tile_a.global_position.x = -_scroll_x
  tile_b.global_position.x = tile_a.global_position.x + _tile_size.x
