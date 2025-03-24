{{/*
Expand the name of the chart.
*/}}
{{- define "langflow.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "langflow.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "langflow.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "langflow.labels" -}}
helm.sh/chart: {{ include "langflow.chart" . }}
{{ include "langflow.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "langflow.selectorLabels" -}}
app.kubernetes.io/name: {{ include "langflow.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "langflow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "langflow.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Docker repository
*/}}
{{- define "common.image.repository" -}}
{{- $global := .Values.langflow.global | default dict -}}
{{- required "'image.repository' or 'global.image.repository' parameter is required" (coalesce .Values.image.repository (($global).image).repository ($global).repository) }}
{{- end }}

{{/*
Docker deployment image
*/}}
{{- define "common.deployment.image" -}}
{{ include "common.image" (list . .Values) }}
{{- end }}

{{/*
Docker backend image
*/}}
{{- define "common.backend.image" -}}
{{ include "common.image" (list . .Values.langflow.backend) }}
{{- end }}

{{/*
Docker frontend image
*/}}
{{- define "common.frontend.image" -}}
{{ include "common.image" (list . .Values.langflow.frontend) }}
{{- end }}

{{/*
Docker application image with priority resolution
*/}}
{{- define "common.image" -}}
{{- $ := index . 0 -}}
{{- $value := index . 1 -}}
{{- $global := $.Values.langflow.global | default dict -}}
{{- $repository := coalesce ($value.image).repository ($global.image).repository -}}
{{- $name := coalesce ($value.image).name ($global.image).name -}}
{{- $tag := coalesce ($value.image).tag ($global.image).tag $.Chart.AppVersion -}}
{{- if and $repository $name -}}
{{ printf "%s/%s:%s" $repository $name $tag }}
{{- else -}}
{{- fail "'repository' and 'name' must be defined in 'image' or 'global'" -}}
{{- end }}
{{- end }}
