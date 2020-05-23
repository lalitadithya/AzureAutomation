## Azure SQL Database
Azure SQL database is Azure's PaaS offering for SQL server. It has everything that you will need, but it lacks the option to start and stop on the server. For many people including me who want to save some $$ on their Azure bill the ability to start and stop SQL server is important. You might only want to run it during business hours or only when you need the instance while retaining the pervious state of the instance. To achieve this, I make of an Azure storage account to save the state of the database and Azure's container instances to destroy and create the SQL server as and when needed. The Azure container instance can be triggered using Azure logic apps or Azure functions.

### Stop Azure SQL Database
In the "StopDatabase" folder you will find the dockerfile and the script to save the state of an Azure SQL server to an Azure storage account using [mssql-scripter](https://github.com/microsoft/mssql-scripter). After the state has been saved, the resource group containing the Azure SQL server will be deleted

### Start SQL Database
In the "StartDatabase" folder you will find the dockerfile and the script to deploy an ARM template (downloaded from Azure storage) and then restore the state of the SQL server from Azure storage using mssql-tools
