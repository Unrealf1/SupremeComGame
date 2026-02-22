extends Node3D

signal died(final_score: float)

@export var speed := 10.0
@export var MAX_HP := 50
@export var max_vertical_angle_diff = 30.0

var hp := MAX_HP
var screenHalfExtents : Vector2
var metersFlown : float = 0.0
var vertical_angle_diff = 0.0
var _is_dead := false
var _afterburner: GPUParticles3D
var _smoke_trail: GPUParticles3D


func _ready() -> void:
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  _setup_engine_effects()


func _process(delta: float) -> void:
  GameState.update_global_state(delta)
  screenHalfExtents = ScreenBounds.get_half_extents(get_viewport())
  var arrow_input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
  var wasd_input := Vector2(
    int(Input.is_physical_key_pressed(KEY_D)) - int(Input.is_physical_key_pressed(KEY_A)),
    int(Input.is_physical_key_pressed(KEY_S)) - int(Input.is_physical_key_pressed(KEY_W))
  )
  var input_vec := arrow_input + wasd_input
  if input_vec.length() > 1.0:
    input_vec = input_vec.normalized()
  global_position += Vector3(input_vec.x, -input_vec.y, 0.0) * speed * delta
  var wantAngle = 0.0
  if input_vec.y > 0.0:
    wantAngle = -max_vertical_angle_diff
  elif input_vec.y < 0.0:
    wantAngle = max_vertical_angle_diff
  
  vertical_angle_diff = lerp(vertical_angle_diff, wantAngle, 1.0 - pow(0.005, delta))
  rotation.z = deg_to_rad(vertical_angle_diff)

  global_position.x = clamp(global_position.x, -screenHalfExtents.x, screenHalfExtents.x)
  global_position.y = clamp(global_position.y, -screenHalfExtents.y, screenHalfExtents.y)
  global_position.z = 0.0
  metersFlown = GameState.global_meters_passed + (global_position.x - -screenHalfExtents.x)
  metersFlown *= 1.0
  _set_engine_effects_enabled(true)


func apply_damage(amount: int) -> void:
  if _is_dead:
    return
  hp = max(hp - amount, 0)
  if hp <= 0:
    _is_dead = true
    _set_engine_effects_enabled(false)
    died.emit(metersFlown)


func heal(amount: int) -> void:
  if _is_dead:
    return
  hp = min(hp + amount, MAX_HP)
    
func is_player() -> bool:
  return true


func _setup_engine_effects() -> void:
  _smoke_trail = GPUParticles3D.new()
  _smoke_trail.name = "SmokeTrail"
  _smoke_trail.amount = 80
  _smoke_trail.lifetime = 0.9
  _smoke_trail.explosiveness = 0.0
  _smoke_trail.randomness = 0.4
  _smoke_trail.local_coords = false
  _smoke_trail.position = Vector3(-1.1, 0.0, 0.0)
  _smoke_trail.draw_order = GPUParticles3D.DRAW_ORDER_LIFETIME
  _smoke_trail.draw_pass_1 = _build_particle_sphere_mesh(0.08)
  _smoke_trail.process_material = _build_smoke_material()
  _smoke_trail.emitting = false
  add_child(_smoke_trail)
  
  _afterburner = GPUParticles3D.new()
  _afterburner.name = "Afterburner"
  _afterburner.amount = 64
  _afterburner.lifetime = 0.15
  _afterburner.explosiveness = 0.0
  _afterburner.randomness = 0.35
  _afterburner.local_coords = false
  _afterburner.position = Vector3(-0.9, 0.0, 0.0)
  _afterburner.draw_order = GPUParticles3D.DRAW_ORDER_LIFETIME
  _afterburner.draw_pass_1 = _build_particle_quad_mesh(0.12, true)
  _afterburner.process_material = _build_afterburner_material()
  _afterburner.emitting = false
  add_child(_afterburner)


func _set_engine_effects_enabled(enabled: bool) -> void:
  if _afterburner != null:
    _afterburner.emitting = enabled
  if _smoke_trail != null:
    _smoke_trail.emitting = enabled


func _build_particle_quad_mesh(size: float, additive: bool) -> QuadMesh:
  var mesh := QuadMesh.new()
  mesh.size = Vector2(size, size)
  var mat := StandardMaterial3D.new()
  mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  mat.vertex_color_use_as_albedo = true
  mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
  mat.cull_mode = BaseMaterial3D.CULL_DISABLED
  if additive:
    mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
  mesh.material = mat
  return mesh


func _build_particle_sphere_mesh(radius: float) -> SphereMesh:
  var mesh := SphereMesh.new()
  mesh.radius = radius
  mesh.height = radius * 2.0
  var mat := StandardMaterial3D.new()
  mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
  mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
  mat.vertex_color_use_as_albedo = true
  mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
  mat.cull_mode = BaseMaterial3D.CULL_DISABLED
  mat.blend_mode = BaseMaterial3D.BLEND_MODE_MIX
  mesh.material = mat
  return mesh


func _build_afterburner_material() -> ParticleProcessMaterial:
  var material := ParticleProcessMaterial.new()
  material.color = Color(1.0, 0.55, 0.1, 1.0)
  material.direction = Vector3(-1.0, 0.0, 0.0)
  material.spread = 22.0
  material.gravity = Vector3.ZERO
  material.set_param(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, Vector2(3.5, 3.9))
  #material.set_param_randomness(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, 0.25)
  material.set_param(ParticleProcessMaterial.PARAM_SCALE, Vector2(0.8, 1.2))
  #material.set_param_randomness(ParticleProcessMaterial.PARAM_SCALE, 0.35)
  material.color_ramp = _build_afterburner_ramp()
  return material


func _build_smoke_material() -> ParticleProcessMaterial:
  var material := ParticleProcessMaterial.new()
  material.direction = Vector3(-1.0, 0.0, 0.0)
  material.spread = 35.0
  material.gravity = Vector3.ZERO
  material.set_param(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, Vector2(1.8, 2.2))
  #material.set_param_randomness(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, 0.4)
  material.set_param(ParticleProcessMaterial.PARAM_SCALE, Vector2(0.75, 1.25))
  #material.set_param_randomness(ParticleProcessMaterial.PARAM_SCALE, 0.5)
  material.set_param(ParticleProcessMaterial.PARAM_DAMPING, Vector2(1.0, 1.0))
  material.color_ramp = _build_smoke_ramp()
  return material


func _build_afterburner_ramp() -> GradientTexture1D:
  var gradient := Gradient.new()
  gradient.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
  gradient.colors = PackedColorArray([
    Color(1.0, 0.95, 0.5, 0.95),
    Color(1.0, 0.5, 0.1, 0.55),
    Color(1.0, 0.2, 0.05, 0.0)
  ])
  var texture := GradientTexture1D.new()
  texture.gradient = gradient
  return texture


func _build_smoke_ramp() -> GradientTexture1D:
  var gradient := Gradient.new()
  gradient.offsets = PackedFloat32Array([0.0, 0.6, 1.0])
  gradient.colors = PackedColorArray([
    Color(0.5, 0.5, 0.5, 0.22),
    Color(0.35, 0.35, 0.35, 0.12),
    Color(0.2, 0.2, 0.2, 0.0)
  ])
  var texture := GradientTexture1D.new()
  texture.gradient = gradient
  return texture
