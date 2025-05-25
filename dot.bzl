# Uncomment implementation to benchmark.

load("//:dot_orig.bzl", _node = "node")
# load("//:dot_eager.bzl", _node = "node")
# load("//:dot_lazy.bzl", _node = "node")

node = _node
