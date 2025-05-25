# Original implementation proposed by https://fzakaria.com/2025/05/20/bazel-knowledge-a-practical-guide-to-depset

GraphvizProviderInfo = provider(
  doc = "A provider for graphviz",
  fields = {
    "fragment": "The edges of this target to it's strict dependencies",
    "deps": "A depset of the dependencies of this target",
  },
)

def _node_impl(ctx):
  # Generate the DOT fragment for the current node
  fragment = '"{}"\n'.format(ctx.label)
  fragment += ''.join(
    ['"{}" -> "{}"\n'.format(ctx.label, dep.label) for dep in ctx.attr.edges]
  )

  # Aggregate transitive dependencies using depset
  transitive_deps = depset(
    direct=ctx.attr.edges,
    transitive=[dep[GraphvizProviderInfo].deps for dep in ctx.attr.edges]
  )

  # Concatenate all fragments from transitive dependencies
  transitive_fragments = ''.join(
    [dep[GraphvizProviderInfo].fragment for dep in transitive_deps.to_list()]
  )

  # Assemble the complete DOT content
  dot_content = "digraph G {\n"
  dot_content += fragment
  dot_content += transitive_fragments
  dot_content += "}\n"

  # Declare and write the DOT file
  dot_file = ctx.actions.declare_file(ctx.attr.name + ".dot")
  ctx.actions.write(dot_file, dot_content)

  # Return the providers
  return [
    DefaultInfo(files=depset([dot_file])),
    GraphvizProviderInfo(fragment=fragment, deps=transitive_deps),
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

