class_name Iso
extends RefCounted
## Chiếu giữa không gian sim (px, hai trục vuông góc) và màn hình isometric 2:1 (S2.T01).
## Sim không biết gì về isometric; chỉ render, input và UI dùng lớp này.


static func to_screen(sim: Vector2) -> Vector2:
	return Vector2(sim.x - sim.y, (sim.x + sim.y) * 0.5)


static func to_sim(screen: Vector2) -> Vector2:
	return Vector2(screen.y + screen.x * 0.5, screen.y - screen.x * 0.5)
