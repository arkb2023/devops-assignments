![Executed from Bash Prompt](https://img.shields.io/badge/Executed-Bash%20Prompt-green?logo=gnu-bash)
![Status: Completed](https://img.shields.io/badge/Status-Completed-brightgreen)

## Module 6: Jenkins Assignment - 3

Tasks To Be Performed:  
1. Create a pipeline in Jenkins  
2. Once push is made to `develop` a branch in Git, trigger job `test`. This will copy Git files to `test node`  
3. If test job is successful, then `prod` job should be triggered  
4. Prod jobs should copy files to `prod node`  

### Prerequisites

- Jenkins lab environment set up, with public access to Jenkins UI via the `ngrok` tool as detailed in [`Lab-Setup-Jenkins-Master-Agent`](../m6-jenkins-lab-setup/README.md)  
- A publicly accessible GitHub repository named [`m6-a03-jenkins`](https://github.com/arkb2023/m6-a03-jenkins.git) created specifically for testing and containing `develop` branch to support webhook-triggered pipeline builds. 


### Step 1: Set Up Jenkins Jobs

Create **two Jenkins jobs** `test` and `prod` with the following settings:

#### **`test` job settings**

- **Name**: `test`
- **Description**: Job triggers on push to `develop` branch; Copies Git files to `test-server`.
- **Type**: Freestyle

**Configuration:**

- **General**
  - Check `GitHub project`
  - *Project URL*: `https://github.com/arkb2023/m6-a03-jenkins.git`
  - Check `Restrict where this project can be run`
  - Label Expression `test`  

  *Jenkins view shows settings for the `General configuration` section for the `test` job.*  

  ![test job configuration general section](images/01-jenkins-test-job-configuration-general.png)

- **Source Code Management**
  - Select `Git`
  - *Repository URL*: `https://github.com/arkb2023/m6-a03-jenkins.git`
  - *Branches specifier*: `*/develop`

  *Jenkins view shows settings for the `Source Code Management` section for the `test` job.*  

  ![test job configuration source code management section](images/02-jenkins-test-job-configuration-source-code-mgmt.png)

- **Build Triggers**
  - Check `GitHub hook trigger for GITScm polling`  

  *Jenkins view shows settings for the `Triggers` section for the `test` job.*  

  ![test job configuration triggers section](images/03-jenkins-test-job-configuration-triggers.png)

- **Environment**
  - Select `Delete workspace before build starts`

  *Jenkins view shows settings for the `Environment` section for the `test` job.*  

  ![test job configuration environment section](images/04-jenkins-test-job-configuration-environment.png)


- **Build Steps**
  - Add build script in `Execute shell`

  *Jenkins view shows settings for the `Build Steps` section for the `test` job.*  
  
  ![test job configuration build steps section](images/05-jenkins-test-job-configuration-build-steps.png)

- **Post-build Actions**
  - Select `Build other projects`
  - Set Projects to build `prod` 
  - Select `Trigger only if build is stable`

  *Jenkins view shows settings for the `Post build actions` section for the `test` job.*  
  
  ![test job configuration post build actions section](images/06-jenkins-test-job-configuration-post-build-actions.png)

---

#### **`prod` job settings**

- **Name**: `prod`
- **Description**: prod job - runs if test job is successful
- **Type**: Freestyle

**Configuration:**

- **General**
  - Check `GitHub project`
  - *Project URL*: `https://github.com/arkb2023/m6-a03-jenkins.git`
  - Check `Restrict where this project can be run`
  - Label Expression `prod`  

  *Jenkins view shows settings for the `General configuration` section for the `prod` job.*  

  ![prod job configuration general section](images/07-jenkins-prod-job-configuration-general.png)

- **Source Code Management**
  - Select `Git`
  - *Repository URL*: `https://github.com/arkb2023/m6-a03-jenkins.git`
  - *Branches specifier*: `*/develop`

  *Jenkins view shows settings for the `Source Code Management` section for the `prod` job.*  

  ![prod job configuration source code management section](images/08-jenkins-prod-job-configuration-source-code-mgmt.png)

- **Environment**
  - Select `Delete workspace before build starts`

  *Jenkins view shows settings for the `Environment` section for the `prod` job.*  

  ![prod job configuration environment section](images/09-jenkins-prod-job-configuration-triggers-environment.png)


- **Build Steps**
  - Add build script in `Execute shell`

  *Jenkins view shows settings for the `Build Steps` section for the `prod` job.*  
  
  ![prod job configuration build steps section](images/10-jenkins-prod-job-configuration-build-steps.png)


### Step 2: Configure GitHub Webhook

Set up a webhook in GitHub repository settings, pointing to the Jenkins URL to trigger builds on any push event.  

*GitHub view shows the repository settings with the webhook configuration.*

![GitHub view shows the repository settings with the webhook configuration.](images/11-webhook-settings.png)


### Step 3: Verify End-to-End Workflow

#### 1. Push Code to the `develop` Branch  

Make a code change and push to the `develop` branch in GitHub to initiate the webhook trigger.  

*Terminal view shows code pushed to the `develop` branch.*
   
![Terminal view shows code pushed to the `develop` branch.](images/31-terminal-view-code-push-in-develop.png)

---
#### 2. Verify Downstream and Upstream Job Linkage

*Jenkins `test` job status view displays the downstream linkage to the `prod` job.*  

![downstream link](images/41-test-job-status-downstream-projects-prod.png)

*Jenkins `prod` job status view displays the upstream linkage to the `test` job.*  

![downstream link](images/51-prod-job-status-upstream-projects-test.png)

---

#### 3. Verify GitHub Triggered Webhook

   *GitHub webhook request view triggered by push to the `develop` branch. (Note the commit ID `59ab1e` in the payload's `after` attribute; this is to correlate with the corresponding Jenkins job logs.)*

   ![GitHub webhook request view triggered by push to the test branch.](images/12-webhook-request.png)
   
   *GitHub webhook successfully received 200 response from Jenkins server.*

   ![GitHub webhook successfully received 200 response from Jenkins server.](images/13-webhook-200-response.png)

---

#### 4. Verify `test` followed by `prod` jobs triggered

In response to the GitHub webhook request, Jenkins automatically starts the `test` job, once test job is successful it triggers `prod` job.

*Jenkins `Build History` view shows the `test` job#10 followed by `prod` job#2 successfully triggered*

![Jenkins view shows jobs successfully triggered.](images/21-jenkins-build-history-test-prod-back2back-triggered.png)

**Verify `test` job #10 details**

*Jenkins view shows `test` job #10 `status` Commit ID `59ab1e`*

![Jenkins view shows jobs successfully triggered.](images/43-test-job10-status-view.png)

*Jenkins view shows the `test` job #10 `console output`* (Note: The last two lines state `Triggering a new build of prod` and `Finished: SUCCESS`, confirming that the `prod` job was triggered as a `downstream action` following a successful test job.)

![Jenkins view shows jobs successfully triggered.](images/45-test-job10-console-output-view.png)

**Verify `prod` job #2 details**

*Jenkins view shows `prod` job #2 `status`* (Note: At the top it says `Started by upstream project test build number 10`, confirming `prod` job #2 was triggered as a downstream to `test` job #10)

![Jenkins view shows jobs successfully triggered.](images/52-prod-job2-status-upstream-projects-test-build-number-10.png)

*Jenkins view shows the `prod` job #2 `console output` confirming successful execition*

![Jenkins view shows jobs successfully triggered.](images/54-prod-job2-console-output-view.png)

*Terminal view shows code deployed to the `prod-server`*
   
![Terminal view shows code deployed to the `prod-server`](images/32-terminal-view-code-deployed-in-prod-server.png)

---
