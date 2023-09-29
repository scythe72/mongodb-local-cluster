#!/usr/bin/env sh

echo "Starting automation agent..."

echo "mmsGroupId=${mmsGroupId}" > /etc/mongodb-mms/automation-agent.config
echo "mmsApiKey=${mmsApiKey}" >> /etc/mongodb-mms/automation-agent.config
echo "mmsBaseUrl=${mmsBaseUrl}" >> /etc/mongodb-mms/automation-agent.config

echo "logFile=${logFile}" >> /etc/mongodb-mms/automation-agent.config
echo "logLevel=${logLevel}" >> /etc/mongodb-mms/automation-agent.config

echo "... using configuration: "
cat /etc/mongodb-mms/automation-agent.config

su -c "/opt/mongodb-mms-automation-agent-12.0.26.7740-1.amzn2_aarch64/mongodb-mms-automation-agent \
-f /etc/mongodb-mms/automation-agent.config \
-pidfilepath /data/configdb/mongodb-mms-automation-mms-agent.pid" mongodb

