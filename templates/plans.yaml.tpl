# Doc: https://rancher.com/docs/k3s/latest/en/upgrades/automated/
# agent plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: k3s-agent
  namespace: system-upgrade
  labels:
    k3s_upgrade: agent
spec:
  concurrency: 1
  channel: https://update.k3s.io/v1-release/channels/${channel}
  nodeSelector:
    matchExpressions:
      - {key: k3s_upgrade, operator: Exists}
      - {key: k3s_upgrade, operator: NotIn, values: ["disabled", "false"]}
      - {key: node-role.kubernetes.io/master, operator: NotIn, values: ["true"]}
  serviceAccountName: system-upgrade
  prepare:
    image: rancher/k3s-upgrade
    args: ["prepare", "k3s-server"]
  drain:
    force: true
    skipWaitForDeleteTimeout: 60
  upgrade:
    image: rancher/k3s-upgrade
---
# server plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: k3s-server
  namespace: system-upgrade
  labels:
    k3s_upgrade: server
spec:
  concurrency: 1
  channel: https://update.k3s.io/v1-release/channels/${channel}
  nodeSelector:
    matchExpressions:
      - {key: k3s_upgrade, operator: Exists}
      - {key: k3s_upgrade, operator: NotIn, values: ["disabled", "false"]}
      - {key: node-role.kubernetes.io/master, operator: In, values: ["true"]}
  tolerations:
    - {key: node-role.kubernetes.io/master, effect: NoSchedule, operator: Exists}
    - {key: CriticalAddonsOnly, effect: NoExecute, operator: Exists}
  serviceAccountName: system-upgrade
  cordon: true
  upgrade:
    image: rancher/k3s-upgrade