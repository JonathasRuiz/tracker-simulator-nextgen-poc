# Welcome to this PoC!

This Proof concept consists of a tracker simulator application deployed in an orchestrated kubernetes environment, via helm charts. This application supports real time communication between clients and servers using several types of communication patterns and protocols such as: WebSocket, SSE, gRPC, MQTT, HTTP Short Pooling and HTTP Long Polling.

Below is the step-by-step guide to spin up this Proof of Concept.

```
NOTE: This step-by-step guide assumes you have a basic understanding of Kubernetes and container orchestration. if you already have your kubernetes cluster up and running, you can skip to section 3.
```

## 1. Prerequisites

Ensure you have the following installed and configured:
- **Kubernetes environment:** You can deploy on your home lab, use a cloud provider like: AWS, GCP,Azure or like me use a cheap cloud service like: Digital Ocean, Akamai (Former Linode), etc.
- **L7 Load Balancer:** You can either use metalLB in your home lab or a cloud provider's load balancer service. (The configuration also allows you to run locally via NodePorts. You can tweak the values in the `values.yaml` file to enable/disable the load balancer and/or NodePorts)
- **Envoy Proxy Ingress:** Install Envoy Proxy as an ingress controller for your Kubernetes cluster.
- **Helm:** A simple package manager for Kubernetes to simplify our deployment process.
- **Container Runtime:** For cost reasons, We'll deploy the necessary infrastructure using a container runtime.

---

## 2. Installation & Configuration

### 2.1. Provisioning a Virtual Machine for our infrastructure
You can use any cloud provider or a home lab to provision a virtual machine. Make sure to have at least 4GB of RAM and 2 CPU cores. (This Step-by-Step guide will teach you how to set up a Kubernetes cluster on https://cloud.digitalocean.com/)

### 2.2. Install Git
To install Git, visit the [official installation page](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and follow the steps for your operating system.

### 2.3. Install Container runtime & container runtime compose
Example: https://docs.docker.com/engine/install/ubuntu/

```bash
sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 2.4. Clone repository and spin up infrastructure
**2.4.1. Clone repository.**
```bash
git clone https://github.com/JonathasRuiz/tracker-simulator-poc.git
```
**2.4.1. Spin up infrastructure.**
```bash
cd tracker-simulator-poc/docker
docker-compose up -d
```

### 2.2. Kubernetes cluster Setup
Same here. You're welcome to use any cloud provider or a home lab to provision a Kubernetes cluster. (This Step-by-Step guide will teach you how to set up a Kubernetes cluster on https://cloud.digitalocean.com/)

#### 2.2.1. Provisioning a k8 cluster in Digital Ocean
- After creating a digital account, head to the Kubernetes section and create a cluster.
- This cluster should have at least 3 nodes with 2GB of RAM and 2 CPU cores each.

#### 2.2.1. Install helm
Check this page for installation instructions: https://helm.sh/docs/intro/install/

#### 2.2.2. Install kubectl
Check this page for installation instructions: https://kubernetes.io/docs/tasks/tools/install-kubectl/

#### 2.2.3. Configure kubectl context
- After creating the cluster, download the kubeconfig file and configure kubectl to use it.
- Edit your kubeconfig file to add the cluster context.(Shown in details in the video tutorial)

---

## 3. Repository Setup

### 3.1. Clone and Navigate
Run the following commands to clone the repo:

```bash
git clone https://github.com/JonathasRuiz/tracker-simulator-poc.git
```

Navigate to the correct folder:

```bash
cd tracker-horizontal-scaling
```

### 3.2. Configuration (values.yaml)
Edit the `values.yaml` file present in the root folder. **Crucial:** Update the following information:

- **`googleMapsApiKey`**
  - Your Google Maps API key.
- **`redis.host`**
  - The host of your Redis instance. When provisioning the infrastructure, you should get a public IP or DNS name from your cloud provider.
- **`redis.port`**
  - The port of your Redis instance.
- **`mqtt.host`**
  - The host of your MQTT broker. When provisioning the infrastructure, you should get a public IP or DNS name from your cloud provider.
- **`mqtt.port`**
  - The port of your MQTT broker.
- **`envoy.host`**
  - The host of your Envoy proxy. When provisioning the infrastructure, you should get a public IP or DNS name from your cloud provider.

---

## 4. Spin Up our Pods & Configure Envoy

In the same folder used in the previous step, run the compose command matching your runtime.

**Provision tracker-simulator:**
```bash
cd tracker-simulator-poc

helm install tracker-simulator https://github.com/JonathasRuiz/tracker-simulator-chart/raw/refs/heads/master/tracker-simulator-0.1.0.tgz -f values.yaml
```

**Install & Configure Envoy:**

```bash
# Install crd envoy gateway
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.0/standard-install.yaml

# Install crd envoy proxy
kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/v1.2.0/install.yaml

# Install tracker simulator envoy chart
helm install tracker-simulator-envoy https://github.com/JonathasRuiz/tracker-simulator-envoy-chart/raw/refs/heads/master/tracker-simulator-envoy-0.1.0.tgz -f values.yaml

```

---

## 5. Let's test!

Here are a few suggestions for tests:

1. Run a rate based simulation using all 6 real time communication patterns with the following parameters:
   - 50 Concurrent users
   - Client/Server exchange ratio: 1:1
   - 60 messages per minute (8 messages per second)
   - 300 data points to be exchanged back and forth.

2. Contrast the previous test with 10x more users:
   - 500 Concurrent users
   - Client/Server exchange ratio: 1:1
   - 60 messages per minute (80 messages per second)
   - 300 data points to be exchanged back and forth.

3. Run a streaming simulation using all 6 real time communication patterns with the following parameters:
   - 10 Concurrent users
   - Client/Server exchange ratio: 1:1
   - 500 data points to be exchanged back and forth.

4. Run a streaming simulation using all 6 real time communication patterns with the following parameters:
   - 100 Concurrent users
   - Client/Server exchange ratio: 1:1
   - 500 data points to be exchanged back and forth.
