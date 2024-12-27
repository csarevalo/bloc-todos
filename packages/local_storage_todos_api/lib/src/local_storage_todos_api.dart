import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos_api/todos_api.dart';

/// {@template local_storage_todos_api}
/// A Flutter implementation of the TodosApi that uses local storage.
/// {@endtemplate}
class LocalStorageTodosApi extends TodosApi {
  /// {@macro local_storage_todos_api}
  LocalStorageTodosApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  late final _todosStreamController = BehaviorSubject<List<Todo>>.seeded(
    const [],
  );

  /// The key used for storing the todos locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kTodosCollectionKey = '__todos_collection_key__';

  // Gets `Todos` in encoded [JsonMap] format from shared preferences.
  String? _getValue(String key) => _plugin.getString(key);

  // Saves `Todos` in [SharedPreferences] plugin.
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  void _init() {
    final todosJson = _getValue(kTodosCollectionKey);
    if (todosJson != null) {
      final todos = List<Map<String, dynamic>>.from(
        json.decode(todosJson) as List,
      ).map(Todo.fromJson).toList();
      _todosStreamController.add(todos);
    } else {
      _todosStreamController.add(const []);
    }
  }

  @override
  Future<int> clearCompleted() async {
    final todos = [..._todosStreamController.value];
    final numTodosCompleted = todos.where((t) => t.isCompleted).length;
    todos.removeWhere((t) => t.isCompleted);
    _todosStreamController.add(todos);
    await _setValue(kTodosCollectionKey, jsonEncode(todos));
    return numTodosCompleted;
  }

  @override
  Future<int> completeAll({required bool isCompleted}) async {
    final todos = [..._todosStreamController.value];
    final numTodosUpdated =
        todos.where((t) => t.isCompleted != isCompleted).length;
    final newTodos = [
      for (final todo in todos) todo.copyWith(isCompleted: isCompleted),
    ];
    _todosStreamController.add(newTodos);
    await _setValue(kTodosCollectionKey, jsonEncode(newTodos));
    return numTodosUpdated;
  }

  @override
  Future<void> deleteTodo(String id) {
    final todos = [..._todosStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == id);
    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);
    }
    _todosStreamController.add(todos);
    return _setValue(kTodosCollectionKey, jsonEncode(todos));
  }

  @override
  Stream<List<Todo>> getTodos() => _todosStreamController.asBroadcastStream();

  @override
  Future<void> saveTodo(Todo todo) {
    final todos = [..._todosStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == todo.id);
    if (todoIndex >= 0) {
      // Update todo in local variable if it exists
      todos[todoIndex] = todo;
    } else {
      // Add to todos list if todo does not exist.
      todos.add(todo);
    }
    // Broadcast todos to stream subscriptions.
    _todosStreamController.add(todos);
    // Update todos in local storage.
    return _setValue(kTodosCollectionKey, json.encode(todos));
  }

  @override
  Future<void> close() {
    return _todosStreamController.close();
  }
}
