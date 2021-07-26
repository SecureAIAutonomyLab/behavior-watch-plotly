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

You should be able to build the Xcode proect successfully now.
                       
