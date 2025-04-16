import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crap_tracker/models/player.dart';
import 'package:crap_tracker/providers/player_provider.dart';
import 'package:crap_tracker/screens/roll_input_screen.dart';
import 'package:crap_tracker/screens/player_stats_screen.dart';
import 'package:crap_tracker/widgets/player_card_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load players when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PlayerProvider>(context, listen: false).loadPlayers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'lib/assets/images/logo.png', 
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const Text('Dice Analytics Pro'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddPlayerDialog,
            tooltip: 'Add Player',
          ),
        ],
      ),
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.players.isEmpty) {
            return _buildEmptyState();
          }
          
          return ListView.builder(
            itemCount: playerProvider.players.length,
            itemBuilder: (context, index) {
              final player = playerProvider.players[index];
              final isSelected = player.id == playerProvider.selectedPlayer?.id;
              
              return PlayerCardWidget(
                player: player,
                isSelected: isSelected,
                onTap: () => _selectPlayer(player),
                onDelete: () => _confirmDeletePlayer(player),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.selectedPlayer == null) {
            return const SizedBox.shrink();
          }
          
          return FloatingActionButton.extended(
            onPressed: () => _navigateToRollInput(playerProvider.selectedPlayer!),
            label: const Text('Analyze Data'),
            icon: const Icon(Icons.analytics),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Users Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a user to start analyzing dice data',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPlayerDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Player'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Player'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Player Name',
            hintText: 'Enter the player\'s name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                Provider.of<PlayerProvider>(context, listen: false)
                    .addPlayer(_nameController.text.trim());
                Navigator.of(context).pop();
                _nameController.clear();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _selectPlayer(Player player) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    
    if (playerProvider.selectedPlayer?.id == player.id) {
      // If already selected, navigate to stats
      _navigateToPlayerStats(player);
    } else {
      // Otherwise, select the player
      playerProvider.selectPlayer(player.id);
    }
  }

  void _confirmDeletePlayer(Player player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}? All associated rolls and sessions will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<PlayerProvider>(context, listen: false)
                  .deletePlayer(player.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToRollInput(Player player) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RollInputScreen(player: player),
      ),
    );
  }

  void _navigateToPlayerStats(Player player) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerStatsScreen(player: player),
      ),
    );
  }
} 