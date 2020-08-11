#!/bin/sh
if ! hash sourcery; then
    echo "Sourcery not found on your PATH"
    exit 1
fi
SOURCERY_ARGS="--args mixpanel=${MIXPANEL_TOKEN} --args bugsnag=${BUGSNAG_APIKEY}"


sourcery --prune --verbose --templates ./Stencil  --sources ${SRCROOT} --output ${SRCROOT}/wallet/Generated $SOURCERY_ARGS 



