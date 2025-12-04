// SPDX-License-Identifier: MIT
// Copyright (c) 2025 kumihoclouds

/// Project model for Kumiho asset management.
///
/// This module provides the [Project] class, which represents the top-level
/// container for organizing assets in Kumiho.
library;

import '../generated/kumiho.pb.dart' as pb;
import 'base.dart';
import 'space.dart';
import 'item.dart';
import 'bundle.dart';

/// A Kumiho project—the top-level container for assets.
///
/// Projects are the root of the Kumiho hierarchy. Each project has its own
/// namespace for spaces and items, and manages access control and settings
/// independently.
///
/// ```dart
/// final project = await kumiho.getProject('my-project');
///
/// // Create spaces
/// final assets = await project.createSpace('assets');
/// final shots = await project.createSpace('shots');
///
/// // Create items
/// final hero = await project.createItem('hero', 'model');
///
/// // List all spaces
/// await for (final space in project.getSpaces(recursive: true)) {
///   print(space.path);
/// }
/// ```
class Project extends KumihoObject {
  /// Creates a [Project] from a protobuf response.
  Project(pb.ProjectResponse response, dynamic client) : super(client) {
    projectId = response.projectId;
    name = response.name;
    description = response.description;
    createdAt = response.createdAt.isEmpty ? null : response.createdAt;
    updatedAt = response.updatedAt.isEmpty ? null : response.updatedAt;
    deprecated = response.deprecated;
    allowPublic = response.allowPublic;
  }

  /// The unique identifier for this project.
  late final String projectId;

  /// The URL-safe name of the project (e.g., "film-2024").
  late final String name;

  /// Human-readable description of the project.
  late final String description;

  /// ISO timestamp when the project was created.
  late final String? createdAt;

  /// ISO timestamp of the last update.
  late final String? updatedAt;

  /// Whether the project is deprecated (soft-deleted).
  late final bool deprecated;

  /// Whether anonymous read access is enabled.
  late final bool allowPublic;

  /// Creates a space within this project.
  ///
  /// ```dart
  /// final chars = await project.createSpace('characters');
  /// final heroes = await project.createSpace('heroes', parentPath: '/$projectName/characters');
  /// ```
  Future<Space> createSpace(String spaceName, {String? parentPath}) async {
    final baseParent = parentPath ?? '/$name';
    final response = await client.createSpace(baseParent, spaceName);
    return Space(response, client);
  }

  /// Creates a new item within this project.
  ///
  /// ```dart
  /// final hero = await project.createItem('hero', 'model');
  /// final texture = await project.createItem('skin', 'texture', parentPath: '/project/textures');
  /// ```
  Future<Item> createItem(
    String itemName,
    String kind, {
    String? parentPath,
  }) async {
    final baseParent = parentPath ?? '/$name';
    final response = await client.createItem(baseParent, itemName, kind);
    return Item(response, client);
  }

  /// Creates a new bundle within this project.
  ///
  /// Bundles are special items that aggregate other items.
  ///
  /// ```dart
  /// final release = await project.createBundle('release-v1');
  /// await release.addMember(hero.kref);
  /// ```
  Future<Bundle> createBundle(
    String bundleName, {
    String? parentPath,
    Map<String, String>? metadata,
  }) async {
    final baseParent = parentPath ?? '/$name';
    final response = await client.createBundle(baseParent, bundleName, metadata: metadata);
    return Bundle(response, client);
  }

  /// Gets a space by path relative to this project.
  ///
  /// ```dart
  /// final chars = await project.getSpace('characters');
  /// final heroes = await project.getSpace('characters/heroes');
  /// ```
  Future<Space> getSpace(String relativePath) async {
    final fullPath = '/$name/$relativePath';
    final response = await client.getSpace(fullPath);
    return Space(response, client);
  }

  /// Gets all child spaces of this project.
  ///
  /// If [recursive] is true, returns all spaces in the hierarchy.
  ///
  /// ```dart
  /// final spaces = await project.getSpaces();
  /// for (final space in spaces) {
  ///   print(space.path);
  /// }
  /// ```
  Future<List<Space>> getSpaces({bool recursive = false}) async {
    final response = await client.getChildSpaces('/$name');
    final spaces = response.spaces.map((s) => Space(s, client)).toList();

    if (recursive && spaces.isNotEmpty) {
      final allSpaces = <Space>[...spaces];
      for (final space in spaces) {
        final children = await space.getChildSpaces(recursive: true);
        allSpaces.addAll(children);
      }
      return allSpaces;
    }

    return spaces;
  }

  /// Gets all items in the root of this project.
  ///
  /// ```dart
  /// final items = await project.getItems();
  /// ```
  Future<List<Item>> getItems({String? kindFilter, String? nameFilter}) async {
    final response = await client.getItems(
      '/$name',
      kindFilter: kindFilter,
      nameFilter: nameFilter,
    );
    return response.items.map((i) => Item(i, client)).toList();
  }

  /// Updates the project description.
  ///
  /// ```dart
  /// await project.update(description: 'Updated description');
  /// ```
  Future<Project> update({String? description}) async {
    final response = await client.updateProject(name, description: description);
    return Project(response, client);
  }

  /// Soft-deletes (deprecates) or hard-deletes this project.
  ///
  /// ```dart
  /// await project.delete();        // Soft delete
  /// await project.delete(force: true);  // Hard delete
  /// ```
  Future<void> delete({bool force = false}) async {
    await client.deleteProject(name, force: force);
  }

  /// Sets the public access mode for this project.
  ///
  /// ```dart
  /// await project.setPublic(true);  // Enable public access
  /// ```
  Future<Project> setPublic(bool allowPublic) async {
    final response = await client.updateProject(name, allowPublic: allowPublic);
    return Project(response, client);
  }

  @override
  String toString() => "Project(name: '$name', id: '$projectId')";
}
