# noctalia — bản vá pairing Bluetooth (DisplayPasskey)

## Vấn đề

Ghép nối bàn phím Bluetooth (Logitech K380/MX Keys, bàn phím BLE nói chung) với
Noctalia v5 không hiện gì cả: không có dãy số để gõ, không thông báo, pairing
lặng lẽ timeout.

Bàn phím là thiết bị *KeyboardOnly*, nên BlueZ chọn mô hình "Passkey Entry":
máy tính **hiển thị** 6 chữ số, người dùng gõ dãy đó **trên bàn phím** rồi Enter.
BlueZ báo bằng `org.bluez.Agent1.DisplayPasskey`. Chuột (MX Master 3S) đi luồng
`RequestConfirmation` nên không dính lỗi này — đó là lý do chuột pair được còn
bàn phím thì không.

## Nguyên nhân gốc (v5.0.0-beta.10, vẫn còn trên `main`)

1. `src/dbus/bluetooth/bluetooth_agent.cpp` — `DisplayPasskey` là fire-and-forget
   nên agent không giữ reply context; `hasPendingRequest()` chỉ nhìn reply context
   nên trả `false`.
2. `src/shell/control_center/tabs/bluetooth_tab.cpp` — `syncPairingCard()` bật/tắt
   card pairing đúng bằng `hasPendingRequest()`, nên với bàn phím card **luôn ẩn**.
3. `src/app/application_services.cpp` — callback pairing chỉ refresh khi Control
   Center đang mở; pairing do thiết bị khởi tạo không hiện gì cả.

## Bản vá làm gì

- `hasPendingRequest()` tính cả yêu cầu chỉ-hiển-thị → card pairing hiện ra.
- `Cancel`/`Release` dọn trạng thái chỉ-hiển-thị; tab tự ẩn card khi thiết bị đã
  `Paired` (BlueZ không gọi lại gì khi pairing thành công).
- Nút "Từ chối" trên prompt chỉ-hiển-thị gọi `Device1.CancelPairing` thật, thay vì
  chỉ xóa trạng thái phía UI.
- Hiện tiến độ `(n/6)` — số chữ số bàn phím đã gõ, lấy từ tham số `entered`.
- Có yêu cầu pairing mà không panel nào đang mở → tự mở Control Center ở tab
  Bluetooth (giống cách polkit agent tự bật panel của nó).

## Cách build / cài

```sh
sudo pacman -S --needed meson ninja nlohmann-json stb wayland-protocols
cd ~/.local/src/noctalia-bt-fix
makepkg -si
```

`pkgrel=1.1` khiến gói vá này "mới hơn" gói chính thức `-1`, nên `pacman -Syu`
sẽ **không** ghi đè nó bằng bản beta.10 chính thức.

## Khi upstream ra bản mới

```sh
cd ~/.local/src/noctalia-bt-fix && ./update.sh
```

Script đồng bộ `pkgver`/checksum từ PKGBUILD chính thức của Arch rồi thử áp patch
lên source bản mới:

- **áp được** → `makepkg -si` để build lại bản vá.
- **không áp được** → nhiều khả năng upstream đã sửa/đổi vùng code này. Kiểm tra
  `hasPendingRequest()` trong `bluetooth_agent.cpp`; nếu đã tính `DisplayPasskey`
  thì chạy `sudo pacman -S noctalia` để quay về gói chính thức và xóa thư mục này.

Patch cố ý nhỏ và tách rời (3 file, 5 hunk) để rebase rẻ và để việc "bỏ patch"
khi upstream fix chỉ là xóa một thư mục.

## Kiểm chứng

```sh
noctalia msg log-level-set debug   # xem log agent khi pair
bluetoothctl devices               # kiểm tra thiết bị sau khi pair
```
