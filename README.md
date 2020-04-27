# ec2-sample-app

ec2-sample-app is a simple node js application. It calls a database and returns a json responds. 

There are 2 basic entpoints 

  - < EC2InstanceIP >/people
  - < EC2InstanceIP >/person/< int >
 
# Structure

![](https://raw.githubusercontent.com/ValenteFV/ec2-sample-app/master/img/Screenshot%202020-04-27%20at%2017.39.46.png)

# Requirements
  - Terraform on host

# Technologies

* [Docker] - Docker / Docker Compose
* [Terraform] - Terraform
* [Node JS] - Node JS

### Installation

This application requires Terraform to be installed on the host machine. Please follow the instalation instructions in the [Terraform website]. Be sure to run ```terraform init``` after running the instalation process. The provider that our Terraform Template uses is AWS, so you need to have the following variables in your enviorment in your system. 

For Mac / Linux
```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_DEFAULT_REGION="eu-west-2"
```

For Windows
You can follow these [window instructions].


Once you installed Terraform, you can git clone this repository, 
```
git clone https://github.com/ValenteFV/ec2-sample-app.git
cd ec2-sample-app
terraform apply
```

# Accessing the endpoint
To be able to access the endpoint go to your [EC2 instance] in AWS and copy the IP (which will be the attached Elastic IP that Terraform has been created) of the the newly created Instance. 

Once you have the Elastic IP, you can check in your browser or use curl
:
EXAMPLE IP:
```18.67.3.43/people```
or 
```18.67.3.43/person/1```
or 
```
curl 18.67.3.43/person/1
```


[EC2 instance]: <https://eu-west-2.console.aws.amazon.com/ec2/v2/home?region=eu-west-2#Home:>
[Terraform website]: <https://learn.hashicorp.com/terraform/getting-started/install.html>
[window instructions]: <https://www.architectryan.com/2018/08/31/how-to-change-environment-variables-on-windows-10/>
[Terraform_link]: <https://www.terraform.io/>
[Terraform]: <https://www.terraform.io/>
[Docker]: <https://www.docker.com/>
[Node Js]: <https://nodejs.org/en/>