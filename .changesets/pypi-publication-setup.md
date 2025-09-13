# PyPI Publication Setup and Development Configuration

## Summary
Configure PyPI publication with enhanced package name and comprehensive development setup for automatic Git-based updates.

## Changes Made

### Package Configuration
- **Updated package name**: Changed from `mcp-redmine` to `mcp-redmine-enhanced` to avoid PyPI conflicts
- **Privacy protection**: Updated author email to GitHub noreply address for public package metadata
- **Fixed build configuration**: Resolved hatchling build issues with proper package specification
- **Enhanced versioning**: Maintained `.post0` suffix for fork identification

### Makefile Automation & Cleanup
- **Removed redundancy**: Eliminated duplicate targets and consolidated similar functionality
- **Added variables**: Centralized configuration with `PACKAGE_NAME`, `TEST_VENV`, `PYTHON_VERSION`
- **Enhanced workflow**: Created comprehensive publication pipeline with pre-checks
- **Improved organization**: Grouped targets by function (Development, Publication, Testing, etc.)
- **Added utilities**: Clean targets for build artifacts and cache files

### Key Makefile Targets Added
- `make pre-publish-check`: Runs tests and validates package build
- `make publish-test`: Publishes to Test PyPI with version bumping
- `make publish-prod`: Publishes to Production PyPI with full workflow
- `make package-inspect-test/prod`: Tests installation from respective PyPI instances
- `make clean`: Removes build artifacts and cache files
- `make help`: Shows comprehensive command documentation

### Documentation
- **Updated README.md**: Added Git repository configuration option for automatic updates with clear explanation
- **Streamlined documentation**: Removed redundant files, kept essential information in README.md

### Git-Based Development Configuration
- **Direct Git repository**: Configure MCP clients to use `git+https://github.com/olssonsten/mcp-redmine.git`
- **Automatic updates**: Fresh install on each MCP client restart
- **Development ready**: Perfect for testing latest features without PyPI publication
- **Multiple options**: Git repository, local development, and PyPI package configurations

## Benefits

### For Development
- **No PyPI dependency**: Test changes immediately without publishing
- **Automatic updates**: Always get latest features from main branch
- **Flexible configuration**: Switch between Git, local, and PyPI sources easily

### For Publication
- **Automated workflow**: Complete publication pipeline with safety checks
- **Conflict avoidance**: Unique package name prevents upstream conflicts
- **Privacy protection**: GitHub noreply email for public package metadata
- **Professional setup**: Clean, organized Makefile with comprehensive documentation

### For Users
- **Multiple installation options**: PyPI package, Git repository, or specific versions
- **Clear documentation**: Comprehensive setup guides for different MCP clients
- **Enhanced features**: Access to response filtering, journal filtering, and security improvements

## Technical Implementation

### Package Name Change
```toml
# Before
name = "mcp-redmine"

# After  
name = "mcp-redmine-enhanced"
```

### Git Configuration Example
```json
{
  "mcpServers": {
    "redmine": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git", "mcp-redmine"],
      "env": {
        "REDMINE_URL": "https://your-redmine-instance.example.com",
        "REDMINE_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Publication Workflow
1. `make pre-publish-check` - Automated testing and build validation
2. `make publish-test` - Test PyPI publication
3. `make publish-prod` - Production PyPI publication with Git integration

## Files Modified
- `pyproject.toml` - Package name, author email, build configuration
- `Makefile` - Complete rewrite with automation, cleanup, and cross-platform compatibility
- `README.md` - Added Git configuration section with clear package/script name explanation
- `.changesets/pypi-publication-setup.md` - This changeset document

## Files Removed
- `PYPI_PUBLICATION.md` - Redundant with Makefile automation
- `DEVELOPMENT_SETUP.md` - Redundant with README.md content

## Testing
- All 106 tests pass after changes
- Package builds successfully with new configuration
- Pre-publication checks validate entire workflow
- Git-based installation tested and working

## Breaking Changes
None - this is purely additive configuration and automation.

## Migration Guide
Users can continue using existing configurations or switch to:
1. **PyPI package**: `mcp-redmine-enhanced` (when published)
2. **Git repository**: `git+https://github.com/olssonsten/mcp-redmine.git`
3. **Local development**: Direct path to repository

## Future Considerations
- Consider automated PyPI publication via GitHub Actions
- Potential for branch-specific Git configurations
- Documentation translations for broader adoption