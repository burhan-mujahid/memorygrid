import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';

class MemoryGrid extends StatelessWidget {
  final GameController controller = Get.find();

  MemoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gridSize = controller.gridSize;
      final screenWidth = MediaQuery.of(context).size.width;
      final padding = 16.0;
      final maxGridSize = screenWidth - (padding * 2);
      final tileSize = (maxGridSize / gridSize).floorToDouble();
      final spacing = 4.0;
      
      return Center(
        child: Container(
          width: (tileSize * gridSize) + (spacing * (gridSize - 1)),
          height: (tileSize * gridSize) + (spacing * (gridSize - 1)),
          padding: EdgeInsets.all(spacing),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: 1,
            ),
            itemCount: controller.tileValues.length,
            itemBuilder: (context, index) {
              if (index >= controller.flippedTiles.length) return const SizedBox();
              return _buildTile(index, tileSize);
            },
          ),
        ),
      );
    });
  }

  Widget _buildTile(int index, double tileSize) {
    return Obx(() {
      final isFlipped = controller.flippedTiles[index];
      return InkWell(
        onTap: controller.isPlaying.value ? () => controller.flipTile(index) : null,
        child: Container(

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.blue.shade100,
          ),
          child: FlipCard(
            isFlipped: isFlipped,
            value: controller.tileValues[index],
            size: tileSize,
          ),
        ),
      );
    });
  }
}

class FlipCard extends StatelessWidget {
  final bool isFlipped;
  final int value;
  final double size;

  const FlipCard({
    super.key,
    required this.isFlipped,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isFlipped ? Colors.white : Colors.blue.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: isFlipped
            ? FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    String.fromCharCode(0x1F300 + value),
                    style: TextStyle(fontSize: size * 0.6),
                  ),
                ),
              )
            : Icon(
                Icons.question_mark,
                color: Colors.white,
                size: size * 0.6,
              ),
      ),
    ).animate(target: isFlipped ? 1 : 0)
     .flip(duration: 400.ms, perspective: 0.5);
  }
}
