import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:graph_flutter_knowledge/graph_flutter_knowledge.dart';

void main() {
  test('GraphNode and GraphEdge model instantiation', () {
    const node = GraphNode(id: '1', label: 'Node 1');
    const edge = GraphEdge(sourceId: '1', targetId: '2');

    expect(node.id, '1');
    expect(edge.sourceId, '1');
  });

  testWidgets('GraphWidget can be built', (WidgetTester tester) async {
    final nodes = [
      const GraphNode(id: '1', label: 'Root'),
      const GraphNode(id: '2', label: 'Leaf'),
    ];
    final edges = [
      const GraphEdge(sourceId: '1', targetId: '2'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GraphWidget(
            nodes: nodes,
            edges: edges,
          ),
        ),
      ),
    );

    expect(find.byType(GraphWidget), findsOneWidget);
  });
}
