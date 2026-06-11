// mobile/lib/features/community/models/buddy_post.dart

import 'package:flutter/material.dart';

enum PostCategory { roommate, hobbyMate, studyMate }

extension PostCategoryExtension on PostCategory {
  String get label {
    switch (this) {
      case PostCategory.roommate:
        return 'Roommate';
      case PostCategory.hobbyMate:
        return 'Hobby Mate';
      case PostCategory.studyMate:
        return 'Study Mate';
    }
  }

  Color get color {
    switch (this) {
      case PostCategory.roommate:
        return const Color(0xFF818CF8);
      case PostCategory.hobbyMate:
        return const Color(0xFFF472B6);
      case PostCategory.studyMate:
        return const Color(0xFF34D399);
    }
  }

  Color get bgColor {
    switch (this) {
      case PostCategory.roommate:
        return const Color(0xFF818CF8).withValues(alpha: 0.12);
      case PostCategory.hobbyMate:
        return const Color(0xFFF472B6).withValues(alpha: 0.12);
      case PostCategory.studyMate:
        return const Color(0xFF34D399).withValues(alpha: 0.12);
    }
  }

  LinearGradient get buttonGradient {
    switch (this) {
      case PostCategory.roommate:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF818CF8), Color(0x99818CF8)],
        );
      case PostCategory.hobbyMate:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF472B6), Color(0x99F472B6)],
        );
      case PostCategory.studyMate:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF34D399), Color(0x9934D399)],
        );
    }
  }

  Color get avatarBgColor {
    switch (this) {
      case PostCategory.roommate:
        return const Color(0xFF818CF8).withValues(alpha: 0.12);
      case PostCategory.hobbyMate:
        return const Color(0xFFF472B6).withValues(alpha: 0.12);
      case PostCategory.studyMate:
        return const Color(0xFF34D399).withValues(alpha: 0.12);
    }
  }
}

class LifestyleDetail {
  final IconData icon;
  final String label;

  const LifestyleDetail({required this.icon, required this.label});
}

class BuddyPost {
  final String id;
  final String emoji;
  final String name;
  final int? matchPercent;
  final String subInfo;
  final String bio;
  final PostCategory category;
  final List<String> tags;
  final List<LifestyleDetail> lifestyleDetails;

  const BuddyPost({
    required this.id,
    required this.emoji,
    required this.name,
    this.matchPercent,
    required this.subInfo,
    required this.bio,
    required this.category,
    required this.tags,
    this.lifestyleDetails = const [],
  });
}

// mock data
final List<BuddyPost> sampleBuddyPosts = [
  BuddyPost(
    id: '1',
    emoji: '🧑‍💻',
    name: 'Min-Ji K.',
    matchPercent: 94,
    subInfo: 'Computing · Y2 · Korean',
    bio:
        'Looking for a chill roommate near UTown. I keep things tidy and respect quiet hours.',
    category: PostCategory.roommate,
    tags: ['Early Bird', 'Non-smoker', 'Neat', 'Korean'],
    lifestyleDetails: [
      LifestyleDetail(icon: Icons.bedtime_outlined, label: 'Early (10pm–6am)'),
      LifestyleDetail(icon: Icons.volume_down_outlined, label: 'Noise: Low'),
      LifestyleDetail(icon: Icons.cleaning_services_outlined, label: 'Very clean'),
      LifestyleDetail(icon: Icons.restaurant_outlined, label: 'Cooking: Often'),
    ],
  ),
  BuddyPost(
    id: '2',
    emoji: '👩‍🎓',
    name: 'Priya S.',
    matchPercent: 78,
    subInfo: 'Business · Y3 · Indian',
    bio:
        'Exchange student from India, friendly and easygoing. Love having people over occasionally.',
    category: PostCategory.roommate,
    tags: ['Night Owl', 'Veggie', 'Sociable'],
    lifestyleDetails: [
      LifestyleDetail(icon: Icons.bedtime_outlined, label: 'Late (12am–8am)'),
      LifestyleDetail(icon: Icons.volume_up_outlined, label: 'Noise: Medium'),
      LifestyleDetail(icon: Icons.cleaning_services_outlined, label: 'Average'),
      LifestyleDetail(icon: Icons.restaurant_outlined, label: 'Cooking: Weekends'),
    ],
  ),
  BuddyPost(
    id: '3',
    emoji: '👨‍🔬',
    name: 'Lucas T.',
    subInfo: 'Engineering · Y1 · French',
    bio:
        "Looking for study partners for CS2100 and MA1508E. Let's grind finals together!",
    category: PostCategory.studyMate,
    tags: ['CS', 'Math', 'Library person'],
  ),
  BuddyPost(
    id: '4',
    emoji: '👩‍🎨',
    name: 'Aiko M.',
    subInfo: 'Arts & Social Sci · Y2 · Japanese',
    bio:
        'Looking for friends to explore SG cafés and play badminton on weekends~',
    category: PostCategory.hobbyMate,
    tags: ['Badminton', 'K-drama', 'Café hopping'],
  ),
  BuddyPost(
    id: '5',
    emoji: '👨‍⚕️',
    name: 'Rahul P.',
    matchPercent: 88,
    subInfo: 'Medicine · Y4 · Malaysian',
    bio: 'Med student, mostly at school. Need a peaceful environment to study and rest.',
    category: PostCategory.roommate,
    tags: ['Quiet', 'Clean', 'Halal'],
    lifestyleDetails: [
      LifestyleDetail(icon: Icons.bedtime_outlined, label: 'Early (10pm–6am)'),
      LifestyleDetail(icon: Icons.volume_mute_outlined, label: 'Noise: Very Low'),
      LifestyleDetail(icon: Icons.cleaning_services_outlined, label: 'Very clean'),
      LifestyleDetail(icon: Icons.restaurant_outlined, label: 'Cooking: Rarely'),
    ],
  ),
  BuddyPost(
    id: '6',
    emoji: '👩‍💻',
    name: 'Sophie W.',
    subInfo: 'Computing · Y2 · German',
    bio:
        'Looking for an algorithms study group! Weekly sessions, happy to do hybrid.',
    category: PostCategory.studyMate,
    tags: ['CS3230', 'Algorithms', 'Zoom ok'],
  ),
  BuddyPost(
    id: '7',
    emoji: '🧑‍🎮',
    name: 'Jin H.',
    subInfo: 'Engineering · Y3 · Korean',
    bio: 'Want gym partners and maybe weekly gaming sessions. Chill vibes only 😎',
    category: PostCategory.hobbyMate,
    tags: ['Gaming', 'K-pop', 'Gym'],
  ),
];
