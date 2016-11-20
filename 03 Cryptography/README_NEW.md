
# Simple Secure API

In this lab you will install and run a simple working API that is used to teach the principles of application deployment. The code is on a repository at `https://github.com/covcom/todo.git`.

## Cloning the Repository

Clone a **Debian Server** instance and log in. Now clone the repository.
```
git clone https://github.com/covcom/todo.git
```
This will create a new directory called `todo/`, Navigate into this.

## Installing NodeJS

You will need to install the Node Version Manager tool which you can then use to install the latest stable version of NodeJS `node` and the Node Package Manager `npm`. Once this is installed you need to install the packages specified by `package.json`. Finally we can run the NodeJS API.
```
curl -s https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.bashrc
nvm list-remote
nvm install 7.1.0
npm install --only=production
node index
```
The script specifies that the default port used by the API is `8080`. Open a web browser and access the root of the API (remember to substitute the IP address of your server):
```
http://10.5.5.10:8080
```

### Specifying a Port

By default the server runs on port 8080 as defined in the defaultPort constant in the script. If we want to run the server on a different port we have two options:

1. change the value of `defaultPort`
2. define an environment variable on the server

The risk of allowing a developer to specifiy the port for a service is that this port would need to be configured on the network which creates additional work for the system admin team. The second option is therefore preferred. This allows the systems admin team to configure their preferred port by defining an environment variable. The developer then needs to incorporate this variable into their script.

Lets define a new environment variable called `PORT` and assign it a value of `8000`. This is added to the `.profile` file in the home directory, then this data is loaded. Finally we print the contents of the variable.
```
"export PORT=8000" >> ~/.profile
source ~/.profile
echo $PORT
```
Stop the server using `ctrl+c` and restart using `node index`. Now the API can be accessed on port `8000` rather than `8080`

## Running over HTTPS

At the moment the server is running over an insecure connection which would allow hackers to intercept data using a packet sniffer. To secure our connection we need to run our server over an encrypted connection.

### Generating an SSL Certificate

```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

 The `openssl` command takes a **command**. In this case we are using the `req` command specifies we want to generate a _PKCS#10 X .509 Certificate Signing Request (CSR)_.
 
 Open the _man page_ for the `req` command and find out the purpose of the different flags we have used.

 1. the `-x509` flag indicates we are generating a _self-signed certificate_
 2. the `-newkey` flag creates a new 4096 bit certificate using the **rsa** algorithm
 3. the `-keyout` flag specifies the filename to use for the _private_ key
 4. the `-out` flag specifies the _certificate_ filename
 5. the `-days` flag defines the valid duration of the certificate (if omitted, the default is 30 days)
 6. the `-nodes` flag specified that the private key should not be encrypted

Running this command will generate both files in the current directory. These need to be imported into the NodeJS script so that it can handle the secure connection. There is a second script called `secure.js` that loads this data. Open it and find the `httpsOptions` constant near the top of the script.

We can run this using `node secure`. Try connecting using:
```
https://10.5.5.10
```
Make sure you substitute your server's IP address. This uses the default port defined in the script however it looks for an environment variable called `HTTPS` and as a systems administrator you should never rely on default values.
```
"export HTTPS=443" >> ~/.profile
source ~/.profile
echo $HTTPS
```

## Using the API

Now the API is installed and running over HTTPS you can interact with it. Open up the **Chrome Postman** tool. This can be installed as either a Mac or Chrome app from https://www.getpostman.com/.

Once open, make sure your API is running then choose the **GET** methos, enter your secure URL and click on the **Send** button. This will send your request to the API.

![an empty set of lists](.images/step01.png)

The response is in JSON format and is displayed under the body tab. Notice that the response code is `404 not found` because there are currently no lists.

### Adding a List

To add a new list we need to POST it. Change the HTTP method from GET to POST then, in the request body add the list name and items in JSON format as shown.
```
{
  "name": "colours",
  "list": [
  	"red",
  	"orange"
  ]
}
```
Now click on the **Send** button. This time you should get the list details back in the response including the last modified date and time plus a unique ID.

![adding a new list](.images/step02.png)

If we now make a **GET** request we should see an array is returned with a single index.

Addd a second list, this time for our shopping.
```
{
  "name": "shopping",
  "list": [
  	"bread",
  	"butter"
  ]
}
```
If we make a GET request we should see an array with two indexes.
```
GET https://10.5.5.10/lists

  {
    "lists": [
      {
        "name": "colours",
        "id": "jo2fpfk9poefw66x09xuvru4f0"
      },
      {
        "name": "shopping",
        "id": "uerxmusyle808xaxvs11572os8"
      }
    ]
  }
```

### Getting List Details

We can see the details of the list by making a GET request, specifying the list ID.
```
GET https://10.5.5.10/lists/uerxmusyle808xaxvs11572os8

  {
    "id": "uerxmusyle808xaxvs11572os8",
    "name": "shopping",
    "modified": "2016-11-20T11:52:14.039Z",
    "list": [
      "bread",
      "butter"
    ]
  }
```
