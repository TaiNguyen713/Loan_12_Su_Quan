class_name UnitDef
extends Resource
## Dữ liệu một loại đơn vị. Sinh từ data/balance/units.csv bằng tools/balance/csv_to_tres.py;
## không sửa tay các file .tres.
## Thứ tự 6 tài nguyên trong cost/upkeep/ammo: Lúa, Gỗ, Đá, Tiền, Sắt, Diêm tiêu.

@export var id: StringName = &""
@export var name_key: String = ""
## Rỗng nghĩa là dùng được cho cả hai phe; "npc" là đơn vị thuê.
@export var faction: StringName = &""
@export var era: int = 1
@export var cost: PackedFloat32Array = PackedFloat32Array([0, 0, 0, 0, 0, 0])
@export var hp: float = 1.0
@export var armor: float = 0.0
@export var attack: float = 0.0
## Khoảng cách giữa hai mép; từ 20 trở xuống là cận chiến.
@export var range: float = 0.0
@export var min_range: float = 0.0
@export var reload_s: float = 0.0
@export var accuracy: float = 1.0
@export var projectile: StringName = &""
@export var splash_px: float = 0.0
## px mỗi giây.
@export var speed: float = 0.0
@export var sight: float = 220.0
@export var radius: float = 8.0
@export var pop: int = 1
@export var train_s: float = 0.0
## Tiêu hao mỗi phút.
@export var upkeep: PackedFloat32Array = PackedFloat32Array([0, 0, 0, 0, 0, 0])
## Tiêu hao mỗi phát bắn.
@export var ammo: PackedFloat32Array = PackedFloat32Array([0, 0, 0, 0, 0, 0])
@export var tags: PackedStringArray = PackedStringArray()
## Tag của mục tiêu -> hệ số nhân sát thương.
@export var bonus: Dictionary = {}
## Hàng đứng trong đội hình, số nhỏ đứng trước.
@export var rank: int = 5
@export var domain: StringName = &"LAND"
@export var capturable: bool = false
@export var can_damage_military: bool = false
## Đơn vị mà đơn vị này thay thế ở phe riêng (ví dụ lính súng Đàng Ngoài).
@export var replaces: String = ""


func has_tag(tag: StringName) -> bool:
	return tags.has(String(tag))
