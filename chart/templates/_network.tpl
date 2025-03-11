{{- define "service.get_ip" -}}
{{-   $type :=  (default ("ClusterIP") ( index $ "type" | first )) -}}
{{-   if and  (index $ "type") (eq $type "ClusterIP") -}}
  clusterIP: {{ default ("None") ((index $ "vars") | first | quote) -}}
{{-   else if and (index $ "type") (eq $type "LoadBalancer") -}}
  loadBalancerIP: {{ default ("None") ((index $ "vars") | first | quote) -}}
{{-   end -}}
{{- end -}}