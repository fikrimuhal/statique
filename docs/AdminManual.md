# Admin Manual

## Components

### Services

* **statique service:** static file web server. Requires passwords.txt, permissions.yml

* **statique-notify service:** watches for changes in Dropbox, starts build.py when change detected. (OPTIONAL)

Recommended approach: use crontab to build every X minutes to save resources.

### Scripts

* **build.py:** copies chosen Dropbox folders to /tmp/statique, uses generate_index, deploys to app public folder.

* **generate_index.md:**  generates index.md files and then compiles all md files into html in the same folder.

* **md2html.sh:** markdown to html compiler command


## Configurable Parameters

* You can provide your custom scripts/templates in your ~/Dropbox/statique folder.
* Sample dropbox folder structure can be seen on *sample_dropbox_folder* folder.
* Statique folder may contain the following files/folders:
  * config
    * include.txt - folders to include in the build
    * passwords.txt - username and password pairs
    * permissions.yml - permission map
  * template.html - HTML template to use for index pages.
  * build.py
  * generate_index.py
  * md2html.sh
* If no custom files (other than config) provided, they will be copied from *sample_dropbox_folder*.
* Providing config folder with *include.txt, passwords.txt, permissions.yml* is **mandatory**.

**Warning:** Be careful to provide a valid YAML File for permissions.yml.
