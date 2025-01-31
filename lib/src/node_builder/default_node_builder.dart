import 'package:flutter/widgets.dart';
import 'package:force_directed_graphview/force_directed_graphview.dart';

/// Callback for building a widget for a node
typedef NodeViewBuilder<N extends NodeBase> = Widget Function(
  BuildContext context,
  N node,
);

/// Dumb implementation of [NodeBuilder].
final class DefaultNodeBuilder<N extends NodeBase> implements NodeBuilder<N> {
  /// {@nodoc}
  DefaultNodeBuilder({
    required this.builder,
  });

  /// {@nodoc}
  final NodeViewBuilder<N> builder;

  @override
  Widget build(BuildContext context, N node) {
    return builder(context, node);
  }
}
