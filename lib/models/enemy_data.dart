// Vector2 class တို့လို Flame တွင်အသုံးပြုသော math-related classes တွေကို import လုပ်ဖို့။
// Vector2 ဆိုတာက (x, y) 2D point/size/position ကို ဖော်ပြရာမှာ အသုံးပြုတယ်။
import 'package:flame/extensions.dart';

//This class stores all the data
//necessary for creation of an enemy.
//ဒီ EnemyData class ဟာ DinoRun game ထဲမှာ ရန်သူ (Enemy) တစ်ခုကို 
//ဖန်တီးဖို့လိုအပ်တဲ့အချက်အလက်အားလုံးကို စုစည်းထားတဲ့ model class ဖြစ်ပါတယ်။
//သူ့ရဲ့အဓိကအလုပ်က Enemy တွေရဲ့ animation, movement, feature (ပျံနိုင်/မနိုင်) စတာတွေကို 
//တစ်ခုတည်းထဲမှာ သိမ်းဆည်းထားဖို့ပါ။
//ဒီ class ဟာ animation & movement logic မှာ logic မပါတဲ့ pure data holder model ဖြစ်ပါတယ်။

// EnemyData  = Model class တစ်ခုဖြစ်ပြီး Enemy တစ်ခုဖန်တီးဖို့လိုအပ်တဲ့ data ကို သိမ်းထားပါတယ်။
class EnemyData {
  final Image image;
  final int nFrames;
  final double stepTime;
  final Vector2 textureSize;
  final double speedX;
  final bool canFly;

//const constructor ဖြစ်တာကြောင့် immutable (မပြောင်းလဲနိုင်တဲ့) object ဖန်တီးနိုင်တယ်။
//required keyword လည်း ပါတဲ့အတွက်၊ EnemyData ကို instantiate လုပ်တဲ့အချိန်မှာ အကုန်လုံးဖြည့်ရမယ်။

  const EnemyData({
    required this.image,
    required this.nFrames,
    required this.stepTime,
    required this.textureSize,
    required this.speedX,
    required this.canFly,
  });
}

// | Property      | Description                                                               |
// | ------------- | ------------------------------------------------------------------------- |
// | `image`       | Enemy ရဲ့ **sprite sheet** (တစ်ခုထဲမှာ animation frames အများအပြား ပါသည်) |
// | `nFrames`     | Animation frame အရေအတွက် (ဥပမာ 6 frames ဆိုရင် 6-ဖရိမ် sprite)            |
// | `stepTime`    | Frame တစ်ခုကို ပြသတဲ့အချိန် (သေးရင်မြန်, ကြီးရင်နှေး)                     |
// | `textureSize` | Frame တစ်ခုချင်းစီရဲ့အရွယ်အစား (width × height)                           |
// | `speedX`      | Enemy ရဲ့ X-axis ပေါ်မှာရွေ့သော speed (pixel per second)                  |
// | `canFly`      | Enemy ဟာ ပျံနိုင်သလား (bat ပျံတတ်တယ်, rino မပျံဘူး)                       |

//အသုံးပြုပုံ===>

// EnemyData(
//   image: game.images.fromCache('Bat/Flying (46x30).png'),
//   nFrames: 7,
//   stepTime: 0.1,
//   textureSize: Vector2(46, 30),
//   speedX: 100,
//   canFly: true,
// );
