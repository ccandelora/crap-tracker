import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/session_provider.dart';
import '../models/player.dart';
import '../models/session.dart';

class SessionPlayersScreen extends StatefulWidget {
  final String sessionId;
  
  const SessionPlayersScreen({
    super.key, 
    required this.sessionId,
  });

  @override
  State<SessionPlayersScreen> createState() => _SessionPlayersScreenState();
}

class _SessionPlayersScreenState extends State<SessionPlayersScreen> {
  bool _isLoading = true;
  List<String> _sessionPlayerIds = [];
  List<Player> _availablePlayers = [];
  Session? _session;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load the session
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      _session = await sessionProvider.getSession(widget.sessionId);
      
      if (_session != null) {
        _sessionPlayerIds = List<String>.from(_session!.playerOrder);
        
        // Add the primary player if not already in the list
        if (!_sessionPlayerIds.contains(_session!.playerId)) {
          _sessionPlayerIds.insert(0, _session!.playerId);
          
          // Update the session player order
          _session!.playerOrder = _sessionPlayerIds;
          await sessionProvider.updateSession(_session!);
        }
      }
      
      // Load all available players
      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
      await playerProvider.loadPlayers();
      _availablePlayers = playerProvider.players;
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading session players: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading players: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Players'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlayerDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildContent() {
    if (_session == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Session not found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Session info
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.group),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Session Players',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_sessionPlayerIds.length} players in this session',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Drag and drop reorderable list
        Expanded(
          child: _sessionPlayerIds.isEmpty
              ? _buildEmptyState()
              : ReorderableListView.builder(
                  itemCount: _sessionPlayerIds.length,
                  padding: const EdgeInsets.all(16),
                  onReorder: _reorderPlayers,
                  itemBuilder: (context, index) {
                    final playerId = _sessionPlayerIds[index];
                    final player = _findPlayerById(playerId);
                    final isMainPlayer = playerId == _session!.playerId;
                    
                    return _buildPlayerItem(
                      player, 
                      index, 
                      isMainPlayer,
                      key: ValueKey(playerId),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Players in Session',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add players to this session',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPlayerDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Player'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerItem(Player? player, int index, bool isMainPlayer, {required Key key}) {
    final playerName = player?.name ?? 'Unknown Player';
    
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isMainPlayer
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary.withOpacity(0.7),
          child: Text(
            playerName.isNotEmpty ? playerName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          playerName,
          style: TextStyle(
            fontWeight: isMainPlayer ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          isMainPlayer ? 'Main player (Session owner)' : 'Position: ${index + 1}',
        ),
        trailing: isMainPlayer
            ? const Icon(Icons.star, color: Colors.amber)
            : IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                onPressed: () => _removePlayer(index),
              ),
      ),
    );
  }
  
  void _reorderPlayers(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final player = _sessionPlayerIds.removeAt(oldIndex);
      _sessionPlayerIds.insert(newIndex, player);
      
      // Update session
      if (_session != null) {
        _session!.playerOrder = _sessionPlayerIds;
        Provider.of<SessionProvider>(context, listen: false)
            .updateSession(_session!);
      }
    });
  }
  
  void _removePlayer(int index) {
    final playerId = _sessionPlayerIds[index];
    
    // Don't allow removing the main player
    if (playerId == _session!.playerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove the main player from the session'),
        ),
      );
      return;
    }
    
    setState(() {
      _sessionPlayerIds.removeAt(index);
      
      // Update session
      if (_session != null) {
        _session!.playerOrder = _sessionPlayerIds;
        Provider.of<SessionProvider>(context, listen: false)
            .updateSession(_session!);
      }
    });
  }
  
  void _showAddPlayerDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final availablePlayers = _availablePlayers.where(
            (player) => !_sessionPlayerIds.contains(player.id)
          ).toList();
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.person_add),
                    const SizedBox(width: 16),
                    const Text(
                      'Add Players to Session',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: availablePlayers.isEmpty
                    ? Center(
                        child: Text(
                          'No more players available to add',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: availablePlayers.length,
                        itemBuilder: (context, index) {
                          final player = availablePlayers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              child: Text(
                                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                              ),
                            ),
                            title: Text(player.name),
                            subtitle: Text('${player.totalRolls} rolls • ${player.totalSessions} sessions'),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () => _addPlayerToSession(player.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _addPlayerToSession(String playerId) {
    setState(() {
      if (!_sessionPlayerIds.contains(playerId)) {
        _sessionPlayerIds.add(playerId);
        
        // Update session
        if (_session != null) {
          _session!.playerOrder = _sessionPlayerIds;
          Provider.of<SessionProvider>(context, listen: false)
              .updateSession(_session!);
        }
      }
    });
    
    // Close the bottom sheet
    Navigator.pop(context);
  }
  
  Player? _findPlayerById(String playerId) {
    try {
      return _availablePlayers.firstWhere((player) => player.id == playerId);
    } catch (e) {
      return null;
    }
  }
} 