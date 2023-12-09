ARG KC_VERSION=23.0.1

FROM quay.io/phasetwo/keycloak-crdb:${KC_VERSION} as builder

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

# Configure a database vendor
# ENV KC_DB=postgres
ENV KC_DB=cockroach
ENV KC_TRANSACTION_XA_ENABLED=false
ENV KC_TRANSACTION_JTA_ENABLED=false

# Build with modified infinispan config
ENV KC_CACHE_CONFIG_FILE=my-cache-ispn.xml

WORKDIR /opt/keycloak

COPY cache-ispn.xml conf/my-cache-ispn.xml

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KC_VERSION}
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_PROXY=edge

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
