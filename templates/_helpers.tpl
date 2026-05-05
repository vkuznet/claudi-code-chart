{{/*
Expand the name of the chart.
*/}}
{{- define "claude-code.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Full name: release-chart, capped at 63 chars.
*/}}
{{- define "claude-code.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "claude-code.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "claude-code.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
app.kubernetes.io/name: {{ include "claude-code.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "claude-code.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- default (include "claude-code.fullname" .) .Values.serviceAccount.name }}
{{- else }}
  {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Name of the Secret that holds Anthropic credentials.
Returns existingSecret when set, otherwise the chart-managed secret name.
*/}}
{{- define "claude-code.secretName" -}}
{{- if .Values.anthropic.existingSecret }}
  {{- .Values.anthropic.existingSecret }}
{{- else }}
  {{- printf "%s-anthropic" (include "claude-code.fullname" .) }}
{{- end }}
{{- end }}
