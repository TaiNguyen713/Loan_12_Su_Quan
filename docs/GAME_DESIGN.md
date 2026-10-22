# Nam Bắc Phân Tranh — Game Design Document v2

| | |
|---|---|
| Phiên bản | **v2.0** · 22/10/2026 |
| Tài liệu chuẩn | Nội dung thiết kế lấy theo doc [Nam Bắc Phân Tranh – Tài liệu thiết kế game](https://claude.ai/artifact/UNNYw8cizh4Fu7epesQjAn) và canvas [Wireframe điện thoại 844×390](https://claude.ai/artifact/4CwFXp1fS4yiPmc1pP8PRD). File này tóm tắt các quyết định đó, **chốt phạm vi bản 1.0** và bổ sung số liệu khởi điểm để dev làm được |
| Liên quan | Số liệu & công thức: [ALGO_P0_P1 §5](plan/algorithms/ALGO_P0_P1.md) · Lộ trình: [01_ROADMAP](plan/01_ROADMAP.md) |
| Quy tắc ưu tiên | 1) Doc Nam Bắc + wireframe → 2) GDD này → 3) ALGO. Khi có mâu thuẫn **về thiết kế** thì theo Nam Bắc. Khi có mâu thuẫn **về số liệu** thì theo ALGO, vì Nam Bắc chưa đặt số |

**Ký hiệu:** Những gì Nam Bắc để ngỏ ("chưa đặt chỉ số", "đề xuất", "cần thử trên máy thật") được ghi là **[GDD v2 đặt]**: đó là giá trị khởi điểm do tài liệu này đặt ra, sẽ chỉnh sau playtest.

---

## 1. Tổng quan

- **Tên tạm:** Nam Bắc Phân Tranh.
- **Thể loại:** RTS. Xây kinh tế, rồi dồn sức vào các trận đánh đông quân, theo khung chơi của **Cossacks 3**.
- **Bối cảnh:** Trịnh – Nguyễn phân tranh. Cả game trải từ 1558 tới 1777, chia 3 giai đoạn.
- **Nền tảng:** **điện thoại trước** (Android, chơi màn hình ngang), PC sau.
- **Thời lượng:** một ván thường 20–30 phút, có lưu và chơi tiếp.

### 1.1 Phạm vi bản 1.0 và sau phát hành

| Hạng mục | **Bản 1.0** | Sau phát hành |
|---|---|---|
| Giai đoạn | **I – Hình thành (1558–1627)** và **II – Đại chiến (1627–1672)** | III – Phân đôi & suy tàn (1672–1777), Nam tiến |
| Phe chơi được | **Trịnh, Nguyễn** (đủ cây công nghệ) | Mạc (sau khi tra cứu sử), Hà Lan (VOC), Bồ Đào Nha |
| Hà Lan, Bồ Đào Nha trong 1.0 | **NPC**: Thương điếm, thanh quan hệ, bán vũ khí, cho thuê tàu/thợ; tàu VOC là đối thủ hoặc đồng minh trong chiến dịch | Thành phe chơi được |
| Chế độ chơi | Chiến dịch (nhiệm vụ 1–7), Đấu tự do với 1–3 AI, Trận lịch sử | Nhiều người chơi (2–4 trên điện thoại, 8 trên PC), nhiệm vụ 8 (1774–75), bản đồ Nam tiến |
| Nền tảng | Android | Bản PC (HUD 1920×1080, phím tắt Cossacks 3, 3000 quân) |

## 2. Nguyên tắc thiết kế

**Giữ từ Cossacks 3:**
- Vòng chơi: nhiều trung tâm → nhiều dân → nhiều tài nguyên → nhiều công trình và quân → tuyển liên tục → thắng.
- 6 tài nguyên, quân phải được nuôi liên tục:
  - hết Lúa thì quân mất máu;
  - hết Tiền thì lính đánh thuê bỏ đi;
  - hết Sắt hoặc Diêm tiêu thì súng, pháo và thuyền ngừng bắn.
- Đánh đông quân, có đội hình, chiếm dân và pháo của địch, giá công trình tăng dần theo số lượng.
- Hai mặt trận: bộ và thủy.

**Đổi cho bối cảnh Việt Nam:**
- 3 giai đoạn lịch sử thay cho mốc "thế kỷ 17 → 18" để mở khóa nội dung.
- Mỗi phe có cơ chế riêng bám theo sử: Lũy cho Nguyễn, lưỡng đầu chế cho Trịnh.
- Voi chiến, thuyền chiến và đại bác là trục quân sự chính.

**Đổi cho điện thoại (ưu tiên số 1):**
- Trần quân thấp hơn PC: **800 quân mỗi trận** trên điện thoại.
- Đội hình dựng tự động bằng một nút.
- Mọi phím tắt PC đều có nút hoặc cử chỉ tương đương.
- Ván ngắn.

## 3. Bối cảnh lịch sử & giai đoạn

| Năm | Sự kiện | Dùng trong game | Bản |
|---|---|---|---|
| 1558 | Nguyễn Hoàng vào trấn thủ Thuận Hóa | Mở đầu giai đoạn I; nhiệm vụ 1 | 1.0 |
| 1599 | Trịnh Tùng được phong vương | Cơ chế lưỡng đầu chế | 1.0 |
| 1620–1623 | Nguyễn Phúc Nguyên ngừng nộp thuế | Mở màn chiến tranh | 1.0 |
| 1627 | Trịnh đánh lớn 4 tháng không thắng | Nhiệm vụ 2; chuyển sang giai đoạn II | 1.0 |
| 1630 | Đào Duy Từ xây Lũy Thầy (nguồn lệch năm) | Cơ chế Lũy; nhiệm vụ 3 | 1.0 |
| 1637 | Hà Lan lập thương điếm ở Phố Hiến | Thương điếm VOC | 1.0 |
| 1643 | Trận sông Gianh với hạm đội VOC (Đại Nam thực lục ghi 1644) | Nhiệm vụ 4 (hải chiến) | 1.0 |
| 1648 | Trường Dục: Trịnh thua lớn trước Lũy | Nhiệm vụ 5 | 1.0 |
| 1651 | VOC hòa với Nguyễn | Cơ chế đổi phe của phương Tây | 1.0 |
| 1655–1656 | Nguyễn tiến ra Nghệ An, bị đẩy về sông Gianh | Nhiệm vụ 6 | 1.0 |
| 1672 | Đình chiến, lấy sông Gianh làm giới tuyến | Nhiệm vụ 7; kết thúc phạm vi 1.0 | 1.0 |
| 1667–1677, 1679–1732, 1744, 1774–1777 | Dẹp Mạc, Nam tiến, Phú Xuân, Trịnh Sâm, Tây Sơn | Giai đoạn III | Sau |

Mỗi sự kiện có ghi độ chắc của nguồn trong doc Nam Bắc (mục 2). Năm lệch giữa các nguồn thì ghi theo **nguồn đa số** và kèm chú thích trong game.

**Chuyển giai đoạn:** Nghiên cứu "Sang giai đoạn II" ở Thư phòng (giá và điều kiện ở ALGO S8.T03). Giai đoạn II mở khóa: Chuồng voi, Xưởng đúc súng, Trường tập bắn, Thương điếm, Tào Ty, Lũy, Voi chiến, Đại bác, Cơ súng và nhóm nghiên cứu cấp II.

## 4. Vòng lặp gameplay

```
Lập làng/khẩn hoang → Dân → Ruộng/Rừng/Mỏ/Thuế → (Chợ, Cảng, Thương điếm)
        ↑                                              ↓
   Nghiên cứu, sang giai đoạn II  ←  Công trình (giá tăng dần) → Tuyển quân liên tục → Lập Đội → Giao chiến
                                                                                  ↓
                                                          Chiếm dân/pháo · phá kinh tế · vượt sông · công Lũy
```

**Điều kiện thắng** (chọn khi tạo trận đấu tự do; chiến dịch có điều kiện riêng):

| Điều kiện | Luật |
|---|---|
| Tiêu diệt (mặc định) | Phá hoặc chiếm hết công trình trung tâm (Phủ chúa, Làng, Triều vua) **và** quân của đối phương |
| Chiếm thủ phủ | Giữ vùng 8 ô quanh Phủ chúa địch liên tục 120 giây mà trong vùng không còn quân địch **[GDD v2 đặt]** |
| Đình chiến | Hết thời gian chọn trước (20/30/45 phút), bên nhiều điểm hơn thắng. Điểm = 40% lãnh thổ + 30% kinh tế + 30% quân **[GDD v2 đặt]** |

## 5. Phe (bản 1.0)

| | **Trịnh (Đàng Ngoài)** | **Nguyễn (Đàng Trong)** |
|---|---|---|
| Điểm mạnh | Đông dân, đông quân; đại bác; thuyền chiến nhiều và vững; lính bắn giỏi | Địa hình và Lũy; voi chiến; cơ súng; thủy binh; ngoại thương cởi mở ở Hội An |
| Điểm yếu | Bộ máy cồng kềnh; ngoại thương bị kiềm chặt (tàu phải dừng ở Phố Hiến chờ cấp phép) | Dân và quân ít hơn |
| Cơ chế riêng | **Lưỡng đầu chế:** có cả Phủ chúa lẫn Triều vua Lê. Triều vua cho "Danh nghĩa" | **Lũy** phòng thủ; **Tào Ty** thu thuế thuyền; **khẩn hoang** (lập làng trên đất trống rẻ hơn) |
| Hiện thực hóa trong luật **[GDD v2 đặt]** | Dân rẻ hơn (40 Lúa thay vì 50). Thời gian nghiên cứu +15%. Thuyền buôn ngoại quốc tới thưa hơn nhưng thuế mỗi thuyền cao hơn | Nhà chỉ +12 dân số (Trịnh +15). Làng trên đất trống −30% giá. Lũy được đứng lên, cộng giáp và tầm. Thuyền buôn tới dày hơn |
| Quân đặc trưng | Lính súng Đàng Ngoài, Thuyền chiến Đàng Ngoài | Cơ súng, Thổ binh, Ngư binh |
| Thủ phủ mặc định | Thăng Long (Phủ chúa) + Triều vua Lê | Phú Xuân / Ái Tử (Phủ chúa) |
| Màu phe | Vàng `#F4C62A`, hoa văn sọc chéo | Đỏ `#D42E28`, hoa văn chấm tròn |

**Phe phụ (sau phát hành):** Mạc, Hà Lan, Bồ Đào Nha. Mạc chưa có dữ kiện sử để gán chỉ số, phải tra cứu trước.

## 6. Kinh tế

| Tài nguyên | Ký hiệu | Thu từ | Dùng để | Khi thiếu |
|---|---|---|---|---|
| Lúa | L | Ruộng (dân cày) | Tuyển dân, nuôi quân | Quân mất máu dần |
| Gỗ | G | Rừng (cây bị khai thác hết) | Xây dựng, đóng thuyền | Không xây, không đóng thuyền được |
| Đá | Đ | Mỏ đá | Lũy, công trình lớn | Không xây Lũy được |
| Tiền (tiền đồng) | T | Thuế đinh, thuế chợ, thuế thuyền | Tuyển lính, lính đánh thuê, upkeep | Lính đánh thuê bỏ đi, thuyền thuê đứng yên |
| Sắt | S | Mỏ sắt, mua của thương nhân | Súng, đại bác | Pháo ngừng bắn |
| Diêm tiêu | D | Mỏ diêm tiêu, mua của thương nhân | Thuốc súng cho súng, pháo, thuyền | Súng và pháo ngừng bắn |

**Luật kinh tế** (công thức ở ALGO S4 và S9):
- **Dân & làng:**
  - Làng tuyển dân và là nơi nộp tài nguyên. Nhà tăng giới hạn dân số.
  - Giá công trình tăng dần theo công thức `giá = gốc × g^n`, với n là số đã có. Hệ số g ở mục 7.
- **Ruộng và mỏ không cạn.** Rừng thì cạn.
  - Ruộng có 4 chỗ cho dân cày; dân chở lúa về Kho lúa hoặc Làng gần nhất.
  - Mỏ có 5 chỗ (nâng cấp được lên 10); dân làm việc **bên trong mỏ**, tài nguyên vào kho trực tiếp.
- **Thuế đinh:** mỗi 60 giây, Tiền tăng 0.5 × số dân **[GDD v2 đặt]**.
- **Upkeep:** mỗi lính tốn Lúa theo thời gian; lính đánh thuê tốn thêm Tiền. Mỗi phát súng, pháo hoặc thuyền tốn Sắt và Diêm tiêu.
- **Chợ:** đổi tài nguyên lấy Tiền và ngược lại. Giá dao động và **dùng chung cho mọi người chơi**, giống Cossacks 3.
- **Cảng & ngoại thương:**
  - Thuyền buôn ngoại quốc ghé Cảng và nộp thuế bằng Tiền.
  - Nguyễn: thuyền tới dày hơn. Tào Ty tăng thuế thuyền đến.
  - Trịnh: thuyền tới thưa hơn nhưng thuế mỗi thuyền cao hơn.
- **Mua vũ khí:** mua Sắt, Diêm tiêu và đại bác qua Thương điếm Hà Lan hoặc Bồ Đào Nha, khi quan hệ đủ cao (mục 10).
- **Kho tối đa (tùy chọn theo bản đồ):** bản đồ Đàng Trong có thể giới hạn 12 kho, theo ghi chép của Phủ biên tạp lục.

## 7. Công trình

Số liệu nguồn: ALGO_P0_P1 §5. "GĐ" là giai đoạn mở khóa. Cột g là hệ số tăng giá theo số lượng.

| Công trình | Thay cho (Cossacks 3) | Vai trò | Phe | GĐ |
|---|---|---|---|---|
| Phủ chúa | Town Hall (thủ phủ) | Luyện dân, nơi nộp tài nguyên, +30 dân số, bắn tên; mỗi phe 1 cái | Cả hai | I |
| Triều vua Lê | — | Danh nghĩa (lưỡng đầu chế) | Trịnh | I |
| Làng | Town Hall | Luyện dân, nơi nộp tài nguyên, +20 dân số | Cả hai | I |
| Nhà | House | +15 dân số (Nguyễn +12) | Cả hai | I |
| Ruộng | Field | 4 chỗ dân cày, không cạn | Cả hai | I |
| Kho lúa | Mill | Nơi nộp Lúa, nghiên cứu năng suất | Cả hai | I |
| Mỏ | Mine | Đặt lên mỏ đá, sắt hoặc diêm tiêu; 5 → 10 chỗ | Cả hai | I |
| Chợ | Market | Đổi tài nguyên | Cả hai | I |
| Doanh trại | Barracks | Lính giáo, lính đao, lính súng | Cả hai | I |
| Chuồng ngựa | Stable | Kỵ binh | Cả hai | I |
| Thư phòng | Academy | Nghiên cứu chung, chuyển giai đoạn | Cả hai | I |
| Cảng | Shipyard | Thuyền chiến, thuyền buôn, đón thuyền ngoại quốc | Cả hai (bản đồ có biển) | I |
| Đồn / tháp canh | Tower | Bắn địch ở gần, chống bắt dân trong 10 ô | Cả hai | I |
| Chuồng voi | — | Voi chiến | Cả hai | II |
| Xưởng đúc súng | Artillery depot | Đại bác, nghiên cứu pháo (Nguyễn gọi là Trường Đúc) | Cả hai | II |
| Trường tập bắn | Academy (phần hỏa lực) | Nghiên cứu hỏa lực; Nguyễn luyện Cơ súng | Cả hai | II |
| Thương điếm | Diplomatic centre | Giao dịch với Hà Lan/Bồ Đào Nha, mua vũ khí, thuê | Theo bản đồ | II |
| Tào Ty | — | +25% thuế thuyền đến; mỗi phe chỉ 1 cái | Nguyễn | II |
| Lũy | Wall | Phòng tuyến; quân bộ của mình đứng lên được, +3 giáp, +15% tầm | Nguyễn | II |
| Tường thường | Wall | Chặn đường | Trịnh | II |
| Cổng | Gate | Quân mình qua được, quân địch bị chặn | Cả hai | II |

**Luật Lũy** (theo Nam Bắc mục 5):
- Chỉ dựng được **trong lãnh thổ của mình**. Tốn nhiều Đá và Gỗ, xây chậm.
- Chỉ **đại bác, voi chiến và thuyền chiến** gây được sát thương lên Lũy và công trình quân sự.
- Nghiên cứu "Binh thư Đào Duy Từ" tăng độ bền Lũy và mở Lũy cấp cao.

**Lãnh thổ** **[GDD v2 đặt]**: gồm các ô trong bán kính 20 ô quanh Phủ chúa, 15 ô quanh Làng, 10 ô quanh Đồn.

## 8. Đơn vị

Số liệu nguồn: ALGO_P0_P1 §5. Chỉ số là **[GDD v2 đặt]** (Nam Bắc chưa đặt). Cột "Khắc" và "Bị khắc" lấy theo Nam Bắc mục 6.

**Đơn vị chung:**

| Đơn vị | Vai trò | Khắc | Bị khắc | GĐ |
|---|---|---|---|---|
| Dân | Thu tài nguyên, xây dựng | – | Mọi lính; bị bắt khi không có quân bảo vệ | I |
| Lính giáo | Bộ binh nặng, giữ hàng, che cho lính súng | Kỵ binh, voi | Lính súng, pháo | I |
| Lính đao | Bộ binh nhẹ, nhanh | Lính súng khi cận chiến | Lính giáo, kỵ binh | I |
| Lính súng hỏa mai | Bắn tầm trung | Bộ binh, voi | Kỵ binh, cận chiến | I |
| Kỵ binh | Đánh sườn, săn dân và pháo | Lính súng, pháo | Lính giáo, voi | I |
| Voi chiến | Phá hàng, phá công trình | Bộ binh đứng dày, cổng lũy | Lính súng tập trung, pháo | II |
| Đại bác | Phá công trình, lũy, đội hình dày | Mọi thứ ở tầm xa | Kỵ binh (bị chiếm) | II |
| Thuyền chiến | Hải chiến, bắn vào bờ | Thuyền buôn, công trình ven bờ | Tàu lớn phương Tây, đại bác trên bờ | I |
| Thuyền buôn | Chở hàng, sinh tiền ở cảng | – | Mọi thuyền chiến | I |
| Cai đội, Lính trống | Game tự thêm khi lập Đội | – | – | I |

**Đơn vị đặc trưng:**

| Phe | Đơn vị | Đặc điểm |
|---|---|---|
| Nguyễn | Cơ súng (GĐ II, ở Trường tập bắn) | Lính súng tinh, bắn chính xác hơn |
| Nguyễn | Thổ binh | Quân địa phương, rẻ, +3 giáp khi trong 15 ô quanh Làng của mình |
| Nguyễn | Ngư binh | Thuyền nhỏ nhanh, ×2 sát thương lên tàu lớn |
| Trịnh | Lính súng Đàng Ngoài (thay lính súng thường) | Rẻ hơn, luyện nhanh hơn, bắn tốt |
| Trịnh | Thuyền chiến Đàng Ngoài (thay thuyền chiến thường) | Bền hơn |
| NPC | Tàu chiến VOC | Tàu lớn, nhiều pháo, chậm, dễ bị thuyền nhỏ vây (thuê được khi quan hệ ≥ 70) |
| NPC | Thợ đúc Bồ Đào Nha | Gắn vào Xưởng đúc: đúc pháo nhanh hơn 25%, pháo +10% sát thương |

**Tổ chức quân:** cơ → đội → thuyền, mỗi thuyền 30–50 lính. Bản 1.0 dùng cách tổ chức này cho cả hai phe (binh chế Lê – Trịnh còn chờ tra cứu).

**Trần quân** **[GDD v2 đặt, cần thử trên máy thật]**:
- Mỗi trận tối đa **800** quân trên điện thoại cấu hình trung bình trở lên, **400** trên máy yếu. Game tự chọn theo cấu hình máy.
- Mỗi người chơi được `trần trận / số người chơi`, ví dụ 1v1 là 400 mỗi bên.

## 9. Đội hình, lệnh, chiến đấu

**Đội** (theo Nam Bắc mục 7):
- Chọn **≥ 30 lính cùng loại**, nhấn **"Lập Đội 30"** hoặc **"Lập Đội 50"**. Game tự thêm 1 cai đội và 1 lính trống (trừ tiền tương ứng), không bắt người chơi ghép tay.
- Ba hình: **Hàng ngang**, **Hàng dọc**, **Hình vuông** (chống kỵ binh và voi nhưng dễ trúng pháo).
- **Bonus theo mức của Cossacks 3:** cận chiến +2 công, +3 giáp; lính bắn +2 hỏa lực, +3 giáp.
- **Sửa các lỗi của bản gốc:**
  - Đội giữ hàng khi gặp địch.
  - Bổ sung lính mới không phá hình.
  - Cai đội và lính trống luôn đứng sau hàng đầu.

**8 lệnh (giữ như Cossacks 3):**

| Lệnh | Tác dụng |
|---|---|
| Giữ vị trí | Không di chuyển, chỉ đánh địch trong tầm |
| Nghỉ | Dừng lệnh, không tự đánh (vẫn phản đòn), hồi sĩ khí nhanh gấp đôi |
| Đi và đánh | Tiến tới điểm đích, đánh mọi địch gặp trên đường |
| Cấm bắn / Cho phép bắn | Bật/tắt việc tự tấn công |
| Bổ sung | Lấp chỗ trống của Đội bằng lính cùng loại đang rảnh gần đó |
| Canh | Đánh địch trong vùng canh rồi quay về |
| Đổi hình | Ngang / Dọc / Vuông |
| Đường đi nhiều điểm | Nút "Thêm điểm" |

**Chiến đấu & chiếm đoạt:**
- Dân, đại bác và công trình dân sự không có quân bảo vệ sẽ **bị chiếm**:
  - Có độ trễ **2 giây** và hiện thẻ cảnh báo trước khi dân bị chiếm.
  - Chiếm được dân của phe khác thì xây được công trình của phe đó.
- Công trình quân sự và Lũy chỉ bị phá bằng đại bác, voi hoặc thuyền chiến.
- **Sông** chặn đường bộ. Chỉ qua được bằng **cầu**, **bến phà** hoặc **thuyền**. Sông Gianh là ranh giới mặc định của bản đồ hai đàng.
- **Sĩ khí** 0–100 (bảng ở ALGO S6.T03). Về 0 thì quân tháo chạy.
- **Dịch bệnh** (tùy chọn khi tạo trận): quân ở ngoài lãnh thổ quá lâu, xa nguồn lúa, sẽ mất máu dần.

## 10. Cơ chế chính trị

- **Lưỡng đầu chế (Trịnh):**
  - Khi Triều vua Lê còn thuộc về Trịnh, Trịnh có "Danh nghĩa": sĩ khí hồi +10%, giá giao dịch ở Thương điếm −15%, quan hệ phương Tây tăng nhanh hơn 20% **[GDD v2 đặt]**.
  - Triều vua bị chiếm hoặc bị phá thì mất bonus này.
- **Liên minh phương Tây:**
  - Hà Lan và Bồ Đào Nha có **thanh quan hệ 0–100** với mỗi phe chính.
  - Quan hệ tăng khi giao dịch bằng Tiền ở Thương điếm.
  - Quan hệ ≥ 40: mua được vũ khí. Quan hệ ≥ 70: thuê được tàu VOC hoặc thợ đúc Bồ Đào Nha.
  - Thua một trận lớn thì quan hệ tụt. Mỗi nước phương Tây chỉ phục vụ phe có quan hệ cao hơn, nên **có thể đổi phe**, như VOC hòa với Nguyễn năm 1651.

## 11. Chế độ chơi

| Chế độ | Nội dung | Bản |
|---|---|---|
| Chiến dịch | 7 nhiệm vụ (bảng dưới) | 1.0 |
| Đấu tự do | Chọn phe; 1–3 đối thủ AI; địa hình; tài nguyên đầu; giai đoạn khởi đầu (I/II); thời gian hòa bình (0/5/10 phút); kích thước bản đồ (nhỏ/vừa); vị trí xuất phát; điều kiện thắng; bật/tắt dịch bệnh | 1.0 |
| Trận lịch sử | Một trận đơn, quân có sẵn, không xây kinh tế (chơi nhanh 10–15 phút) | 1.0 |
| Nhiều người chơi | 2–4 người trên điện thoại, tối đa 8 trên PC | Sau |
| Nam tiến | Bản đồ mở rộng về phía nam (giai đoạn III) | Sau |

**Nhiệm vụ chiến dịch** (theo Nam Bắc mục 8):

| # | Trận | Phe chơi | Mục tiêu trong game | Bản |
|---|---|---|---|---|
| 1 | Vào Thuận Hóa (1558) | Nguyễn | Hướng dẫn chơi: lập làng, khẩn hoang, dựng phủ ở Ái Tử | 1.0 |
| 2 | Trận 1627 | Nguyễn hoặc Trịnh | Cầm cự (rút từ 4 tháng thành vài phút) trước quân đông hơn | 1.0 |
| 3 | Lũy Thầy (1630) | Nguyễn | Xây xong tuyến lũy trước khi Trịnh tới | 1.0 |
| 4 | Sông Gianh (1643) | Nguyễn | Hải chiến: dùng thuyền nhỏ đánh bại tàu VOC | 1.0 |
| 5 | Trường Dục (1648) | Nguyễn | Giữ lũy rồi dùng voi phản công đêm | 1.0 |
| 6 | Nghệ An (1655–1656) | Trịnh | Cùng Trịnh Tạc và Trịnh Căn đẩy Nguyễn về sông Gianh | 1.0 |
| 7 | Trận cuối (1672) | Trịnh | Thử chiếm Phú Xuân lần cuối, kết thúc bằng đình chiến | 1.0 |
| 8 | Chiếm Phú Xuân (1774–1775) | Trịnh | Vượt sông, chiếm Phú Xuân, chống dịch bệnh | Sau |

Nhân vật lịch sử (Nguyễn Phúc Tần, Trịnh Tạc, Trịnh Căn, Đào Duy Từ…) chỉ xuất hiện **trong chiến dịch**, dưới dạng đơn vị chỉ huy có tên và một aura nhỏ. Tên và lời thoại phải được **người hiểu sử duyệt** (S17.T02).

## 12. Điều khiển & HUD (chuẩn: wireframe 844×390)

**Khung tham chiếu:** 844×390 pt, màn hình ngang. Chừa vùng an toàn 44 pt trái/phải cho tai thỏ và thanh home.

### 12.1 Cử chỉ

| Thao tác PC | Cử chỉ điện thoại |
|---|---|
| Chọn một đơn vị | Chạm |
| Kéo khung chọn | **Giữ 0.3 giây rồi kéo**, hoặc bật nút "Chọn vùng" rồi kéo |
| Chọn mọi đơn vị cùng loại | Chạm đúp |
| Ra lệnh đi/đánh | Chạm lên đất hoặc địch khi đang có lựa chọn |
| Đường đi nhiều điểm | Giữ nút "Thêm điểm" rồi chạm lần lượt các điểm |
| Di chuyển camera | **Kéo hai ngón**; chạm minimap |
| Zoom | Chụm/mở hai ngón |
| Nhóm Ctrl + 0–9 | 5 ô nhóm nhanh ở cột trái; giữ ô để gán, chạm để chọn |
| Lệnh S, C, A, E/D, F, G | Thanh lệnh 6 nút khi đang chọn quân |
| Đổi hình J, K, L | 3 nút hình đội trong thanh lệnh |
| Tuyển quân (trái +1, phải −1, Shift ×5, Ctrl vô hạn) | Chạm để +1; giữ để mở bảng số lượng (−1, +5, vô hạn) |
| Điểm tập kết | Nút "Điểm tập kết" rồi chạm lên bản đồ |
| Chọn dân rảnh | Chạm ô "Rảnh" trên thanh trên |
| F10 (menu) | Nút tạm dừng ở góc trên phải |

Mặc định kéo **một** ngón không cuộn camera, đúng theo chuẩn. Cài đặt có tùy chọn "Kéo 1 ngón để cuộn", mặc định tắt.

### 12.2 Bố cục (theo canvas, artboard 1 và 2)

```
┌─ an toàn 44 ─┬──────────── Thanh trên 36 pt ────────────────────────────────┬─ 44 ─┐
│              │ [Dân 148/200][Rảnh 3] Lúa 980 Gỗ 1240 Đá 2210 Tiền 420 Sắt 310 Diêm 275 [II] │
│ ┌52┐         │        ┌ Thẻ cảnh báo 220×36: "Dân ở mỏ đá sắp bị bắt – chạm để tới" ┐       │
│ │1 │ 52×44   │                                                                               │
│ │2 │ ô nhóm  │                        BẢN ĐỒ (kéo 2 ngón, chụm để zoom)                       │
│ │3 │         │                                                                               │
│ │4 │         │                                                                               │
│ │5 │         │ ┌Minimap 120×120┐ ┌ Bảng lệnh ≤ 25% chiều cao, nút 48×48 ────┐ (Thêm điểm 64) (Xây 64) │
│ └──┘         │ └───────────────┘ │ Đội lính giáo ×50 · Hình vuông  Giáp +3   │                  │
│              │                   │ [Giữ][Nghỉ][Đi&đánh][Cấm bắn][Bổ sung][Canh] | [Ngang][Dọc][Vuông] │
└──────────────┴───────────────────┴──────────────────────────────────────────┴──────────────────┘
```
- **Thanh trên (cao 36 pt):** dân số, nút "Rảnh N" (nền cam khi N > 0), 6 tài nguyên (chỉ hiện số trong kho; chạm để xem số người làm và thu/chi mỗi phút), nút tạm dừng 44×44.
- **Cột trái (rộng 52 pt):** 5 ô nhóm 52×44 pt, cách nhau 6 pt; ô trống viền đứt.
- **Góc dưới trái:** minimap 120×120 pt.
- **Đáy giữa:** bảng lệnh rộng khoảng 456 pt, cao ≤ 96 pt (≤ 25% chiều cao màn hình), nút 48×48 pt. Dòng đầu ghi tên và số lượng đơn vị đang chọn cùng bonus. **Bảng ẩn khi không chọn gì.**
- **Góc dưới phải:** nút **Xây** 64×64 pt (màu nhấn) và nút **Thêm điểm** 64×64 pt.
- **Thẻ cảnh báo** nằm dưới thanh trên. Gồm: dân sắp bị bắt, Tiền âm, hết Lúa, hết Sắt/Diêm tiêu, quân bị tấn công. Chạm thẻ để camera nhảy tới chỗ đó.
- **Lưới Xây** (artboard 2): tấm bên phải rộng 420 pt.
  - 4 tab: **Kinh tế / Quân sự / Phòng thủ / Biển**. Lưới 4 cột, ô cao 72 pt, ghi tên và giá.
  - Ô mờ là chưa mở khóa, có ghi điều kiện (ví dụ "Tào Ty – Giai đoạn II"). Giá màu đỏ là thiếu tài nguyên. Giá tăng dần theo số đã xây.
  - Nút đóng × 44×44.
  - Bên trái: "Chọn công trình rồi chạm lên bản đồ để đặt. Ô xanh = đặt được, ô đỏ = không đặt được."
- **Quy tắc chung:** ô chạm tối thiểu 44×44 pt, chữ tối thiểu 12 pt, có chỉnh cỡ UI, tôn trọng vùng an toàn, bảng lệnh không che quá 25% chiều cao.

### 12.3 Luồng màn hình
```
Menu chính ─┬─ Chiến dịch → Chọn chiến dịch (Trịnh | Nguyễn) → Bản đồ nhiệm vụ → Briefing → TRẬN → Kết thúc
            ├─ Đấu tự do → Thiết lập trận → TRẬN → Kết thúc
            ├─ Trận lịch sử → Chọn trận → TRẬN → Kết thúc
            ├─ Bách khoa · Cài đặt · Hướng dẫn
TRẬN → Tạm dừng: Tiếp tục · Lưu · Tải · Cài đặt · Chơi lại · Thoát
```

## 13. AI & độ khó

- Có 3 mức độ khó: **Dễ / Thường / Khó**. Tham số ở ALGO S10.T03.
- Đấu tự do cho phép 1–3 AI cùng lúc.
- AI chơi đủ: 6 tài nguyên, chợ, chuyển giai đoạn, lập Đội.
- AI không nhìn xuyên sương mù.

## 14. Nghiên cứu

Theo Nam Bắc, có **khoảng 40 mục** cho bản điện thoại, xếp theo nhóm: năng suất (lúa, gỗ, đá, mỏ), hỏa lực, giáp, tầm pháo, tốc độ đóng thuyền, sức bền lũy, cùng mục chuyển giai đoạn.
- Theo luật cộng phần trăm của Cossacks: nâng cấp từng loại lính ở công trình luyện ra nó, hỏa lực chung thì mua ở Thư phòng.
- Danh sách 40 mục kèm giá và hiệu quả nằm ở **ALGO_P2 S8.T02**.

## 15. Đồ họa & âm thanh

- **Phong cách:** 2D isometric, sprite render sẵn từ 3D. Trang phục, công trình và tàu thuyền thế kỷ 17 có tư liệu tham chiếu, được người hiểu sử duyệt.
- **Danh sách asset dự kiến cho bản 1.0:**
  - Quân bộ: 13 bộ sprite (9 chung + Cơ súng, Thổ binh, Lính súng Đàng Ngoài, cùng nhân vật chỉ huy dùng chung bộ khung).
  - Thủy: 5 bộ sprite (thuyền chiến, thuyền chiến Đàng Ngoài, thuyền buôn, ngư binh, tàu VOC).
  - Công trình: khoảng 21 loại × 4 trạng thái.
  - Nhạc: 8 bài. Hiệu ứng âm thanh: khoảng 70. Giọng nói: lời xác nhận lệnh.
- **Nhạy cảm:** đây là nội chiến giữa người Việt với nhau. Cần trình bày cân bằng, không tôn một bên.

## 16. Phạm vi 1.0 (MoSCoW)

| Mức | Tính năng |
|---|---|
| **Must** | Trịnh + Nguyễn; giai đoạn I–II; 6 tài nguyên; giá tăng dần; Chợ; Cảng và thuyền buôn; Thương điếm NPC và quan hệ phương Tây; lưỡng đầu chế; Lũy, khẩn hoang, Tào Ty; Đội 30/50 với 8 lệnh; chiếm đoạt có trễ 2 giây; cầu, bến phà, thủy chiến; sương mù; AI 3 mức với 1–3 đối thủ; Chiến dịch (nhiệm vụ 1–7), Đấu tự do, Trận lịch sử; lưu/tải; tiếng Việt và tiếng Anh; HUD 844×390 |
| **Should** | Dịch bệnh (tùy chọn); bách khoa lịch sử; giọng nói tiếng Việt; chế độ tiết kiệm pin |
| **Could** | Giới hạn 12 kho trên bản đồ Đàng Trong; Lũy cấp cao |
| **Won't (1.0)** | Giai đoạn III và Nam tiến; Mạc, Hà Lan, Bồ Đào Nha chơi được; nhiều người chơi; bản PC; nhiệm vụ 8 |

## 17. Khoảng trống còn mở (theo Nam Bắc mục 10)

- [ ] Tra cứu phe Mạc (cho sau phát hành).
- [ ] Tra binh chế Lê – Trịnh. Hiện đang mượn cách tổ chức của Nguyễn.
- [ ] Chỉnh chỉ số và công thức giá sau playtest. GDD v2 mới đặt giá trị khởi điểm.
- [ ] Chốt danh sách 40 nghiên cứu sau playtest.
- [ ] Thử trần 800 quân trên máy tầm trung (S0.T06, S18.T01).
- [ ] Nhờ người hiểu sử duyệt tên, lời thoại, hình ảnh công trình và trang phục (S17.T02).

**Rủi ro:**
- Số liệu sử không dùng làm số cứng trong game.
- Năm trận lệch giữa các nguồn.
- Cân bằng hai phe (Trịnh đông quân, Nguyễn giỏi phòng thủ) phải playtest sớm.
- Hiệu năng khi có 800 quân.
- Tính nhạy cảm của đề tài nội chiến.
