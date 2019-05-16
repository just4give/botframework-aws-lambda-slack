# botframework-aws-lambda-slack
This repo contains code and guidance to deploy Microsoft bot code to AWS Lambda and Integrate with Slack.

<img width="945" alt="Screen Shot 2019-05-16 at 2 50 10 PM" src="https://user-images.githubusercontent.com/9275193/57879263-01565b00-77ea-11e9-9d35-0c78654c3e70.png">

I got very excited when I first saw Microsoft Bot Framework (https://dev.botframework.com). Microsoft has done a great job! You can deploy same bot to multiple channels such as MS Team, Slack, Facebook. But all the documents/tutorial I read recommend to deploy bot backend code to Azure. 
I have been working with AWS for few years but never used Azure before. So was looking for a solution to deploy the nodejs backend
to AWS lambda as I am more comfortable. I still need to create Azure account to create the bot and deploy to channels but that's OK ( who knows in future I may migrate from AWS Lambda to Azure Fuction :) ) 


I googled but did not find a solution which just works out of the box. So I decided to poke the framework code a bit and get it deployed to lambda. 

PS: If you know a better and more elegent solution, please let me know.


I used yoman builder to scaffold the bot framework following this tutorial (https://docs.microsoft.com/en-us/azure/bot-service/javascript/bot-builder-javascript-quickstart?view=azure-bot-service-4.0) 

<img width="914" alt="Screen Shot 2019-05-15 at 3 18 45 PM" src="https://user-images.githubusercontent.com/9275193/57819723-a7a55080-7757-11e9-9d2f-80f71d14b037.png">

The framwork code comes with *restify* webserver which does not work out of the box on AWS Lambda. But fortunately AWS released *aws-serverless-express* which is build on top of Express server and works with AWS Lambda.
So I simply removed restify and injected aws-serverless-express & express in the framework code. 

Check out the commit to find the exact code change I had to do ( https://github.com/just4give/botframework-aws-lambda-slack/commit/cb46b5b9c76cd5e6c113fe866c8ea79e363cb3d4 )

That's all !!!

Now you are ready to deploy this code to AWS Lambda and create AWS API Gateway to access the code over REST API. Once you deploy to AWS and get the API endpoint, simply update that to Azure Bot as below.

<img width="775" alt="Screen Shot 2019-05-15 at 8 55 06 PM" src="https://user-images.githubusercontent.com/9275193/57819989-dc65d780-7758-11e9-8677-b8b765a85c80.png">


If you are on the same boat as me and want to give a try, I have created terraform scripts to help you create AWS resoures ( Lambda, Gateway ) and deploy backend code through your terminal without even log into AWS Console. 

```
cd terraform
terraform init
terraform apply --var-file=variables.tfvars --auto-approve
```
At the end the script will print API Gateway endpoint on your terminal. Copy that and update in Azure.

<img width="776" alt="Screen Shot 2019-05-15 at 9 38 05 PM" src="https://user-images.githubusercontent.com/9275193/57820254-fce26180-7759-11e9-9d1d-65188e1abd1c.png">


