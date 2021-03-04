# Hashtopolis Server Docker
### Simple hashtopolis server using linuxserver.io base nginx image.

### Notes
This is for my own personal use so don't expect alot but if it needs updating just let me know.

### Install
1. Create a database and user in something like MySQL or MariaDB.

2. Map the ports and volumes.

3. Go to container in browser and it will ask for database credentials and begin installing.

4. Profit

### Container Volumes
`/data` - Place for storing imported data like wordlists or rules.

`/config` - Place for storing any configs and logs.

### Container Ports
`80` - HTTP

`443` - HTTPS