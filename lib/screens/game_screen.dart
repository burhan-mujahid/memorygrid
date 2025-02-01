import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../widgets/memory_grid.dart';

class GameScreen extends StatelessWidget {
  final GameController controller = Get.put(GameController());

  GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildGameStats(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: MemoryGrid(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildControls(),
              const SizedBox(height: 16),
              _buildProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Memory Grid',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Obx(() {
          return DropdownButton<int>(
            value: controller.currentLevel.value,
            items: List.generate(10, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text('Level ${index + 1}'),
              );
            }),
            onChanged: !controller.isPlaying.value 
              ? (value) {
                  if (value != null) {
                    controller.setLevel(value);
                  }
                }
              : null,
          );
        }),
      ],
    );
  }

  Widget _buildGameStats() {
    return Obx(() {
      final minutes = controller.elapsedTime.value.inMinutes;
      final seconds = controller.elapsedTime.value.inSeconds % 60;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Time', '$minutes:${seconds.toString().padLeft(2, '0')}'),
            _buildStatCard('Moves', '${controller.moves}'),
            _buildStatCard('Score', '${controller.score}'),
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Obx(() {
      return ElevatedButton(
        onPressed: controller.isPlaying.value 
          ? controller.stopGame 
          : controller.initializeGame,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: controller.isPlaying.value ? Colors.red : Colors.blue,
          foregroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.isPlaying.value ? 'Stop Game' : 'Start Game',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProgressSection() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        final progress = controller.progressHistory.value;
        
        if (progress.isEmpty) {
          return const Center(
            child: Text('No progress data yet. Start playing!'),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: progress.length,
          itemBuilder: (context, index) {
            final game = progress[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${game.date.day}/${game.date.month}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Level ${game.level}'),
                  Text('Score: ${game.score}'),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
