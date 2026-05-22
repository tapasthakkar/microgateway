FROM debian:12-slim

# === SECURITY & NODE.JS INSTALL LAYER ===
# 1. Install standard pre-requisites (curl, ca-certificates, gnupg)
# 2. Configure NodeSource repository for Node.js v24.x
# 3. Install Node.js, upgrade OS packages, and update global npm
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g npm@latest && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
# ========================================

COPY installnode.sh /tmp
COPY --chown=101:101 installedgemicro.sh /tmp

# create user and group for microgateway
RUN addgroup --system --gid 101 apigee && \
    adduser --shell /bin/bash --uid 101 --system --ingroup apigee --home /opt/apigee apigee

ENV NODE_ENV production

# install microgateway
RUN chmod +x /tmp/installnode.sh && \
    /bin/bash /tmp/installnode.sh && \
    rm -f /tmp/installnode.sh

USER apigee
WORKDIR /opt/apigee
RUN mkdir /opt/apigee/.edgemicro && mkdir /opt/apigee/logs && mkdir /opt/apigee/plugins
VOLUME /opt/apigee/.edgemicro
VOLUME /opt/apigee/logs
VOLUME /opt/apigee/plugins

# copy tls files if needed
# COPY key.pem /opt/apigee/.edgemicro
# COPY cert.pem /opt/apigee/.edgemicro

# copy entrypoint
COPY --chown=101:101 entrypoint.sh /opt/apigee

# initialize edgemicro
RUN /bin/bash /tmp/installedgemicro.sh&& \
    rm -f /tmp/installedgemicro.sh

# Expose ports
EXPOSE 8000
EXPOSE 8443

ENTRYPOINT ["/opt/apigee/entrypoint.sh"]
