# rules_graphviz example

Example implementations of a simple Graphviz ruleset for Bazel inspired by
https://fzakaria.com/2025/05/20/bazel-knowledge-a-practical-guide-to-depset .

Implemented primarily to benchmark the alternate implementations and to propose
a third implementation (`dot_lazy.bzl`) that I believe may be more performant.

## Quick-and-dirty benchmark procedure

1. Choose the desired implementation by editing `dot.bzl`.

2. Run builds of graphs of various sizes; linked-lists are used because they're easy to build up
   and get deep quickly, demonstrating certain scaling effects of the different implementatations.

```
bazel clean; bazel shutdown; bazel build --disk_cache= ll1k:node1000; bazel info used-heap-size-after-gc
bazel clean; bazel shutdown; bazel build --disk_cache= ll2k:node2000; bazel info used-heap-size-after-gc
bazel clean; bazel shutdown; bazel build --disk_cache= ll3k:node3000; bazel info used-heap-size-after-gc
```

## Results

### Elapsed time

|       | ll1k:node1000 | ll2k:node2000 | ll3k:node3000
|-------|---------------|---------------|--------------
| orig  | 2.454s        | 3.608s        | 5.148s
| eager | 2.513s        | 3.619s        | 5.464s
| lazy  | 2.298s        | 2.928s        | 3.940s

### bazel info used-heap-size-after-gc

|       | ll1k:node1000 | ll2k:node2000 | ll3k:node3000
|-------|---------------|---------------|--------------
| orig  | 35MB          |  44MB         |  59MB
| eager | 64MB          | 164MB         | 330MB
| lazy  | 32MB          |  34MB         |  36MB
