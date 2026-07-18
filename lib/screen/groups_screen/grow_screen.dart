import 'package:flutter/material.dart';
import '../../theme/ks_theme.dart';

class GrowScreen extends StatefulWidget {
  const GrowScreen({super.key});
  @override
  State<GrowScreen> createState() => _GrowScreenState();
}

class _GrowScreenState extends State<GrowScreen> {
  int _selectedAI = 0;
  final TextEditingController _aiController = TextEditingController();
  String _aiResponse = '';
  bool _isLoading = false;

  final aiFeatures = [
    {'icon': Icons.self_improvement, 'label': 'Prayer\nPartner', 'color': 0xFF00C9C8, 'prompt': 'Write a powerful prayer for: '},
    {'icon': Icons.bolt, 'label': 'Decree\nGenerator', 'color': 0xFFC9A227, 'prompt': 'Write a faith decree and declaration for: '},
    {'icon': Icons.menu_book, 'label': 'Bible\nAnswer', 'color': 0xFF9B59B6, 'prompt': 'Answer this Bible question with scripture: '},
    {'icon': Icons.trending_up, 'label': 'Kingdom\nBusiness', 'color': 0xFF00C9C8, 'prompt': 'Give Kingdom marketplace wisdom for: '},
    {'icon': Icons.record_voice_over, 'label': 'Sermon\nPrep', 'color': 0xFFC9A227, 'prompt': 'Help me prepare a sermon outline about: '},
    {'icon': Icons.favorite, 'label': 'Daily\nWord', 'color': 0xFFFF2D9B, 'prompt': 'Give me a personalized devotional about: '},
  ];

  final challenges = [
    {'title': '7-Day Prayer Challenge', 'desc': 'Pray for 10 minutes daily', 'days': '7', 'joined': '2.4K'},
    {'title': '21-Day Faith Fast', 'desc': 'Fast and seek God daily', 'days': '21', 'joined': '1.8K'},
    {'title': '30-Day Decree Challenge', 'desc': 'Speak life every morning', 'days': '30', 'joined': '3.1K'},
  ];

  final testimonies = [
    {'name': 'Sarah J.', 'text': 'God healed my marriage! After 3 years of struggle, we are restored! 🙏', 'likes': '345'},
    {'name': 'David M.', 'text': 'Got the job promotion I\'ve been believing God for! Faith works!', 'likes': '612'},
    {'name': 'Pastor James', 'text': 'Our church doubled in size this year. God is doing great things!', 'likes': '891'},
  ];

  Future<void> _askAI() async {
    if (_aiController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; _aiResponse = ''; });
    
    final feature = aiFeatures[_selectedAI];
    final prompt = '${feature['prompt']}${_aiController.text.trim()}. Keep it faith-based, encouraging, and grounded in scripture. Be concise but powerful.';
    
    try {
      final response = await _callClaudeAPI(prompt);
      setState(() { _aiResponse = response; _isLoading = false; });
    } catch (e) {
      setState(() { _aiResponse = 'Unable to connect. Please try again.'; _isLoading = false; });
    }
  }

  Future<String> _callClaudeAPI(String prompt) async {
    // Using the Anthropic API
    final http = await _httpPost(
      'https://api.anthropic.com/v1/messages',
      headers: {
        'Content-Type': 'application/json',
        'anthropic-version': '2023-06-01',
      },
      body: {
        'model': 'claude-sonnet-4-6',
        'max_tokens': 500,
        'messages': [{'role': 'user', 'content': prompt}],
        'system': 'You are KingdomAI, a faith-based AI companion for KingdomShift.Live. You provide biblical wisdom, prayer, decrees, and Kingdom marketplace guidance. Always ground responses in scripture and speak life. Be warm, encouraging and anointed in your responses.',
      },
    );
    return http;
  }

  Future<String> _httpPost(String url, {required Map<String, String> headers, required Map body}) async {
    // Placeholder - will use dio/http package
    await Future.delayed(const Duration(seconds: 2));
    final feature = aiFeatures[_selectedAI];
    final responses = {
      0: '🙏 Heavenly Father, I come before You on behalf of Your child. ${_aiController.text}. Lord, You are Jehovah Jireh, our Provider. You said in Philippians 4:19 that You shall supply ALL our needs according to Your riches in glory. We stand on Your Word today and trust You completely. Let Your perfect will be done. In Jesus\' mighty name, Amen! 🙏',
      1: '🔥 I DECREE AND DECLARE in the Name of Jesus: ${_aiController.text} is settled in Heaven and manifesting on Earth NOW! Isaiah 54:17 says no weapon formed against me shall prosper! I am more than a conqueror through Christ! Every blessing is mine, every promise is YES and AMEN! I walk in Kingdom authority today! 👑',
      2: '📖 Great question! The Bible speaks directly to this. Proverbs 3:5-6 says "Trust in the Lord with all your heart and lean not on your own understanding." Regarding ${_aiController.text}, Jeremiah 29:11 reminds us that God\'s plans for us are good — to give us a future and a hope. Would you like me to go deeper on any specific scripture?',
      3: '💼 Kingdom Business Wisdom: Deuteronomy 8:18 says God gives you power to get wealth to establish His covenant. For ${_aiController.text}, here are 3 Kingdom principles: 1) Seek first the Kingdom (Matthew 6:33) — purpose before profit. 2) Serve excellently (Colossians 3:23) — work as unto the Lord. 3) Give generously (Luke 6:38) — what you make happen for others, God makes happen for you. 👑',
      4: '📝 Sermon Outline: "${_aiController.text}"\n\nI. INTRODUCTION — Hook with a relevant story\nII. FOUNDATION — Key scripture text\nIII. BODY\n   A. Point 1 — The Problem\n   B. Point 2 — God\'s Answer\n   C. Point 3 — Our Response\nIV. APPLICATION — Practical steps\nV. ALTAR CALL — Invitation to respond',
      5: '✨ Daily Word for You: The Lord sees exactly where you are regarding ${_aiController.text}. Psalm 46:10 says "Be still and know that I am God." Today, rest in His love. You are not forgotten. Isaiah 40:31 promises that those who wait on the Lord shall renew their strength. Your season of breakthrough is closer than you think. Keep believing! 💫',
    };
    return responses[_selectedAI] ?? 'God has a word for you today!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KSTheme.bgDark,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Grow', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    Text('AI-powered Kingdom growth tools', style: TextStyle(color: KSTheme.textSecondary, fontSize: 13)),
                  ]),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('KingdomAI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ]),
              ),
            ),
            // AI Feature selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('KingdomAI Tools', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: aiFeatures.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final feature = aiFeatures[i];
                          final isSelected = _selectedAI == i;
                          return GestureDetector(
                            onTap: () => setState(() { _selectedAI = i; _aiResponse = ''; }),
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: isSelected ? Color(feature['color'] as int).withValues(alpha: 0.2) : KSTheme.bgCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isSelected ? Color(feature['color'] as int) : KSTheme.divider, width: isSelected ? 2 : 1),
                              ),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(feature['icon'] as IconData, color: Color(feature['color'] as int), size: 26),
                                const SizedBox(height: 6),
                                Text(feature['label'] as String, style: TextStyle(color: isSelected ? Colors.white : KSTheme.textSecondary, fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // AI Input
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(color: KSTheme.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Color(aiFeatures[_selectedAI]['color'] as int).withValues(alpha: 0.5))),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(children: [
                          Icon(aiFeatures[_selectedAI]['icon'] as IconData, color: Color(aiFeatures[_selectedAI]['color'] as int), size: 20),
                          const SizedBox(width: 8),
                          Text((aiFeatures[_selectedAI]['label'] as String).replaceAll('\n', ' '), style: TextStyle(color: Color(aiFeatures[_selectedAI]['color'] as int), fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      TextField(
                        controller: _aiController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: _getHintText(),
                          hintStyle: TextStyle(color: KSTheme.textSecondary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _isLoading ? null : _askAI,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(12)),
                              child: Center(child: _isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('Ask KingdomAI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                    ])),
                            ),
                          ),
                        ),
                      ),
                      if (_aiResponse.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: KSTheme.bgCardLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: KSTheme.teal.withValues(alpha: 0.3))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.auto_awesome, color: KSTheme.teal, size: 16),
                              const SizedBox(width: 6),
                              const Text('KingdomAI', style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                              const Spacer(),
                              GestureDetector(onTap: () {}, child: const Icon(Icons.share_outlined, color: KSTheme.textSecondary, size: 18)),
                              const SizedBox(width: 12),
                              GestureDetector(onTap: () {}, child: const Icon(Icons.copy, color: KSTheme.textSecondary, size: 18)),
                            ]),
                            const SizedBox(height: 10),
                            Text(_aiResponse, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                          ]),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Kingdom Challenges
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Kingdom Challenges', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final challenge = challenges[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: KSTheme.cardDecoration,
                      child: Row(children: [
                        Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(12)),
                          child: Center(child: Text('${challenge['days']}d', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(challenge['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(challenge['desc']!, style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${challenge['joined']} joined', style: TextStyle(color: KSTheme.teal, fontSize: 11, fontWeight: FontWeight.w600)),
                        ])),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: KSTheme.teal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: KSTheme.teal)),
                          child: const Text('Join', style: TextStyle(color: KSTheme.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ]),
                    ),
                  );
                },
                childCount: challenges.length,
              ),
            ),
            // Prayer Wall
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Prayer Wall', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: KSTheme.cardDecoration,
                  child: Column(children: [
                    TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Share a prayer request with the community...',
                        hintStyle: TextStyle(color: KSTheme.textSecondary),
                        border: InputBorder.none,
                      ),
                      maxLines: 2,
                    ),
                    const Divider(color: KSTheme.divider),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('🙏 Anonymous option', style: TextStyle(color: KSTheme.textSecondary, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(gradient: KSTheme.tealGradient, borderRadius: BorderRadius.circular(20)),
                        child: const Text('Post Prayer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ),
            // Testimonies
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Testimonies', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('See All >', style: TextStyle(color: KSTheme.teal, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final t = testimonies[i];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: KSTheme.cardDecoration,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(radius: 16, backgroundColor: KSTheme.bgCardLight, child: Text(t['name']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          const SizedBox(width: 8),
                          Text(t['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: KSTheme.teal, size: 14),
                          const Spacer(),
                          const Icon(Icons.more_horiz, color: KSTheme.textSecondary),
                        ]),
                        const SizedBox(height: 8),
                        Text(t['text']!, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.favorite_outline, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(t['likes']!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          const SizedBox(width: 16),
                          const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                          const Spacer(),
                          const Icon(Icons.share_outlined, color: Colors.white, size: 18),
                        ]),
                      ]),
                    ),
                  );
                },
                childCount: testimonies.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    final hints = [
      'Type your prayer need here...',
      'What do you want to decree over your life?',
      'Ask any Bible question...',
      'What business challenge are you facing?',
      'What topic do you want to preach about?',
      'What are you going through today?',
    ];
    return hints[_selectedAI];
  }
}
