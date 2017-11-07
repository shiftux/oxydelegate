sed -i '/Installing process management software.../ i \    echo -e "done.\\n" && echo -n "Installing sodium... "\n\
    npm install sodium --save --unsafe-per &>> $logfile || { echo "Could not install process sodium. Exiting." && exit 1; }' /opt/oxy-node/oxy_manager.bash

sed -i '/cd public && npm install/ i \      cd public && npm install sodium --save --unsafe-per \&>> $logfile || { echo "Could not install process sodium. Exiting." && exit 1; }\n\
    npm install grunt-cli --save-dev \&>> $logfile || { echo "Could not install grunt-cli. Exiting." && exit 1; }' /opt/oxy-node/oxy_manager.bash

sed -i -e 's/cd public && npm install &/npm install \&/g' /opt/oxy-node/oxy_manager.bash