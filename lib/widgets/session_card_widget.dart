import 'package:flutter/material.dart';
import 'package:crap_tracker/models/session.dart';
import 'package:intl/intl.dart';

class SessionCardWidget extends StatelessWidget {
  final Session session;
  final String playerName;
  final VoidCallback? onTap;

  const SessionCardWidget({
    Key? key,
    required this.session,
    required this.playerName,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');
    final durationString = _formatDuration(session.durationInSeconds);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateFormat.format(session.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: session.isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      session.isActive ? 'Active' : 'Completed',
                      style: TextStyle(
                        color: session.isActive ? Colors.green.shade800 : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    Icons.person,
                    'User',
                    playerName,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    Icons.analytics,
                    'Data Points',
                    session.totalRolls.toString(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoItem(
                context,
                Icons.timer,
                'Duration',
                durationString,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds ${seconds == 1 ? 'second' : 'seconds'}';
    }
    
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    
    if (minutes < 60) {
      final result = '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
      if (remainingSeconds > 0) {
        return '$result, $remainingSeconds ${remainingSeconds == 1 ? 'second' : 'seconds'}';
      }
      return result;
    }
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    final result = '$hours ${hours == 1 ? 'hour' : 'hours'}';
    if (remainingMinutes > 0) {
      return '$result, $remainingMinutes ${remainingMinutes == 1 ? 'minute' : 'minutes'}';
    }
    return result;
  }
} 