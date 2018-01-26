

# Interesting lessons from the of project generator

If code that was working before the project generator is now not working, check
several things:

1. Have target memberships for your source files changed? (for source files,
   interface files, etc)
2. Have the type of file for source files changed?(for example, from 'Default -
   Swift Source' to 'Data')
3. Were Swift settings like version, bridging header, etc removed in the
   process?
4. Were Catalog.xcassets converted into regular files and folders?
5. Was your deployment target rolled back? (for example, to iOS 5.1)

My recommendation for using the project generator - treat it as a potentially
destructive operation everytime new addons are compiled. Always commit before
running a project generator update, and ruthlessly review right afterwards.

Project generator also uses the old plist format, so touching the project
file(say by modifying the deployment target) will force xcode to recreate it.
This way, only changes related to the new addon can be reviewed


