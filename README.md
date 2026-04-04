# Tutorial 7 - Basic 3D Game Mechanics (Godot 4)

## Tujuan Implementasi
- Membuat kontrol karakter 3D yang responsif (jalan, lari, jongkok, lompat, dan mouse look).
- Menerapkan pola interaksi berbasis raycast + class dasar `Interactable`.
- Menambahkan sistem inventory berbasis `Dictionary` dengan UI.
- Menghubungkan pickup item ke inventory dan efek penggunaan item.
- Membuat trigger area untuk transisi scene (level ke win screen).

## Struktur Scene dan Script Utama
- Scene utama: `scenes/Level 1.tscn`.
- Player: `scenes/Player.tscn` dengan script `scripts/player.gd`.
- Raycast interaksi: `scripts/ray_cast_3d.gd` pada `RayCast3D` di kamera player.
- Base interaksi: `scripts/Interactable.gd`.
- Item pickup: `scenes/PickupItem.tscn` + `scripts/PickupItem.gd`.
- UI inventory: `scenes/InventoryUI.tscn` + `scripts/InventoryUI.gd`.
- Trigger perpindahan scene: `scenes/AreaTrigger.tscn` + `scripts/Goal.gd`.
- Layar akhir: `scenes/Win Screen.tscn` + `scripts/WinScreen.gd`.

## Proses Pengerjaan

### 1. Menyiapkan Proyek dan Scene Utama
1. Membuat/menentukan scene utama `Level 1` sebagai entry point (`run/main_scene` pada `project.godot`).
2. Menempatkan instance player, world, area goal, pit, pickup item, dan inventory UI di scene utama.
3. Menentukan aksi input utama pada `project.godot`:
   - `movement_forward/backward/left/right` (WASD)
   - `jump` (Space)
   - `interact` (E)
4. Menambahkan input tambahan via script (`player.gd` dan `InventoryUI.gd`) agar aman jika aksi belum terdaftar:
   - `sprint` (Shift)
   - `crouch` (Ctrl)
   - `inventory_toggle` (Tab)

### 2. Implementasi Kontrol Player FPS (`scripts/player.gd`)
1. Menggunakan `CharacterBody3D` untuk pergerakan fisik.
2. Mengatur mouse look:
   - Rotasi horizontal di node `Head`.
   - Rotasi vertikal di `Camera3D` dengan clamp sudut agar tidak over-rotate.
3. Mengimplementasikan movement vector berdasarkan orientasi `Head`.
4. Menambahkan mode kecepatan:
   - `normal_speed`
   - `sprint_speed`
   - `crouch_speed`
5. Menambahkan transisi jongkok halus dengan interpolasi tinggi `Head`.
6. Menambahkan gravitasi dan lompat (hanya saat di lantai dan tidak jongkok).
7. Menambahkan kontrol enable/disable saat inventory dibuka (`set_controls_enabled`).

### 3. Pola Interaksi Objek (Raycast + Interactable)
1. Membuat class dasar `Interactable` sebagai kontrak method `interact()`.
2. Di `ray_cast_3d.gd`:
   - Mengecek collider yang terkena raycast.
   - Jika collider turunan `Interactable` dan tombol `interact` ditekan, panggil `interact(interactor)`.
3. Menentukan `interactor` secara dinamis dengan menelusuri parent sampai menemukan `CharacterBody3D`.

### 4. Sistem Inventory dan Item Pickup
1. Menyimpan inventory di player sebagai `Dictionary` (`item_id -> jumlah`).
2. Menyediakan method:
   - `add_to_inventory()`
   - `get_inventory()`
   - `use_inventory_item()`
3. Menambahkan sinyal `inventory_changed` agar UI sinkron saat isi inventory berubah.
4. Implementasi pickup item di `PickupItem.gd`:
   - Memastikan interactor memiliki `add_to_inventory()`.
   - Menambahkan item ke inventory.
   - Menghapus node pickup dari scene setelah berhasil diambil.
5. Menambahkan efek item contoh (`energy_cell`) di `_apply_item_effect()`:
   - Menambah `jump_power` secara bertahap dengan batas maksimum.

### 5. Implementasi UI Inventory (`scripts/InventoryUI.gd`)
1. Menggunakan `CanvasLayer` dengan panel sederhana.
2. Toggle UI dengan `Tab` (`inventory_toggle`).
3. Saat inventory dibuka:
   - Menampilkan daftar item yang sudah diurutkan.
   - Navigasi pilihan dengan `ui_up/ui_down`.
   - Gunakan item terpilih dengan `ui_accept`.
4. Menghubungkan UI ke player melalui `player_path` dan sinyal `inventory_changed`.
5. Menonaktifkan kontrol player saat UI terbuka agar input tidak bentrok.

### 6. Trigger Goal dan Transisi Scene
1. Menggunakan `Area3D` (`AreaTrigger.tscn`) untuk mendeteksi player masuk area.
2. Pada `Goal.gd`, jika body bernama `Player`:
   - Mouse mode diubah ke visible.
   - Scene berpindah menggunakan `change_scene_to_file()`.
3. Di `Level 1`, goal diarahkan ke scene `Win Screen` melalui properti `sceneName`.

### 7. Win Screen dan Alur Akhir
1. `Win Screen.tscn` menampilkan UI sederhana (Play Again?).
2. Script `WinScreen.gd`:
   - Tombol `Yes` memuat ulang `Level 1`.
   - Tombol `No` menutup game.

## Kontrol Gameplay
- `W/A/S/D`: Bergerak
- `Mouse`: Lihat sekeliling
- `Space`: Lompat
- `Shift`: Sprint
- `Ctrl`: Crouch
- `E`: Interaksi objek
- `Tab`: Buka/Tutup inventory
- `Up/Down`: Navigasi item inventory
- `Enter`: Gunakan item terpilih

## Cara Menjalankan
1. Buka proyek di Godot 4.x.
2. Pastikan scene utama adalah `scenes/Level 1.tscn` (sudah diatur di `project.godot`).
3. Jalankan proyek (`F5` / tombol Play di Godot).

## Catatan Implementasi
- Sistem inventory saat ini masih sederhana (belum ada slot visual/grid dan drag-drop).
- Efek item baru diimplementasikan untuk contoh item `energy_cell`.
- Validasi interaksi dilakukan dengan pengecekan method (`has_method`) agar script lebih aman terhadap perubahan node.

## Referensi
1. Godot Docs - CharacterBody3D (Godot 4): https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html
2. Godot Docs - RayCast3D: https://docs.godotengine.org/en/stable/classes/class_raycast3d.html
3. Godot Docs - Area3D: https://docs.godotengine.org/en/stable/classes/class_area3d.html
4. Godot Docs - Input & InputMap: https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html
5. Godot Docs - Signals: https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
6. Godot Docs - CanvasLayer: https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html
7. Godot Docs - SceneTree scene change: https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-change-scene-to-file
