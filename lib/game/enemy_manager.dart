import 'dart:math';

import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/models/enemy_data.dart';

// This class is responsible for spawning random enemies at certain
// interval of time depending upon players current score.
//ဒီ EnemyManager class က DinoRun game ထဲမှာ ရန်သူ (Enemy) တွေကို အချိန်အတိုင်းအတာတစ်ခုခြားပြီး 
//တစ်စီချင်းစီ random နေရာမှာ ထွက်အောင် spawn လုပ်ပေးတဲ့ class ဖြစ်ပါတယ်။ 
//ဒါ့အပြင် enemy ကိုဖယ်ရှားခြင်းလည်း ထိန်းချုပ်ပါတယ်။

//Component = 	Flame game engine ထဲမှာ attach လုပ်နိုင်တဲ့ reusable unit
//HasGameReference = Main game (DinoRun) ကို access လုပ်ဖို့ game instance reference

class EnemyManager extends Component with HasGameReference<DinoRun> {
  // A list to hold data for all the enemies.
  //Enemy အမျိုးအစားများကို သိမ်းထားတဲ့ list (sprite, speed, texture size, etc.)
  final List<EnemyData> _data = [];

  // Random generator required for randomly selecting enemy type.
  // Random number generator — enemy spawn ကို random ဖြစ်အောင်
  final Random _random = Random();

  // Timer to decide when to spawn next enemy.
  // 2 seconds တစ်ကြိမ်ခြားပြီး enemy တစ်ယောက် spawn မယ် (looped)
  final Timer _timer = Timer(2, repeat: true);

  EnemyManager() {
    //Timer တစ်ခု setup လုပ်ပြီး onTick အချိန်တိုင်း 
    //spawnRandomEnemy() method ကို ခေါ်တယ်။
    _timer.onTick = spawnRandomEnemy;
  }

  // This method is responsible for spawning a random enemy.
  void spawnRandomEnemy() {
    /// Generate a random index within [_data] and get an [EnemyData].
    //_data list ထဲကမှ random index ထုတ်ပြီး enemyData ရယူတယ်။
    //အဲဒီ data ကို အခြေခံပြီး Enemy object ဖန်တီးတယ်။
    final randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = Enemy(enemyData);

    //Help in setting all enemies on ground.
    //Enemy ကို screen ရဲ့ညာဘက်အပြင်ထဲမှာ position ချတယ်
    //ဒါကြောင့် left ကနေ right သွားတဲ့ effect ဖြစ်တယ်။
    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(game.virtualSize.x + 32, game.virtualSize.y - 24);

    // If this enemy can fly, set its y position randomly.
    // canFly ဆိုရင် random height ထဲမှာ အနည်းငယ် float လုပ်သွားမယ်။
    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    // Due to the size of our viewport, we can
    // use textureSize as size for the components.
    // Enemy ရဲ့ size ကို textureSize နဲ့ညှိတယ်။
    // Game world ထဲထည့်တယ်။
    enemy.size = enemyData.textureSize;
    game.world.add(enemy);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    // Don't fill list again and again on every mount.
    if (_data.isEmpty) {
      // As soon as this component is mounted, initilize all the data.
      //Component တင်သွင်းတဲ့အချိန်မှာသာ enemyData တွေကို load တယ်။
      _data.addAll([
        EnemyData(
          image: game.images.fromCache('AngryPig/Walk (36x30).png'), //game preload images မှ cache ထဲကယူတာ။
          nFrames: 16,
          stepTime: 0.1,
          textureSize: Vector2(36, 30),
          speedX: 80,
          canFly: false,
        ),
        EnemyData(
          image: game.images.fromCache('Bat/Flying (46x30).png'),
          nFrames: 7,
          stepTime: 0.1,
          textureSize: Vector2(46, 30),
          speedX: 100,
          canFly: true,
        ),
        EnemyData(
          image: game.images.fromCache('Rino/Run (52x34).png'),
          nFrames: 6,
          stepTime: 0.09,
          textureSize: Vector2(52, 34),
          speedX: 150,
          canFly: false,
        ),
      ]);
    }
    _timer.start();
    super.onMount();
  }

  @override
  void update(double dt) {
    //Frame တစ်ခုချင်း timer.update() ခေါ်ပြီး 
    //သတ်မှတ်ထားတဲ့ second (2s) ပြည့်ရင် enemy spawn ခေါ်တယ်။
    _timer.update(dt);
    super.update(dt);
  }

  void removeAllEnemies() {
    //Game world ထဲမှာရှိတဲ့ Enemy objects တွေကိုရှာပြီးအားလုံး ဖယ်ရှားတယ်။ 
    //(Reset လုပ်တဲ့အချိန် အသုံးဝင်တယ်)
    final enemies = game.world.children.whereType<Enemy>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}

// | Method / Variable    | Description                             |
// | -------------------- | --------------------------------------- |
// | `_data`              | Enemy type တွေကို store ထားတယ်          |
// | `_random`            | Random enemy spawn လုပ်ဖို့             |
// | `_timer`             | Spawn every 2s                          |
// | `spawnRandomEnemy()` | Random enemy spawn + set position, size |
// | `onMount()`          | data initialize + timer start           |
// | `update()`           | timer run တဲ့ frame update            |
// | `removeAllEnemies()` | game reset မတိုင်ခင်မှာ enemy ဖယ်ရှား   |
