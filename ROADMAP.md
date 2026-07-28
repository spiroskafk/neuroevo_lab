# NeuroEvo Lab — Roadmap

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

### NEAT Engine (Core)
- [x] `activator.dart` — tanh activation function
- [x] `neuron.dart` — Node types and storage
- [x] `connection.dart` — Synapse with innovation number, enable/disable
- [x] `genome.dart` — Collection of nodes + connections, forward pass, topological sort
- [x] `species.dart` — Compatibility distance, speciation, stagnation
- [x] `population.dart` — Evolution loop (select, crossover, mutate)
- [x] Innovation number registry (shared across genomes)
- [x] Global elitism (best genome preserved across species)

### Base Simulation Framework
- [x] `simulation.dart` — Abstract base class
- [x] `simulation_config.dart` — Config model
- [x] `evolution_state.dart` — Generation, fitness, species tracking
- [x] `simulation_canvas.dart` — CustomPaint wrapper
- [x] `controls_bar.dart` — Play/Pause, Speed, Analysis, NN toggle, Reset
- [x] `info_overlay.dart` — Generation/alive/laps/species display
- [x] `fitness_graph.dart` — Best + avg fitness line chart
- [x] `neural_network_painter.dart` — Live NN topology overlay
- [x] `analysis_sheet.dart` — Species/complexity history, per-species detail

### Home Screen
- [x] `simulation_meta.dart` — Model for simulation metadata
- [x] `simulation_card.dart` — Card widget for each simulation
- [x] `home_screen.dart` — Grid layout with locked/unlocked state

### Simulation 1: Self-driving Cars
- [x] `car.dart` — Car physics, 5+ ray sensors, checkpoint tracking, stagnation timeout
- [x] `track.dart` — Waypoint-based closed loop with borders
- [x] `car_painter.dart` — Canvas rendering (cars, sensors, track)
- [x] `car_simulation.dart` — NEAT wiring, fitness calc (laps + checkpoint based)
- [x] Controls + info + graph integration
- [x] Species diversity fix (innovation sharing)

### Simulation 2: Flappy Bird AI
- [/] `bird.dart` — Bird physics (gravity, flap, collision)
- [/] `pipe.dart` — Pipe obstacles generation
- [/] `flappy_painter.dart` — Canvas rendering
- [/] `flappy_simulation.dart` — NEAT inputs (bird y, pipe gap, pipe x) → flap
- [ ] Controls + info + graph integration

### Simulation 3: Smart Rockets
- [ ] `rocket.dart` — Rocket physics
- [ ] `obstacle.dart` / `target.dart`
- [ ] `smart_rocket_painter.dart` — Canvas rendering
- [ ] `smart_rocket_simulation.dart` — Pure GA evolution

---

## Phase 2 — Expansion

### Simulation 4: Maze Solver
- [ ] Maze generation algorithm (DFS / recursive backtracking)
- [ ] Maze painter
- [ ] NEAT or Q-Learning agent
- [ ] Player-vs-AI mode (optional)

### Simulation 5: CartPole
- [ ] Pole physics (pendulum on cart)
- [ ] NEAT controller
- [ ] Classic RL benchmark visualization

### Simulation 6: Soccer
- [ ] Multi-agent NEAT
- [ ] Team competition
- [ ] Passing, shooting, positioning

### App Enhancements
- [ ] Save/load run data to local storage
- [ ] Run browser + detail view
- [ ] Compare mode (2+ runs)
- [ ] NEAT parameter sliders from UI
- [ ] Settings screen (global + per-simulation)
- [ ] Track editor for Self-driving Cars
- [ ] NEAT network animation (signal flowing through nodes)

---

## Phase 3 — Advanced

### Simulation 7: Mountain Car
- [ ] Q-Learning agent
- [ ] Continuous state/action space visualization

### Simulation 8: Predator vs Prey
- [ ] Multi-agent pursuit-evasion
- [ ] Swarm behavior

### Simulation 9: Creature Walker
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
