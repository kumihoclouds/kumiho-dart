Getting Started
===============

Installation
------------

Add the SDK to your ``pubspec.yaml``. Until the package is published to pub.dev, use the Git repository directly::

  dependencies:
    kumiho:
      git:
        url: https://github.com/kumihoclouds/kumiho-dart.git

Then fetch dependencies with ``dart pub get``.

Quickstart
----------

Create a client and build a simple asset hierarchy. Tokens are auto-loaded from the environment or cached credentials unless you provide one explicitly.

.. code-block:: dart

   import 'package:kumiho/kumiho.dart';

   Future<void> main() async {
     final client = KumihoClient(
       host: 'localhost',
       port: 50051,
     );

     try {
       final project = await client.createProject('demo-project');
       final space = await client.createSpace('/demo-project', 'models');
       final item = await client.createItem('/demo-project/models', 'hero', 'model');
       final revision = await client.createRevision(item.kref);
       await client.createArtifact(revision.kref, 'mesh', '/path/to/hero.fbx');
     } finally {
       await client.shutdownAsync();
     }
   }

Why Kumiho?
-----------

* Graph-native modeling that tracks relationships between revisions and bundles.
* BYO-storage philosophy—store file references as artifacts while keeping your own storage layer.
* Fluent, high-level Dart models layered on top of the generated gRPC stubs.
