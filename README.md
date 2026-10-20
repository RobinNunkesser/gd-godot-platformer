# 🍄 gd-platformer-godot (Super Mario World 1-1 in Godot 4)

> **Didaktisches 2D-Tile-Platformer-Gegenstück** zur Vorlesung *Interaktive Grafikanwendungen (IGA)*  
> Duale Implementierung (Target 1: Godot 4 Native 2D) basierend auf demselben **Micro-GDD** wie `ts-platformer-babylonjs`.

---

## 🎯 Didaktische Ziele & Duale Architektur

Dieses Projekt demonstriert die Realisierung eines klassischen Tile-Platformers in **Godot 4 (GDScript)** auf Basis der vollständigen ASCII-Matrix des **Video Game Level Corpus (VGLC)** für *Super Mario Bros.* World 1-1 (202 Spalten $\times$ 14 Zeilen):

- **$\mathcal{O}(1)$ Kachel-Kollision:** Schnelle Zuordnung von Weltkoordinaten zu diskreten Kacheln ohne Paarvergleiche.
- **Engine-Native Physik:** Nutzung von `CharacterBody2D.move_and_slide()` für stabile Kanten- und Rampenkollisionen.
- **Game Feel & Saftigkeit:**
  - **Coyote Time (120 ms):** Sprünge nach Verlassen einer Kante bleiben für eine kurze Gnadenfrist gültig.
  - **Jump Buffering (120 ms):** Vorab-Eingaben kurz vor der Landung werden beim Bodenkontakt sofort ausgelöst.
  - **Variable Sprunghöhe:** Frühes Loslassen der Sprungtaste kappt den Aufwärtsimpuls.
- **Zustandsautomat & Highscore:** `READY`, `PLAYING`, `PAUSED`, `FALLEN`, `VICTORY` mit lokaler Persistenz (`user://mario_platformer_score.save`).

---

## 📂 Projektstruktur & Micro-GDD

```text
gd-platformer-godot/
├── docs/gdd/                   # Identische 5 Micro-GDD Bausteine
│   ├── 01_concept_and_loop.md
│   ├── 02_input_and_controls.md
│   ├── 03_architecture_dual.md
│   ├── 04_state_machine.md
│   └── 05_parameters.md
├── levels/
│   └── mario-1-1.txt           # Vollständiges VGLC World 1-1 (202 Spalten)
├── scenes/
│   ├── main.tscn               # 2D-Hauptszene (ColorRect, 2D-Kamera)
│   ├── player.tscn             # 2D CharacterBody2D Szene
│   ├── main_3d.tscn            # 2.5D-Hauptszene (PBR-Kuben, Vulkan 3D-Licht & Schatten)
│   └── player_3d.tscn          # 2.5D CharacterBody3D (Z-Achse gelockt)
├── scripts/
│   ├── config.gd               # 2D Tuning-Parameter (PlatformerConfig)
│   ├── config_3d.gd            # 3D Tuning-Parameter (PlatformerConfig3D)
│   ├── tilemap_loader.gd       # 2D ASCII Parser
│   ├── tilemap_loader_3d.gd    # 3D PBR Extrusion & Tiefenparallaxe
│   ├── player.gd               # 2D Kinematik & Sprung
│   ├── player_3d.gd            # 3D Kinematik (axis_lock_linear_z = true)
│   ├── state_manager.gd        # Finite State Machine & Highscore
│   ├── main.gd                 # 2D Game Loop
│   └── main_3d.gd              # 3D Game Loop
├── test_gameplay.gd            # Headless Unit- & Gameplay-Testrunner (2D & 3D)
└── project.godot               # Godot 4 Projektkonfiguration
```

---

## 🚀 Spiel starten

### 1. In Godot 4 Editor
1. Öffne Godot 4.3+.
2. Wähle **Import** und navigiere in diesen Ordner.
3. Starte entweder:
   - `scenes/main.tscn` für die **native 2D-Version**, oder
   - `scenes/main_3d.tscn` für die **plastische 2.5D-Version mit 3D-Licht und Schatten**.

### 2. Über die Kommandozeile
```bash
# 2D-Version starten
godot scenes/main.tscn

# 2.5D-3D-Version mit Vulkan-Licht und Parallaxe starten
godot scenes/main_3d.tscn

# Headless Unit-Tests (prüft 2D & 3D Pipelines)
godot --headless -s test_gameplay.gd
```

---

## 🎮 Steuerung

| Aktion | Tastatur |
|---|---|
| **Laufen** | `A` / `D` oder Pfeiltasten `←` / `→` |
| **Springen** | `Leertaste`, `W` oder Pfeiltaste `↑` |
| **Pause** | `P` |
| **Schnell-Reset** | `R` |

---

## 🔗 Verwandte Repositories

- **Babylon.js 2.5D Gegenstück:** [`RobinNunkesser/ts-platformer-babylonjs`](https://github.com/RobinNunkesser/ts-platformer-babylonjs)
- **Live-Demo (Web):** [https://robinnunkesser.github.io/ts-platformer-babylonjs/](https://robinnunkesser.github.io/ts-platformer-babylonjs/)
- **Vorlesung:** [Modul 10: Tile-basierte Welten & Platformer-Physik](https://robinnunkesser.github.io)
