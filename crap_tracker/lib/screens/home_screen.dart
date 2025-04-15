import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/session_provider.dart';
import '../models/player.dart';
import '../widgets/hexagon_button.dart';
import 'roll_input_screen.dart';
import 'player_stats_screen.dart';
import 'all_rolls_screen.dart';
import 'settings_screen.dart';
import 'strategy_guide_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedPlayerId;
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
  
  @override
  void activate() {
    super.activate();
    // Refresh data when this screen becomes active again (coming back from other screens)
    _loadData();
  }
  
  Future<void> _loadData() async {
    // Set loading state
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Load players from database on init
      final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
      await playerProvider.loadPlayers();
      
      // Force refresh of session data for all players
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      await sessionProvider.loadSessions();
      
      // If there's a selected player, load their active session
      if (_selectedPlayerId != null) {
        playerProvider.selectPlayer(_selectedPlayerId!);
        await sessionProvider.loadActiveSessionForPlayer(_selectedPlayerId!);
        await sessionProvider.loadSessionsByPlayer(_selectedPlayerId!);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        leadingWidth: 0,
        centerTitle: true,
        title: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width > 600 ? 400 : MediaQuery.of(context).size.width * 0.9,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Image.asset(
            'assets/images/logo.png', 
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to the alternative path if the first one fails
              return Image.asset(
                'lib/assets/images/logo.png',
                fit: BoxFit.fitWidth,
              );
            },
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _navigateToAllRolls,
            tooltip: 'View All Rolls',
          ),
          IconButton(
            icon: const Icon(Icons.tips_and_updates),
            onPressed: _navigateToStrategyGuide,
            tooltip: 'Strategy Guide',
          ),
          if (_error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
              tooltip: 'Retry loading data',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                _navigateToSettings();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: HexagonButton(
        size: 80,
        color: Theme.of(context).colorScheme.primary,
        onPressed: _showAddPlayerDialog,
        child: const Icon(
          Icons.add, 
          color: Colors.white, 
          size: 32,
        ),
      ),
    );
  }
  
  Widget _buildBody() {
    // Show loading indicator
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading players...'),
          ],
        ),
      );
    }
    
    // Show error if there is one
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    // Show content if no error
    final playerProvider = Provider.of<PlayerProvider>(context);
    final players = playerProvider.players;
    
    return players.isEmpty 
        ? _buildEmptyState() 
        : _buildPlayerList(players);
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.casino,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Players Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a player to start tracking dice rolls',
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerList(List<Player> players) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.grey.shade50,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          final isSelected = player.id == _selectedPlayerId;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSelected
                    ? [
                        const Color(0xFF1A237E), // Darker blue
                        const Color(0xFF3949AB), // Medium blue
                      ]
                    : [
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF252525)
                            : Colors.grey.shade50,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                    ? const Color(0xFF1A237E).withOpacity(0.5)
                    : Colors.black.withOpacity(0.1),
                  blurRadius: isSelected ? 15 : 10,
                  offset: const Offset(0, 4),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
              border: Border.all(
                color: isSelected 
                  ? const Color(0xFF1A237E) 
                  : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _selectPlayer(player.id),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Player avatar/icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.7)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              player.name.isNotEmpty
                                  ? player.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Player information
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatBadge(
                                    Icons.casino,
                                    '${player.totalRolls}',
                                    'Rolls',
                                    isSelected,
                                  ),
                                  const SizedBox(height: 6),
                                  _buildStatBadge(
                                    Icons.date_range,
                                    '${player.totalSessions}',
                                    'Sessions',
                                    isSelected,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.casino,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                  onPressed: () => _navigateToRollInput(player.id),
                                  tooltip: 'Roll Dice',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.bar_chart,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.secondary,
                                  ),
                                  onPressed: () => _navigateToPlayerStats(player.id),
                                  tooltip: 'View Stats',
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete, 
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.red,
                              ),
                              onPressed: () => _deletePlayer(player.id),
                              tooltip: 'Delete Player',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatBadge(IconData icon, String value, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(bottom: 2),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.25)
            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected
                  ? Colors.white.withOpacity(0.9)
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  void _showAddPlayerDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Player'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              hintText: 'Enter the player\'s name',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<PlayerProvider>(context, listen: false)
                    .addPlayer(nameController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  
  void _selectPlayer(String id) {
    setState(() {
      _selectedPlayerId = id;
    });
    
    // Automatically navigate to roll input or stats when selecting
    if (_selectedPlayerId != null) {
      // You could show a bottom sheet with options, or go directly to roll input
      _showPlayerOptions(_selectedPlayerId!);
    }
  }
  
  void _showPlayerOptions(String playerId) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = playerProvider.players.firstWhere((p) => p.id == playerId);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
              ? const Color(0xFF1E1E1E) 
              : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      player.name.isNotEmpty 
                          ? player.name[0].toUpperCase() 
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${player.totalRolls} rolls • ${player.totalSessions} sessions',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToRollInput(playerId);
                    },
                    icon: const Icon(Icons.casino),
                    label: const Text('ROLL DICE'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToPlayerStats(playerId);
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('VIEW STATS'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NEW! Try the auto-roll simulation feature to generate statistics quickly',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _deletePlayer(String id) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final player = playerProvider.players.firstWhere((p) => p.id == id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              playerProvider.deletePlayer(id);
              setState(() {
                if (_selectedPlayerId == id) {
                  _selectedPlayerId = null;
                }
              });
              Navigator.pop(context);
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
  
  void _navigateToRollInput(String id) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => RollInputScreen(playerId: id),
      ),
    );
  }
  
  void _navigateToPlayerStats(String id) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => PlayerStatsScreen(playerId: id),
      ),
    );
  }
  
  void _navigateToAllRolls() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const AllRollsScreen(),
      ),
    );
  }
  
  void _navigateToSettings() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
  
  void _navigateToStrategyGuide() {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const StrategyGuideScreen(),
      ),
    );
  }
}
