/// Centralized asset path references for the NGO ERP application.
///
/// Use this class to reference any images, icons, or other static
/// assets so paths are never hardcoded across widgets.
class AppAssets {
  AppAssets._(); // Prevent instantiation

  // ── Base Paths ─────────────────────────────────────────────
  static const String _imagesBase = 'assets/images';
  static const String _iconsBase = 'assets/icons';

  // ── Images ──────────────────────────────────────────────────
  static const String mh14Logo = '$_imagesBase/mh14_logo.jpg';
  static const String welcomeIllustration =
      '$_imagesBase/welcome_illustration.png';
  static const String sleepingAnimals = '$_imagesBase/sleeping_animals.png';

  // ── Icons (add paths as assets are created) ────────────────
  // static const String animalIcon = '$_iconsBase/animal.svg';
}
