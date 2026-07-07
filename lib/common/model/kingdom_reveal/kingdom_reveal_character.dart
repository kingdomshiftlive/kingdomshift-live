class KingdomRevealCharacter {
  final String id;
  final String name;
  final String imageUrl;
  final String? frameBaseUrl;
  final int? frameCount;
  final String? audioUrl;

  const KingdomRevealCharacter({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.frameBaseUrl,
    this.frameCount,
    this.audioUrl,
  });

  List<String> get frameUrls {
    if (frameBaseUrl == null || frameCount == null) return [];
    return List.generate(
      frameCount!,
      (i) => '$frameBaseUrl${i.toString().padLeft(3, '0')}.png',
    );
  }
}

const List<KingdomRevealCharacter> kingdomRevealCharacters = [
  KingdomRevealCharacter(
    id: 'lion_judah',
    name: 'Lion of Judah',
    imageUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-characters/thumb_lion_raw.png',
    frameBaseUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-frames/lionv2_',
    frameCount: 20,
    audioUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-audio/lionv2.mp3',
  ),
  KingdomRevealCharacter(
    id: 'guardian_angel',
    name: 'Guardian Angel',
    imageUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-characters/thumb_guardian_raw.png',
    frameBaseUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-frames/guardianv2_',
    frameCount: 20,
    audioUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-audio/guardianv2.mp3',
  ),
  KingdomRevealCharacter(
    id: 'dove_peace',
    name: 'Dove of Peace',
    imageUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-characters/thumb_dove_raw.png',
    frameBaseUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-frames/dovev2_',
    frameCount: 20,
    audioUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-audio/dovev2.mp3',
  ),
  KingdomRevealCharacter(
    id: 'kingdom_crown',
    name: 'Kingdom Crown',
    imageUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-characters/thumb_crown_raw.png',
    frameBaseUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-frames/crownv2_',
    frameCount: 20,
    audioUrl: 'https://cotcogrkmtgibbpwhxrg.supabase.co/storage/v1/object/public/kingdom-reveal-audio/crownv2.mp3',
  ),
];
