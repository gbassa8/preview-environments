# ExternalDNS

## Rol En El Proyecto

El resultado buscado es que una preview aparezca y desaparezca con su DNS sin tocar Cloudflare a mano.

`ExternalDNS` se encarga de crear y borrar registros DNS a partir de recursos del cluster.

Esto evita depender de un wildcard DNS tipo `*.preview...` que exista siempre aunque no haya previews.

## Configuración Actual

- Usa la zona real `serviciosimpositivos.com.ar`
- Crea, actualiza y borra registros según el estado del cluster
- Marca sus registros con TXT para no pisarse con otros controllers

## Token De Cloudflare

`ExternalDNS` necesita credenciales para editar DNS en Cloudflare.

Permisos mínimos:

- `Zone:DNS:Edit`
- `Zone:Zone:Read`

Alcance:

- La zona `serviciosimpositivos.com.ar`

## Cómo Usa Un Ingress

Para que `ExternalDNS` cree un registro DNS a partir de un `Ingress`, el host tiene que vivir dentro de la zona real que maneja.

Ejemplo:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-prueba
  namespace: default
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - app-prueba.preview.serviciosimpositivos.com.ar
      secretName: preview-wildcard-tls
  rules:
    - host: app-prueba.preview.serviciosimpositivos.com.ar
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-prueba
                port:
                  number: 80
```

## Validar Creación

```bash
dig app-prueba.preview.serviciosimpositivos.com.ar +short
```
