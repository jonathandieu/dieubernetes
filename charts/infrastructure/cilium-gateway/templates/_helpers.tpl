{{/*
Cloudflare published IPv4 ranges as a DigitalOcean LB allow-rules string.
IPv6 omitted: DO load balancers reject IPv6 CIDRs in this field.
https://www.cloudflare.com/ips-v4/
*/}}
{{- define "cilium-gateway.cloudflareAllowRules" -}}
{{- $rules := list -}}
{{- range .Values.gateway.originLock.cloudflareIPv4 -}}
{{- $rules = append $rules (printf "cidr:%s" .) -}}
{{- end -}}
{{- join "," $rules -}}
{{- end }}
