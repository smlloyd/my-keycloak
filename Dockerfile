ARG KC_VERSION=latest@sha256:2ce6c7c70994c70dbbd70b372a5422c3b4eebb32583175eac03751320609e52c

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
