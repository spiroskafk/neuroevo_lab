# NeuroEvo Lab

**Interactive mobile simulations** (Android/iOS) demonstrating AI learning algorithms — NEAT, Genetic Algorithms, Q-Learning, and Multi-agent systems.

Built with **Flutter**. Zero external AI/ML dependencies — all algorithms hand-written in Dart.

---

## Simulations

| Icon | Simulation | Algorithm | Status |
|------|-----------|-----------|--------|
| Car | Self-driving Cars | NEAT | Released |
| Bird | Flappy Bird AI | NEAT | Building |
| Rocket | Smart Rockets | Pure GA | Planned |
| Maze | Maze Solver | NEAT / Q-Learning | Planned |
| Weight | CartPole | NEAT | Planned |
| Soccer | Soccer | Multi-agent NEAT | Planned |
| Mountain | Mountain Car | Q-Learning | Planned |
| Predator/Prey | Predator vs Prey | Multi-population NEAT | Building |

## Simulation Screen

Shared runner for all simulations:

- **Canvas** renders simulation in real-time (CustomPainter)
- **Controls**: Play/Pause, Speed (1x/2x/5x), Analysis, NN viz toggle, Reset
- **Info**: Generation, alive count, best laps, species count
- **Fitness Graph**: best + avg fitness with 1-lap target line
- **Analysis Sheet**: species history, complexity chart, per-species table
- **NN Overlay**: live best-genome topology (connection weights, neuron activations)

## Architecture

```
lib/
  main.dart
  app.dart

  core/neat/                   # NEAT engine
    genome.dart                # Neuron + connection genes
    neuron.dart                # Bias/input/hidden/output types
    connection.dart            # Synapse with innovation number
    species.dart               # Compatibility distance, stagnation
    population.dart            # Evolution loop (select, crossover, mutate)
    activator.dart             # tanh activation

  simulations/
    base/
      simulation.dart          # Abstract base class
      simulation_config.dart
      evolution_state.dart     # Generation, fitness, species tracking

    self_driving/              # NEAT cars
      car.dart                 # Physics, ray sensors, checkpoint tracking
      track.dart               # Waypoint-based closed loop
      car_simulation.dart      # NEAT wiring, fitness calc
      car_painter.dart         # Canvas rendering

    flappy_bird/               # NEAT birds (in progress)

  screens/
    home_screen.dart           # Simulation library grid
    simulation_screen.dart     # Shared runner with controls

  widgets/
    simulation_canvas.dart
    controls_bar.dart
    info_overlay.dart
    fitness_graph.dart
    simulation_card.dart
    analysis_sheet.dart        # Species/complexity analysis
    neural_network_painter.dart # Live NN topology overlay

  models/
    simulation_meta.dart
```

## NEAT Engine

Custom implementation from scratch:

- **Innovation numbers**: global registry, one per new structure
- **Speciation**: compatibility distance with N=1 for <20 connections
- **Selection**: tournament within species + global elitism
- **Crossover**: aligned by innovation numbers
- **Mutation**: weight perturbation, add node, add connection, toggle

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| Language | Dart |
| Rendering | CustomPainter |
| State | ChangeNotifier + ListenableBuilder |
| AI/ML | Custom (no external packages) |
| Charts | CustomPainter |

## Getting Started

```bash
git clone https://github.com/spiroskafk/neuroevo_lab.git
cd neuroevo_lab
flutter pub get
flutter run
```

## License

MIT
