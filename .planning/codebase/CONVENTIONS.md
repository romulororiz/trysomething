# Coding Conventions

**Analysis Date:** 2026-03-21

## Naming Patterns

**Files:**
- Snake case: `hobby_card.dart`, `auth_provider.dart`, `discover_feed_screen.dart`
- Class files match class name: `HobbyCard` lives in `hobby_card.dart`
- Repository interfaces and implementations: `hobby_repository.dart` (abstract), `hobby_repository_api.dart` (implementation)
- Notifier classes: `*_notifier.dart` (e.g., `user_hobbies_notifier_test.dart`)

**Functions:**
- camelCase: `getHobbies()`, `saveHobby()`, `toggleStep()`, `buildImage()`
- Private functions prefixed with underscore: `_extractError()`, `_buildBottomContent()`, `_load()`
- Async functions explicitly return `Future`: `Future<Hobby?> getHobbyById(String id)`

**Variables:**
- camelCase: `_pageController`, `selectedCategory`, `isSaved`, `mockRepo`
- Private fields prefixed with underscore: `_prefs`, `_repo`, `_currentIndex`, `_showSwipeHint`
- Late variables: `late SharedPreferences prefs;`, `late PageController _pageController;`
- Final constants for class-level keys: `static const _key = 'user_hobbies';`

**Types and Classes:**
- PascalCase: `UserHobby`, `HobbyStatus`, `AuthState`, `AuthNotifier`
- Enums: PascalCase with lowercase values: `enum AuthStatus { unknown, unauthenticated, loading, authenticated }`
- Model classes: Always use `@freezed` with `part 'file.freezed.dart';` and `part 'file.g.dart';`

**Constants:**
- Global constants: UPPER_SNAKE_CASE when they are configuration values (e.g., `SALT_ROUNDS = 12`)
- Token system values in `app_colors.dart`: camelCase (e.g., `coral`, `warmWhite`, `nearBlack`)
- No raw hex colors in screens — always use `AppColors.*`, `AppTypography.*`, `Spacing.*`, `Motion.*`

## Code Style

**Formatting:**
- Tool: `flutter analyze lib/` enforces style
- Line length: Wrapped for readability (no strict limit enforced)
- Indentation: 2 spaces (Flutter standard)
- Use `const` constructors where possible (linter rule: `prefer_const_constructors`)
- Use `const` declarations where possible (linter rule: `prefer_const_declarations`)

**Linting:**
- Tool: `flutter_lints` package (configured in `analysis_options.yaml`)
- Rules enforced:
  - `prefer_const_constructors: true` — Use const constructors
  - `prefer_const_declarations: true` — Use const for variables
  - `avoid_print: true` — Use `debugPrint` only (see `lib/main.dart` lines 50-58 for debugPrint usage pattern)
  - `prefer_single_quotes: true` — Use single quotes unless string contains apostrophe
  - `sort_child_properties_last: true` — `child:` parameter always last in widgets

**File Organization — Dart:**
- Imports grouped in order:
  1. `dart:` standard library (e.g., `import 'dart:math'`)
  2. `package:flutter/` (e.g., `import 'package:flutter/material.dart'`)
  3. `package:flutter_riverpod/` and third-party packages (e.g., `package:go_router/`, `package:dio/`)
  4. Relative imports (`../../models/`, `../theme/`)
- Section comments: `// ═══════════════════════════════════` separate logical sections (see `lib/main.dart` lines 262-266)
- Class documentation comments: `///` precedes each public class/function (see `lib/theme/app_colors.dart` lines 1-8)
- One import per line, no wildcard imports

**File Organization — TypeScript (Server):**
- Imports at top, grouped:
  1. External packages (`import bcrypt from "bcryptjs";`)
  2. Internal libs (`import { errorResponse } from "../../lib/middleware";`)
- Strict type imports: `import type { VercelRequest } from "@vercel/node";`
- Section comments: `// ── Name ─────────────────────────` separate endpoints/functions
- Function comments above handlers: standard JSDoc style
- 2-space indentation, semicolons required

## Import Organization

**Order:**
1. Dart standard library: `import 'dart:math';`
2. Flutter packages: `import 'package:flutter/material.dart';`
3. Third-party packages: `import 'package:flutter_riverpod/flutter_riverpod.dart';`, `import 'package:dio/dio.dart';`
4. Relative imports: `import '../../models/hobby.dart';`, `import '../theme/app_colors.dart';`

**Path Aliases:**
- Dart: No path aliases configured (all relative imports)
- TypeScript (server): `@lib/*` maps to `lib/*` in `tsconfig.json`

**No Wildcard Imports:**
- Always explicit: `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- Not: `import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;`

## Error Handling

**Patterns:**
- Try/catch in notifiers for API calls — see `lib/providers/auth_provider.dart` lines 87–111
- Catch-all exception handler that uses `_extractError()` to convert to user-facing messages
- For Dio exceptions: Check `e.response?.statusCode` and `e.response?.data` for error details
- Optimistic updates with rollback: Update state immediately, then rollback on API failure with `debugPrint`
- Never silently swallow errors — always log with `debugPrint` when rolling back state
- Sentry error reporting in `lib/core/error/error_reporter.dart` (lines 35-59) captures exceptions with context

**Error Extraction Example:**
```dart
String _extractError(dynamic e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data.containsKey('error')) {
      return data['error'] as String;
    }
    if (e.response?.statusCode == 409) return 'Email already registered';
  }
  return 'Something went wrong. Please try again.';
}
```

**Server Error Response (TypeScript):**
```typescript
export function errorResponse(
  res: VercelResponse,
  status: number,
  message: string
): void {
  res.status(status).json({ error: message });
}
```

## Logging

**Framework:** `debugPrint()` only (not `print()` — violates linter rule `avoid_print`)

**Patterns:**
- Use brackets for scoping: `debugPrint('[GoogleAuth] Attempting sign-in...');`
- Log before long operations: `debugPrint('[GoogleAuth] Calling server...');`
- Log success and failure: `debugPrint('[GoogleAuth] Success!');`
- For errors, include type and stack:
```dart
debugPrint('Type: ${e.runtimeType}');
debugPrint('Error: $e');
debugPrint('Stack: $stackTrace');
```
- Separator lines for major errors (see `lib/main.dart` lines 50-58):
```dart
debugPrint('══════════════════════════════════════════');
debugPrint('Google sign-in FAILED');
debugPrint('══════════════════════════════════════════');
```

**Server Logging:**
- No centralized logger configured
- Use `console.log()` if needed (will appear in Vercel logs)
- Not required for normal operations

## Comments

**When to Comment:**
- Public methods and classes: Always document with `///`
- Complex algorithms: Explain the "why", not the "what"
- Gotchas and platform-specific behavior: Note workarounds (see `lib/main.dart` lines 47-52 for kIsWeb checks)
- Section headers: Use separator comments to group related code (see `lib/main.dart` lines 262-266)

**JSDoc/TSDoc:**
- Dart: Use `///` for public APIs:
```dart
/// Extracts and verifies the JWT from the Authorization header.
/// Returns the userId on success, or null after sending a 401 response.
class ErrorReporter {
  /// Report an error. In debug mode, prints to console.
  void reportError(Object error, StackTrace? stackTrace, {String? context}) {
```

- TypeScript: Use JSDoc `/**  */`:
```typescript
/**
 * Extracts and verifies the JWT from the Authorization header.
 * Returns the userId on success, or null after sending a 401 response.
 */
export function requireAuth(req: VercelRequest, res: VercelResponse): string | null
```

## Function Design

**Size:**
- Target: 20–50 lines per function (smaller is better)
- Larger functions: Break into named helper functions (e.g., `_buildImage()`, `_buildBottomContent()`)
- Private helpers use underscore prefix

**Parameters:**
- Use named parameters for functions with 2+ parameters: `Future<bool> login({required String email, required String password})`
- Positional parameters only for single, obvious parameters: `void complete()`
- Always mark required params: `required String hobbyId`
- Default values for optional params: `{int limit = 3}`

**Return Values:**
- Explicit return types (no `var` or `dynamic`): `Future<List<Hobby>>`, `Map<String, UserHobby>`, `bool`
- Nullable returns marked with `?`: `Future<Hobby?>`, `String?`
- Async functions return `Future`: `Future<void>` for fire-and-forget

## Module Design

**Exports:**
- Repository pattern: Abstract interface in `lib/data/repositories/hobby_repository.dart`, implementation in `lib/data/repositories/hobby_repository_api.dart`
- Notifiers: Exported as class + provider in single file (e.g., `lib/providers/auth_provider.dart`)
- Models: `@freezed` classes with `fromJson`/`toJson` methods in single file (e.g., `lib/models/hobby.dart`)

**Barrel Files:**
- Not used in this codebase
- All imports are explicit

**Riverpod Providers (StateNotifierProvider Pattern):**
```dart
final userHobbiesProvider = StateNotifierProvider<UserHobbiesNotifier, Map<String, UserHobby>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repo = ref.watch(userProgressRepositoryProvider);
  return UserHobbiesNotifier(prefs, repo);
});

class UserHobbiesNotifier extends StateNotifier<Map<String, UserHobby>> {
  final SharedPreferences _prefs;
  final UserProgressRepository _repo;
  static const _key = 'user_hobbies';

  UserHobbiesNotifier(this._prefs, this._repo) : super(_load(_prefs));

  // Public methods that update state
}
```

**Computed Providers (Provider pattern):**
```dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});
```

## Widget Conventions

**StatefulWidget Structure:**
```dart
class DiscoverFeedScreen extends ConsumerStatefulWidget {
  const DiscoverFeedScreen({super.key});

  @override
  ConsumerState<DiscoverFeedScreen> createState() => _DiscoverFeedScreenState();
}

class _DiscoverFeedScreenState extends ConsumerState<DiscoverFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.watch() for Riverpod
    final hobbies = ref.watch(hobbyProvider);
    return SizedBox();
  }
}
```

**StatelessWidget with Riverpod (ConsumerWidget):**
```dart
class HobbyCard extends StatelessWidget {
  final Hobby hobby;
  const HobbyCard({super.key, required this.hobby});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

**Glass Card Component Pattern** (see `lib/components/glass_card.dart` lines 14-97):
- Use `GlassCard` widget everywhere, not manual containers
- `blur: true` only for max 3-5 static/hero elements per screen (uses BackdropFilter, performance-conscious)
- `blur: false` (default) for scrollable lists, safe at 60fps
- Scale animation to 0.97 on press when `onTap` provided
- Never hardcode glass colors — use `AppColors.glassBackground` and `AppColors.glassBorder`

**Theme Constants:**
- Never hardcode colors: Use `AppColors.coral`, `AppColors.driftwood`, `AppColors.textPrimary`
- Never hardcode spacing: Use `Spacing.md`, `Spacing.lg`
- Never hardcode animations: Use `Motion.fast`, `Motion.normal`
- Exception: Hardcoded `Colors.white` for text on overlays is intentional (100+ usages, DO NOT convert to tokens)

## Server TypeScript Conventions

**Handler Pattern (Vercel Functions):**
```typescript
export default async function handler(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  if (handleCors(req, res)) return;
  if (methodNotAllowed(req, res, ["POST"])) return;

  const { action } = req.query;

  switch (action) {
    case "register":
      return handleRegister(req, res);
    default:
      errorResponse(res, 404, `Unknown action '${action}'`);
  }
}

async function handleRegister(
  req: VercelRequest,
  res: VercelResponse
): Promise<void> {
  try {
    const { email } = req.body ?? {};
    if (!email) {
      errorResponse(res, 400, "email is required");
      return;
    }
    // Logic here
  } catch (error) {
    errorResponse(res, 500, "Internal server error");
  }
}
```

**Validation Pattern:**
- Validate inputs before database operations
- Check for required fields: `if (!email || !password)`
- Type-check strings: `if (typeof password !== "string")`
- Return early with `errorResponse()` if validation fails

---

*Convention analysis: 2026-03-21*
