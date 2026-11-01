class_name FxModel
extends RefCounted
## Helpers for the 3D FX models (ART glbs or code-built fallbacks).


## Merged mesh AABB of `root` and its descendants, in root's local space
## (root's own transform is treated as identity). Works outside the tree.
static func model_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first: bool = true
	var nodes: Array[Node] = [root]
	var xforms: Array[Transform3D] = [Transform3D.IDENTITY]
	while not nodes.is_empty():
		var n: Node = nodes.pop_back()
		var xf: Transform3D = xforms.pop_back()
		if n is MeshInstance3D:
			var mi := n as MeshInstance3D
			if mi.mesh != null:
				var box: AABB = xf * mi.get_aabb()
				if first:
					out = box
					first = false
				else:
					out = out.merge(box)
		for c in n.get_children():
			nodes.append(c)
			if c is Node3D:
				xforms.append(xf * (c as Node3D).transform)
			else:
				xforms.append(xf)
	return out


## Scales `model` uniformly so its longest side equals `longest`, and moves it
## so the AABB point picked by `anchor` (in 0..1 per axis of the box, e.g.
## (0.5, 0.5, 0.5) = centre, (0.5, 0, 0.5) = bottom centre) sits at the
## parent's origin. Returns the scale applied (0 if the model has no mesh).
static func normalise(model: Node3D, longest: float, anchor: Vector3 = Vector3(0.5, 0.5, 0.5)) -> float:
	var box: AABB = model_aabb(model)
	var side: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
	if side < 0.0001:
		return 0.0
	var s: float = longest / side
	var pivot: Vector3 = box.position + box.size * anchor
	model.transform = Transform3D(Basis.IDENTITY.scaled(Vector3(s, s, s)), -pivot * s)
	return s


## Like normalise() but fits the horizontal (x/z) extent instead of the
## longest side (used for the marker, whose height may exceed its width).
static func normalise_width(model: Node3D, width: float, anchor: Vector3 = Vector3(0.5, 0.0, 0.5)) -> float:
	var box: AABB = model_aabb(model)
	var side: float = maxf(box.size.x, box.size.z)
	if side < 0.0001:
		return 0.0
	var s: float = width / side
	var pivot: Vector3 = box.position + box.size * anchor
	model.transform = Transform3D(Basis.IDENTITY.scaled(Vector3(s, s, s)), -pivot * s)
	return s


## FX geometry never casts shadows (bills fly next to the camera).
static func no_shadows(n: Node) -> void:
	if n is GeometryInstance3D:
		(n as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for c in n.get_children():
		no_shadows(c)


## Unit-sized lit material for code-built fallbacks.
static func mat(color: Color, unshaded: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m
