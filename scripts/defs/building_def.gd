class_name BuildingDef
extends Resource
## Dữ liệu một loại công trình. Sinh từ data/balance/buildings.csv bằng
## tools/balance/csv_to_tres.py; không sửa tay các file .tres.

@export var id: StringName = &""
@export var name_key: String = ""
@export var faction: StringName = &""
@export var era: int = 1
## Giá gốc theo thứ tự Lúa, Gỗ, Đá, Tiền, Sắt, Diêm tiêu.
@export var cost: PackedFloat32Array = PackedFloat32Array([0, 0, 0, 0, 0, 0])
## Hệ số tăng giá theo số công trình cùng loại đã có: giá = gốc × growth^n.
@export var growth: float = 1.0
@export var hp: float = 1.0
@export var armor: float = 0.0
@export var size: Vector2i = Vector2i.ONE
@export var build_s: float = 0.0
@export var pop_bonus: int = 0
## Công trình quân sự chỉ bị phá bởi đơn vị có can_damage_military.
@export var military: bool = false
@export var capturable: bool = false
## 0 nghĩa là không giới hạn.
@export var max_count: int = 0
@export var coast_only: bool = false
@export var slots: int = 0
@export var territory_radius: int = 0
@export var trains: PackedStringArray = PackedStringArray()
@export var researches: PackedStringArray = PackedStringArray()
## Các loại tài nguyên công trình nhận khi dân trả hàng (L, G, DA, T, S, DI).
@export var dropoff: PackedStringArray = PackedStringArray()
@export var wall: bool = false
@export var gate: bool = false
## Bộ binh của chủ đứng lên được (Lũy của Nguyễn).
@export var walk_inf_owner: bool = false
@export var attack: float = 0.0
@export var range: float = 0.0
@export var reload_s: float = 0.0
@export var anti_capture_radius: int = 0


## Giá của công trình thứ n+1 khi đã có n công trình cùng loại, làm tròn nửa lên.
## Cộng thêm sai số nhỏ để 364.4999999 do số thực không bị làm tròn xuống nhầm.
func cost_for_count(count: int) -> PackedFloat32Array:
	var result := PackedFloat32Array()
	var factor := pow(growth, count)
	for base in cost:
		result.append(floorf(base * factor + 0.5 + 0.000001))
	return result
