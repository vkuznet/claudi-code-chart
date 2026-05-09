# claude-code Helm chart

Runs **Claude Code** (`claude` CLI) inside a Kubernetes Pod.  
You can build your own container or use default debian one where
claude client will be installed via official install script.

---
## Build custom image

```
# we can build custom claude image using provided Docker file

# step 0: obtain github token from your repo (see settings)

# step 1: login to your github repo with token credentials
echo `cat ~/private/github-token` | docker login ghcr.io -u <username> --password-stdin

# step 2: build your image
docker build -t ghcr.io/<username>/claude-cli:latest .

# step 3: upload your image to your GHCR area
docker push ghcr.io/<username>/claude-cli:latest
```

---

## Quick start

```bash
# create claude namespace and create the Secret with your URL/token
kubectl create namespace claude
kubectl create secret generic claude-anthropic \
  --namespace claude \
  --from-literal=ANTHROPIC_AUTH_TOKEN=sk-ant-… \
  --from-literal=ANTHROPIC_BASE_URL=https://api.ai.../

# Install the chart, pointing at your pre-existing secret
helm install claude-code ./claude-code \
  --namespace claude \
  -f values-local.yaml \
  --set anthropic.existingSecret=claude-anthropic

# Attach interactively
kubectl attach -it -n claude claude-code-claude-code
```

#### Run ollama with claude:
The provided Dockerfile (image) also provides ollama CLI which
you can use to start local ollama server and run ollama with claude
model. For instance, here is a recipe to run ollama claude with
gpt-oss model.


```
# start ollama server
nohup ollama serve 2>&1 1>& ollama.log < /dev/null &

# pull some models
ollama pull gpt-oss:20b-cloud
ollama run opencoder
ollama list

# if ollama ask to login in for a specific model
# you may use
ollama singin

# run ollama with claude
ollama launch claude --model gpt-oss:20b-cloud
```

For more openly available models please visit
[ollama library](https://ollama.com/library/) and select your favorite one.

---

## Key values

| Value | Default | Description |
|---|---|---|
| `anthropic.existingSecret` | `""` | Name of a pre-existing Secret (recommended) |
| `anthropic.inlineSecret.*` | — | Credentials created as a chart Secret (dev only) |
| `models.model` | `anthropic.claude-sonnet-4-5` | Primary model |
| `models.smallFastModel` | `anthropic.claude-haiku-4-5` | Background/fast model |
| `flags.disableExperimentalBetas` | `true` | Required for most gateways |
| `flags.disableTelemetry` | `true` | Prevents Statsig A/B data leakage |
| `prompt` | `""` | Non-interactive prompt; empty = interactive shell |
| `mounts` | `[]` | List of `{hostPath, containerPath, permission}` |
| `restartPolicy` | `Never` | `Never` for one-shot, `Always` for persistent pod |

### Mount permissions

```yaml
mounts:
  - hostPath: /home/user/project   # absolute path on the Kubernetes node
    containerPath: /workspace/project
    permission: rw                 # rw = read-write, ro = read-only
  - hostPath: /data/reference
    containerPath: /workspace/reference
    permission: ro
```

### Non-interactive (CI / scripted) use

```yaml
prompt: "Explain the main function in /workspace/project/main.go"
restartPolicy: Never
```

Stream the output:

```bash
kubectl logs -n claude claude-code-claude-code -f
```

---

## Production credential management

Never commit tokens to version control.  Preferred patterns:

```bash
# Option A – kubectl
kubectl create secret generic claude-anthropic \
  --from-literal=ANTHROPIC_AUTH_TOKEN=sk-ant-… \
  --from-literal=ANTHROPIC_BASE_URL=https://…

# Option B – sealed-secrets
kubeseal --format yaml < plain-secret.yaml > sealed-secret.yaml

# Option C – external-secrets (Vault, AWS SM, etc.)
# Create an ExternalSecret CR that syncs into the namespace.
```

Then reference it:

```yaml
anthropic:
  existingSecret: claude-anthropic
```
