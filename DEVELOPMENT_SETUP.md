# Development Setup for MCP Redmine Enhanced

This guide shows how to configure RooCode and Kiro to automatically use the latest version from your GitHub repository for development and testing.

## Option 1: Direct Git Repository (Recommended for Development)

Configure your MCP client to pull directly from your GitHub repository:

### For RooCode/Kiro Configuration:
```json
{
  "mcpServers": {
    "redmine": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git",
              "mcp-redmine"],
      "env": {
        "REDMINE_URL": "https://your-redmine-instance.example.com",
        "REDMINE_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Benefits:
- ✅ Always gets the latest `main` branch
- ✅ No need to publish to PyPI for testing
- ✅ Automatic updates when you push changes
- ✅ Perfect for development and testing

### How it works:
- `uvx` will clone your repository and install it fresh each time
- Uses the latest commit from the `main` branch
- Automatically handles dependencies from `pyproject.toml`

## Option 2: Specific Branch or Commit

You can also target specific branches or commits in RooCode/Kiro:

```json
{
  "mcpServers": {
    "redmine": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git@develop",
              "mcp-redmine"],
      "env": {
        "REDMINE_URL": "https://your-redmine-instance.example.com",
        "REDMINE_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Branch/Commit Options:
- `@main` - Latest main branch (default)
- `@develop` - Specific branch
- `@v1.2.3` - Specific tag
- `@abc1234` - Specific commit hash

## Option 3: Local Development Path

For active development, you can point directly to your local repository:

```json
{
  "mcpServers": {
    "redmine": {
      "command": "uv",
      "args": ["run", "--directory", "/home/atmp/data/dev-tools-1/mcp/mcp-redmine-fork",
              "python", "-m", "mcp_redmine.server"],
      "env": {
        "REDMINE_URL": "https://your-redmine-instance.example.com",
        "REDMINE_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Benefits:
- ✅ Instant changes without commits
- ✅ Perfect for active development
- ✅ No network dependency
- ✅ Fastest iteration cycle

## Option 4: Hybrid Approach with Refresh Control

Use the git repository but control when updates happen:

```json
{
  "mcpServers": {
    "redmine": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git",
              "--refresh-package", "mcp-redmine", "mcp-redmine"],
      "env": {
        "REDMINE_URL": "https://your-redmine-instance.example.com",
        "REDMINE_API_KEY": "your-api-key"
      }
    }
  }
}
```

### Control Updates:
- With `--refresh-package`: Updates on every Claude Desktop restart
- Without `--refresh-package`: Caches until manually cleared

## RooCode/Kiro Specific Configuration

### Configuration File Location:
RooCode and Kiro typically use MCP configuration files. Check your specific client documentation for the exact location, but common paths include:
- `~/.config/roocode/mcp_servers.json`
- `~/.config/kiro/mcp_servers.json`
- Project-specific `.mcp_config.json`

### Environment Variables:
You can also set up environment variables for easier management:

```bash
export REDMINE_URL="https://your-redmine-instance.example.com"
export REDMINE_API_KEY="your-api-key"
```

Then use in configuration:
```json
{
  "mcpServers": {
    "redmine": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git", "mcp-redmine"],
      "env": {
        "REDMINE_URL": "${REDMINE_URL}",
        "REDMINE_API_KEY": "${REDMINE_API_KEY}"
      }
    }
  }
}
```

## Recommendations

### For Development:
Use **Option 1** (Direct Git Repository) - gives you automatic updates from your latest commits without needing PyPI publication.

### For Production:
Use the PyPI version once you're satisfied with stability.

### For Active Coding:
Use **Option 3** (Local Development Path) - instant feedback on changes.

## Testing Your Setup

After updating your MCP configuration:

1. Restart your MCP client (RooCode/Kiro)
2. Test the MCP server connection
3. Verify you're getting the latest features

You can check which version is running by looking at the server logs or testing the enhanced filtering features that are unique to your fork.

## Troubleshooting

### Git Authentication Issues:
If you have a private repository, you may need to configure git credentials or use SSH:

```json
"args": ["--from", "git+ssh://git@github.com/olssonsten/mcp-redmine.git", "mcp-redmine"]
```

### Cache Issues:
Clear uvx cache if you're not seeing updates:
```bash
uvx cache clear
```

### Dependency Issues:
If you encounter dependency conflicts, use the isolated approach:
```json
"args": ["--from", "git+https://github.com/olssonsten/mcp-redmine.git", 
         "--isolated", "mcp-redmine"]