import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '/game/enemy.dart';
import '/game/dino_run.dart';
import '/game/audio_manager.dart';
import '/models/player_data.dart';

//This enum represents the animation states of [Dino].
//ဒီကုဒ်က DinoRun game ထဲမှာ အသုံးပြုတဲ့ main player character ဖြစ်တဲ့ Dino class ကိုဖေါ်ပြတာပါ။
//ဒီ Dino class က သုံးသပ် animation, gravity, collision, jump, hit စတာတွေအကုန် handle လုပ်ပါတယ်။

//Character ဟာ idle, run, kick, hit, sprint ဆိုတဲ့ animation 5 မျိုး ရှိတယ်။
enum DinoAnimationStates { idle, run, kick, hit, sprint }

//This represents the dino character of this game.
//DinoAnimationStates =>  enum သုံးပြီး animation states ကို control
//Collision detection => (တစ်ခြား enemy နဲ့ ထိတာ)
//HasGameReference<DinoRun>  => game.virtualSize စတာ access လုပ်ဖို့ game instance reference

class Dino extends SpriteAnimationGroupComponent<DinoAnimationStates>
    with CollisionCallbacks, HasGameReference<DinoRun> {
  // A map of all the animation states and their corresponding animations.
  // Sprite sheet တစ်ခုထဲမှာ frame-based animation တွေကို
  // stepTime နဲ့ texturePosition တို့ဖြင့် animation state တစ်ခုချင်းစီ ဆွဲထုတ်တယ်။
  static final _animationMap = {
    DinoAnimationStates.idle: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
    ),
    DinoAnimationStates.run: SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4) * 24, 0),
    ),
    DinoAnimationStates.kick: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6) * 24, 0),
    ),
    DinoAnimationStates.hit: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4) * 24, 0),
    ),
    DinoAnimationStates.sprint: SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4 + 3) * 24, 0),
    ),
  };

  // The max distance from top of the screen beyond which
  // dino should never go. Basically the screen height - ground height
  // yMax – dino ရဲ့  (ground level)
  double yMax = 0.0;

  // Dino's current speed along y-axis.
  // speedY – Y direction ရဲ့ current speed (jump/gravity)
  double speedY = 0.0;

  // Controlls how long the hit animations will be played.
  final Timer _hitTimer = Timer(1);

  //gravity – fall speed
  static const double gravity = 800;

  final PlayerData playerData;

 //isHit – dino  က enemy ကိုထိတာ စောင့်ကြည့်
  bool isHit = false;

  //Sprite sheet image နဲ့ animationMap ကို ပေးပြီး 
  //superclass (SpriteAnimationGroupComponent) ကို initialize လုပ်တယ်။

  Dino(Image image, this.playerData)
      : super.fromFrameData(image, _animationMap);

  @override
  void onMount() {
    // First reset all the important properties, because onMount()
    // will be called even while restarting the game.
    _reset();

    // Add a hitbox for dino.
    //collision detect မလုပ်နိုင်အောင်
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );
    yMax = y; //yMax ကို dino ရဲ့ current Y coordinate ထားတယ်။

    /// Set the callback for [_hitTimer].
    //_hitTimer.onTick မှာ hit animation ပြီးရင် run ပြန်ထားတယ်။
    _hitTimer.onTick = () {
      current = DinoAnimationStates.run;
      isHit = false;
    };

    super.onMount();
  }

//Gravity update => dino fall
//Jump ပြီးမြေပေါ်ရောက်ရင် => Y value ကို limit
//isOnGround ဖြစ်ရင် animation ကို run ပြန်ထားတယ်။
//_hitTimer.update(dt) – hit animation ပြီးဖို့ timer run
  @override
  void update(double dt) {
    // v = u + at
    speedY += gravity * dt;

    // d = s0 + s * t
    y += speedY * dt;

    /// This code makes sure that dino never goes beyond [yMax].
    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != DinoAnimationStates.hit) &&
          (current != DinoAnimationStates.run)) {
        current = DinoAnimationStates.run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  // Gets called when dino collides with other Collidables.
  //တခြား object (enemy) နဲ့ dino ထိတိုက်တိုင်း hit() method ခေါ်တယ်။
  //isHit မဖြစ်လျှင်သာ hit ခေါ်တယ်။
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Call hit only if other component is an Enemy and dino
    // is not already in hit state.
    if ((other is Enemy) && (!isHit)) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  // Returns true if dino is on ground.
  bool get isOnGround => (y >= yMax);

  // Makes the dino jump.
  //Ground မှာရှိရင်သာ ခုန်နိုင်တယ်။
  //speedY = -300 => ခုန်ခြင်း
  //Sound effect play
  void jump() {
    // Jump only if dino is on ground.
    if (isOnGround) {
      speedY = -300;
      current = DinoAnimationStates.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  // This method changes the animation state to
  /// [DinoAnimationStates.hit], plays the hit sound
  /// effect and reduces the player life by 1.
  //Hit ဖြစ်သွားရင်
  //isHit = true
  //Hit sound play
  //Hit animation start
  //Timer ပြီးရင် run ပြန်သွားဖို့ _hitTimer
  //Player lives 1 လျှော့တယ်
  void hit() {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = DinoAnimationStates.hit;
    _hitTimer.start();
    playerData.lives -= 1;
  }

  // This method reset some of the important properties
  // of this component back to normal.
  //Dino ကို initial position/size/animation ဖြင့် reset
  //game.virtualSize.y - 22 ဆိုတာ ground level မှာရှိဖို့
  //run animation ကို default အနေနဲ့ ပြထားတယ်။
  void _reset() {
    if (isMounted) {
      removeFromParent();
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(32, game.virtualSize.y - 22);
    size = Vector2.all(24);
    current = DinoAnimationStates.run;
    isHit = false;
    speedY = 0.0;
  }
}


// | Function        | Role                                       |
// | --------------- | ------------------------------------------ |
// | `Dino` class    | Player character (animated + controllable) |
// | `jump()`        | Character ခုန်ဖို့                         |
// | `hit()`         | Life လျော့ဖို့ & animation                 |
// | `update()`      | Gravity effect, fall, animation            |
// | `onCollision()` | Enemy ထိတိုက်တာကို handle                  |
// | `_reset()`      | Game စမယ်ဆိုရင် dino ကို refresh           |
// | `onMount()`     | Game world ထဲထည့်သည့်အချိန်မှာ Run         |

