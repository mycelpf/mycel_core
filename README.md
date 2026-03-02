# mycel_core — base images for mycel modules

Container images providing the shared runtime for mycel module services, web shells, and MCP servers.

## Images

| Image | Description | Pull |
|-------|-------------|------|
| `ghcr.io/mycelpf/mycel_core_service` | Python 3.12 FastAPI service | `docker pull ghcr.io/mycelpf/mycel_core_service:v0.1.0` |
| `ghcr.io/mycelpf/mycel_core_web` | Node 20 React/Vite shell | `docker pull ghcr.io/mycelpf/mycel_core_web:v0.1.0` |
| `ghcr.io/mycelpf/mycel_core_mcp` | Python 3.12 MCP server | `docker pull ghcr.io/mycelpf/mycel_core_mcp:v0.1.0` |

## Usage

Module Dockerfiles extend these base images:

```dockerfile
ARG CORE_VERSION=v0.1.0
FROM ghcr.io/mycelpf/mycel_core_service:${CORE_VERSION}

# Install module dependencies
COPY my_module_service/pyproject.toml ./my_module_service/
RUN pip install --no-cache-dir ./my_module_service/

# Copy module source
COPY my_module_service/ ./my_module_service/
```

## License Acceptance

All images require `ACCEPT_LICENSE=yes` at runtime:

```yaml
environment:
  ACCEPT_LICENSE: "yes"
```

Without it the container prints the license notice and exits.

## License

PROPRIETARY — CogniWorks. All rights reserved. See [LICENSE](LICENSE).
