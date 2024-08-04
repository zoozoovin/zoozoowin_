import 'dart:math';

class ProfileNameGenerator {
  final Random _random = Random();

  // Predefined lists of adjectives and nouns
  final List<String> _adjectives = [
    'Brave', 'Clever', 'Jolly', 'Kind', 'Lively', 'Quick', 'Witty', 'Zany'
  ];
  final List<String> _nouns = [
    'Panda', 'Lion', 'Eagle', 'Wizard', 'Ninja', 'Pirate', 'Knight', 'Elf'
  ];

  String generateRandomName() {
    // Select a random adjective and noun
    String adjective = _adjectives[_random.nextInt(_adjectives.length)];
    String noun = _nouns[_random.nextInt(_nouns.length)];
    return '$adjective $noun';
  }
}

void main() {
  ProfileNameGenerator generator = ProfileNameGenerator();
  String randomName = generator.generateRandomName();
  print(randomName); // Example output: 'Quick Panda'
}
