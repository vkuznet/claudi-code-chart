# claude-code Helm chart

Runs **Claude Code** (`claude` CLI) inside a Kubernetes Pod.  
On every start the container installs the latest CLI via the official install script, exports your Anthropic credentials from a Kubernetes Secret, mounts the host directories you specify, then either:

- drops into an **interactive shell** (default), or  
- executes a **non-interactive prompt** and exits.

---

## Quick start

```bash
# 1. (Recommended) create the Secret yourself so the token never touches Helm history
kubectl create namespace claude
kubectl create secret generic claude-anthropic \
  --namespace claude \
  --from-literal=ANTHROPIC_AUTH_TOKEN=sk-ant-… \
  --from-literal=ANTHROPIC_BASE_URL=https://api.ai.../

# 2. Install the chart, pointing at your pre-existing secret
helm install claude-code ./claude-code \
  --namespace claude \
  -f values-local.yaml \
  --set anthropic.existingSecret=claude-anthropic

# 3. Attach interactively
kubectl attach -it -n claude claude-code-claude-code
```

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
