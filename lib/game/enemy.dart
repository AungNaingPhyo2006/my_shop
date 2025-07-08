import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/dino_run.dart';
import '/models/enemy_data.dart';

// This represents an enemy in the game world.
//ဒီ Enemy class က Flame game engine ကို အသုံးပြုပြီးရေးထားတဲ့ Game World ထဲမှာထည့်မယ့် ရန်သူ (enemy) character တစ်ခုကို ဖော်ပြတာပါ။ 
//ဒါဟာ dino game ထဲမှာ dinosaur နဲ့ တိုက်ခိုက်မယ့် character ဖြစ်ပါတယ်။

// SpriteAnimationComponent = Enemy ဟာ animated sprite တစ်ခုဖြစ်တယ် (frame-based animation)
// CollisionCallbacks = Enemy ဟာ collision detection လုပ်တယ်
// HasGameReference<DinoRun> = Game world (DinoRun) ကို reference လုပ်နိုင်တယ် (player data, score access လုပ်ဖို့)

class Enemy extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameReference<DinoRun> {
  // The data required for creation of this enemy.
  //enemyData ဆိုတာ EnemyData model class မှာရှိတဲ့ ရန်သူတစ်ဦးစီရဲ့ 
  //animation info (image, frame count, step time, texture size, speedX) ပါ။
  final EnemyData enemyData;

  Enemy(this.enemyData) {
    animation = SpriteAnimation.fromFrameData(
      enemyData.image,
      SpriteAnimationData.sequenced(
        amount: enemyData.nFrames,
        stepTime: enemyData.stepTime,
        textureSize: enemyData.textureSize,
      ),
    );
  }

  @override
  void onMount() {
    // Reduce the size of enemy as they look too
    // big compared to the dino.
    size *= 0.6;

    // Add a hitbox for this enemy.
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.2, size.y * 0.2) / 2,
      ),
    );
    super.onMount();
  }

  @override
  void update(double dt) {
    position.x -= enemyData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    if (position.x < -enemyData.textureSize.x) {
      removeFromParent();
      game.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}
