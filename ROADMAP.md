# 🧬 NeuroEvo Lab — Roadmap

## Legend

- [ ] Not started
- [/] In progress
- [x] Completed

---

## Phase 1 — Foundation (Current)

### Project Setup
- [x] Flutter project created
- [x] Directory structure
- [x] README with full spec
- [x] ROADMAP with checklists
- [ ] GitHub repo created + initial commit
- [ ] CI/CD (basic GitHub Actions for build)

### NEAT Engine (Core)
- [ ] `activator.dart` — Activation functions (sigmoid, tanh, relu, gaussian)
- [ ] `neuron.dart` — Node types and storage
- [ ] `connection.dart` — Synapse with innovation number, enable/disable
- [ ] `genome.dart` — Collection of nodes + connections
- [ ] `species.dart` — Compatibility distance, speciation, stagnation
- [ ] `population.dart` — Evolution loop (tournament select, crossover, mutate)
- [ ] XOR test — Validate NEAT learns XOR

### Base Simulation Framework
- [ ] `simulation.dart` — Abstract base class
- [ ] `simulation_config.dart` — Config model
- [ ] `evolution_state.dart` — Generation, fitness tracking
- [ ] `simulation_canvas.dart` — CustomPaint wrapper with FPS control
- [ ] `controls_bar.dart` — Play/Pause, Speed slider, Reset
- [ ] `info_overlay.dart` — Generation/alive/fitness display
- [ ] `fitness_graph.dart` — Best + avg fitness line chart
- [ ] `neat_visualizer.dart` — Live neural network visualization

### Home Screen
- [ ] `simulation_meta.dart` — Model for simulation metadata
- [ ] `simulation_card.dart` — Card widget for each simulation
- [ ] `home_screen.dart` — Grid layout with all simulations
- [ ] Locked/unlocked state for future simulations

### Simulation 1: Self-driving Cars 🚗
- [ ] `car.dart` — Car with position, angle, speed, 5 ray sensors
- [ ] `sensor.dart` — Ray casting to detect walls/edges
- [ ] `track.dart` — Waypoint-based closed loop with borders
- [ ] `car_painter.dart` — Canvas rendering (cars, sensors, track)
- [ ] `car_simulation.dart` — Wire NEAT → CarPhysics → Fitness
- [ ] Controls + info integration
- [ ] Fitness graph integration

### Simulation 2: Flappy Bird AI 🐦
- [ ] `bird.dart` — Bird physics (gravity, flap, collision)
- [ ] `pipe.dart` — Pipe obstacles generation
- [ ] `flappy_painter.dart` — Canvas rendering
- [ ] `flappy_simulation.dart` — NEAT inputs (bird y, pipe gap, pipe x) → flap
- [ ] Controls + info + graph integration

### Simulation 3: Smart Rockets 🚀
- [ ] `rocket.dart` — Rocket physics
- [ ] `obstacle.dart` / `target.dart`
- [ ] `smart_rocket_painter.dart` — Canvas rendering
- [ ] `smart_rocket_simulation.dart` — Pure GA evolution
- [ ] Controls + info + graph integration

---

## Phase 2 — Expansion

### Simulation 4: Maze Solver 🧩
- [ ] Maze generation algorithm (DFS / recursive backtracking)
- [ ] Maze painter
- [ ] NEAT or Q-Learning agent
- [ ] Player-vs-AI mode (optional)

### Simulation 5: CartPole ⚖️
- [ ] Pole physics (pendulum on cart)
- [ ] NEAT controller
- [ ] Classic RL benchmark visualization

### Simulation 6: Soccer ⚽
- [ ] Multi-agent NEAT
- [ ] Team competition
- [ ] Passing, shooting, positioning

### App Enhancements
- [ ] Settings screen (global + per-simulation)
- [ ] Save/load best genome to local storage
- [ ] Simulation selector drawer improvement
- [ ] Dark mode
- [ ] Track editor for Self-driving Cars (draw your own track)
- [ ] NEAT network animation (signal flowing through nodes)

---

## Phase 3 — Advanced

### Simulation 7: Mountain Car ⛰️
- [ ] Q-Learning agent
- [ ] Continuous state/action space visualization

### Simulation 8: Predator vs Prey 🦁🐰
- [ ] Multi-agent pursuit-evasion
- [ ] Swarm behavior

### Simulation 9: Creature Walker 🦿
- [ ] 2D physics (joints, bones, muscles)
- [ ] NEAT controls muscle activation
- [ ] Evolve walking/running/jumping gaits

### Platform & Quality
- [ ] Tablet layout support
- [ ] Web support (Flutter Web)
- [ ] Desktop support (macOS, Windows, Linux)
- [ ] Performance profiling + optimization
- [ ] Accessibility (screen reader, contrast)

---

## Future Ideas

- Upload/share best genomes between users
- Challenge mode: beat the AI after it trains
- Real-time network topology export (image/JSON)
- Tutorial/onboarding flow explaining each algorithm
- Record simulation replay
- Benchmark mode: compare algorithms (NEAT vs Q-Learning vs GA)

---

## Workflow

For every change:
1. **Branch**: feature branch from `main`
2. **PR**: descriptive title + changes summary
3. **Test**: run `flutter analyze` + manual sanity check
4. **Merge**: squash-merge to `main`

---

*Last updated: 2026-07-29*
