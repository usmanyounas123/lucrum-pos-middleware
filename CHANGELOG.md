# Changelog

All notable changes to the Lucrum POS Middleware project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-09-19

### 🎯 Major Update - Streamlined Batch Files

### Added
- **Streamlined batch files** - Consolidated 13+ files into 5 simple, focused files
- `install.bat` - Simple install and start, then close (service runs in background)
- `test.bat` - Comprehensive testing of all functionality
- `manage.bat` - Simple start/stop/restart/status operations
- `status.bat` - Check everything and optionally open log files
- `uninstall.bat` - Complete service removal
- Enhanced error handling and user feedback
- Comprehensive validation during installation
- Auto-restart configuration for service reliability
- Port conflict detection and guidance
- Fallback installation methods
- Better permission handling for service accounts

### Changed
- **90% reduction in batch file count** (from 13+ to 5 files)
- Simplified user interface with clear, single-purpose files
- Improved installation process with integrated fixes
- Enhanced service management with better error messages
- Updated documentation to reflect streamlined approach

### Fixed
- Service installation timeout issues
- Path handling for different installation locations
- Permission problems with service accounts
- Port conflict detection and resolution
- Service auto-restart configuration

### Removed
- Multiple redundant batch files
- Complex multi-step installation processes
- Separate fix files (functionality integrated into main files)

## [1.0.0] - 2025-08-29

### Added
- Initial release of Lucrum POS Middleware
- Complete TypeScript-based POS middleware application
- RESTful API with full CRUD operations for orders
- Real-time WebSocket support for live updates
- Lucrum integration with sales order management
- Kitchen Display System (KDS) support
- SQLite database with comprehensive data models
- Windows service support with automatic installation
- Standalone executable (no Node.js required for deployment)
- API key authentication and rate limiting
- Comprehensive logging system
- Multi-branch and table support for restaurants
- Legacy API compatibility for existing systems

### API Endpoints
- `/api/v1/orders` - Legacy order management
- `/api/v1/lucrum/sales-orders` - Lucrum sales order integration
- `/api/v1/lucrum/kds/orders` - Kitchen Display System
- `/api/v1/clients` - Client registration and management
- `/api/v1/auth/validate` - API key validation

### Features
- **Sales Order Management** - Complete Lucrum sales order lifecycle
- **Kitchen Display System** - Real-time kitchen workflow management
- **Multi-location Support** - Branch and table-based order routing
- **Item Status Tracking** - Individual item preparation status
- **Real-time Broadcasting** - WebSocket events for live updates
- **Windows Service Integration** - Background service operation
- **Comprehensive Security** - API key auth, rate limiting, CORS protection
- **Database Management** - SQLite with automatic schema management
- **Logging and Monitoring** - Detailed application and error logging

### Documentation
- Complete API documentation with examples
- WebSocket testing client
- Installation and deployment guides
- Troubleshooting documentation
- Feature overview and migration guides

---

## Legend
- **Added** - New features
- **Changed** - Changes in existing functionality
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features
- **Fixed** - Bug fixes
- **Security** - Security improvements