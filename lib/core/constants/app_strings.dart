/// Centralized string constants for the NGO ERP application.
///
/// Keeping all user-facing strings in one place makes future
/// localization (l10n) and copy updates trivial.
class AppStrings {
  AppStrings._(); // Prevent instantiation

  // ── App-level ──────────────────────────────────────────────
  static const String appTitle = 'MH14 Animal Hospital';
  static const String appTagline = 'Together We Save Lives';

  // ── Auth ───────────────────────────────────────────────────
  static const String welcomeTitle = 'Welcome to MH14 Animal Hospital';
  static const String welcomeHeading = 'Helping Animals\nTogether';
  static const String welcomeDescription =
      'Join our community to\nmake a real difference in\nthe lives of animals in need.';
  static const String getStarted = 'Get Started';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String signIn = 'Sign In';
  static const String reportRescues = 'Report Rescues';
  static const String supportTreatments = 'Support Treatments';
  static const String adopt = 'Adopt';
  static const String volunteer = 'Volunteer';
  static const String loginTitle = 'Login';
  static const String loginHeading = 'Welcome Back';
  static const String loginSubtitle = 'Log in to your account to continue.';
  static const String loginButtonLabel = 'Login';
  static const String emailLabel = 'Email Address *';
  static const String emailHint = 'jane@example.com';
  static const String passwordLabel = 'Password *';
  static const String passwordHint = '••••••••';
  static const String dontHaveAccount = 'Don\'t have an account?';
  static const String signUp = 'Sign Up';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsConditions = 'Terms & Conditions';

  // ── Admin Dashboard ────────────────────────────────────────
  static const String dashboardTitle = 'Admin Dashboard';
  static const String dashboardTransitionHeading =
      'Preparing Your Community Dashboard';
  static const String dashboardTransitionSubtitle =
      'Just a moment while we fetch the latest furry friends looking for a home.';
  static const String dashboardOverview = 'Dashboard Overview';
  static const String menuTitle = 'MH14 Animal Hospital';

  // ── Menu Items ─────────────────────────────────────────────
  static const String animalManagement = 'Animal Management';
  static const String employeeManagement = 'Employee Management';

  // ── KPI Labels ─────────────────────────────────────────────
  static const String admissionsToday = 'Admissions Today';
  static const String criticalAnimals = 'Critical Animals';
  static const String recoveries = 'Recoveries';
}
