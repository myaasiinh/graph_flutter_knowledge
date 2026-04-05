import 'package:flutter/material.dart';
import 'package:flutter_graph/flutter_graph.dart';
import 'data/mock_graph_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_graph Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const DynamicGraphPage(),
    );
  }
}

class DynamicGraphPage extends StatefulWidget {
  const DynamicGraphPage({super.key});

  @override
  State<DynamicGraphPage> createState() => _DynamicGraphPageState();
}

class _DynamicGraphPageState extends State<DynamicGraphPage> {
  final TextEditingController _searchController = TextEditingController();
  final MockGraphService _graphService = MockGraphService();
  
  // Current data state
  List<GraphNode> _currentNodes = [];
  List<GraphEdge> _currentEdges = [];
  String? _mainNodeId;
  int _layoutSeed = 42;
  String _statusMessage = 'Search for "AI", "Graph", "Quantum"...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _performSearch('AI');
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Searching in massive knowledge pool...';
    });

    final result = await _graphService.search(query);
    
    setState(() {
      _isLoading = false;
      _currentNodes = (result['nodes'] as List?)?.cast<GraphNode>() ?? [];
      _currentEdges = (result['edges'] as List?)?.cast<GraphEdge>() ?? [];
      _mainNodeId = result['mainNodeId'] as String?;
      _layoutSeed = result['seed'] as int? ?? query.hashCode;
      
      _statusMessage = _currentNodes.isEmpty 
          ? 'No matches found in knowledge pool.' 
          : 'Showing Top ${_currentNodes.length} results for "$query"';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Explorer'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search (AI, Quantum, Flutter)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isLoading ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ) : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: _performSearch,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Opacity(
                opacity: _isLoading ? 0.3 : 1.0,
                child: _currentNodes.isEmpty && !_isLoading
                  ? const Center(child: Text('No nodes to display'))
                  : GraphWidget(
                      nodes: _currentNodes,
                      edges: _currentEdges,
                      mainNodeId: _mainNodeId,
                      onNodeTap: (node) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Focused: ${node.label}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      config: GraphConfiguration(
                        layoutSeed: _layoutSeed,
                        repulsionStrength: 1.2,
                        attractionStrength: 0.9,
                      ),
                    ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.w600, 
                      color: theme.colorScheme.primary
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
