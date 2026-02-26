#!/bin/bash

sudo yum update -y 

sudo yum install docker -y

sudo service docker start

git clone https://github.com/arieluchka-lectures/terraform-100625/tree/Sergey/010-One_Click_Apps/Stirling-PDF/Sergey