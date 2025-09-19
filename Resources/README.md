\# dataset\_phones.json

Obtained from: 'https://www.kaggle.com/datasets/sulthonaqthoris/mobile-phone-specifications-dataset/data'.

Modified for insertion into a CouchDB database.



\# setup.ps1

A simple script that prompts for credentials to access a CouchDB database at 'localhost:5984' and creates (or resets) a database named Phones using 'dataset\_phones.json'.



\## Prerequisites

* Curl installed.
* A CouchDB instance running on 'localhost:5984'.
* A dataset file named dataset\_phones.json in the same directory as this script.



\## Execution

> powershell.exe -executionpolicy unrestricted C:\\setup.ps1

