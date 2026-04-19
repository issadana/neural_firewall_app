# Neural Firewall App - Project Setup Guide

## Current Status

Core implementation files have been created at the `lib/` level. To complete the project structure setup, you need to run the project initialization script.

## Setup Instructions

### Option 1: Automated Setup (Recommended)

Run the setup script from the project root:

```bash
cd c:\Users\PC\OneDrive\Desktop\FYP\neural_firewall_app
dart run setup_neural_firewall.dart
```

Or if you prefer:

```bash
dart setup_neural_firewall.dart
```

This script will:
1. Create all required directories under `lib/`
2. Create all core implementation files in their correct locations
3. Organize the project structure as designed

### Option 2: Manual Setup

If the script doesn't work, manually create these directories:

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── models/
├── services/
├── blocs/
│   ├── vpn/
│   ├── traffic/
│   ├── dashboard/
│   ├── blacklist/
│   ├── acl/
│   └── settings/
└── screens/
    ├── home/
    │   └── widgets/
    ├── blacklist/
    │   └── widgets/
    ├── acl/
    │   └── widgets/
    ├── settings/
    │   └── widgets/
    └── splash/
```

Then move these temporary files to their final locations:

**From `lib/` to `lib/core/constants/`:**
- `AppConstants.dart` → `app_constants.dart`
- `HiveTypeIds.dart` → `hive_boxes.dart`

**From `lib/` to `lib/core/`:**
- `app_enums.dart` → `enums.dart` (rename)

**From `lib/` to `lib/core/theme/`:**
- `AppColors.dart` → `app_colors.dart`
- `AppTheme.dart` → `app_theme.dart`

**From `lib/` to `lib/core/utils/`:**
- `ProtocolHelper.dart` → `protocol_helper.dart`
- `FormatUtils.dart` → `format_utils.dart`

### Step 3: Update Imports

After running the setup script, update imports in the generated files to use the new paths:

- `AppTheme.dart` imports should change from `AppColors` to `'app_colors.dart'`
- `ProtocolHelper.dart` imports should change from `app_enums` to `'../enums.dart'`

### Step 4: Install Dependencies

```bash
flutter pub get
```

## Created Core Files

✅ **AppConstants.dart** - Application-wide constants
- Blacklist/ACL box names
- Default thresholds and limits
- App metadata

✅ **HiveTypeIds.dart** - Hive database type IDs
- Blacklist entry type ID
- ACL entry type ID
- Flow features type ID

✅ **app_enums.dart** - All enumeration types
- VpnStatus, PacketStatus, Protocol
- BlacklistReason, AclAction, TrafficType
- DashboardView, AlertSeverity

✅ **AppColors.dart** - Theme color palette
- Primary colors (dark, black, blue, green)
- Status colors (normal, warning, danger, critical)
- UI colors (surface, border, text variations)
- Chart and VPN colors

✅ **AppTheme.dart** - Dark theme configuration
- Material 3 theme with custom colors
- AppBar styling
- Input decoration theme
- Button styling
- Text theme definition

✅ **ProtocolHelper.dart** - Protocol utility functions
- Protocol name mapping
- Convert between protocol numbers and enums
- TCP (6), UDP (17), ICMP (1), IGMP (2)

✅ **FormatUtils.dart** - Data formatting utilities
- formatBytes() - Convert bytes to human-readable format
- formatPackets() - Format packet counts
- formatLatency() - Format network latency
- formatPercentage() - Format percentages
- formatThreshold() - Format threshold values
- formatDateTime() / formatDate() - Date/time formatting
- formatDuration() - Format time durations

## Directory Structure After Setup

```
neural_firewall_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── hive_boxes.dart
│   │   ├── enums.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── format_utils.dart
│   │       └── protocol_helper.dart
│   ├── models/          (ready for model definitions)
│   ├── services/        (ready for service implementations)
│   ├── blocs/
│   │   ├── vpn/
│   │   ├── traffic/
│   │   ├── dashboard/
│   │   ├── blacklist/
│   │   ├── acl/
│   │   └── settings/
│   ├── screens/
│   │   ├── home/widgets/
│   │   ├── blacklist/widgets/
│   │   ├── acl/widgets/
│   │   ├── settings/widgets/
│   │   └── splash/
│   └── main.dart        (entry point - to be updated)
├── pubspec.yaml         (already configured with all dependencies)
├── analysis_options.yaml
└── ...
```

## Next Steps

1. Run the setup script: `dart run setup_neural_firewall.dart`
2. Verify directory structure: `flutter analyze`
3. Get dependencies: `flutter pub get`
4. Start implementing BLoCs, models, and screens

## Setup Script Files Available

- `setup_neural_firewall.dart` - **Main setup script (RECOMMENDED)**
- `init_project.dart` - Alternative setup script
- `setup_dirs.py` - Python alternative
- `create_structure.bat` - Windows batch file alternative

All scripts perform the same task - create directories and move files to correct locations.

## Troubleshooting

**Issue:** "Parent directory does not exist" error  
**Solution:** Run the setup script first to create all directories

**Issue:** Import errors after setup  
**Solution:** Ensure all files are in the correct directories as specified above

**Issue:** Script won't execute  
**Solution:** Make sure you're in the project root directory and have Dart SDK installed

## Support Files Created

During setup investigation, these temporary support files were created:
- `create_dirs.dart`
- `setup_project.dart` 
- `setup_dirs.py`
- `create_structure.bat`
- `setup.sh`
- `app_constants_temp.dart`

These can be safely deleted after running the main setup script.

---

**Status**: Core files created ✅  
**Next**: Run setup script to organize into proper directory structure  
**Last Updated**: [Current Session]
