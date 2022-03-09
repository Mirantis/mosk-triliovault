# Prerequisites
## AMQP (RabbitMQ) configuration
Apply the following settings under spec.services section of openstack/osdpl:
```
messaging:
  rabbitmq:
    values:
      conf:
        aux_conf:
          policies:
          - definition:
              message-ttl: 120000
            name: default-policy-tvault
            pattern: ^(?!amq\.).*
            vhost: tvault
          - definition:
              expires: 3600000
            name: results_expire_tvault
            pattern: ^results\.
            priority: 1
            vhost: tvault
          - definition:
              expires: 3600000
            name: tasks_expire_tvault
            pattern: ^tasks\.
            priority: 1
            vhost: tvault
        users:
          tvault_service:
            auth:
              tvault:
                password: lRw68C5IbA5S3liTURuYLwaWcH
                username: tvaultJ1
            path: /tvault
          tvault_service_notifications:
            auth:
              tvault:
                password: BTeFg9DdnH8GwfJJsINTaZzufC
                username: tvaultAD
            path: /openstack
```

## S3 buckets
Apply the following settings under spec.objectStorage.rgw section of ceph-lcm-mirantis/miraceph:
```
buckets:
  - trilio
```
 ## Glance images
 In order to provide the needed virtual devices and use the filesystem freezing functionality when needed,
 the following properties need to be defined for Glance image:
- hw_qemu_guest_agent=yes # Create the needed device to allow the guest agent to run
- os_require_quiesce=yes # Accept requests to freeze/thaw filesystems

```
openstack image set --property os_require_quiesce=yes --property hw_qemu_guest_agent=yes <IMAGE ID>
```
# Installation
## Prepare values overrides for helm chart
```
kubectl -n rook-ceph get secret rgw-ssl-certificate -ojsonpath='{.data.cert}' | base64 -d
kubectl -n rook-ceph get secret trilio -ojsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d
kubectl -n rook-ceph get secret trilio -ojsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d
kubectl -n rook-ceph get cm trilio -ojsonpath='{.data.BUCKET_NAME}'
```
The data from the above outputs could be used to fill out the appropriate settings below:
```
conf:
  workloadmgr:
    DEFAULT:
      cloud_admin_project_id: <INSERT DATA>
      cloud_admin_user_id: <INSERT DATA>
      triliovault_user_domain_id: <INSERT DATA>
    keystone_authtoken:
      project_domain_id: <INSERT DATA>
      user_domain_id: <INSERT DATA>
  tvostore: 
    DEFAULT:
      vault_s3_access_key_id: <INSERT DATA>
      vault_s3_bucket: trilio-<INSERT DATA>
      vault_s3_secret_access_key: <INSERT DATA>
  s3cert: |
    -----BEGIN RSA PRIVATE KEY-----
    -----END CERTIFICATE-----
  alembic:
    alembic:
      sqlalchemy.url: 'mysql+pymysql://wlm:jDy1yW90uawDwtknESEnHYMckj1g@mariadb.openstack.svc.cluster.local:3306/workloadmgr'
ceph_client:
  configmap: rook-ceph-config
  user_secret_name: nova-rbd-keyring
endpoints:
  cluster_domain_suffix: cluster.local
  identity:
    auth:
      admin:
        default_domain_id: default
        password: d2IVBBBxGuxh8ghDRnr6nEgn5L7T29Dx
        project_domain_name: default
        project_name: admin
        region_name: RegionOne
        user_domain_name: default
        username: admin
      tvault:
        password: qfIgc7Mjwp1WgpQIl0LHFjW44VeXlKVT
        username: tvault
  datamover:
    host_fqdn_override:
      public:
        host: tvault.it.just.works
        tls:
          ca: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          crt: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
    hosts:
      admin:
        host: tvault-api
      default: tvault
      internal: tvault-api
      public:
        host: tvault
        tls:
          ca: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          crt: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
    port:
      api:
        admin: 8785
        default: 80
        internal: 8785
        public: 443
    scheme:
      default: http
      public: https
  workloads:
    host_fqdn_override:
      public:
        host: workloadmgr.it.just.works
        tls:
          ca: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          crt: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
    hosts:
      admin:
        host: workloadmgr-api
      default: workloadmgr
      internal: workloadmgr-api
      public:
        host: workloadmgr
        tls:
          ca: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          crt: |
            -----BEGIN CERTIFICATE-----
            -----END CERTIFICATE-----
          key: |
            -----BEGIN RSA PRIVATE KEY-----
            -----END RSA PRIVATE KEY-----
    port:
      api:
        admin: 8780
        default: 80
        internal: 8780
        public: 443
    scheme:
      default: http
      public: https
  oslo_cache:
    statefulset:
      name: openstack-memcached-memcached
      replicas: 3
  oslo_db:
    auth:
      admin:
        username: root
        password: EGNpnn2YzhrJleYRQ0Rl6A9E530WQDun
      tvault:
        password: jDy1yW90uawDwtknESEnHYMckj1g
        username: tvault
  oslo_db_wlm:
    auth:
      admin:
        password: EGNpnn2YzhrJleYRQ0Rl6A9E530WQDun
        username: root
      wlm:
        password: jDy1yW90uawDwtknESEnHYMckj1g
        username: wlm
  oslo_messaging:
    auth:
      admin:
        password: ZF0eNSvmhbBBZdtXwq2Tyb2z7w9GI2Xm
        username: rabbitmq
      tvault:
        password: lRw68C5IbA5S3liTURuYLwaWcH
        username: tvaultJ1
      user:
        password: ZF0eNSvmhbBBZdtXwq2Tyb2z7w9GI2Xm
        username: rabbitmq
    hosts:
      default: rabbitmq
    path: /tvault
    statefulset:
      name: openstack-rabbitmq-rabbitmq
      replicas: 1
  oslo_messaging_notifications:
    auth:
      tvault:
        password: BTeFg9DdnH8GwfJJsINTaZzufC
        username: tvaultAD
    host_fqdn_override: {}
    hosts:
      default: rabbitmq
    path: /openstack
    port:
      amqp:
        default: 5672
      http:
        default: 15672
    scheme: rabbit
    statefulset:
      name: openstack-rabbitmq-rabbitmq
      replicas: 1
images:
  tags:
    bootstrap: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211129124739
    db_drop: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211111200716
    db_init: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211129124739
    dep_check: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/extra/kubernetes-entrypoint:v1.0.0-20200311160233
    tvault_api: docker-review-local.docker.mirantis.net/review/trilio-vault-115632:4
    tvault_contego: docker-review-local.docker.mirantis.net/review/trilio-vault-115632:4
    tvault_db_sync: docker-review-local.docker.mirantis.net/review/trilio-vault-115632:4
    image_repo_sync: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/extra/docker:17.07.0
    ks_endpoints: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211129124739
    ks_service: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211129124739
    ks_user: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/heat:victoria-bionic-20211129124739
    rabbit_init: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/general/rabbitmq:3.9.8-management
    test: docker-dev-kaas-virtual.artifactory-eu.mcp.mirantis.net/openstack/extra/xrally-openstack:2.1.0-20211007200025
jobs:
  ks_endpoints:
    restartPolicy: Never
  ks_service:
    restartPolicy: Never
  ks_user:
    restartPolicy: Never
manifests:
  job_rabbit_init: false
  network_policy: false
network:
  api:
    ingress:
      classes:
        namespace: openstack-ingress-nginx
  proxy:
    enabled: false
pod:
  lifecycle:
    disruption_budget:
      api:
        min_available: 2
      registry:
        min_available: 2
    upgrades:
      deployments:
        pod_replacement_strategy: RollingUpdate
        rolling_update:
          max_surge: 0
          max_unavailable: 10%
  replicas:
    api: 1
secrets:
  rbd: nova-rbd-keyring
```
## Fire up setup of trilio vault chart
```
helm3 upgrade --install tvault ./tvault --namespace=openstack --values=/tmp/tvault.yaml
```
## Apply license and trust
```
workloadmgr --endpoint-type internal license-create <license_file>
workloadmgr --endpoint-type internal trust-create --is_cloud_trust True admin
```
