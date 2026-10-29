import 'package:flutter/material.dart';

enum TaskRepeat { daily, once }

class RewardTask {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final int bonus;
  final TaskRepeat repeat;

  /// Daily tasks only: how many times per day.
  final int max;

  const RewardTask({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.bonus,
    this.repeat = TaskRepeat.daily,
    this.max = 1,
  });

  static const general = [
    RewardTask(
      key: 'video',
      title: 'Watch a video',
      description: 'Earn bonus every time you finish watching a short video',
      icon: Icons.play_circle_outline_rounded,
      bonus: 1,
      max: 5,
    ),
    RewardTask(
      key: 'visit',
      title: 'Explore new stories',
      description: 'Open three different book pages to collect',
      icon: Icons.travel_explore_rounded,
      bonus: 2,
      max: 3,
    ),
    RewardTask(
      key: 'share',
      title: 'Share a story',
      description: 'Share any book with a friend',
      icon: Icons.share_rounded,
      bonus: 3,
    ),
  ];

  static const social = [
    RewardTask(
      key: 'facebook', title: 'Follow us on Facebook', description: 'One-time reward',
      icon: Icons.facebook_rounded, bonus: 3, repeat: TaskRepeat.once,
    ),
    RewardTask(
      key: 'instagram', title: 'Follow us on Instagram', description: 'One-time reward',
      icon: Icons.camera_alt_outlined, bonus: 3, repeat: TaskRepeat.once,
    ),
    RewardTask(
      key: 'tiktok', title: 'Follow us on TikTok', description: 'One-time reward',
      icon: Icons.music_note_rounded, bonus: 3, repeat: TaskRepeat.once,
    ),
    RewardTask(
      key: 'invite', title: 'Invite a friend', description: 'Get bonus when a friend joins with your link',
      icon: Icons.person_add_alt_1_rounded, bonus: 50, repeat: TaskRepeat.once,
    ),
  ];
}

class ReadingMilestone {
  final int minutes;
  final int bonus;
  final int gems;

  const ReadingMilestone(this.minutes, this.bonus, [this.gems = 0]);

  static const all = [ReadingMilestone(15, 5), ReadingMilestone(30, 10, 1), ReadingMilestone(60, 20, 1)];
}
