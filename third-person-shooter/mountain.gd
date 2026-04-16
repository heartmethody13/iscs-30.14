extends MeshInstance3D

@export var size := 10
@export var resolution := 20
@export var height := 3.0

func _ready():
	mesh = create_hill_mesh()

func create_hill_mesh() -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in range(resolution):
		for x in range(resolution):
			var x0 = float(x) / resolution * size - size / 2.0
			var x1 = float(x + 1) / resolution * size - size / 2.0
			var z0 = float(z) / resolution * size - size / 2.0
			var z1 = float(z + 1) / resolution * size - size / 2.0

			var v00 = Vector3(x0, hill_height(x0, z0), z0)
			var v10 = Vector3(x1, hill_height(x1, z0), z0)
			var v01 = Vector3(x0, hill_height(x0, z1), z1)
			var v11 = Vector3(x1, hill_height(x1, z1), z1)

			st.add_vertex(v00)
			st.add_vertex(v10)
			st.add_vertex(v01)

			st.add_vertex(v10)
			st.add_vertex(v11)
			st.add_vertex(v01)

	st.generate_normals()
	return st.commit()

func hill_height(x: float, z: float) -> float:
	var dist = sqrt(x * x + z * z)
	var max_dist = size / 2.0
	var t = clamp(1.0 - (dist / max_dist), 0.0, 1.0)
	return t * height
