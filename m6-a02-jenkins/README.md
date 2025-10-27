![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

## Module 6: Jenkins Assignment - 2

Tasks To Be Performed:  
1. Add `2 nodes` to `Jenkins master`  
2. Create `2 jobs` with the following jobs:  
   - Push to `test`  
   - Push to `prod`  
3. Once a push is made to `test` branch, copy Git files to `test server`  
4. Once a push is made to `master` branch, copy Git files to `prod server`  


### Prerequisites

- Jenkins lab environment set up as detailed in [`Lab-Setup-Jenkins-Master-Agent`](../m6-jenkins-lab-setup/README.md)  
- Ensure public access to the Jenkins UI via the `ngrok` tool
- A publicly accessible GitHub repository named [`m6-a02-jenkins`](https://github.com/arkb2023/m6-a02-jenkins.git) was created specifically for testing purposes, featuring both `test` and `main` branches configured to support webhook-triggered pipeline builds.

### Step 1: Set Up Jenkins Pipeline Jobs

Create **two Jenkins pipeline jobs** with the following settings:

#### **Job #1: push-to-test**

- **Name**: `push-to-test`
- **Description**: Job triggers on push to `test` branch; copies Git files to `test server`.
- **Type**: Pipeline

**Configuration:**

- **General**
  - Check `GitHub project`
  - *Project URL*: `https://github.com/arkb2023/m6-a02-jenkins.git`
- **Build Triggers**
  - Check `GitHub hook trigger for GITScm polling`
- **Pipeline Definition**
  - Select `Pipeline script from SCM`
  - *SCM*: `Git`
    - *Repository URL*: `https://github.com/arkb2023/m6-a02-jenkins.git`
    - *Branches to build*: `*/test`
    - *Script Path*: [`jenkinsfile`](./jenkinsfile)

**Screenshots:**

*Jenkins view shows settings for the `General configuration` section for the `push-to-test` job.*

![Jenkins view shows settings for the `General configuration` section for the `push-to-test` job.](images/jenkins-push-to-test/21-jenkins-push-to-test-job-configuration-general-view.png)

*Jenkins view shows the settings for the `GitHub project repository` and `parameters` in the General section.*

![Jenkins view shows the “GitHub project” option enabled in the General section with the project URL set, linking the Jenkins job to the associated GitHub repository.](images/jenkins-push-to-test/22-jenkins-push-to-test-job-configuration-general-github-project-view.png)

*Jenkins view shows the `Triggers` section for the `push-to-test` job, with `GitHub hook trigger for GITScm polling` enabled to allow `GitHub webhooks` to automatically trigger builds on `push events`*

![Jenkins view shows the Triggers section for the `push-to-test` job, with “GitHub hook trigger for GITScm polling” enabled to allow GitHub webhooks to automatically trigger builds on push events.](images/jenkins-push-to-test/23-jenkins-push-to-test-job-configuration-triggers-view.png)

*Jenkins view shows the `Pipeline` section with `Pipeline script from SCM` selected, `SCM` set to `Git`, the `repository URL` provided, and the `branch specifier` set to `*/test` along with the `script path` for the [`jenkinsfile`](./jenkinsfile)*

![Jenkins view shows the Pipeline section with "Pipeline script from SCM" selected, SCM set to Git, the repository URL provided, and the branch specifier set to `*/test` along with the correct script path for the shared Jenkinsfile.](images/jenkins-push-to-test/24-jenkins-push-to-test-job-configuration-pipeline-view.png)

***

#### **Job #2: push-to-prod**

- **Name**: `push-to-prod`
- **Description**: Job triggers on push to `main` branch; copies Git files to `prod server`.
- **Type**: Pipeline

**Configuration:**

- **General**
  - Check `GitHub project`
  - *Project URL*: `https://github.com/arkb2023/m6-a02-jenkins.git`
- **Build Triggers**
  - Check `GitHub hook trigger for GITScm polling`
- **Pipeline Definition**
  - Select `Pipeline script from SCM`
  - *SCM*: `Git`
    - *Repository URL*: `https://github.com/arkb2023/m6-a02-jenkins.git`
    - *Branches to build*: `*/main`
    - *Script Path*: [`jenkinsfile`](./jenkinsfile)


**Screenshots:**

*Jenkins view shows settings for the `General configuration` section for the `push-to-prod` job.*

![Jenkins view shows settings for the `General configuration` section for the `push-to-prod` job.](images/jenkins-push-to-prod/21-jenkins-push-to-prod-job-configuration-general-view.png)

*Jenkins view shows the settings for the `GitHub project repository` and `parameters` in the General section.*

![Jenkins view shows the “GitHub project” option enabled in the General section with the project URL set, linking the Jenkins job to the associated GitHub repository.](images/jenkins-push-to-prod/22-jenkins-push-to-prod-job-configuration-github-project-view.png)

*Jenkins view shows the `Triggers` section for the `push-to-prod` job, with `GitHub hook trigger for GITScm polling` enabled to allow `GitHub webhooks` to automatically trigger builds on `push events`*

![Jenkins view shows the Triggers section for the `push-to-prod` job, with “GitHub hook trigger for GITScm polling” enabled to allow GitHub webhooks to automatically trigger builds on push events.](images/jenkins-push-to-prod/23-jenkins-push-to-prod-job-configuration-triggers-view.png)

*Jenkins view shows the `Pipeline` section with `Pipeline script from SCM` selected, `SCM` set to `Git`, the `repository URL` provided, and the `branch specifier` set to `*/main` along with the `script path` for the [`jenkinsfile`](./jenkinsfile)*

![Jenkins view shows the Pipeline section with "Pipeline script from SCM" selected, SCM set to Git, the repository URL provided, and the branch specifier set to `*/main` along with the correct script path for the shared Jenkinsfile.](images/jenkins-push-to-prod/24-jenkins-push-to-prod-job-configuration-pipeline-view.png)

***

> *Both jobs use the same [`jenkinsfile`](./jenkinsfile), parameterized by branch, and trigger automatically via GitHub webhooks upon push events to their respective branches.*  


### Step 2: Configure GitHub Webhook

Set up a webhook in GitHub repository settings, pointing to the Jenkins URL to trigger builds on any push event. Jenkins will filter and build only the configured branch for each job.

- **Payload URL**:  `https://apologal-nonperpendicularly-shelli.ngrok-free.dev/github-webhook`  
  *In this setup, the Payload URL is provided by `ngrok` as a `public reverse proxy`. It relays incoming GitHub webhook traffic to the internal Jenkins server at `http://localhost:8080/` acting as a bridge to enable public webhook delivery to a local Jenkins instance.*
- **Content type**: `application/json`
- **Event**:  Just the `push` event

*GitHub view shows the repository settings with the webhook configuration.*

![GitHub view shows the repository settings with the webhook configuration.](images/github/01-add-webhook.png)


### Step 3: Verify `push-to-test` End-to-End Workflow

#### 1. Push Code to the `test` Branch  
   Make a code change and push to the `test` branch in GitHub to initiate the webhook trigger.  
   ```bash
   # 1. Ensure you are on the test branch
   git checkout test

   # 2. Make your code changes
   touch code.txt && echo "code updated in test branch" > code.txt

   # 3. Add & Commit changes
   git add code.txt
   git commit -m "Updated code in test branch"

   # 4. Push the test branch to GitHub
   git push origin test
   ```

   *Terminal view shows code pushed to the `test` branch.*

   ![Terminal view shows code pushed to the `test` branch.](images/terminal/01-terminal-push-to-test-view.png)

---

#### 2. Verify GitHub Triggered Webhook

   *GitHub webhook request view triggered by push to the test branch. (Note the commit ID `1078210` in the payload's `after` attribute; this is to correlate with the corresponding Jenkins job logs.)*

   ![GitHub webhook request view triggered by push to the test branch.](images/github/02-webhooks-manage-webhook-request-view.png)
   
   *GitHub webhook successfully received 200 response from Jenkins server.*

   ![GitHub webhook successfully received 200 response from Jenkins server.](images/github/03-webhooks-manage-webhook-response-200-success-view.png)

---

#### 3. Verify Build Triggered

Jenkins automatically starts the `push-to-test` job, triggered by the GitHub webhook push event to the `test` branch.

*Jenkins view shows the job successfully triggered (see job #13 among other entries in the screenshot).*

![Jenkins view shows job successfully triggered.](images/jenkins-push-to-test/01-jenkins-push-to-test-job-auto-triggered-view.png)


*Jenkins view shows job successfully triggered—the commit ID `1078210` matches the earlier webhook request.*

![Jenkins view shows job successfully triggered with matching commit ID.](images/jenkins-push-to-test/02-jenkins-push-to-test-job-changes-view.png)

---

#### 4. Verify Pipeline Execution

Use the Jenkins UI to examine the `push-to-test` job’s `status` `console output` `polling logs` and `pipeline overview` sections, confirming the pipeline ran successfully in response to the `test` branch push.

*Jenkins `push-to-test` job #13 `status` view displays details essential for confirming correlation with the earlier Git push and webhook:*
- `Started by GitHub push ...`
- `Revision:` 1078210dda73e7b3b838402fc8edde0b92d8cf28
- `Repository:` https://github.com/arkb2023/m6-a02-jenkins.git
- `Branch:` refs/remotes/origin/test
- `Commit ID:` 1078210

![Jenkins status for triggered job](images/jenkins-push-to-test/15-jenkins-push-to-test-job-status-view.png)

*Jenkins `push-to-test` job #13 `console output` confirms usage of the [`jenkinsfile`](./jenkinsfile) from the script path and that execution occurred on the `test` node:*
- `Obtained jenkinsfile from ...`
- `Running on test in /home/jenkins/agent/workspace/push-to-test`

![Jenkins console output for triggered job](images/jenkins-push-to-test/03-jenkins-push-to-test-job-console-output-view.png)


*Jenkins `push-to-test` job #13 `polling log` shows the webhook URL, confirming successful use of the ngrok reverse proxy:*
- `Started by event from 140.82.115.39 ⇒ https://apologal-nonperpendicularly-shelli.ngrok-free.dev:8080/github-webhook/ ...`

![Jenkins polling log for triggered job](images/jenkins-push-to-test/13-jenkins-push-to-test-job-polling-log-view.png)

*Jenkins `push-to-test` job #13 `pipeline overview` confirms successful completion of each pipeline stage:*

- **Checkout SCM**
  
  ![Jenkins polling log pipeline checkout SCM](images/jenkins-push-to-test/05-jenkins-push-to-test-job-pipeline-overview-checkout-scm-stage-view.png)
  
  **Set Host**  
  *(maps target host to `test-server`)*
  
  ![Jenkins pipeline set host stage](images/jenkins-push-to-test/06-jenkins-push-to-test-job-pipeline-overview-set-host-stage-view.png)
  
  **Checkout**  
  *(stage successful on `test` agent)*
  
  ![Jenkins pipeline checkout stage](images/jenkins-push-to-test/07-jenkins-push-to-test-job-pipeline-overview-checkout-stage-view.png)
  
  **Deploy**  
  *(stage successful—code deployed to `test-server` at `/home/jenkins/deploy` via rsync)*
  
  ![Jenkins pipeline deploy stage](images/jenkins-push-to-test/08-jenkins-push-to-test-job-pipeline-overview-deploy-stage-view.png)

---

#### 5. Verify on jenkins test agent node: `jenkins-agent-test`

Review the `jenkins-agent-test` container workspace at `/home/jenkins/agent/workspace/push-to-test` and verify the `m6-a02-jenkins` cloned Git repository and its contents.

```bash
# From the Jenkins agent container, check out the workspace contents
docker exec -it --user jenkins jenkins-agent-test /bin/bash
cd /home/jenkins/agent/workspace/push-to-test
ls -l
cat code.txt
```
*Terminal view shows the `Jenkins test agent` workspace with Git files checked out in `/home/jenkins/agent/workspace/push-to-test`.*

![code file in jenkins test agent](images/terminal/02-terminal-jenkins-agent-test-workspace-view.png)

---

#### 6. Verify on `test-server`

SSH into the `test-server` container and check the deployed contents in `/home/jenkins/deploy`.

```bash
# From jenkins-agent-test, SSH to test-server and check deployed files
docker exec -it --user jenkins jenkins-agent-test /bin/bash
ssh jenkins@test-server
cd /home/jenkins/deploy
ls -l
cat code.txt
```
*Terminal view shows Git files copied to `test-server` in the `/home/jenkins/deploy` folder.*

![code file deployed to test-server](images/terminal/03-terminal-test-server-deployed-content-view.png)

---


### Step 4: Verify `push-to-prod` End-to-End Workflow

#### 1. Push Code to the `main` Branch  
   Make a code change and push to the `main` branch in GitHub to initiate the webhook trigger.  
   ```bash
   # 1. Ensure you are on the test branch
   git checkout main

   # 2. Make your code changes
   touch code.txt && echo "code updated in main branch" > code.txt

   # 3. Add & Commit changes
   git add code.txt
   git commit -m "Updated code in main branch"

   # 4. Push the test branch to GitHub
   git push origin main
   ```

   *Terminal view shows code pushed to the `main` branch.*

   ![Terminal view shows code pushed to the `main` branch.](images/terminal/04-terminal-push-to-prod-view.png)

---

#### 2. Verify GitHub Triggered Webhook

   *GitHub webhook request view triggered by push to the main branch. (Note the commit ID `d1a1516` in the payload's `after` attribute; this is to correlate with the corresponding Jenkins job logs.)*

   ![GitHub webhook request view triggered by push to the main branch.](images/github/06-webhooks-manage-push-to-prod-request-view.png)
   
   *GitHub webhook successfully received 200 response from Jenkins server.*

   ![GitHub webhook successfully received 200 response from Jenkins server.](images/github/07-webhooks-manage-push-to-prod-response-view.png)

---

#### 3. Verify Build Triggered

Jenkins automatically starts the `push-to-prod` job, triggered by the GitHub webhook push event to the `main` branch.

*Jenkins view shows the job successfully triggered (see job #5 among other entries in the screenshot).*

![Jenkins view shows job successfully triggered.](images/jenkins-push-to-prod/01-jenkins-push-to-prod-job-auto-triggered-view.png)


*Jenkins view shows job successfully triggered—the commit ID `d1a1516` matches the earlier webhook request.*

![Jenkins view shows job successfully triggered with matching commit ID.](images/jenkins-push-to-prod/03-jenkins-push-to-prod-job-changes-view.png)

---

#### 4. Verify Pipeline Execution

Use the Jenkins UI to examine the `push-to-prod` job’s `status` `console output` `polling logs` and `pipeline overview` sections, confirming the pipeline ran successfully in response to the `main` branch push.

*Jenkins `push-to-prod` job #5 `status` view displays details essential for confirming correlation with the earlier Git push and webhook:*
- `Started by GitHub push ...`
- `Revision:` d1a1516c59eabc82ca062bad3c793f185e994d07
- `Repository:` https://github.com/arkb2023/m6-a02-jenkins.git
- `Branch:` refs/remotes/origin/main
- `Commit ID:` d1a1516

![Jenkins status for triggered job](images/jenkins-push-to-prod/02-jenkins-push-to-prod-job-status-view.png)

*Jenkins `push-to-prod` job #5 `console output` confirms usage of the [`jenkinsfile`](./jenkinsfile) from the script path and that execution occurred on the `main` node:*
- `Obtained jenkinsfile from ...`
- `Running on prod in /home/jenkins/agent/workspace/push-to-prod`

![Jenkins console output for triggered job](images/jenkins-push-to-prod/04-jenkins-push-to-prod-job-console-output-begin-view.png)


*Jenkins `push-to-prod` job #5 `polling log` shows the webhook URL, confirming successful use of the ngrok reverse proxy:*
- `Started by event from 140.82.115.82 ⇒ https://apologal-nonperpendicularly-shelli.ngrok-free.dev:8080/github-webhook/ ...`

![Jenkins polling log for triggered job](images/jenkins-push-to-prod/05-jenkins-push-to-prod-job-polling-log-view.png)

*Jenkins `push-to-prod` job #5 `pipeline overview` confirms successful completion of each pipeline stage:*

- **Checkout SCM**
  
  ![Jenkins polling log pipeline checkout SCM](images/jenkins-push-to-prod/08-jenkins-push-to-prod-job-pipeline-overview-checkout-scm-stage-view.png)
  
  **Set Host**  
  *(maps target host to `prod-server`)*
  
  ![Jenkins pipeline set host stage](images/jenkins-push-to-prod/09-jenkins-push-to-prod-job-pipeline-overview-set-host-stage-view.png)
  
  **Checkout**  
  *(stage successful on `prod` agent)*
  
  ![Jenkins pipeline checkout stage](images/jenkins-push-to-prod/10-jenkins-push-to-prod-job-pipeline-overview-checkout-stage-view.png)
  
  **Deploy**  
  *(stage successful—code deployed to `prod-server` at `/home/jenkins/deploy` via rsync)*
  
  ![Jenkins pipeline deploy stage](images/jenkins-push-to-prod/11-jenkins-push-to-prod-job-pipeline-overview-deploy-stage-view.png)

---

#### 5. Verify on jenkins test agent node: `jenkins-agent-prod`

Review the `jenkins-agent-prod` container workspace at `/home/jenkins/agent/workspace/push-to-prod` and verify the `m6-a02-jenkins` cloned Git repository and its contents.

```bash
# From the Jenkins agent container, check out the workspace contents
docker exec -it --user jenkins jenkins-agent-prod /bin/bash
cd /home/jenkins/agent/workspace/push-to-prod
ls -l
cat code.txt
```
*Terminal view shows the `Jenkins prod agent` workspace with Git files checked out in `/home/jenkins/agent/workspace/push-to-prod`.*

![code file in jenkins prod agent](images/terminal/05-terminal-jenkins-agent-prod-workspace-view.png)

---

#### 6. Verify on `prod-server`

SSH into the `prod-server` container and check the deployed contents in `/home/jenkins/deploy`.

```bash
# From jenkins-agent-prod, SSH to prod-server and check deployed files
docker exec -it --user jenkins jenkins-agent-prod /bin/bash
ssh jenkins@prod-server
cd /home/jenkins/deploy
ls -l
cat code.txt
```
*Terminal view shows Git files copied to `prod-server` in the `/home/jenkins/deploy` folder.*

![code file deployed to prod-server](images/terminal/06-terminal-prod-server-deployed-content-view.png)

---
