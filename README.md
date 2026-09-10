# Krystal Dance Edition
### by mrdelord | glitchprod.com

> Fork dari Uhhhhhh (STEVE-916-create) — dikustomisasi penuh untuk Krystal Dance Edition

---

## Loadstring

```lua
-- Raw loadstring
loadstring(game:HttpGet("https://raw.githubusercontent.com/mrdelord/KRYSTAL-DANCE-V1/main/source/reanim.lua"))()
```

---

## Dance Modules Bawaan (community/mrdelord)

| Nama | Deskripsi |
|------|-----------|
| **CRONOSHIFT** | Signature dance mrdelord — slide + spin + freeze |
| **Glitch Step** | Gerakan patah-patah ala glitch effect |
| **Void Wave** | Flowing wave dance khas KRYSTAL |
| **Krystal Idle** | Idle pose signature Krystal Dance Edition |

---

## Cara Install Module

1. Taruh file `.lua` dari `community/mrdelord/` ke:
   ```
   executor workspace/KrystalDanceV1/Modules/krystal_dances.lua
   ```

2. File `.anim` dan `.mp3` otomatis di-download saat pertama kali dance dipilih.

3. Refresh modules di UI → dance langsung muncul.

---

## Cara Buat Dance Sendiri

Ikuti format di `community/mrdelord/krystal_dances.lua`:

```lua
{
    name    = "Nama Dance Kamu",
    desc    = "Deskripsi singkat",
    anim    = "NamaAnim.anim",
    animUrl = "https://link-ke-file.anim",
    song    = "NamaSong.mp3",
    songUrl = "https://link-ke-file.mp3",
    volume  = 0.8,
    loopStart = 0,
    loopEnd   = 60,
    speed     = 1,
},
```

---

## Filesystem Structure

```
executor workspace/
└── KrystalDanceV1/
    ├── Modules/          ← taruh .lua module di sini
    ├── Content/
    │   ├── Anims/        ← .anim files (auto-download)
    │   ├── Sounds/       ← .mp3 files (auto-download)
    │   └── Images/
    └── tree.ehehetilde   ← save data (JSON)
```

---

## Credits

- Base engine: **Uhhhhhh** by STEVETHEREALONE (steve_internal)
- Customization & Krystal Dance Edition: **mrdelord** (glitchprod.com)
- Community dances: googlyeyes, Memeili, awesthealter1, GeometryRunC

---

*Krystal Dance Edition — still in development. Lebih banyak dance coming soon!*
