
Am Building a lockscreen mechanism where the app sets up the password and using it to authenticate whenever there is no input for 15 seconds or the app is paused
- use getx or get for state management. Do not use stateful widgets
Libraries
- get
- local_auth
- flutter_screen_lock
- flutter_secure_storage


STEPS
The steps may not be necessarily in order
- Create a controller to handle the logic. It will accept the following inputs. 
1. If the prompt should be on start
2. Max tries
3. function to call if password auth fails after max tries
4. storage name
5. function to call to allow update password or not 

- Create a class for the options so as to be passed as a single argument to controller

- controller should use local auth to get all available types and if they can be used

- controller should use flutter_secure_storage to store the pattern. The pattern should be encrypted using a randomly generate key that is persisted in the secure storage

- controller should save the state of the authentication.
 - setup not done, set up done, 


- Controller should expose a setUpAuthentication class that receives a type to use 
 - the setUpAuthentication should check if setup is already done and authenticate first before proceeding. If it fails clear the storage and logout user 

- controller should expose an authenticate class that triggers the right 


- could you update such that the options are passed to the class constructor of the api

- could you update such that the options are passed to the class constructor of the api
also controller onInit should list the possible types available for setting up and use through the UI can choose from the list password plus one of them

