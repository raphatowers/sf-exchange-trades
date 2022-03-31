# Salesforce App
Welcome to the Salesforce Exchange Trades App. Find the steps to run it below.

## Dev, Build and Test
Create a new scratch org with your preferred DevHub:
```
sfdx force:org:create --setdefaultusername --definitionfile config/project-scratch-def.json --setalias [org-alias]
```

Push the app code to the scratch org:
```
sfdx force:source:push
```

Assign the permission set to your user:
```
sfdx force:user:permset:assign --permsetname Exchange_Trades --targetusername [org-username]
```

Open the scratch org:
```
sfdx force:org:open
```

Follow the next steps to set-up the application:
1. Set your *Fixer.io API Access Key* in the **Exchange Trade Settings** custom setting.
2. Add the corresponding users to the **Trade reviewers** queue to automatically create new trade chatter posts.

Run the application:
1. Open the Salesforce App Launcher.
2. Search *Exchange Trades*.
3. Open the application and start creating new trades!