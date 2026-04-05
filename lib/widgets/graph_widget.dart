import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../models/graph_models.dart';
import '../configs/graph_configuration.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({
    super.key,
    required this.nodes,
    required this.edges,
    this.mainNodeId,
    this.onNodeTap,
    this.config = const GraphConfiguration(),
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? mainNodeId;
  final Function(GraphNode)? onNodeTap;
  final GraphConfiguration config;

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  _GraphLayout? _lastLayout;

  void _handleTap(TapUpDetails details, Size size) {
    if (_lastLayout == null || widget.onNodeTap == null) return;

    final tapPos = details.localPosition;
    
    // Check nodes (hit testing)
    for (final node in widget.nodes) {
      final center = _lastLayout!.positions[node.id];
      final radius = _lastLayout!.radii[node.id] ?? 20.0;
      if (center != null) {
        final dist = (tapPos - center).distance;
        if (dist <= radius) {
          widget.onNodeTap!(node);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Compute layout once or when data changes for efficiency
        _lastLayout = _computeLayout(
          size,
          widget.nodes,
          widget.edges,
          widget.mainNodeId,
          widget.config,
        );

        return GestureDetector(
          onTapUp: (details) => _handleTap(details, size),
          child: InteractiveViewer(
            constrained: true,
            boundaryMargin: widget.config.boundaryMargin,
            minScale: widget.config.minScale,
            maxScale: widget.config.maxScale,
            child: CustomPaint(
              size: size,
              painter: _GraphPainter(
                nodes: widget.nodes,
                edges: widget.edges,
                mainNodeId: widget.mainNodeId,
                config: widget.config,
                layout: _lastLayout!,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GraphLayout {
  _GraphLayout(this.positions, this.radii);

  final Map<String, Offset> positions;
  final Map<String, double> radii;
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    required this.nodes,
    required this.edges,
    required this.mainNodeId,
    required this.config,
    required this.layout,
  });

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final String? mainNodeId;
  final GraphConfiguration config;
  final _GraphLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    // Use pre-computed layout from state
    // Draw edges first
    for (final edge in edges) {
      final p1 = layout.positions[edge.sourceId];
      final p2 = layout.positions[edge.targetId];
      if (p1 == null || p2 == null) continue;

      final paint = Paint()
        ..color = (edge.color ?? config.edgeColor).withValues(alpha: 0.75)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      if (edge.isDashed) {
        _drawDashedLine(canvas, p1, p2, paint);
      } else {
        canvas.drawLine(p1, p2, paint);
      }
    }

    final placedLabelRects = <Rect>[];

    // Draw nodes on top
    for (final node in nodes) {
      final center = layout.positions[node.id];
      if (center == null) continue;
      final radius = layout.radii[node.id] ?? 16.0;

      final bgColor = (node.id == mainNodeId)
          ? config.mainNodeColor
          : (node.color ?? config.defaultNodeColor);

      // Draw shadow
      canvas.drawCircle(
        center.translate(1, 2),
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
      );

      // Circle node
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = bgColor
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      final labelPainter = TextPainter(
        text: TextSpan(text: node.label, style: config.labelStyle),
        maxLines: 1,
        ellipsis: '…',
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: radius * 3.5);

      var textOffset = Offset(
        center.dx - labelPainter.width / 2,
        center.dy + radius + 7,
      );

      var labelRect =
          textOffset & Size(labelPainter.width, labelPainter.height);

      const labelPadding = 4.0;
      var iterations = 0;
      while (placedLabelRects.any((rect) => rect.overlaps(labelRect)) &&
          iterations < 5) {
        labelRect = labelRect.translate(0, labelPainter.height + labelPadding);
        iterations++;
      }

      placedLabelRects.add(labelRect);
      labelPainter.paint(canvas, labelRect.topLeft);
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) => 
    oldDelegate.layout != layout || oldDelegate.nodes != nodes || oldDelegate.edges != edges;
}

_GraphLayout _computeLayout(
  Size size,
  List<GraphNode> nodes,
  List<GraphEdge> edges,
  String? mainNodeId,
  GraphConfiguration config,
) {
  final n = nodes.length;
  if (n == 0) return _GraphLayout({}, {});

  final area = size.width * size.height;
  final k = math.sqrt(area / n) * config.repulsionStrength;
  final center = Offset(size.width / 2, size.height / 2);
  final initialRadius = 0.4 * math.min(size.width, size.height);

  final positions = <String, Offset>{};
  final disp = <String, Offset>{};
  final rand = math.Random(config.layoutSeed);

  for (var i = 0; i < n; i++) {
    final angle = 2 * math.pi * i / n;
    final id = nodes[i].id;
    positions[id] =
        center +
        Offset(
          initialRadius * math.cos(angle),
          initialRadius * math.sin(angle),
        );
    disp[id] = Offset.zero;
  }

  double t = math.min(size.width, size.height) / 2.5;

  for (var iter = 0; iter < config.iterations; iter++) {
    for (var i = 0; i < n; i++) {
      disp[nodes[i].id] = Offset.zero;
    }

    // Repulsive forces
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final v = nodes[i].id;
        final u = nodes[j].id;
        var delta = positions[v]! - positions[u]!;
        var dist = delta.distance;
        if (dist == 0) {
          delta = Offset(
            (rand.nextDouble() - 0.5) * 0.01,
            (rand.nextDouble() - 0.5) * 0.01,
          );
          dist = delta.distance;
        }
        final force = (k * k) / (dist == 0 ? 0.01 : dist);
        final rep = delta / (dist == 0 ? 0.01 : dist) * force;
        disp[v] = disp[v]! + rep;
        disp[u] = disp[u]! - rep;
      }
    }

    // Attractive forces
    for (final edge in edges) {
      final v = edge.sourceId;
      final u = edge.targetId;
      if (positions[v] == null || positions[u] == null) continue;
      final delta = positions[v]! - positions[u]!;
      final dist = delta.distance == 0 ? 0.01 : delta.distance;
      final force = (dist * dist) / k * config.attractionStrength;
      final attr = delta / dist * force;
      disp[v] = disp[v]! - attr;
      disp[u] = disp[u]! + attr;
    }

    // Update positions
    for (final node in nodes) {
      var d = disp[node.id]!;
      final dist = d.distance;
      if (dist > t) d = d / dist * t;
      var pos = positions[node.id]! + d;
      const margin = 45.0;
      pos = Offset(
        pos.dx.clamp(margin, size.width - margin),
        pos.dy.clamp(margin, size.height - margin),
      );
      positions[node.id] = pos;
    }
    t *= config.coolingRate;
  }

  final degree = <String, int>{};
  for (final edge in edges) {
    degree[edge.sourceId] = (degree[edge.sourceId] ?? 0) + 1;
    degree[edge.targetId] = (degree[edge.targetId] ?? 0) + 1;
  }

  final radii = <String, double>{};
  for (final node in nodes) {
    final deg = (degree[node.id] ?? 0).toDouble();
    var r = 14.0 + math.sqrt(deg + 1) * 5.5;
    if (mainNodeId != null && node.id == mainNodeId) r *= 1.5;
    radii[node.id] = r.clamp(config.minNodeRadius, config.maxNodeRadius);
  }

  return _GraphLayout(positions, radii);
}

void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
  const dashLength = 6.0;
  const gapLength = 5.0;
  final totalLength = (p2 - p1).distance;
  if (totalLength == 0) return;
  final direction = (p2 - p1) / totalLength;
  double distance = 0;
  while (distance < totalLength) {
    final start = p1 + direction * distance;
    final end = p1 + direction * math.min(distance + dashLength, totalLength);
    canvas.drawLine(start, end, paint);
    distance += dashLength + gapLength;
  }
}
