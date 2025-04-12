import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/player.dart';

class PlayerProvider with ChangeNotifier {
  List<Player> _players = [];
  Player? _currentPlayer;

  List<Player> get players => _players;
  Player? get currentPlayer => _currentPlayer;

  Future<void> loadPlayers() async {
    final box = await Hive.openBox<Player>('players');
    _players = box.values.toList();
    _players.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  Future<void> addPlayer(Player player) async {
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
    
    notifyListeners();
  }

  void setCurrentPlayer(Player? player) {
    _currentPlayer = player;
    notifyListeners();
  }
  
  Player? getPlayerById(String id) {
    return _players.firstWhere((player) => player.id == id, orElse: () => null as Player);
  }
} 
} 