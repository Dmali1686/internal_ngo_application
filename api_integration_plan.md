# Create Employee — Full Integration Plan

## API Flow Diagram

```
SUPER ADMIN taps "Add Employee"
          │
          ▼
  ┌─────────────────────────────────────────────┐
  │  Screen Init (parallel calls)               │
  │  GET /api/v1/departments  →  dropdown data  │
  │  GET /api/v1/positions    →  dropdown data  │
  └─────────────────────────────────────────────┘
          │
          ▼
  ┌─────────────────────────────────────────────┐
  │  User fills form:                           │
  │  Full Name, Username, Email, Mobile,        │
  │  Password, Department, Position, Role       │
  └─────────────────────────────────────────────┘
          │
          ▼ On Submit
  ┌─────────────────────────────────────────────┐
  │  API Call 1:  POST /api/v1/users            │
  │  Body: { full_name, username, email,        │
  │          mobile, password }                 │
  │  Response: { message, user_id }             │
  └─────────────────────────────────────────────┘
          │  Extract user_id from response
          ▼
  ┌─────────────────────────────────────────────┐
  │  API Call 2:  POST /api/v1/users/{id}/      │
  │               assignments                   │
  │  Body: { assignments: [                     │
  │    { access_category_id, department_id,     │
  │      position_id, is_primary }              │
  │  ]}                                         │
  └─────────────────────────────────────────────┘
          │
          ▼
     ✅ Success → Show confirmation / navigate back
```

---

## Step 1: Add Endpoints to `api_endpoints.dart`

```dart
// ─── Organization ───────────────────────────────────────────
static const String departments = '/departments';
static const String positions   = '/positions';

// ─── Users ──────────────────────────────────────────────────
static const String createUser = '/users';
static String userAssignments(String id) => '/users/$id/assignments';
```

---

## Step 2: Create Data Models

### `lib/features/users/models/department_model.dart`
```dart
class DepartmentModel {
  final String id;
  final String departmentCode;
  final String name;
  final String description;
  final bool isActive;

  DepartmentModel({
    required this.id,
    required this.departmentCode,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id:             json['id'],
      departmentCode: json['department_code'],
      name:           json['name'],
      description:    json['description'] ?? '',
      isActive:       json['is_active'],
    );
  }
}
```

### `lib/features/users/models/position_model.dart`
```dart
class PositionModel {
  final String id;
  final String departmentId;
  final String positionCode;
  final String name;
  final bool isHod;
  final bool isActive;

  PositionModel({
    required this.id,
    required this.departmentId,
    required this.positionCode,
    required this.name,
    required this.isHod,
    required this.isActive,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id:           json['id'],
      departmentId: json['department_id'],
      positionCode: json['position_code'],
      name:         json['name'],
      isHod:        json['is_hod'],
      isActive:     json['is_active'],
    );
  }
}
```

### `lib/features/users/models/create_user_request.dart`
```dart
class CreateUserRequest {
  final String fullName;
  final String username;
  final String email;
  final String mobile;
  final String password;

  CreateUserRequest({
    required this.fullName,
    required this.username,
    required this.email,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'username':  username,
    'email':     email,
    'mobile':    mobile,
    'password':  password,
  };
}
```

### `lib/features/users/models/user_assignment_request.dart`
```dart
class UserAssignmentRequest {
  final String accessCategoryId; // UUID from access_categories table
  final String? departmentId;
  final String? positionId;
  final bool isPrimary;

  UserAssignmentRequest({
    required this.accessCategoryId,
    this.departmentId,
    this.positionId,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() => {
    'access_category_id': accessCategoryId,
    if (departmentId != null) 'department_id': departmentId,
    if (positionId != null)   'position_id':   positionId,
    'is_primary': isPrimary,
  };
}
```

---

## Step 3: Create the API Service

### `lib/features/users/services/user_api_service.dart`
```dart
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/create_user_request.dart';
import '../models/user_assignment_request.dart';
import '../models/department_model.dart';
import '../models/position_model.dart';

class UserApiService {
  final ApiClient _client = ApiClient();

  /// GET /api/v1/departments
  Future<ApiResponse<List<DepartmentModel>>> getDepartments() async {
    final response = await _client.get(ApiEndpoints.departments);
    if (response.success && response.data is List) {
      final list = (response.data as List)
          .map((e) => DepartmentModel.fromJson(e))
          .toList();
      return ApiResponse.ok(list);
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load departments');
  }

  /// GET /api/v1/positions
  Future<ApiResponse<List<PositionModel>>> getPositions() async {
    final response = await _client.get(ApiEndpoints.positions);
    if (response.success && response.data is List) {
      final list = (response.data as List)
          .map((e) => PositionModel.fromJson(e))
          .toList();
      return ApiResponse.ok(list);
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to load positions');
  }

  /// POST /api/v1/users
  Future<ApiResponse<String>> createUser(CreateUserRequest req) async {
    final response = await _client.post(
      ApiEndpoints.createUser,
      body: req.toJson(),
    );
    if (response.success && response.data is Map) {
      final userId = response.data['user_id'] as String;
      return ApiResponse.ok(userId, statusCode: 201);
    }
    return ApiResponse.error(response.errorMessage ?? 'Failed to create user');
  }

  /// POST /api/v1/users/{id}/assignments
  Future<ApiResponse<dynamic>> assignUser(
    String userId,
    List<UserAssignmentRequest> assignments,
  ) async {
    return _client.post(
      ApiEndpoints.userAssignments(userId),
      body: {
        'assignments': assignments.map((a) => a.toJson()).toList(),
      },
    );
  }

  /// Combined: createUser + assignUser in one call.
  Future<ApiResponse<dynamic>> createEmployeeWithAssignment({
    required CreateUserRequest user,
    required UserAssignmentRequest assignment,
  }) async {
    // Step 1: Create user
    final createRes = await createUser(user);
    if (!createRes.success) return ApiResponse.error(createRes.errorMessage!);

    final userId = createRes.data!;

    // Step 2: Assign role/position
    final assignRes = await assignUser(userId, [assignment]);
    if (!assignRes.success) {
      return ApiResponse.error(
        'User created (ID: $userId) but assignment failed: ${assignRes.errorMessage}',
      );
    }

    return ApiResponse.ok({'user_id': userId, 'message': 'Employee created successfully'});
  }
}
```

> [!IMPORTANT]
> The `ApiClient` already auto-injects the `Authorization: Bearer <token>` header from stored tokens on every request. No extra work needed for auth headers.

---

## Step 4: The Screen Flow (UI)

Create `lib/features/users/screens/create_employee_screen.dart` with a two-section form:

### Section 1 — Personal Details
| Field | Type | Validation |
|-------|------|-----------|
| Full Name | TextInput | required |
| Username | TextInput | required |
| Email | TextInput | required, valid email |
| Mobile | TextInput | required, 10 digits |
| Password | TextInput (obscured) | required, min 6 chars |

### Section 2 — Job Assignment
| Field | Type | Data Source |
|-------|------|-------------|
| Department | Dropdown | `GET /departments` |
| Position | Dropdown | Filtered by selected dept from `GET /positions` |
| Access Role | Dropdown | Hardcoded: Super Admin / Dept Admin / Employee |

### On Submit
```
1. Validate form
2. Show loading indicator
3. Call createEmployeeWithAssignment()
4. On success → pop screen + show SnackBar "Employee created!"
5. On error → show error dialog
```

---

## Access Category IDs

> [!NOTE]
> The access_categories table is seeded with these fixed codes. You need to fetch the UUID of the selected category to pass as `access_category_id`. Either:
> - Add `GET /api/v1/access-categories` endpoint (recommended), OR
> - Hardcode a `GET /departments` call and derive, OR
> - Store them in Flutter constants after first login

The seeded categories are:
| Code | Name |
|------|------|
| `SUP001` | Super Admin |
| `ADM001` | Department Admin |
| `EMP001` | Employee |
