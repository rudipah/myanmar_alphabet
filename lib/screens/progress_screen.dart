import 'package:flutter/material.dart';
import 'package:myanmar_alphabet/data/flashcard_data.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildNavButton(Icons.arrow_back_ios_rounded, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  const Text(
                    "Alphabet Overview",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D4E)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              const Text(
                "Explore the Alphabet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D2D4E)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: flashcards.length,
                  itemBuilder: (context, index) {
                    final letter = flashcards[index].letter;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            fontFamily: 'Pyidaungsu-2.5.3_Regular.ttf',
                            color: const Color(0xFF2D2D4E),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32, color: const Color(0xFF6C5CE7)),
        onPressed: onPressed,
      ),
    );
  }
}
