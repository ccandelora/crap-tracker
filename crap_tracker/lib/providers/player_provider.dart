import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/database_service.dart';

class PlayerProvider with ChangeNotifier {
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = false;
  String? _error;

  List<Player> get players => _players;
  Player? get selectedPlayer => _selectedPlayer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlayers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      debugPrint('PlayerProvider: Loading players from database...');
      _players = await DatabaseService.getAllPlayers();
      debugPrint('PlayerProvider: Loaded ${_players.length} players');
      
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PlayerProvider: Error loading players: $e');
      debugPrint('Stack trace: $stackTrace');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addPlayer(String name) async {
    try {
      debugPrint('PlayerProvider: Adding new player: $name');
      final player = Player(name: name);
      await DatabaseService.addPlayer(player);
      _players.add(player);
      debugPrint('PlayerProvider: Player added successfully with ID: ${player.id}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PlayerProvider: Error adding player: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void selectPlayer(String id) {
    try {
      debugPrint('PlayerProvider: Selecting player with ID: $id');
      _selectedPlayer = _players.firstWhere((player) => player.id == id);
      debugPrint('PlayerProvider: Selected player: ${_selectedPlayer?.name}');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PlayerProvider: Error selecting player: $e');
      debugPrint('Stack trace: $stackTrace');
      // Don't rethrow here, just log the error
    }
  }

  Future<void> updatePlayer(Player player) async {
    try {
      debugPrint('PlayerProvider: Updating player: ${player.name} (ID: ${player.id})');
      await DatabaseService.updatePlayer(player);
      
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index >= 0) {
        _players[index] = player;
        
        if (_selectedPlayer?.id == player.id) {
          _selectedPlayer = player;
        }
        
        debugPrint('PlayerProvider: Player updated successfully');
        notifyListeners();
      } else {
        debugPrint('PlayerProvider: Player not found in list, cannot update');
      }
    } catch (e, stackTrace) {
      debugPrint('PlayerProvider: Error updating player: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      debugPrint('PlayerProvider: Deleting player with ID: $id');
      await DatabaseService.deletePlayer(id);
      
      _players.removeWhere((player) => player.id == id);
      
      if (_selectedPlayer?.id == id) {
        _selectedPlayer = null;
      }
      
      debugPrint('PlayerProvider: Player deleted successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('PlayerProvider: Error deleting player: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  String getPlayerName(String playerId) {
    try {
      final player = _players.firstWhere(
        (player) => player.id == playerId,
      );
      return player.name;
    } catch (e) {
      debugPrint('PlayerProvider: Error getting player name: $e');
      return 'Unknown Player';
    }
  }
}
