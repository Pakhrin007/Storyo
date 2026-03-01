class DemoUser {
  final String id;
  final String fullName;
  final String username;
  final String bio;
  final int followers;
  final int following;
  final int stories;
  final String avatarAsset;

  const DemoUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
    required this.stories,
    required this.avatarAsset,
  });
}

final demoUsers = <DemoUser>[
  const DemoUser(
    id: "u1",
    fullName: "Elena Rose",
    username: "elenarose_writes",
    bio: "Storyteller & Dreamer. Exploring the world through words.",
    followers: 1200,
    following: 450,
    stories: 18,
    avatarAsset: "assets/logo/storyo.png",
  ),
  const DemoUser(
    id: "u2",
    fullName: "Marcus Aurel",
    username: "marcus_aurel",
    bio: "Sci-Fi lover | Building worlds one chapter at a time.",
    followers: 980,
    following: 210,
    stories: 10,
    avatarAsset: "assets/logo/storyo.png",
  ),
  const DemoUser(
    id: "u3",
    fullName: "Hana Sato",
    username: "hana_sato",
    bio: "Romance + travel stories 🌸",
    followers: 640,
    following: 310,
    stories: 7,
    avatarAsset: "assets/logo/storyo.png",
  ),
];