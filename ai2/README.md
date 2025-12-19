

## Manylinux builder image

```bash
# Run from the root of the repo
docker buildx build -t mujoco-ai2-manylinux:latest -f ai2/build_manylinux.Dockerfile . --platform linux/amd64
```

