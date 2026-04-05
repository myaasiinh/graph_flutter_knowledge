# Flutter Graph 🚀

A beautiful, lightweight, and highly customizable **Force-Directed Graph** widget for Flutter. Designed to visualize complex relationships, AI knowledge bases, and neural networks with a premium aesthetic.

<img width="621" height="987" alt="Image" src="https://github.com/user-attachments/assets/89a70cd7-d1f8-461a-8a7f-2b120caa8e80" />
<img width="619" height="982" alt="Image" src="https://github.com/user-attachments/assets/1ee60fb8-3a44-4cd3-aa4c-1b96b15b5919" />
<img width="622" height="981" alt="Image" src="https://github.com/user-attachments/assets/b60ebe7f-7c8e-47a5-90b4-40d9ecc621e3" />

## 🎥 Demo Video

[Demo Program](https://github.com/user-attachments/assets/c306666c-af28-442a-bef6-0ebf753301cf)

## ✨ Features

-   **Autonomous Simulation**: Powered by the **Fruchterman-Reingold** algorithm for natural and stable node distribution.
-   **Fine-tuned Physics**: Control repulsion, attraction, and cooling rates via `GraphConfiguration`.
-   **Premium Aesthetics**: Built-in node shadowing, configurable colors, and `CustomPainter` rendering for high performance.
-   **Interaction Ready**: 
    -   🔍 **Pinch-to-zoom & Pan** out of the box using `InteractiveViewer`.
    -   👆 **High-Performance Tap Detection**: Built-in hit-testing for interactive nodes via `onNodeTap`.
-   **Generic & Decoupled**: Use your own data models by mapping them to `GraphNode` and `GraphEdge`.

---

## 🚀 Getting Started

### 1. Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  graph_flutter_knowledge: ^0.0.1+5
```

### 2. Usage

To display a graph, simply provide a list of `GraphNode` and `GraphEdge`. The widget handles the physics simulation automatically.

```dart
import 'package:graph_flutter_knowledge/graph_flutter_knowledge.dart';

GraphWidget(
  nodes: [
    GraphNode(id: 'n1', label: 'Paper AI', color: Colors.blueAccent),
    GraphNode(id: 'n2', label: 'Transformer'),
  ],
  edges: [
    GraphEdge(sourceId: 'n1', targetId: 'n2', label: 'cite', isDashed: true),
  ],
  onNodeTap: (node) => print('Tapped on ${node.label}'),
  config: GraphConfiguration(
    repulsionStrength: 1.1,
    attractionStrength: 0.9,
    layoutSeed: 42, // Set a fixed seed for deterministic layout
  ),
)
```

### 3. Reactive Data (API Integration)

The `GraphWidget` is fully reactive. When you update the nodes or edges list via `setState` (e.g., after a gRPC or REST call), the graph automatically re-simulates the layout. Use `layoutSeed` to ensure a unique visual scattering for different datasets:

```dart
// Result from your gRPC/REST service
final apiResult = await graphService.search(query);

setState(() {
  this.nodes = apiResult.nodes;
  this.edges = apiResult.edges;
  this.currentSeed = query.hashCode; // Unique seed per search term
});

// In build method...
GraphWidget(
  nodes: nodes,
  edges: edges,
  config: GraphConfiguration(
    layoutSeed: currentSeed, 
  ),
)
```

---

## 🛠 Configuration Options

### Physics & Layout
| Parameter | Default | Description |
|-----------|---------|-------------|
| `repulsionStrength` | `1.1` | How hard nodes push each other away. |
| `attractionStrength` | `1.0` | How hard connected nodes pull each other. |
| `iterations` | `90`    | Number of simulation cycles for stability. |
| `coolingRate` | `0.95`  | How fast the simulation "freezes" into position. |
| `layoutSeed`  | `42`    | Deterministic seed for initial node placement. |

### Styling
| Parameter | Default | Description |
|-----------|---------|-------------|
| `mainNodeColor` | `Color(0xFFFB7185)` | Color for the highlighted/central node. |
| `defaultNodeColor`| `Color(0xFF0EA5E9)` | Fallback color for standard nodes. |
| `edgeColor` | `Color(0xFF38BDF8)` | Default color for the relationship links. |
| `labelStyle` | `TextStyle(...)` | Style for the text displayed below nodes. |

---

## 📖 Example App

Check out the [example app](example/lib/main.dart) for a complete, production-grade demonstration:

1.  **Search Massive Knowledge Pool**: A real-world scenario showing how to handle "millions" of data points by filtering them into the Top 10 visible nodes.
2.  **Separation of Concerns (SoC)**: Learn how to isolate your API/Mock logic using the `MockGraphService` pattern.
3.  **Dynamic Rendering**: Experience how the graph automatically updates its layout when search results change.
4.  **Custom Physics**: See different `layoutSeed` values creating unique visual topologies.

To run it:
```bash
cd example
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or think of a new feature, please open an issue or submit a pull request.
