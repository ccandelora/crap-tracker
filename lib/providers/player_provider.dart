import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/player.dart';

class PlayerProvider with ChangeNotifier {
  List<Player> _players = [];
  Player? _currentPlayer;
  Player? _selectedPlayer;

  List<Player> get players => _players;
  Player? get currentPlayer => _currentPlayer;
  Player? get selectedPlayer => _selectedPlayer;

  Future<void> loadPlayers() async {
    final box = await Hive.openBox<Player>('players');
    _players = box.values.toList();
    _players.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> addPlayer(String name) async {
    final player = Player(name: name);
    
    final box = await Hive.openBox<Player>('players');
    await box.put(player.id, player);
    
    if (!_players.contains(player)) {
      _players.add(player);
      _players.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
    }
  }

  Future<void> updatePlayer(Player player) async {
    final box = await Hive.openBox<Player>('players');
    await box.put(player.id, player);
    
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index >= 0) {
      _players[index] = player;
      _players.sort((a, b) => a.name.compareTo(b.name));
      
      if (_currentPlayer?.id == player.id) {
        _currentPlayer = player;
      }
      
      if (_selectedPlayer?.id == player.id) {
        _selectedPlayer = player;
      }
      
      notifyListeners();
    }
  }

  Future<void> deletePlayer(String playerId) async {
    final box = await Hive.openBox<Player>('players');
    await box.delete(playerId);
    
    _players.removeWhere((player) => player.id == playerId);
    
    if (_currentPlayer?.id == playerId) {
      _currentPlayer = null;
    }
    
    if (_selectedPlayer?.id == playerId) {
      _selectedPlayer = null;
    }
    
    notifyListeners();
  }

  void setCurrentPlayer(Player? player) {
    _currentPlayer = player;
    notifyListeners();
  }
  
  void selectPlayer(String playerId) {
    try {
      _selectedPlayer = _players.firstWhere((player) => player.id == playerId);
    } catch (e) {
      _selectedPlayer = null;
    }
    notifyListeners();
  }
  
  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((player) => player.id == id);
    } catch (e) {
      return null;
    }
  }
} 