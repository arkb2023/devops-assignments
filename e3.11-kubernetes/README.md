Exercise: 3.11. Kubernetes

Familiarize yourself with Kubernetes terminology and draw a diagram describing what "parts" the Kubernetes contains and how those are related to each other.

You should draw a diagram of at least three host machines in a Kubernetes cluster. In the diagram assume that the cluster is running two applications. The applications can be anything you want. An example could be a video game server and a blog website.

You may take inspiration from the diagrams of part Chapter 3(opens in a new tab)(opens in a new tab).

The applications may utilize other machines or APIs that are not part of the cluster. At least three of the machines should be utilized. Include "your own computer" in the diagram as the one sending instructions via kubectl to deploy an application. In addition, include a HTTP message coming from the internet to your Kubernetes cluster and how it may reach an application.

Make sure to label the diagram so that anyone else who has completed this exercise, would understand it. The diagram should contain at least four of the following labels: Pod, Cluster, Container, Service, and Volume. I prefer to use draw.io(opens in a new tab)(opens in a new tab) for diagrams, but you can use whichever tool you want.

See the Kubernetes Glossary(opens in a new tab)(opens in a new tab), and have a look to some helpful diagrams(opens in a new tab)(opens in a new tab)

As the answer submit the URL where the diagram can be found.

My take away:
Kubernetes Parts and interrelation
3 host machines in 1 cluster
cluster runs 2 apps
Apps may use atleast 3 machines or APIs outside cluster
Separate Controller (kubectl) host 
Trace Public Incoming HTTP request to app Running in cluster
Label entities in diagram - Pod, CCluster, Container, Service, Volume

Provide a case study where i can map these requirements to draw the diagram


Here’s a detailed case study scenario you can use to map the Kubernetes cluster for your exercise and draw an informative, clearly-labelled diagram:

***

**Case Study Scenario: "Acme Services Platform"**

**Background:**
You are tasked with deploying a multi-application Kubernetes cluster for Acme Corp. The platform hosts two main applications:
- **App 1:** A multiplayer video game server (GameServer) that stores session data in a Redis cache.
- **App 2:** A blog web application (BlogSite) that interacts with an external image storage API and uses a MySQL database (outside the cluster).

**Cluster Setup:**
- The Kubernetes cluster consists of three worker nodes (host machines): **Node A**, **Node B**, and **Node C**.
- Both applications are deployed as Kubernetes Deployments, each running on at least two of the nodes for redundancy.
- The cluster is managed from **Your Own Computer**, which uses `kubectl` to send commands to the cluster’s control plane/API server.
- The cluster exposes both apps via their own **Kubernetes Service** objects (e.g., NodePort or LoadBalancer for HTTP/ingress).
- External HTTP requests from users on the Internet are routed via a Load Balancer (Service) to the correct app/pod inside the cluster.

**External Resources:**
- **GameServer** accesses:
    - An external REST API for leaderboard management.
    - A Redis cache running on one of the nodes (as a Pod with a Persistent Volume).
- **BlogSite** accesses:
    - An external S3-compatible image storage API.
    - A managed MySQL database outside the cluster (hosted, e.g., on AWS RDS).

**Entities to Label in Diagram:**
Include labels for: **Cluster**, **Pod**, **Container**, **Service**, and **Volume**.
- Clearly show that each Pod runs one or more Containers.
- Show which Pods and Services run on which host machines.
- Show the HTTP request path from the Internet to the in-cluster Applications.
- Show how the applications communicate with external APIs/resources.
- Label Your Own Computer and a typical kubectl interaction sending a deployment instruction to the cluster.
- Optional: Add network connections, e.g., between Services and Pods; between Pods and Volumes; from Pods/Services to external APIs.

***

**Outline for Your Diagram (draw.io/mermaid):**

- Left side: **Your Own Computer** (with `kubectl`)
- Center: **Cluster boundary** (Group all nodes inside a “Cluster” box or dashed boundary)
    - At least **3 Nodes** (Node A, Node B, Node C)
        - **Pods** for each app (GameServer, BlogSite) distributed on nodes
        - **Pod** for Redis on one node, with attached **Volume**
    - **Services** inside cluster mapping to apps
- Top/Outside: **Internet/Clients** → HTTP Request → Cluster Ingress/Service  
- Right/Bottom: External APIs/Resources
    - REST API for GameServer (outside cluster)
    - S3-compatible storage API (outside cluster)
    - MySQL database (outside cluster)

***

**How Each Label Fits:**
- **Cluster:** Encompasses all nodes/machines in the Kubernetes cluster
- **Pod:** Smallest deployable unit within the nodes; runs containers
- **Container:** Packs the app’s code + runtime; inside Pods
- **Service:** Exposes Pods to other pods/Internet (stable endpoints)
- **Volume:** Persistent storage attached to Pods

***

**Sample Flow:**
- Public HTTP request → Cluster’s LoadBalancer Service → Targets correct Pod (BlogSite or GameServer)
- App Pod may talk to Redis Pod (internal), MySQL DB (external), or image storage API (external)
- kubectl applies a deployment from your computer to the API server, which schedules Pods across Nodes

***
