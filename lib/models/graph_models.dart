import 'package:flutter/material.dart';

/// Represents a node in the Graph.
class GraphNode {
  const GraphNode({
    required this.id,
    required this.label,
    this.color,
    this.data,
  });

  /// Unique identifier for the node.
  final String id;

  /// Text displayed near the node.
  final String label;

  /// Optional custom color for this specific node.
  final Color? color;

  /// Optional extra data associated with the node.
  final Map<String, dynamic>? data;
}

/// Represents an edge (relationship) between two nodes.
class GraphEdge {
  const GraphEdge({
    required this.sourceId,
    required this.targetId,
    this.label,
    this.isDashed = false,
    this.color,
  });

  /// The ID of the starting node.
  final String sourceId;

  /// The ID of the ending node.
  final String targetId;

  /// Optional text label for the edge.
  final String? label;

  /// Whether the edge should be drawn as a dashed line.
  final bool isDashed;

  /// Optional custom color for this specific edge.
  final Color? color;
}
