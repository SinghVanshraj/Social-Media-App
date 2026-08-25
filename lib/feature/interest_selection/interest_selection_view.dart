import 'package:flutter/material.dart';

class InterestSelectionView extends StatefulWidget {
  const InterestSelectionView({super.key});

  @override
  State<InterestSelectionView> createState() => _InterestSelectionViewState();
}

class _InterestSelectionViewState extends State<InterestSelectionView> {
  final List<Map<String, dynamic>> _interests = [
    {
      'id': '7f3a1c92-5b84-4e17-9d63-2a8f6c41b705',
      'name': 'Technology',
      'icon': Icons.computer_rounded,
      'selected': false,
    },
    {
      'id': 'c2e91b47-83d6-4a52-bf19-71e5c9038a24',
      'name': 'Travel',
      'icon': Icons.flight_takeoff_rounded,
      'selected': false,
    },
    {
      'id': 'a64d8e31-2f97-4c05-91b8-53e7a26d4f10',
      'name': 'Gastronomy',
      'icon': Icons.restaurant_rounded,
      'selected': false,
    },
    {
      'id': 'e8b52c74-61a3-49df-8c27-14f6b935a802',
      'name': 'Fitness Hub',
      'icon': Icons.fitness_center_rounded,
      'selected': false,
    },
    {
      'id': '3d9f7a26-b841-45ce-a713-68c2e94f1057',
      'name': 'Acoustics',
      'icon': Icons.music_note_rounded,
      'selected': false,
    },
    {
      'id': 'b17c5e93-4a62-48f1-9d35-72e8c6410fb9',
      'name': 'Visual Art',
      'icon': Icons.brush_rounded,
      'selected': false,
    },
  ];

  void _toggleSelected(int index) {
    setState(() {
      _interests[index]['selected'] = !_interests[index]['selected'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are your interests?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tailor your dynamic home recommendation metrics accurately.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = interest['selected'];
                  return GestureDetector(
                    onTap: () => _toggleSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent.withValues(alpha: 0.12)
                            : const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blueAccent
                              : Colors.grey[900]!,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            interest['icon'],
                            color: isSelected
                                ? Colors.blueAccent
                                : Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              interest['name'],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[300],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
