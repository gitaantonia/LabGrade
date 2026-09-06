import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =========================================================================
// PALET WARNA — BIRU PASTEL + PUTIH
// =========================================================================
const Color kBgWhite = Color(0xFFFFFFFF);
const Color kBgSoft = Color(0xFFF3F9FC); // putih kebiruan untuk background
const Color kBluePale = Color(0xFFDCEEF9); // biru pastel sangat muda
const Color kBlueLight = Color(0xFFAED9EE); // biru pastel
const Color kBlueMid = Color(0xFF6FB6DE); // biru aksen (tombol, appbar)
const Color kBlueDark = Color(0xFF2E6A8E); // biru tua untuk teks judul

// =========================================================================
// STRUKTUR DATA GLOBAL (logika tidak berubah dari versi sebelumnya)
// =========================================================================
List<Map<String, dynamic>> mataPraktikum = [];

void main() {
  runApp(const LabGradeApp());
}

class LabGradeApp extends StatelessWidget {
  const LabGradeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = GoogleFonts.nunitoTextTheme();
    final judulFont = GoogleFonts.baloo2();

    return MaterialApp(
      title: 'LabGrade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBgSoft,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBlueMid,
          brightness: Brightness.light,
          primary: kBlueMid,
          secondary: kBlueLight,
          surface: kBgWhite,
        ),
        textTheme: baseTextTheme.copyWith(
          headlineMedium: judulFont.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: kBlueDark,
          ),
          headlineSmall: judulFont.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: kBlueDark,
          ),
          titleLarge: judulFont.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: kBlueDark,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: kBlueDark,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kBlueMid,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: judulFont.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          color: kBgWhite,
          elevation: 3,
          shadowColor: kBlueLight.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kBluePale,
          labelStyle: GoogleFonts.nunito(
            color: kBlueDark,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: kBlueMid, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kBlueMid,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kBlueDark),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: kBlueMid,
          foregroundColor: Colors.white,
        ),
        listTileTheme: ListTileThemeData(
          titleTextStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: kBlueDark,
          ),
          subtitleTextStyle: GoogleFonts.nunito(color: Colors.black54),
        ),
      ),
      home: const LandingScreen(),
    );
  }
}

class MyApp extends LabGradeApp {
  const MyApp({super.key});
}

// =========================================================================
// FUNGSI LOGIKA BERSAMA (sama seperti versi sebelumnya)
// =========================================================================

int cariIndexPraktikan(List<dynamic> praktikanList, String nim) {
  for (int i = 0; i < praktikanList.length; i++) {
    if (praktikanList[i]['nim'] == nim) return i;
  }
  return -1;
}

void syncNilaiKeys(Map<String, dynamic> mp) {
  Map<String, dynamic> bobot = mp['bobot'];
  List<dynamic> praktikanList = mp['praktikan'];
  for (var praktikan in praktikanList) {
    Map<String, dynamic> nilai = praktikan['nilai'] ?? {};
    for (String key in bobot.keys) {
      if (!nilai.containsKey(key)) nilai[key] = 0.0;
    }
    nilai.removeWhere((key, value) => !bobot.containsKey(key));
    praktikan['nilai'] = nilai;
  }
}

int jumlahKomponenSelainProject(Map<String, dynamic> mp) {
  Map<String, dynamic> bobot = mp['bobot'];
  return bobot.keys.where((k) => k.toLowerCase() != 'project').length;
}

double hitungTotalSebelumProject(
  Map<String, dynamic> praktikan,
  Map<String, dynamic> mp,
) {
  Map<String, dynamic> nilai = praktikan['nilai'];
  Map<String, dynamic> bobot = mp['bobot'];
  double total = 0;
  for (String komponen in bobot.keys) {
    if (komponen.toLowerCase() == 'project') continue;
    total += (nilai[komponen] ?? 0.0) as double;
  }
  return total;
}

double hitungRataRataSebelumProject(
  Map<String, dynamic> praktikan,
  Map<String, dynamic> mp,
) {
  int jumlah = jumlahKomponenSelainProject(mp);
  if (jumlah == 0) return 0;
  return hitungTotalSebelumProject(praktikan, mp) / jumlah;
}

double hitungNilaiAkhir(
  Map<String, dynamic> praktikan,
  Map<String, dynamic> mp,
) {
  Map<String, dynamic> bobot = mp['bobot'];
  Map<String, dynamic> nilai = praktikan['nilai'];
  double akhir = 0;
  for (String komponen in bobot.keys) {
    double nilaiKomponen = (nilai[komponen] ?? 0.0) as double;
    double bobotKomponen = (bobot[komponen] ?? 0.0) as double;
    akhir += nilaiKomponen * bobotKomponen / 100;
  }
  return akhir;
}

// =========================================================================
// LANDING SCREEN — Logo animasi + tombol mulai
// =========================================================================

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBluePale, kBgWhite],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo animasi: cincin berputar + ikon melayang naik-turun
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value; // 0..1
                  final rotasi = t * 2 * math.pi;
                  final naikTurun = math.sin(t * 2 * math.pi) * 8;
                  final skala = 1.0 + math.sin(t * 2 * math.pi) * 0.04;

                  return Transform.translate(
                    offset: Offset(0, naikTurun),
                    child: Transform.scale(
                      scale: skala,
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: rotasi,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: [
                                      kBlueLight.withOpacity(0.2),
                                      kBlueMid,
                                      kBlueLight.withOpacity(0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 110,
                              height: 110,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: kBgWhite,
                                boxShadow: [
                                  BoxShadow(
                                    color: kBlueLight,
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 56,
                                color: kBlueMid,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                'LabGrade',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Sistem Pengelolaan Penilaian & Pembagian Kelompok Praktikum',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Mulai'),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// LOGIN SCREEN
// =========================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;

  void _login() {
    if (_usernameCtrl.text == 'aslab' && _passwordCtrl.text == 'aslab123') {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _error = 'Username atau password salah.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kBluePale, kBgWhite],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kBluePale,
                        ),
                        child: const Icon(
                          Icons.lock_person_rounded,
                          size: 36,
                          color: kBlueMid,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Login Aslab',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usernameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        onSubmitted: (_) => _login(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// HOME SCREEN — Daftar Mata Praktikum
// =========================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _tampilkanDataTim() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Data Kelompok'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lucy Katarina Naibaho (124240040)'),
            Text('Gevinta Aprilia Putri (124240114)'),
            Text('Serena Luna Halim (124240035)'),
            Text('Gita Antonia Sipayung (124240132)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahMataPraktikum() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const FormBobotScreen()));
    if (result == true) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LabGrade'),
        actions: [
          IconButton(
            tooltip: 'Data Tim',
            onPressed: _tampilkanDataTim,
            icon: const Icon(Icons.groups),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: mataPraktikum.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 56,
                      color: kBlueLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada mata praktikum',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tekan tombol + untuk menambahkan',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: mataPraktikum.length,
              itemBuilder: (context, index) {
                final mp = mataPraktikum[index];
                final jumlahPraktikan = (mp['praktikan'] as List).length;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kBluePale,
                      ),
                      child: const Icon(Icons.book_rounded, color: kBlueMid),
                    ),
                    title: Text(mp['nama']),
                    subtitle: Text('$jumlahPraktikan praktikan'),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: kBlueMid,
                    ),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MataPraktikumScreen(mp: mp),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahMataPraktikum,
        icon: const Icon(Icons.add),
        label: const Text('Mata Praktikum'),
      ),
    );
  }
}

// =========================================================================
// FORM BOBOT — Tambah Mata Praktikum & Atur Bobot Komponen
// =========================================================================

class FormBobotScreen extends StatefulWidget {
  final Map<String, dynamic>? mataPraktikumExisting;

  const FormBobotScreen({super.key, this.mataPraktikumExisting});

  @override
  State<FormBobotScreen> createState() => _FormBobotScreenState();
}

class _FormBobotScreenState extends State<FormBobotScreen> {
  late TextEditingController _namaCtrl;
  final List<TextEditingController> _namaKomponenCtrl = [];
  final List<TextEditingController> _bobotKomponenCtrl = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    final mp = widget.mataPraktikumExisting;
    _namaCtrl = TextEditingController(text: mp?['nama'] ?? '');

    if (mp != null) {
      final Map<String, dynamic> bobot = mp['bobot'];
      bobot.forEach((k, v) {
        _namaKomponenCtrl.add(TextEditingController(text: k));
        _bobotKomponenCtrl.add(TextEditingController(text: v.toString()));
      });
    } else {
      _namaKomponenCtrl.add(TextEditingController());
      _bobotKomponenCtrl.add(TextEditingController());
    }
  }

  void _tambahBaris() {
    setState(() {
      _namaKomponenCtrl.add(TextEditingController());
      _bobotKomponenCtrl.add(TextEditingController());
    });
  }

  void _hapusBaris(int index) {
    setState(() {
      _namaKomponenCtrl.removeAt(index);
      _bobotKomponenCtrl.removeAt(index);
    });
  }

  void _simpan() {
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) {
      setState(() => _error = 'Nama mata praktikum tidak boleh kosong.');
      return;
    }

    Map<String, double> bobotBaru = {};
    double total = 0;

    for (int i = 0; i < _namaKomponenCtrl.length; i++) {
      final namaKomponen = _namaKomponenCtrl[i].text.trim();
      final bobotStr = _bobotKomponenCtrl[i].text.trim();
      if (namaKomponen.isEmpty || bobotStr.isEmpty) {
        setState(
          () => _error = 'Semua komponen harus memiliki nama dan bobot.',
        );
        return;
      }
      final bobot = double.tryParse(bobotStr);
      if (bobot == null || bobot < 0) {
        setState(() => _error = 'Bobot "$namaKomponen" tidak valid.');
        return;
      }
      bobotBaru[namaKomponen] = bobot;
      total += bobot;
    }

    if (total != 100) {
      setState(
        () => _error = 'Total bobot saat ini $total%, harus tepat 100%.',
      );
      return;
    }

    if (!bobotBaru.keys.any((k) => k.toLowerCase() == 'project')) {
      setState(() => _error = 'Harus ada satu komponen bernama "project".');
      return;
    }

    if (widget.mataPraktikumExisting == null) {
      mataPraktikum.add({
        'nama': nama,
        'bobot': bobotBaru,
        'praktikan': <Map<String, dynamic>>[],
      });
    } else {
      final mp = widget.mataPraktikumExisting!;
      mp['nama'] = nama;
      mp['bobot'] = bobotBaru;
      syncNilaiKeys(mp);
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final modeEdit = widget.mataPraktikumExisting != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(modeEdit ? 'Atur Bobot Komponen' : 'Tambah Mata Praktikum'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _namaCtrl,
            enabled: !modeEdit,
            decoration: const InputDecoration(labelText: 'Nama Mata Praktikum'),
          ),
          const SizedBox(height: 18),
          Text(
            'Komponen Penilaian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text(
            'Total harus 100%, wajib ada komponen "project"',
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < _namaKomponenCtrl.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _namaKomponenCtrl[i],
                      decoration: const InputDecoration(
                        labelText: 'Nama komponen',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _bobotKomponenCtrl[i],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bobot %'),
                    ),
                  ),
                  IconButton(
                    onPressed: _namaKomponenCtrl.length > 1
                        ? () => _hapusBaris(i)
                        : null,
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          TextButton.icon(
            onPressed: _tambahBaris,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Komponen'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 22),
          FilledButton(onPressed: _simpan, child: const Text('Simpan')),
        ],
      ),
    );
  }
}

// =========================================================================
// MATA PRAKTIKUM SCREEN — Menu per mata praktikum
// =========================================================================

class MataPraktikumScreen extends StatefulWidget {
  final Map<String, dynamic> mp;
  const MataPraktikumScreen({super.key, required this.mp});

  @override
  State<MataPraktikumScreen> createState() => _MataPraktikumScreenState();
}

class _MataPraktikumScreenState extends State<MataPraktikumScreen> {
  Future<void> _buka(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mp = widget.mp;
    final menu = [
      (
        'Atur Bobot Komponen',
        Icons.tune_rounded,
        () => _buka(FormBobotScreen(mataPraktikumExisting: mp)),
      ),
      (
        'Kelola Data Praktikan',
        Icons.people_alt_rounded,
        () => _buka(KelolaPraktikanScreen(mp: mp)),
      ),
      (
        'Input Nilai',
        Icons.edit_note_rounded,
        () => _buka(InputNilaiScreen(mp: mp)),
      ),
      (
        'Bagi Kelompok Project',
        Icons.groups_2_rounded,
        () => _buka(BagiKelompokScreen(mp: mp)),
      ),
      (
        'Input Nilai Project',
        Icons.assignment_turned_in_rounded,
        () => _buka(InputNilaiProjectScreen(mp: mp)),
      ),
      (
        'Rekap Nilai Akhir',
        Icons.leaderboard_rounded,
        () => _buka(RekapNilaiScreen(mp: mp)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(mp['nama'])),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: menu.length,
        itemBuilder: (context, index) {
          final (title, icon, onTap) = menu[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBluePale,
                ),
                child: Icon(icon, color: kBlueMid),
              ),
              title: Text(title),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: kBlueMid,
              ),
              onTap: onTap,
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// KELOLA DATA PRAKTIKAN
// =========================================================================

class KelolaPraktikanScreen extends StatefulWidget {
  final Map<String, dynamic> mp;
  const KelolaPraktikanScreen({super.key, required this.mp});

  @override
  State<KelolaPraktikanScreen> createState() => _KelolaPraktikanScreenState();
}

class _KelolaPraktikanScreenState extends State<KelolaPraktikanScreen> {
  Future<void> _tambahPraktikan() async {
    final namaCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Tambah Praktikan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nimCtrl,
                decoration: const InputDecoration(labelText: 'NIM'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final nama = namaCtrl.text.trim();
                final nim = nimCtrl.text.trim();
                final praktikanList = widget.mp['praktikan'] as List<dynamic>;

                if (nama.isEmpty || nim.isEmpty) {
                  setDialogState(
                    () => error = 'Nama dan NIM tidak boleh kosong.',
                  );
                  return;
                }
                if (cariIndexPraktikan(praktikanList, nim) != -1) {
                  setDialogState(() => error = 'NIM sudah terdaftar.');
                  return;
                }

                Map<String, double> nilaiAwal = {};
                for (String key in (widget.mp['bobot'] as Map).keys) {
                  nilaiAwal[key] = 0.0;
                }
                praktikanList.add({
                  'nama': nama,
                  'nim': nim,
                  'nilai': nilaiAwal,
                  'kelompok': 0,
                  'nilaiAkhir': 0.0,
                });
                setState(() {});
                Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _ubahPraktikan(Map<String, dynamic> praktikan) async {
    final namaCtrl = TextEditingController(text: praktikan['nama']);
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ubah Nama Praktikan'),
        content: TextField(
          controller: namaCtrl,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (namaCtrl.text.trim().isNotEmpty) {
                praktikan['nama'] = namaCtrl.text.trim();
                setState(() {});
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _hapusPraktikan(int index) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Praktikan'),
        content: const Text('Yakin ingin menghapus praktikan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (konfirmasi == true) {
      (widget.mp['praktikan'] as List).removeAt(index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Data Praktikan')),
      body: praktikanList.isEmpty
          ? const Center(child: Text('Belum ada praktikan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: praktikanList.length,
              itemBuilder: (context, index) {
                final p = praktikanList[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    title: Text(p['nama']),
                    subtitle: Text(
                      'NIM: ${p['nim']} • Kelompok: ${p['kelompok']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _ubahPraktikan(p),
                          icon: const Icon(Icons.edit_rounded, color: kBlueMid),
                        ),
                        IconButton(
                          onPressed: () => _hapusPraktikan(index),
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahPraktikan,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =========================================================================
// INPUT NILAI (komponen selain project)
// =========================================================================

class InputNilaiScreen extends StatefulWidget {
  final Map<String, dynamic> mp;
  const InputNilaiScreen({super.key, required this.mp});

  @override
  State<InputNilaiScreen> createState() => _InputNilaiScreenState();
}

class _InputNilaiScreenState extends State<InputNilaiScreen> {
  final Map<String, TextEditingController> _controllers = {};

  String _ctrlKey(String nim, String komponen) => '$nim|$komponen';

  TextEditingController _ctrlFor(
    Map<String, dynamic> praktikan,
    String komponen,
  ) {
    final key = _ctrlKey(praktikan['nim'], komponen);
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: (praktikan['nilai'][komponen] ?? 0.0).toString(),
      ),
    );
  }

  void _simpanPraktikan(
    Map<String, dynamic> praktikan,
    List<String> komponenList,
  ) {
    for (String komponen in komponenList) {
      final ctrl = _ctrlFor(praktikan, komponen);
      final nilai = double.tryParse(ctrl.text.trim());
      if (nilai == null || nilai < 0 || nilai > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Nilai $komponen untuk ${praktikan['nama']} harus 0-100.',
            ),
          ),
        );
        return;
      }
      praktikan['nilai'][komponen] = nilai;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Nilai ${praktikan['nama']} disimpan.')),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    final bobot = widget.mp['bobot'] as Map<String, dynamic>;
    final komponenList = bobot.keys
        .where((k) => k.toLowerCase() != 'project')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai')),
      body: praktikanList.isEmpty
          ? const Center(child: Text('Belum ada praktikan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: praktikanList.length,
              itemBuilder: (context, index) {
                final p = praktikanList[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          p['nama'],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text('NIM: ${p['nim']}'),
                        const SizedBox(height: 14),
                        for (String komponen in komponenList)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TextField(
                              controller: _ctrlFor(p, komponen),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Nilai $komponen (0-100)',
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: () => _simpanPraktikan(p, komponenList),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================================
// HITUNG NILAI SEBELUM PROJECT
// =========================================================================

class HitungSebelumProjectScreen extends StatelessWidget {
  final Map<String, dynamic> mp;
  const HitungSebelumProjectScreen({super.key, required this.mp});

  @override
  Widget build(BuildContext context) {
    final praktikanList = mp['praktikan'] as List<dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai Sebelum Project')),
      body: praktikanList.isEmpty
          ? const Center(child: Text('Belum ada praktikan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: praktikanList.length,
              itemBuilder: (context, index) {
                final p = praktikanList[index];
                final total = hitungTotalSebelumProject(p, mp);
                final rataRata = hitungRataRataSebelumProject(p, mp);
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    title: Text(p['nama']),
                    subtitle: Text('NIM: ${p['nim']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Total: ${total.toStringAsFixed(2)}'),
                        Text('Rata-rata: ${rataRata.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// =========================================================================
// BAGI KELOMPOK PROJECT
// =========================================================================

class BagiKelompokScreen extends StatefulWidget {
  final Map<String, dynamic> mp;
  const BagiKelompokScreen({super.key, required this.mp});

  @override
  State<BagiKelompokScreen> createState() => _BagiKelompokScreenState();
}

class _BagiKelompokScreenState extends State<BagiKelompokScreen> {
  String? _error;

  void _bagi() {
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    if (praktikanList.isEmpty) {
      setState(() => _error = 'Belum ada praktikan untuk dibagi kelompok.');
      return;
    }
    for (final praktikan in praktikanList) {
      final nilaiSebelumProject = hitungRataRataSebelumProject(
        praktikan,
        widget.mp,
      );
      final nilaiSebelumKoma = nilaiSebelumProject.floor();
      praktikan['kelompok'] = nilaiSebelumKoma.isOdd ? 'Ganjil' : 'Genap';
    }
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Bagi Kelompok Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nilai di belakang koma diabaikan. Nilai sebelum koma ganjil '
              'masuk Kelompok Ganjil, sedangkan nilai genap masuk Kelompok Genap.',
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _bagi,
              child: const Text('Bagi Berdasarkan Nilai'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: praktikanList.length,
                itemBuilder: (context, index) {
                  final p = praktikanList[index];
                  final nilaiSebelumProject = hitungRataRataSebelumProject(
                    p,
                    widget.mp,
                  );
                  final nilaiSebelumKoma = nilaiSebelumProject.floor();
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      title: Text(p['nama']),
                      subtitle: Text(
                        'NIM: ${p['nim']}\n'
                        'Nilai sebelum project: '
                        '${nilaiSebelumProject.toStringAsFixed(2)} '
                        '(dipakai: $nilaiSebelumKoma)',
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        'Kelompok ${p['kelompok']}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// INPUT NILAI PROJECT & HITUNG NILAI AKHIR
// =========================================================================

class InputNilaiProjectScreen extends StatefulWidget {
  final Map<String, dynamic> mp;
  const InputNilaiProjectScreen({super.key, required this.mp});

  @override
  State<InputNilaiProjectScreen> createState() =>
      _InputNilaiProjectScreenState();
}

class _InputNilaiProjectScreenState extends State<InputNilaiProjectScreen> {
  final Map<String, TextEditingController> _controllers = {};
  String? _keyProject;
  String? _error;

  @override
  void initState() {
    super.initState();
    final bobot = widget.mp['bobot'] as Map<String, dynamic>;
    for (String key in bobot.keys) {
      if (key.toLowerCase() == 'project') {
        _keyProject = key;
        break;
      }
    }
  }

  TextEditingController _ctrlFor(Map<String, dynamic> praktikan) {
    return _controllers.putIfAbsent(
      praktikan['nim'],
      () => TextEditingController(
        text: (praktikan['nilai'][_keyProject] ?? 0.0).toString(),
      ),
    );
  }

  void _simpanSemua() {
    if (_keyProject == null) {
      setState(
        () => _error =
            'Komponen "project" tidak ditemukan pada bobot mata praktikum ini.',
      );
      return;
    }
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    for (var p in praktikanList) {
      final ctrl = _ctrlFor(p);
      final nilai = double.tryParse(ctrl.text.trim());
      if (nilai == null || nilai < 0 || nilai > 100) {
        setState(
          () => _error = 'Nilai project ${p['nama']} harus antara 0-100.',
        );
        return;
      }
      p['nilai'][_keyProject] = nilai;
      p['nilaiAkhir'] = hitungNilaiAkhir(p, widget.mp);
    }
    setState(() => _error = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nilai project & nilai akhir berhasil dihitung.'),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final praktikanList = widget.mp['praktikan'] as List<dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Input Nilai Project')),
      body: praktikanList.isEmpty
          ? const Center(child: Text('Belum ada praktikan.'))
          : ListView(
              padding: const EdgeInsets.all(14),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                for (final p in praktikanList)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${p['nama']}\nNIM: ${p['nim']}'),
                          ),
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: _ctrlFor(p),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Nilai',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _simpanSemua,
                    child: const Text('Simpan Semua & Hitung Nilai Akhir'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

// =========================================================================
// REKAP NILAI AKHIR
// =========================================================================

class RekapNilaiScreen extends StatelessWidget {
  final Map<String, dynamic> mp;
  const RekapNilaiScreen({super.key, required this.mp});

  @override
  Widget build(BuildContext context) {
    final praktikanList = mp['praktikan'] as List<dynamic>;
    final bobot = mp['bobot'] as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Rekap Nilai Akhir')),
      body: praktikanList.isEmpty
          ? const Center(child: Text('Belum ada praktikan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: praktikanList.length,
              itemBuilder: (context, index) {
                final p = praktikanList[index];
                final nilai = p['nilai'] as Map<String, dynamic>;
                final nilaiAkhir = hitungNilaiAkhir(p, mp);

                return Card(
                  child: ExpansionTile(
                    title: Text(p['nama']),
                    subtitle: Text(
                      'NIM: ${p['nim']} • Kelompok ${p['kelompok']}\n'
                      'Nilai akhir: ${nilaiAkhir.toStringAsFixed(2)}',
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    children: [
                      const Divider(),
                      for (final entry in bobot.entries)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.key),
                          subtitle: Text('Bobot ${entry.value}%'),
                          trailing: Text(
                            '${((nilai[entry.key] ?? 0.0) as num).toStringAsFixed(2)}',
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Nilai akhir: ${nilaiAkhir.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
