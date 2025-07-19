import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Uncommented for custom fonts

void main() => runApp(StudyQuestApp());

class StudyQuestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // A bold, playful, and truly vibrant color palette
    const Color primaryBg = Color(0xFFF8F0FF);     // Very light lavender/off-white for background
    const Color cardBg = Color(0xFFEEDDFF);       // Lighter purple for cards, giving a dreamy feel
    const Color primaryAccent = Color(0xFF8A2BE2); // A rich, vibrant Electric Purple
    const Color secondaryAccent = Color(0xFFDA70D6); // A bright, cheerful Orchid Pink
    const Color darkText = Color(0xFF330066);       // Deep Violet for primary text
    const Color mutedText = Color(0xFF663399);      // Medium Lavender for secondary text
    const Color successGreen = Color(0xFF32CD32);   // A strong, vivid Lime Green
    const Color dangerRed = Color(0xFFFF4500);      // A striking, energetic Orange-Red
    const Color warmGold = Color(0xFFFFA500);       // A brilliant, unmistakable Orange Gold for coins
    const Color focusTimeBlue = Color(0xFF1E90FF);  // A deep, clear Dodger Blue for focus
    const Color breakTimePink = Color(0xFFFA69B4); // A lively, unmistakable Hot Pink for break


    return MaterialApp(
      title: 'Study Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: primaryBg,
        appBarTheme: AppBarTheme(
          backgroundColor: cardBg,
          foregroundColor: darkText,
          elevation: 2,
          // Using GoogleFonts for the AppBar title
          titleTextStyle: GoogleFonts.comfortaa(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryAccent, // Primary button color
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            // Using GoogleFonts for button text
            textStyle: GoogleFonts.comfortaa(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: mutedText,
            // Using GoogleFonts for text buttons
            textStyle: GoogleFonts.comfortaa(),
          ),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: cardBg,
          titleTextStyle: GoogleFonts.comfortaa(color: darkText, fontSize: 20, fontWeight: FontWeight.bold),
          contentTextStyle: GoogleFonts.comfortaa(color: mutedText, fontSize: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: primaryBg,
          labelStyle: GoogleFonts.comfortaa(color: mutedText),
          hintStyle: GoogleFonts.comfortaa(color: mutedText.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryAccent, width: 1.5),
          ),
        ),
        // Global text theme using GoogleFonts
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.comfortaa(fontSize: 52, fontWeight: FontWeight.bold, color: darkText, letterSpacing: 1.2), // Timer
          headlineMedium: GoogleFonts.comfortaa(fontSize: 22, fontWeight: FontWeight.w600, color: darkText), // Focus/Break
          bodyLarge: GoogleFonts.comfortaa(fontSize: 19, color: darkText), // Level, Monster
          bodyMedium: GoogleFonts.comfortaa(fontSize: 16, color: mutedText), // Sessions, XP
          labelLarge: GoogleFonts.comfortaa(fontSize: 18, color: warmGold), // Coins
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.purple,
        ).copyWith(
          primary: primaryAccent,
          secondary: successGreen,
          error: dangerRed,
          surface: cardBg,
          background: primaryBg,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          onSurface: darkText,
          onBackground: darkText,
        ),
      ),
      home: StudyHomePage(
        focusTimeColor: focusTimeBlue,
        breakTimeColor: breakTimePink,
        successColor: successGreen,
        dangerColor: dangerRed,
        primaryAccent: primaryAccent,
      ),
    );
  }
}

class StudyHomePage extends StatefulWidget {
  final Color focusTimeColor;
  final Color breakTimeColor;
  final Color successColor;
  final Color dangerColor;
  final Color primaryAccent;


  StudyHomePage({
    required this.focusTimeColor,
    required this.breakTimeColor,
    required this.successColor,
    required this.dangerColor,
    required this.primaryAccent,
  });

  @override
  _StudyHomePageState createState() => _StudyHomePageState();
}

class _StudyHomePageState extends State<StudyHomePage> {
  int studyDuration = 25 * 60;
  int breakDuration = 5 * 60;
  int remainingSeconds = 25 * 60;
  bool isRunning = false;
  bool isBreak = false;
  Timer? timer;

  int coins = 0;
  int level = 1;
  int currentXp = 0;
  final int xpPerSession = 10;
  int sessionsCompleted = 0;

  int avatarIndex = 0;

  List<String> avatars = [
    "🧑‍🎓", // Level 1 default
    "🧙", // Unlocked at Level 2
    "🧛", // Unlocked at Level 3
    "🧝", // Unlocked at Level 4
    "🧞", // Unlocked at Level 5
    "👸", // Unlocked at Level 6
    "🤖", // Unlocked at Level 7
  ];

  final List<int> levelUpThresholds = [
    0,    // Level 1
    50,   // Level 2 requires 50 XP
    120,  // Level 3 requires 120 XP
    220,  // Level 4 requires 220 XP
    350,  // Level 5 requires 350 XP
    500,  // Level 6 requires 500 XP
    700,  // Level 7 requires 700 XP
    950,  // Level 8 requires 950 XP
    1250, // Level 9 requires 1250 XP
    1600, // Level 10 requires 1600 XP
    2000, // Level 11 requires 2000 XP
  ];

  List<int> avatarPrices = [0, 20, 40, 60, 80, 100, 120];

  List<bool> ownedAvatars = [];

  List<String> monsters = [
    "😴",
    "📱",
    "😵",
  ];

  late String currentMonster;

  TextEditingController focusController = TextEditingController(text: "25");
  TextEditingController breakController = TextEditingController(text: "5");

  @override
  void initState() {
    super.initState();
    currentMonster = monsters[Random().nextInt(monsters.length)];
    ownedAvatars = List<bool>.filled(avatars.length, false);
    ownedAvatars[0] = true;
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      level = prefs.getInt('level') ?? 1;
      currentXp = prefs.getInt('currentXp') ?? 0;
      sessionsCompleted = prefs.getInt('sessionsCompleted') ?? 0;
      avatarIndex = prefs.getInt('avatarIndex') ?? 0;

      List<String>? storedOwned = prefs.getStringList('ownedAvatars');
      if (storedOwned != null && storedOwned.length == avatars.length) {
        ownedAvatars = storedOwned.map((e) => e == "true").toList();
      } else {
        ownedAvatars = List<bool>.filled(avatars.length, false);
        ownedAvatars[0] = true;
      }
    });
    _checkLevelUp(isInitialLoad: true);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('level', level);
    await prefs.setInt('currentXp', currentXp);
    await prefs.setInt('sessionsCompleted', sessionsCompleted);
    await prefs.setInt('avatarIndex', avatarIndex);
    await prefs.setStringList('ownedAvatars', ownedAvatars.map((e) => e ? "true" : "false").toList());
  }

  void startTimer() {
    int? focusMinutes = int.tryParse(focusController.text);
    if (focusMinutes == null || focusMinutes <= 0) {
      _showInvalidDurationDialog();
      return;
    }

    studyDuration = focusMinutes * 60;

    int? breakMinutes = int.tryParse(breakController.text);
    if (breakMinutes == null || breakMinutes <= 0) {
      breakDuration = 5 * 60;
      breakController.text = "5";
    } else {
      breakDuration = breakMinutes * 60;
    }

    setState(() {
      isRunning = true;
      isBreak = false;
      remainingSeconds = studyDuration;
      currentMonster = monsters[Random().nextInt(monsters.length)];
    });

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        t.cancel();
        onSessionComplete();
      }
    });
  }

  void onSessionComplete() {
    if (!isBreak) {
      coins += 10;
      sessionsCompleted++;
      currentXp += xpPerSession;

      _checkLevelUp();
      _saveData();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("🎉 Victory!", style: Theme.of(context).dialogTheme.titleTextStyle),
          content: Text("You defeated $currentMonster!\n\n🪙 Coins earned: +10\n✨ XP gained: +$xpPerSession\n🎖 Level: $level", style: Theme.of(context).dialogTheme.contentTextStyle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startBreak();
              },
              child: Text("🌴 Take a Break"),
            )
          ],
        ),
      );
    } else {
      startFocus();
    }
  }

  void _checkLevelUp({bool isInitialLoad = false}) {
    bool leveledUp = false;
    while (level < levelUpThresholds.length && currentXp >= levelUpThresholds[level]) {
      level++;
      leveledUp = true;

      if (level <= avatars.length) {
        int avatarToAwardIndex = level - 1;
        if (!ownedAvatars[avatarToAwardIndex]) {
          ownedAvatars[avatarToAwardIndex] = true;
          if (!isInitialLoad) {
            Future.delayed(Duration(milliseconds: 50), () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("🎉 New Avatar Unlocked!", style: Theme.of(context).dialogTheme.titleTextStyle),
                  content: Text("You've unlocked the ${avatars[avatarToAwardIndex]} avatar for reaching Level $level! Check the shop to select it.", style: Theme.of(context).dialogTheme.contentTextStyle),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text("Awesome!")),
                  ],
                ),
              );
            });
          }
        }
      }
    }
    if (leveledUp) {
      setState(() {});
      _saveData();
    }
  }

  int? getNextLevelXp() {
    if (level >= levelUpThresholds.length) {
      return null;
    }
    return levelUpThresholds[level];
  }

  void startFocus() {
    setState(() {
      isBreak = false;
      remainingSeconds = studyDuration;
      isRunning = false;
    });
  }

  void startBreak() {
    setState(() {
      isBreak = true;
      remainingSeconds = breakDuration;
      isRunning = false;
    });
  }

  void resetTimer() {
    if (isRunning && remainingSeconds > 0) {
      timer?.cancel();
      _showDefeatDialog();
    } else {
      timer?.cancel();
      setState(() {
        remainingSeconds = isBreak ? breakDuration : studyDuration;
        isRunning = false;
      });
    }
  }

  void _showInvalidDurationDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("⚠️ Invalid Focus Duration", style: Theme.of(context).dialogTheme.titleTextStyle),
        content: Text("Please set a focus duration greater than 0.", style: Theme.of(context).dialogTheme.contentTextStyle),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        ],
      ),
    );
  }

  void _showDefeatDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("😈 You Lost...", style: Theme.of(context).dialogTheme.titleTextStyle),
        content: Text("Oh no! $currentMonster defeated you!\nNo coins earned this session.", style: Theme.of(context).dialogTheme.contentTextStyle),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                remainingSeconds = isBreak ? breakDuration : studyDuration;
                isRunning = false;
              });
            },
            child: Text("Try Again"),
          )
        ],
      ),
    );
  }

  String formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void showDurationPicker() {
    focusController.text = (studyDuration ~/ 60).toString();
    breakController.text = (breakDuration ~/ 60).toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("⏱ Customize Durations", style: Theme.of(context).dialogTheme.titleTextStyle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: focusController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Focus Duration (mins) *required*",
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: breakController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Break Duration (mins) (optional)",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              int? focusMinutes = int.tryParse(focusController.text);
              if (focusMinutes == null || focusMinutes <= 0) {
                _showInvalidDurationDialog();
                return;
              }

              int? breakMinutes = int.tryParse(breakController.text);
              if (breakMinutes == null || breakMinutes <= 0) {
                breakDuration = 5 * 60;
                breakController.text = "5";
              } else {
                breakDuration = breakMinutes * 60;
              }

              setState(() {
                studyDuration = focusMinutes * 60;
                remainingSeconds = studyDuration;
              });

              Navigator.pop(context);
            },
            child: Text("Save"),
          )
        ],
      ),
    );
  }

  void openShop() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("🛒 Avatar Shop", style: Theme.of(context).dialogTheme.titleTextStyle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(avatars.length, (index) {
              bool owned = ownedAvatars[index];
              bool canBuy = coins >= avatarPrices[index];
              return ListTile(
                leading: Text(
                  avatars[index],
                  style: TextStyle(fontSize: 28),
                ),
                title: Text(
                  owned ? "Owned" : "Price: ${avatarPrices[index]} coins",
                  style: Theme.of(context).dialogTheme.contentTextStyle,
                ),
                trailing: owned
                    ? (avatarIndex == index
                        ? Icon(Icons.check_circle_rounded, color: widget.successColor)
                        : TextButton(
                            child: Text("Select"),
                            onPressed: () {
                              setState(() {
                                avatarIndex = index;
                                _saveData();
                              });
                              Navigator.pop(context);
                            },
                          ))
                    : TextButton(
                        child: Text("Buy",
                            style: TextStyle(
                                color: canBuy ? widget.primaryAccent : Colors.grey.shade400)),
                        onPressed: canBuy
                            ? () {
                                setState(() {
                                  coins -= avatarPrices[index];
                                  ownedAvatars[index] = true;
                                  avatarIndex = index;
                                  _saveData();
                                });
                                Navigator.pop(context);
                              }
                            : null,
                      ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    focusController.dispose();
    breakController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int? xpToNextLevel = getNextLevelXp();
    // Ensure xpProgress is calculated correctly for animation
    double xpProgress = xpToNextLevel != null && xpToNextLevel > 0
        ? (currentXp / xpToNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Study Quest"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: showDurationPicker,
          ),
          IconButton(
            icon: Icon(Icons.store_outlined),
            onPressed: openShop,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main Content Card
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Animated Avatar
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            child: Text(
                              avatars[avatarIndex],
                              key: ValueKey<int>(avatarIndex), // Key changes with avatar
                              style: TextStyle(fontSize: 80),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Level: $level",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 10),
                          // Animated XP Progress Bar
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: xpProgress),
                            duration: const Duration(milliseconds: 500),
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              );
                            },
                          ),
                          SizedBox(height: 8),
                          Text(
                            xpToNextLevel != null
                                ? "XP: $currentXp / $xpToNextLevel"
                                : "XP: $currentXp (Max Level!)",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Sessions Completed: $sessionsCompleted",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Coins: $coins 🪙",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  Text(
                    isBreak ? "Break Time" : "Focus Time",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isBreak ? widget.breakTimeColor : widget.focusTimeColor,
                    ),
                  ),
                  SizedBox(height: 8), // Reduced space slightly for "What's Next"
                  // "What's Next" Text
                  Text(
                    isRunning
                        ? (isBreak ? "Enjoy your break!" : "Stay focused!")
                        : (isBreak ? "Ready for next focus session!" : "Ready to start a new session!"),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12), // Adjust spacing after "What's Next"
                  // Animated Timer Numbers
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200), // Quick animation for numbers
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      formatTime(remainingSeconds),
                      key: ValueKey<int>(remainingSeconds), // Key changes with time
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isRunning ? null : startTimer,
                          icon: Icon(Icons.play_arrow_rounded),
                          label: Text("Start"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.successColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isRunning || remainingSeconds != (isBreak ? breakDuration : studyDuration)
                              ? resetTimer
                              : null,
                          icon: Icon(Icons.stop_rounded),
                          label: Text("Stop"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.dangerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Current Distraction Monster:",
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  // Animated Monster
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Text(
                      currentMonster,
                      key: ValueKey<String>(currentMonster), // Key changes with monster
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}