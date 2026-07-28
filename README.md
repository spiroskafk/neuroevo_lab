# 🧬 NeuroEvo Lab

Μια **συλλογή από interactive simulations** για κινητά (Android/iOS) που δείχνουν αλγόριθμους μάθησης σε δράση — NEAT, Genetic Algorithms, Q-Learning, και Multi-agent systems.

Built with **Flutter**. Zero external AI/ML dependencies — όλοι οι αλγόριθμοι γραμμένοι από το μηδέν.

---

## Screens

### 1. Home Screen — Library

Grid with simulation cards. Tap to launch.

| Icon | Simulation | Algorithm | Status |
|------|-----------|-----------|--------|
| 🚗 | Self-driving Cars | NEAT | ✅ Phase 1 |
| 🐦 | Flappy Bird AI | NEAT | ✅ Phase 1 |
| 🚀 | Smart Rockets | Pure GA | ✅ Phase 1 |
| 🧩 | Maze Solver | NEAT / Q-Learning | 🔜 Phase 2 |
| ⚖️ | CartPole | NEAT | 🔜 Phase 2 |
| ⚽ | Soccer | Multi-agent NEAT | 🔜 Phase 2 |
| ⛰️ | Mountain Car | Q-Learning | 🔜 Phase 3 |
| 🦁🐰 | Predator vs Prey | Multi-agent | 🔜 Phase 3 |

### 2. Simulation Screen — Runner

Shared screen for all simulations:

```
┌────────────────────────────────┐
│ ← Cars    Gen:47  Best:891    │
│  ┌──────────────────────────┐  │
│  │   ╔══════════╗           │  │
│  │   ║  🚗🏆🚗   ║           │  │
│  │   ║    🚗     ║           │  │
│  │   ╚══════════╝           │  │
│  └──────────────────────────┘  │
│  ▶ ⏩2x ⏩5x ⟲ ⚙️              │
│  ┌── Fitness ──────────────┐  │
│  │  ▁▃▆██▇▆▅▄▃▂▁ 891      │  │
│  │  ▁▁▂▃▄▄▄▃▂▁  512       │  │
│  └──────────────────────────┘  │
│  [📊 Network]                  │
└────────────────────────────────┘
```

- **Canvas** renders simulation in real-time (CustomPainter)
- **Controls**: Play/Pause, Speed (1x/2x/5x), Reset, Settings
- **Info**: Generation counter, alive count, best fitness
- **Fitness Graph**: best + avg fitness over generations
- **Network Visualizer**: live NEAT neural network structure

### 3. Settings Panel

Per-simulation adjustable parameters:
- Population size
- Mutation rate
- Crossover rate
- Max generations
- Simulation-specific params (track difficulty, obstacle count, etc.)

---

## Architecture

```
lib/
  main.dart                     # Entry point
  app.dart                      # MaterialApp with theme, routes

  core/                         # Algorithm engines
    neat/                       # NEAT (NeuroEvolution of Augmenting Topologies)
      genome.dart               # Connection genes + node genes
      neuron.dart               # Input/hidden/output types
      connection.dart           # Synapse with innovation number
      species.dart              # Compatibility distance, speciation
      population.dart           # Evolution loop (select, crossover, mutate)
      activator.dart            # Activation functions (sigmoid, tanh, relu)

    ga/                         # Pure Genetic Algorithm
      individual.dart           # GA individual (fixed genome)
      ga_population.dart        # GA evolution loop

    qlearning/                  # Q-Learning (future)
      q_table.dart
      q_agent.dart

  simulations/
    base/
      simulation.dart           # Abstract base: init(), update(), render(), evolve()
      simulation_config.dart    # Config model
      evolution_state.dart      # Generation, fitness, alive count

    self_driving/               # NEAT cars
      car.dart                  # Position, angle, speed, sensors
      track.dart                # Waypoint-based closed loop
      sensor.dart               # Ray casting distance detection
      car_simulation.dart       # Simulation implementation
      car_painter.dart          # CustomPainter rendering

    flappy_bird/                # NEAT birds (Phase 2)
    smart_rockets/              # GA rockets (Phase 2)

  screens/
    home_screen.dart            # Library grid
    simulation_screen.dart      # Shared runner

  widgets/
    simulation_canvas.dart      # CustomPaint wrapper
    controls_bar.dart           # ▶ ⏩ ⟲
    info_overlay.dart           # Generation, alive, fitness
    fitness_graph.dart          # CustomPainter chart
    neat_visualizer.dart        # NN structure visualization
    simulation_card.dart        # Home screen card
    parameter_panel.dart        # ⚙️ settings

  models/
    simulation_meta.dart        # id, title, icon, description, status

  utils/
    math_utils.dart             # Vector math, interpolation
```

---

## NEAT Engine — Details

Built from scratch:

- **Input nodes**: simulation-specific (sensor distances, speed, angle, bias)
- **Output nodes**: simulation-specific (acceleration, steering / flap / steer)
- **Hidden nodes**: evolve dynamically via add_node mutation
- **Innovation numbers**: global counter, one per new connection/node
- **Speciation**: topological + weight similarity via compatibility distance
- **Selection**: tournament selection within species (elitism per species)
- **Crossover**: aligned by innovation numbers; disjoint/excess genes from fitter parent
- **Mutation**: weight perturbation (±gaussian), add node (split connection), add connection (new link), toggle enable/disable

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.44+ |
| **Language** | Dart 3.12+ |
| **Rendering** | CustomPainter (Canvas API) |
| **State** | ChangeNotifier + ListenableBuilder |
| **AI/ML** | Custom implementation (no external packages) |
| **Charts** | CustomPainter (no charting packages) |
| **Platform** | Android, iOS (desktop/web later) |

---

## Getting Started

```bash
git clone https://github.com/spiroskafk/neuroevo_lab.git
cd neuroevo_lab
flutter pub get
flutter run
```

---

## License

MIT
