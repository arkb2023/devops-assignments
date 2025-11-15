Initialize Elastic Beanstalk Apps
Repeat for both frontend and backend directories:

    Choose your region.
    For platform: Choose Node.js for frontend, Go for backend.
    Configure or create application names as prompted.
Create an environment (one per app):

##
cd example-frontend
eb init
# Choose Node.js for frontend
eb create example-frontend-env

###
cd ../example-backend
eb init
# Select Go platform
eb create example-backend-env

# create teturns the URLs

Step 3: Set Environment Variables
For backend (CORS origin):
eb setenv REQUEST_ORIGIN=http://<frontend-env-url>.elasticbeanstalk.com

For frontend (backend API endpoint):

eb setenv REACT_APP_BACKEND_URL=http://<backend-env-url>.elasticbeanstalk.com

eb setenv REQUEST_ORIGIN=http://example-frontend-env.eba-qemduucp.ap-south-1.elasticbeanstalk.com
eb setenv REACT_APP_BACKEND_URL=http://example-backend-env.eba-u4kmkuwp.ap-south-1.elasticbeanstalk.com


Step 4: Test Local Deploy
(Optional, manual step)

bash
eb deploy

Visit the URLs shown after deploy complete and verify frontend/backend apps work as expected.


Step 5: Set Up AWS Credentials in GitHub
Go to IAM in AWS and create a user with AWS Elastic Beanstalk Full Access and S3 Full Access policies.

Generate access key and secret.

In your repository’s Settings → Secrets and Variables → Actions, add:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

(Optional: AWS_REGION)


tep 6: GitHub Actions Workflow
Sample workflow to deploy both apps on push:

.github/workflows/eb-deploy.yaml

name: Deploy to AWS Elastic Beanstalk

on:
  push:
    branches: [main]  # or your dev branch
    paths:
      - 'example-frontend/**'
      - 'example-backend/**'
      - '.github/workflows/eb-deploy.yaml'

env:
  AWS_REGION: ap-south-1  # or your chosen region

jobs:
  deploy-frontend:
    name: Deploy Frontend to Beanstalk
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to Elastic Beanstalk (Frontend)
        run: |
          cd example-frontend
          pip install --upgrade awsebcli
          eb deploy example-frontend-env

  deploy-backend:
    name: Deploy Backend to Beanstalk
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Deploy to Elastic Beanstalk (Backend)
        run: |
          cd example-backend
          pip install --upgrade awsebcli
          eb deploy example-backend-env




Using CLI to Get the URLs Later
If you lost the CLI output:

bash
eb status example-backend-env
or

bash
eb open example-backend-env


Deploy backend, get its URL.

Deploy frontend, get its URL.

Run environment variable commands:

bash
# On backend, set the frontend origin
eb setenv REQUEST_ORIGIN=http://example-frontend-env.eba-yyyyyy.ap-south-1.elasticbeanstalk.com --environment example-backend-env

# On frontend, set the backend URL
eb setenv REACT_APP_BACKEND_URL=http://example-backend-env.eba-xxxxxxx.ap-south-1.elasticbeanstalk.


# backend
docker build -t backend-app-server .
docker run -d --name backend-app-server --env REQUEST_ORIGIN=http://localhost:5000 -p 8080:8080 backend-app-server

# frontend
docker run -d --name frontend-app-server -p 5000:5000 frontend-app-server
docker run -p 5000:5000 --env PORT=5000 --env REACT_APP_BACKEND_URL=http://localhost:8080 frontend-app-server
