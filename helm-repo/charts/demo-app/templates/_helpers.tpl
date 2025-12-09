{{- define "demo-app.name" -}}
demo-app
{{- end }}

{{- define "demo-app.fullname" -}}
{{ include "demo-app.name" . }}
{{- end }}
