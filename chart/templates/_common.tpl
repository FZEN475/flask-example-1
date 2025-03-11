{{- define "common.standardLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: "{{ .Release.Service }}"
{{- end -}}

{{- define "common.standardSelectorLabels" -}}
app.kubernetes.io/name: "{{ .Release.Name }}"
release: "{{ .Release.Name }}"
{{- end -}}

{{/*
Get value from multiple source with list of acceptable values.
Variables [str]:
  - name - Name in yaml
  - vars - List of source values
  - accept_list - List of acceptable values (optional)
  - default - default value (optional)
  - nindent
*/}}

{{- define "common.get_int_value" -}}
{{-   $def := false -}}
{{-   range $var := index . "vars" -}}
{{-     if $var -}}
{{-       if (index $ "accept_list") -}}
{{-         range $key := (index $ "accept_list") -}}
{{-           if eq $var $key -}}
{{-             $def = true -}}
{{-             index $ "name" -}}: {{ $var | int -}}
{{-             break -}}
{{-           end -}}
{{-         end -}}
{{-       else -}}
{{-         $def = true -}}
{{-         index $ "name" -}}: {{ $var | int -}}
{{-         break -}}
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{-   if and ( index . "default") (not $def) -}}
{{-     index . "name" -}}: {{ index . "default" | int -}}
{{-   end -}}
{{- end -}}

{{- define "common.get_str_value" -}}
{{-   $def := false -}}
{{-   range $var := index . "vars" -}}
{{-     if $var -}}
{{-       if (index $ "accept_list") -}}
{{-         range $key := (index $ "accept_list") -}}
{{-           if eq $var $key -}}
{{-             $def = true -}}
{{-             index $ "name" -}}: {{ $var | quote -}}
{{-             break -}}
{{-           end -}}
{{-         end -}}
{{-       else -}}
{{-         $def = true -}}
{{-         index $ "name" -}}: {{ $var | quote -}}
{{-         break -}}
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{-   if and ( index . "default") (not $def) -}}
{{-     index . "name" -}}: {{ index . "default" | quote -}}
{{-   end -}}
{{- end -}}

{{/*
Get lists from multiple source with concat uniq .
Variables [dict]:
  - name - Name in yaml
  - vars - List of source lists
  - nindent
*/}}

{{- define "common.get_lists" -}}
{{-   $list := (list) -}}
{{-   range $key := index . "vars" -}}
{{-     $list = concat (default (list) $list) (default (list) $key) | uniq | compact -}}
{{-   end -}}
{{-   if $list -}}
{{-     if (index $ "name")  -}}
{{-       index $ "name" -}}:
{{-     end -}}
{{-     $list | toYaml  | nindent (default (0) (index $ "nindent")) -}}
{{-   end -}}
{{- end -}}

{{/*
Get dict from multiple source with merge or coalesce.
Variables [dict]:
  - name - Name in yaml
  - vars - List of source dict
  - env_stile - kubernetes env format
  - coalesce - if true, get first not empty value, else merge all values
  - nindent
*/}}

{{- define "common.get_dict" -}}
{{-   $dict := (dict) -}}
{{-   range $key := index . "vars" -}}
{{-     if and (index $ "coalesce") ( eq (index $ "coalesce") true) -}}
{{-       $dict = coalesce (default (dict) $dict)   (default (dict) $key) -}}
{{-     else -}}
{{-       $dict = merge (default (dict) $dict)  (default (dict) $key) -}}
{{-     end -}}
{{-   end -}}
{{-   if $dict -}}
{{-     if (index $ "name")  -}}
{{-       (index $ "name") -}} {{- ":" -}}
{{-     end -}}
{{-     if and (index $ "env_stile") (eq (index $ "env_stile") true)  -}}
{{-       range $key, $value := $dict }}
- name: {{ $key }}
  value: {{ $value | quote -}}
{{-      end -}}
{{-    else -}}
{{- $dict | toYaml | nindent (default (0) (index $ "nindent")) -}}
{{-    end -}}
{{-   end -}}
{{- end -}}

{{/*
  include "common.podSecurityContext" (dict "vars" (list .securityContext ) "coalesce" true )
*/}}

{{- define "common.podSecurityContext" -}}
{{-   $dict := (dict) -}}
{{-   range $key := index . "vars" -}}
{{-     if and (index $ "coalesce") ( eq (index $ "coalesce") true) -}}
{{-       $dict = coalesce (default (dict) $dict)   (default (dict) $key) -}}
{{-     else -}}
{{-       $dict = merge (default (dict) $dict)  (default (dict) $key) -}}
{{-     end -}}
{{-   end -}}
{{-   if $dict -}}
{{-     range $key := (list "runAsUser" "runAsGroup" "runAsNonRoot" "seLinuxOptions" "seccompProfile" "windowsOptions" "fsGroup" "fsGroupChangePolicy" "supplementalGroups" "sysctls") -}}
{{-       if  (index $dict $key) }}
securityContext:
{{-         break -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $dict.runAsUser) }}
  runAsUser: {{ $dict.runAsUser }}
{{-     end }}
{{-     if not (empty $dict.runAsGroup) }}
  runAsGroup: {{ $dict.runAsGroup }}
{{-     end }}
{{-     if not (empty $dict.runAsNonRoot) }}
  runAsNonRoot: {{ $dict.runAsNonRoot }}
{{-     end }}
{{-     if not (empty $dict.seLinuxOptions) }}
  seLinuxOptions:
    {{- $dict.seLinuxOptions | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.seccompProfile) }}
  seccompProfile:
{{-       $dict.seccompProfile | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.windowsOptions) }}
  windowsOptions:
{{-       $dict.windowsOptions | toYaml | nindent 4 }}
{{-     end }}

{{-     if not (empty $dict.fsGroup) }}
  fsGroup: {{ $dict.fsGroup }}
{{-     end }}
{{-     if not (empty $dict.fsGroupChangePolicy) }}
  fsGroupChangePolicy: {{ $dict.fsGroupChangePolicy }}
{{-     end }}
{{-     if not (empty $dict.supplementalGroups) }}
  supplementalGroups:
{{-       $dict.supplementalGroups | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.sysctls) }}
  sysctls:
{{-       $dict.sysctls | toYaml | nindent 4 }}
{{-     end }}
{{-   end }}
{{- end -}}


{{/*
  include "common.containerSecurityContext" (dict "vars" (list .securityContext ) "coalesce" true )
*/}}

{{- define "common.containerSecurityContext" -}}
{{-   $dict := (dict) -}}
{{-   range $key := index . "vars" -}}
{{-     if and (index $ "coalesce") ( eq (index $ "coalesce") true) -}}
{{-       $dict = coalesce (default (dict) $dict)   (default (dict) $key) -}}
{{-     else -}}
{{-       $dict = merge (default (dict) $dict)  (default (dict) $key) -}}
{{-     end -}}
{{-   end -}}
{{-   if $dict -}}
{{-     range $key := (list "runAsUser" "runAsGroup" "runAsNonRoot" "seLinuxOptions" "seccompProfile" "windowsOptions" "allowPrivilegeEscalation" "capabilities" "privileged" "procMount" "readOnlyRootFilesystem") -}}
{{-       if  (index $dict $key) }}
securityContext:
{{-         break -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $dict.runAsUser) }}
  runAsUser: {{ $dict.runAsUser }}
{{-     end }}
{{-     if not (empty $dict.runAsGroup) }}
  runAsGroup: {{ $dict.runAsGroup }}
{{-     end }}
{{-     if not (empty $dict.runAsNonRoot) }}
  runAsNonRoot: {{ $dict.runAsNonRoot }}
{{-     end }}
{{-     if not (empty $dict.seLinuxOptions) }}
  seLinuxOptions:
    {{- $dict.seLinuxOptions | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.seccompProfile) }}
  seccompProfile:
{{-       $dict.seccompProfile | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.windowsOptions) }}
  windowsOptions:
{{-       $dict.windowsOptions | toYaml | nindent 4 }}
{{-     end }}

{{-     if not (empty $dict.allowPrivilegeEscalation) }}
  allowPrivilegeEscalation: {{ $dict.allowPrivilegeEscalation }}
{{-     end }}
{{-     if not (empty $dict.capabilities) }}
  capabilities:
{{-       $dict.capabilities | toYaml | nindent 4 }}
{{-     end }}
{{-     if not (empty $dict.privileged) }}
  privileged: {{ $dict.privileged }}
{{-     end }}
{{-     if not (empty $dict.procMount) }}
  procMount: {{ $dict.procMount }}
{{-     end }}
{{-     if not (empty $dict.readOnlyRootFilesystem) }}
  readOnlyRootFilesystem: {{ $dict.readOnlyRootFilesystem }}
{{-     end }}

{{- end }}
{{- end -}}