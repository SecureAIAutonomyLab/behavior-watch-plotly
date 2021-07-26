# Cloud-Vitals-V5.0
Newest Cloud Vitals Version

In case the instructions on the README file do not work go to the following link and use the tutorial as necessary

https://docs.amplify.aws/start/q/integration/ios

After cloning the Xcode project open a terminal at the file and run the following commands in the presented order.

(make sure to use sudo for all)

 
You must have cocoapods installed in order to run pod install
 
Install Cocoapods with: 

(Install Guide Link: https://cocoapods.org)
 
        $ sudo gem install cocoapods
     
This command should now run and download all the pods listed in the podfile

        pod install

Now we need to create a connection between our app and AWS through Amplify

Option 1:

        curl -sL https://aws-amplify.github.io/amplify-cli/install | bash && $SHELL

If you have npm installed use the second option (recommended)
  
Option 2:

        npm install -g @aws-amplify/cli

(go to this link to install npm: https://nodejs.org/en/)

        amplify init --quickstart --frontend ios

Now we need to configure the connection from Cloud Vitals to AWS

Open a command terminal at the project's folder (behavior-watch-plotly) and run the command below

        amplify init
        
After running this command a bunch of configuration settings will appear in the following order

Answer them in this order
   ? Do you want to use an existing environment? (Y/n) 
                          
        y
    
If you do not have an existing environment create one called "ailadev"

If given a list of environments to choose pick "ailadev"


   Next you will be asked to choose your default editor
   
   Use the arrow keys to choose "Xcode"
   
   After that you will be asked to choose your privacy preference
   
   Use the arrow keys and select "Access Keys"
   
   Access Key:
   
      AKIA6A6KUJWZGQR3OZW7
   
   Secret Access Key:
   
      Fu860GmuvRxina4JO8HRyB6X6dskazKhyOlGJgzJ
      
   Finally you will be asked to pick your prefered region
   
   Use the arrow keys and select "us-east-2"

You should be able to build the Xcode proect successfully now.

To ensure everything worked well run the app on your phone connected to the debugger and check for the message "Initialized Amplify" at the top of the debugging console. Also when you upload any piece of data to S3 ensure that the message "DONE UPLOADING DATA" appears in the console.

                       
