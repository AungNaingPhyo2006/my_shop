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
      enemyData.image, //Image: Enemy ရဲ့ sprite sheet.
      SpriteAnimationData.sequenced(
        amount: enemyData.nFrames, //Frames: Frame count.
        stepTime: enemyData.stepTime, //stepTime: Frame တစ်ခုကို ပြသချိန်.
        textureSize: enemyData.textureSize, //textureSize: Frame တစ်ခုချင်းစီရဲ့အရွယ်အစား.
      ),
    );
  }

  @override
  void onMount() {
    // Reduce the size of enemy as they look too
    // big compared to the dino.
    //size *= 0.6 – Enemy ကို ပုံမှန်ထက် 60% ချုံ့တယ် (dino ထက် မကြီးအောင်).
    size *= 0.6;

    // Add a hitbox for this enemy.
    // Collision detect လုပ်ဖို့ hitbox တပ်တယ်။ 0.8 ဆိုတာ 80% hitbox ဖြစ်တယ်။
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
    //Enemy ကို left direction (↤) ကို သွားအောင်လုပ်တယ်။
    //speedX ဆိုတာ enemy's movement speed.
    position.x -= enemyData.speedX * dt;

    // Remove the enemy and increase player score
    // by 1, if enemy has gone past left end of the screen.
    //Enemy က screen ရဲ့ ဘယ်ဘက်ကိုထွက်သွားပြီလား စစ်တယ်။
    //ထွက်သွားရင်
    //removeFromParent() → Game world မှ ဖယ်ရှား
    //game.playerData.currentScore += 1 → Player score တစ်ချက်တိုး
    if (position.x < -enemyData.textureSize.x) {
      removeFromParent();
      game.playerData.currentScore += 1;
    }

    super.update(dt);
  }
}

// | Function             | Description                             |
// | -------------------- | --------------------------------------- |
// | `EnemyData`          | Enemy sprite animation & speed info     |
// | `animation`          | Frame-based animation from sprite sheet |
// | `onMount()`          | Enemy size scale down + hitbox တပ်တယ်   |
// | `update()`           | Enemy move left + score တိုး/ဖျက်       |
// | `CollisionCallbacks` | dino နဲ့ ထိသွားရင် detect လုပ်ဖို့      |

// Enemy object တွေ သည် frame တစ်ခုစီမှာ x-axis ပေါ်အတိုင်း ဆွဲသွားမယ်။
// Collision များကို onCollision() မှာ handle မလုပ်ဘူး၊ ဒါကို dino class မှာ handle လုပ်တယ်။
// Game score ကို Enemy ကို ဖျက်ခြင်းနဲ့တင်တိုးတယ် — ဒီ logic ကို later ပြန် refine လုပ်လို့ရတယ်။