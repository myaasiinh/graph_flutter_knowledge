import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graph_flutter_knowledge/models/graph_models.dart';

/// A service that simulates a massive knowledge base (millions of records logically)
/// but filters and returns only the most relevant subset (Top 10) for UI display.
class MockGraphService {
  final List<String> _topics = [
    'AI', 'Machine Learning', 'Deep Learning', 'Neural Network', 'Transformer', 
    'BERT', 'GPT', 'PyTorch', 'TensorFlow', 'Convolutional', 'Recurrent',
    'Quantum', 'Qubit', 'Entanglement', 'Superposition', 'Decoherence',
    'Blockchain', 'Node', 'Block', 'Cryptography', 'Decentralized', 'Web3',
    'Flutter', 'Widget', 'Dart', 'CustomPainter', 'ForceDirected', 'StateManagement'
  ];

  Future<Map<String, dynamic>> search(String query) async {
    // Simulate API network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final normalizedQuery = query.toLowerCase();
    final List<GraphNode> foundNodes = [];
    final rand = math.Random(query.hashCode);

    // Identify which topics the query touches
    final matchingTopics = _topics
        .where((t) => t.toLowerCase().contains(normalizedQuery))
        .toList();

    // Fallback if no specific topic matches
    if (matchingTopics.isEmpty && query.isNotEmpty) {
      matchingTopics.add(query);
    }

    if (matchingTopics.isEmpty) {
      return {
        'nodes': <GraphNode>[],
        'edges': <GraphEdge>[],
        'mainNodeId': null,
        'seed': query.hashCode,
      };
    }

    // Generate up to 10 nodes specifically for this search
    for (var i = 0; i < 10; i++) {
      final topic = matchingTopics[rand.nextInt(matchingTopics.length)];
      final id = 'id_${query}_$i';
      
      foundNodes.add(
        GraphNode(
          id: id,
          label: '$topic ${rand.nextInt(100)}',
          color: Colors.primaries[rand.nextInt(Colors.primaries.length)],
        ),
      );
    }

    // Create dynamic relationships (Mesh/Tree structure)
    final List<GraphEdge> foundEdges = [];
    for (var i = 1; i < foundNodes.length; i++) {
      foundEdges.add(
        GraphEdge(
          sourceId: foundNodes[i ~/ 2].id,
          targetId: foundNodes[i].id,
          label: i % 2 == 0 ? 'part of' : 'relates',
          isDashed: i % 3 == 0,
        ),
      );
      
      if (i > 3 && rand.nextDouble() > 0.6) {
        final randomTargetIdx = rand.nextInt(i);
        if (randomTargetIdx != i ~/ 2) {
          foundEdges.add(
            GraphEdge(
              sourceId: foundNodes[i].id,
              targetId: foundNodes[randomTargetIdx].id,
              color: Colors.grey.withValues(alpha: 0.5),
              isDashed: true,
            ),
          );
        }
      }
    }

    return {
      'nodes': foundNodes,
      'edges': foundEdges,
      'mainNodeId': foundNodes.isNotEmpty ? foundNodes[0].id : null,
      'seed': query.hashCode,
    };
  }
}
