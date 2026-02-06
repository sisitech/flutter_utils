import 'package:flutter/material.dart';
import 'package:flutter_utils/extensions/date_extensions.dart';
import 'package:flutter_utils/text_view/text_view_extensions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller.dart';
import 'models.dart';
import 'utils.dart';

/// Widget for managing and viewing background tasks
class BackgroundTaskManagerWidget extends StatelessWidget {
  final String? controllerTag;
  final bool showRefreshButton;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const BackgroundTaskManagerWidget({
    super.key,
    this.controllerTag,
    this.showRefreshButton = true,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    var controller =
        Get.find<BackgroundWorkManagerController>(tag: controllerTag);

    return Column(
      children: [
        if (showRefreshButton)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Background Tasks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.restart_alt),
                            onPressed: () =>
                                _confirmForceReregister(context, controller),
                            tooltip: 'Force re-register all',
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => controller.refreshStatuses(),
                            tooltip: 'Refresh statuses',
                          ),
                        ],
                      )),
              ],
            ),
          ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.taskStatuses.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.taskStatuses.isEmpty) {
              return const Center(
                child: Text('No background tasks registered'),
              );
            }

            return ListView.builder(
              shrinkWrap: shrinkWrap,
              physics: physics,
              itemCount: controller.taskStatuses.length,
              itemBuilder: (context, index) {
                var status = controller.taskStatuses[index];
                return BackgroundTaskItemWidget(
                  status: status,
                  onPause: () => controller.pauseTask(status.uniqueName),
                  onResume: () => controller.resumeTask(status.uniqueName),
                  onCancel: () => controller.cancelTask(status.uniqueName),
                  onRemove: () => _confirmRemove(context, controller, status),
                  onViewHistory: () =>
                      _showHistoryDialog(context, status),
                  onClearHistory: () => controller.clearHistory(status.uniqueName),
                  onRunNow: () => controller.runTaskNow(status.uniqueName),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _confirmForceReregister(
    BuildContext context,
    BackgroundWorkManagerController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Re-register All'),
        content: const Text(
            'This will cancel all tasks (including paused ones) and re-register them fresh. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.forceReregisterAll();
            },
            child: const Text('Re-register All'),
          ),
        ],
      ),
    );
  }

  void _confirmRemove(
    BuildContext context,
    BackgroundWorkManagerController controller,
    BackgroundTaskStatus status,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Task'),
        content: Text(
            'Are you sure you want to remove "${status.name.titleCase}"? This will cancel the task and clear all history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.removeTask(status.uniqueName);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, BackgroundTaskStatus status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskHistoryBottomSheet(status: status),
    );
  }
}

/// Widget for displaying a single task item
class BackgroundTaskItemWidget extends StatelessWidget {
  final BackgroundTaskStatus status;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final VoidCallback? onRemove;
  final VoidCallback? onViewHistory;
  final VoidCallback? onClearHistory;
  final VoidCallback? onRunNow;

  const BackgroundTaskItemWidget({
    super.key,
    required this.status,
    this.onPause,
    this.onResume,
    this.onCancel,
    this.onRemove,
    this.onViewHistory,
    this.onClearHistory,
    this.onRunNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ExpansionTile(
          leading: _buildStatusIcon(context),
          title: Row(
            children: [
              Expanded(child: Text(status.name.titleCase)),
              _buildTypeBadge(context),
            ],
          ),
          subtitle: _buildSubtitle(context),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 12),
                  _buildDetailsRow(context),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    final theme = Theme.of(context);

    // Running state - show animated indicator
    if (status.isRunning) {
      return SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: theme.colorScheme.primary,
        ),
      );
    }

    Color color;
    IconData icon;

    if (status.isPaused) {
      color = Colors.orange;
      icon = Icons.pause_circle;
    } else if (status.isRegistered) {
      color = Colors.green;
      icon = Icons.play_circle;
    } else {
      color = Colors.grey;
      icon = Icons.stop_circle;
    }

    return Icon(icon, color: color, size: 32);
  }

  Widget _buildTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isPeriodic = status.type == BackgroundWorkManagerTaskType.periodic;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPeriodic
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPeriodic ? 'Periodic' : 'One-Off',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isPeriodic
              ? theme.colorScheme.primary
              : theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);

    // Show running indicator
    if (status.isRunning) {
      return Text(
        'Running...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final parts = <String>[];

    if (status.lastExecutedAt != null) {
      parts.add('Last: ${status.lastExecutedAt!.toRelativeTime}');
    }

    if (status.type == BackgroundWorkManagerTaskType.periodic &&
        status.nextScheduledRun != null) {
      parts.add('Next: ${status.nextScheduledRun!.toRelativeTime}');
    }

    if (parts.isEmpty) {
      parts.add('Never executed');
    }

    return Text(
      parts.join(' | '),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          context,
          'Executions',
          status.executionCount.toString(),
          Icons.repeat,
        ),
        _buildStatItem(
          context,
          'Success',
          status.successCount.toString(),
          Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatItem(
          context,
          'Failed',
          status.failureCount.toString(),
          Icons.error,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).iconTheme.color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDetailsRow(BuildContext context) {
    final details = <Widget>[];

    if (status.registeredAt != null) {
      details.add(_buildDetailItem(
        context,
        'Registered',
        status.registeredAt!.toRelativeTime,
      ));
    }

    if (status.frequency != null) {
      details.add(_buildDetailItem(
        context,
        'Frequency',
        _formatDuration(status.frequency!),
      ));
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: details,
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Only show pause/resume/cancel for PERIODIC tasks
    final isPeriodic = status.type == BackgroundWorkManagerTaskType.periodic;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Run Now button - shown when task is not currently running
        if (!status.isRunning)
          OutlinedButton.icon(
            onPressed: onRunNow,
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('Run Now'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        // Pause button - only for periodic tasks that are registered and not paused
        if (isPeriodic && status.isRegistered && !status.isPaused)
          OutlinedButton.icon(
            onPressed: onPause,
            icon: const Icon(Icons.pause, size: 18),
            label: const Text('Pause'),
          ),
        // Resume button - only for periodic tasks that are paused
        if (isPeriodic && status.isPaused)
          OutlinedButton.icon(
            onPressed: onResume,
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Resume'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
            ),
          ),
        // Cancel button - only for periodic tasks that are registered and not paused
        if (isPeriodic && !status.isPaused && status.isRegistered)
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.stop, size: 18),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
        OutlinedButton.icon(
          onPressed: onViewHistory,
          icon: const Icon(Icons.history, size: 18),
          label: const Text('History'),
        ),
        if (status.history.isNotEmpty)
          OutlinedButton.icon(
            onPressed: onClearHistory,
            icon: const Icon(Icons.clear_all, size: 18),
            label: const Text('Clear'),
          ),
        OutlinedButton.icon(
          onPressed: onRemove,
          icon: const Icon(Icons.delete, size: 18),
          label: const Text('Remove'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours >= 1) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Bottom sheet for viewing task execution history
class TaskHistoryBottomSheet extends StatelessWidget {
  final BackgroundTaskStatus status;

  const TaskHistoryBottomSheet({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'History: ${status.name.titleCase}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: status.history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No execution history',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: status.history.length,
                        itemBuilder: (context, index) {
                          // Show most recent first
                          final record =
                              status.history[status.history.length - 1 - index];
                          return _buildHistoryItem(context, record);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, TaskExecutionRecord record) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: record.success
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            record.success ? Icons.check_circle : Icons.error,
            color: record.success ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy HH:mm:ss').format(record.executedAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Duration: ${record.duration.inMilliseconds}ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (record.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple page wrapper for the task manager
class BackgroundTaskManagerPage extends StatelessWidget {
  final String? controllerTag;
  final String title;

  const BackgroundTaskManagerPage({
    super.key,
    this.controllerTag,
    this.title = 'Background Tasks',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        top: false,
        child: BackgroundTaskManagerWidget(
          controllerTag: controllerTag,
          showRefreshButton: true,
        ),
      ),
    );
  }
}
