import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'daily_tasks';
  static const String _lastDateKey = 'last_date';

  // Obtenir la date du jour au format yyyy-MM-dd
  String _getTodayDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Vérifier si on est sur un nouveau jour
  Future<bool> _isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString(_lastDateKey);
    final today = _getTodayDate();
    return lastDate != today;
  }

  // Mettre à jour la date du dernier accès
  Future<void> _updateLastDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDateKey, _getTodayDate());
  }

  // Charger les tâches
  Future<List<Task>> loadTasks() async {
    // Si c'est un nouveau jour, supprimer seulement les tâches complétées
    if (await _isNewDay()) {
      await _removeCompletedTasks();
      await _updateLastDate();
    }

    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(tasksJson);
    return decoded.map((json) => Task.fromJson(json)).toList();
  }

  // Supprimer seulement les tâches complétées
  Future<void> _removeCompletedTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey);
    
    if (tasksJson == null) {
      return;
    }

    final List<dynamic> decoded = jsonDecode(tasksJson);
    final tasks = decoded.map((json) => Task.fromJson(json)).toList();
    
    // Garder seulement les tâches non-complétées
    final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
    
    if (incompleteTasks.isEmpty) {
      await prefs.remove(_tasksKey);
    } else {
      final tasksJsonFiltered = jsonEncode(incompleteTasks.map((task) => task.toJson()).toList());
      await prefs.setString(_tasksKey, tasksJsonFiltered);
    }
  }

  // Sauvegarder les tâches
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
    await _updateLastDate();
  }

  // Effacer toutes les tâches
  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
