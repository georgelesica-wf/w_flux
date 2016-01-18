// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library w_flux.example.todo_app.store;

import 'package:w_flux/w_flux.dart';

import 'actions.dart';

class ToDoStore extends Store {
  /// Public data
  List<Todo> _todos;
  List<Todo> get todos => _todos;

  /// Internals
  ToDoActions _actions;

  ToDoStore(ToDoActions this._actions) {
    _todos = [];

    triggerOnAction(_actions.createTodo, (todo) => _todos.add(todo.value));
    triggerOnAction(_actions.completeTodo, (todo) => _todos[_todos.indexOf(todo.value)].completed = true);
    triggerOnAction(_actions.deleteTodo, (todo) => _todos.remove(todo.value));
    triggerOnAction(_actions.clearTodoList, (_) => _todos = []);
  }
}

class Todo implements JsonEncodable {
  static Todo todoFactory(Map attributeMap) {
    var todo = new Todo(attributeMap['description']);
    todo.completed = attributeMap['completed'];
    return todo;
  }

  String description;
  bool completed = false;

  Todo(String this.description);

  @override
  Map toJson() {
    return {
      'description': description,
      'completed': completed
    };
  }

  int get hashCode => description.hashCode * 10 + (completed ? 1 : 0);

  operator ==(Todo other) => hashCode == other.hashCode;
}
