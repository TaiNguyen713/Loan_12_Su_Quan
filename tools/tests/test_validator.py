"""Test cho tools/data_validator (S1.T04)."""
import shutil

from conftest import REPO
from validate import validate_dir

BALANCE = REPO / "data" / "balance"


def copy_balance(tmp_path):
    target = tmp_path / "balance"
    shutil.copytree(BALANCE, target)
    return target


def edit(path, old, new):
    text = path.read_text(encoding="utf-8")
    assert old in text, old
    path.write_text(text.replace(old, new, 1), encoding="utf-8", newline="\n")


def test_real_data_is_valid():
    assert validate_dir(BALANCE) == []


def test_S1_T04_TC2_unit_available_before_its_building(tmp_path):
    data = copy_balance(tmp_path)
    # Voi chiến era 1 nhưng Chuồng voi era 2: đơn vị mở khóa trước công trình luyện ra nó
    edit(data / "units.csv", "voi_chien,unit.voi_chien,,2,", "voi_chien,unit.voi_chien,,1,")
    errors = validate_dir(data)
    assert any("voi_chien" in str(e) and "mở khóa trước" in e.msg for e in errors)


def test_S1_T04_TC3_firearm_without_ammo(tmp_path):
    data = copy_balance(tmp_path)
    edit(data / "units.csv", "S:1|DI:2,siege|ranged", ",siege|ranged")
    errors = validate_dir(data)
    assert any("dai_bac" in e.msg and "ammo" in e.msg for e in errors)


def test_negative_value_reports_file_line_column(tmp_path):
    data = copy_balance(tmp_path)
    edit(data / "units.csv", "dan,unit.dan,,1,L:50,40,", "dan,unit.dan,,1,L:50,-5,")
    errors = validate_dir(data)
    assert len(errors) == 1
    err = errors[0]
    assert err.line == 2 and err.col == 6
    assert "hp" in err.msg
    assert str(err).startswith(f"{(data / 'units.csv').as_posix()}:2:6:")


def test_unknown_unit_reference(tmp_path):
    data = copy_balance(tmp_path)
    edit(data / "buildings.csv", "ky_binh,,,false", "ky_binh|khong_co,,,false")
    errors = validate_dir(data)
    assert any("khong_co" in e.msg for e in errors)


def test_duplicate_id(tmp_path):
    data = copy_balance(tmp_path)
    text = (data / "units.csv").read_text(encoding="utf-8").splitlines()
    (data / "units.csv").write_text("\n".join(text + [text[1]]) + "\n", encoding="utf-8", newline="\n")
    errors = validate_dir(data)
    assert any("id trùng" in e.msg for e in errors)


def test_faction_mismatch(tmp_path):
    data = copy_balance(tmp_path)
    # Tào Ty (Nguyễn) luyện một đơn vị của Trịnh
    edit(data / "buildings.csv", "tao_ty,building.tao_ty,nguyen,2,G:200|DA:100|T:200,1.0,800,1,2x2,25,0,false,false,1,false,0,0,,",
         "tao_ty,building.tao_ty,nguyen,2,G:200|DA:100|T:200,1.0,800,1,2x2,25,0,false,false,1,false,0,0,thuyen_chien_dang_ngoai,")
    errors = validate_dir(data)
    assert any("của phe trinh" in e.msg for e in errors)
