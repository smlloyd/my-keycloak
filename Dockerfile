ARG KC_VERSION=latest@sha256:4a81762677f8911c6266e3dea57a2d78fa17bd63408debbf23afd8cc46fe256e

FROM quay.io/keycloak/keycloak:${KC_VERSION} as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
ENV KC_DB=postgres

WORKDIR /opt/keycloak

RUN /opt/keycloak/bin/kc.sh build

FROM registry.access.redhat.com/ubi9 AS ubi-micro-build
ADD https://public-keys.slloyd.net/certs/Lloyd%2BCA.crt /etc/pki/ca-trust/source/anchors/slloydCA.crt
RUN update-ca-trust

FROM quay.io/keycloak/keycloak:${KC_VERSION}

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=ubi-micro-build /etc/pki /etc/pki

ENV KC_DB=postgres

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
