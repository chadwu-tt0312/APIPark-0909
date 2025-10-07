{{/*
Expand the name of the chart.
*/}}
{{- define "apipark.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "apipark.fullname" -}}
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
{{- define "apipark.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "apipark.labels" -}}
helm.sh/chart: {{ include "apipark.chart" . }}
{{ include "apipark.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "apipark.selectorLabels" -}}
app.kubernetes.io/name: {{ include "apipark.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "apipark.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "apipark.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
MySQL fullname
*/}}
{{- define "apipark.mysql.fullname" -}}
{{- printf "%s-mysql" (include "apipark.fullname" .) }}
{{- end }}

{{/*
Redis fullname
*/}}
{{- define "apipark.redis.fullname" -}}
{{- printf "%s-redis" (include "apipark.fullname" .) }}
{{- end }}

{{/*
InfluxDB fullname
*/}}
{{- define "apipark.influxdb.fullname" -}}
{{- printf "%s-influxdb" (include "apipark.fullname" .) }}
{{- end }}

{{/*
Loki fullname
*/}}
{{- define "apipark.loki.fullname" -}}
{{- printf "%s-loki" (include "apipark.fullname" .) }}
{{- end }}

{{/*
Grafana fullname
*/}}
{{- define "apipark.grafana.fullname" -}}
{{- printf "%s-grafana" (include "apipark.fullname" .) }}
{{- end }}

{{/*
NSQ fullname
*/}}
{{- define "apipark.nsq.fullname" -}}
{{- printf "%s-nsq" (include "apipark.fullname" .) }}
{{- end }}

{{/*
Apinto fullname
*/}}
{{- define "apipark.apinto.fullname" -}}
{{- printf "%s-apinto" (include "apipark.fullname" .) }}
{{- end }}

{{/*
Ingress fullname
*/}}
{{- define "apipark.ingress.fullname" -}}
{{- printf "%s-ingress" (include "apipark.fullname" .) }}
{{- end }}
