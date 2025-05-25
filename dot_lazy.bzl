# Alternate, lazy implementation

GraphvizProviderInfo = provider(
  doc = "A provider for graphviz",
  fields = {
    "fragment": "The edges reachable through this target, including its transitive dependencies",
  },
)

def _fmt_edge(edge):
  if edge.dst == None:
    return '"{}"'.format(edge.src)
  return '"{}" -> "{}"'.format(edge.src, edge.dst)

def _node_impl(ctx):
  # Create this node's fragment as a depset of edge-structs including the transitive deps by reference.
  fragment = depset(
    direct = [struct(src=ctx.label, dst=None)] + [
      struct(src=ctx.label, dst=dep.label) for dep in ctx.attr.edges
    ],
    transitive = [dep[GraphvizProviderInfo].fragment for dep in ctx.attr.edges],
  )

  # Generate the DOT fragment for the current node
  dot_content = (
      ctx.actions.args()
          .set_param_file_format("multiline")  # Don't do any flags-y stuff; just write lines.
          .add("digraph G {")
          .add_all(fragment, map_each=_fmt_edge)
          .add("}")
  )

  # Declare and write the DOT file
  dot_file = ctx.actions.declare_file(ctx.attr.name + ".dot")
  ctx.actions.write(dot_file, dot_content)

  # Return the providers
  return [
    DefaultInfo(files=depset([dot_file])),
    GraphvizProviderInfo(fragment=fragment),
  ]

node = rule(
  implementation = _node_impl,
  attrs = {
    "edges": attr.label_list(
      doc = "Edges to other Graphviz nodes.",
      providers = [GraphvizProviderInfo],
    ),
  },
  output_to_genfiles = True,
)
