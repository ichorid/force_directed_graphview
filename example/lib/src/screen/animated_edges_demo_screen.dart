import 'dart:math';

import 'package:example/src/model/user.dart';
import 'package:example/src/widget/background_grid.dart';
import 'package:example/src/widget/control_buttons.dart';
import 'package:example/src/widget/user_node.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

class AnimatedEdgesDemoScreen extends StatefulWidget {
  const AnimatedEdgesDemoScreen({super.key,});

  @override
  AnimatedEdgesDemoScreenState createState() => AnimatedEdgesDemoScreenState();
}

class AnimatedEdgesDemoScreenState extends State<AnimatedEdgesDemoScreen>
    with SingleTickerProviderStateMixin {
  final _controller = GraphController<Node<User>, Edge<Node<User>, int>>();

  late final _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  Set<Node<User>> get _nodes => _controller.nodes;

  final _random = Random(0);

  @override
  void initState() {
    super.initState();

    _controller.mutate((mutator) {

      final node1 = Node(
        data: User.generate(),
        size: 20.toDouble(),
      );
      final node2 = Node(
        data: User.generate(),
        size: 20.toDouble(),
      );

      mutator.addNode(node1);
      mutator.addNode(node2);
      _controller.setPinned(node1, true);
      _controller.setPinned(node2, true);
      mutator.addEdge(
        Edge(
          source: node1,
          destination: node2,
          data: random.integer(255, min: 100),
        ),
      );

    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Edges Demo'),
      ),
      floatingActionButton: ControlButtons(controller: _controller),
      body: Stack(
        children: [
          GraphView<Node<User>, Edge<Node<User>, int>>(
            controller: _controller,
            canvasSize: const GraphCanvasSize.proportional(50),
            edgePainter: AnimatedHighlightedEdgePainter(
              thickness: 60,
              animation: _animationController,
            ),
            layoutAlgorithm: FruchtermanReingoldAlgorithm(
              iterations: 1500,
              showIterations: true,
              initialPositionExtractor: (node, canvasSize) {
                if (node.pinned) {
                  return Offset(
                    _random.nextDouble() * canvasSize.width,
                    _random.nextDouble() * canvasSize.height,
                  );
                }

                return FruchtermanReingoldAlgorithm
                    .defaultInitialPositionExtractor(node, canvasSize);
              },
            ),
            nodeBuilder: (context, node) => UserNode(node: node),
            canvasBackgroundBuilder: (context) => const BackgroundGrid(),
          ),
        ],
      ),
    );
  }
}
