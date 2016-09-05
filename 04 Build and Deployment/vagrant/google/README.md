
# Deploying to Google Using Vagrant

Make sure the latest version of Vargrant is installed.

Install the vagrant-google plugin.
```
vagrant plugin install vagrant-google
```

Goto the Google Cloud Platform Dashboard: https://console.cloud.google.com

Dropdown list in blue banner choose **Create Project**.

Give the project a name such as **myAPI**. Make a note of the *project ID* such as `myapi-142519`.

Choose *View more projects* from the dropdown list and choose this project. Click **Open**.

Click on the *Get Started* button in the **Try Compute Engine** section.

In the tutorial sidebar choose *continue*. It will take a few minutes for Compute Engine to start.

Go to the API dashboard.

https://console.cloud.google.com/apis/dashboard

Click on **Credentials**.

Choose **Create credentials > Service account key**

Choose Compute Engine default service account, make sure the JSON option is selected.

Store the downloaded key in a safe location and _don't lose it!_

Click on **manage service accounts**.

copy the appropriate service account id that ends in gserviceaccount.com

34404495536-compute@developer.gserviceaccount.com

burger menu > compute > compute engine. Choose Metadata > SSH keys tab.

**Add SSH keys**

Copy public SSH key into this screen.

vagrant box add gce https://github.com/mitchellh/vagrant-google/raw/master/google.box

Configure the Vagrantfile with your credentials.

vagrant up --provider=google

# Open Port

burger menu > Networking.

Firewall rules

Create firewall rule.

- Name: node
- Description: default nodejs Port
- Source Filter: allow from any Source
- Allowed protocols and ports: tcp:8080

Save.