import 'package:flutter/material.dart';

/// Configuration options for the Graph widget.
class GraphConfiguration {
  const GraphConfiguration({
    this.repulsionStrength = 1.1,
    this.attractionStrength = 1.0,
    this.iterations = 90,
    this.coolingRate = 0.95,
    this.minNodeRadius = 12.0,
    this.maxNodeRadius = 40.0,
    this.defaultNodeColor = const Color(0xFF0EA5E9),
    this.mainNodeColor = const Color(0xFFFB7185),
    this.highlightColor = const Color(0xFFF97373),
    this.edgeColor = const Color(0xFF38BDF8),
    this.labelStyle = const TextStyle(
      fontSize: 11,
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    this.minScale = 0.5,
    this.maxScale = 2.5,
    this.boundaryMargin = const EdgeInsets.all(40),
    this.layoutSeed = 42,
  });

  /// The random seed used for the initial layout generation.
  /// Set this dynamically per search to ensure unique graph positions.
  final int layoutSeed;

  /// The strength of the repulsion force between all nodes.
  final double repulsionStrength;

  /// The strength of the attraction force along edges.
  final double attractionStrength;

  /// The number of simulation iterations to compute.
  final int iterations;

  /// The cooling factor or temperature reduction per iteration.
  final double coolingRate;

  /// Minimum radius for node circles.
  final double minNodeRadius;

  /// Maximum radius for node circles.
  final double maxNodeRadius;

  /// Default color for standard nodes.
  final Color defaultNodeColor;

  /// Color for the main/highlighted node.
  final Color mainNodeColor;

  /// Color used for specific relationship types (e.g., citation).
  final Color highlightColor;

  /// Default color for graph edges.
  final Color edgeColor;

  /// Text style used for node labels.
  final TextStyle labelStyle;

  /// Minimum zoom scale for InteractiveViewer.
  final double minScale;

  /// Maximum zoom scale for InteractiveViewer.
  final double maxScale;

  /// Margin around the graph boundaries.
  final EdgeInsets boundaryMargin;
}
