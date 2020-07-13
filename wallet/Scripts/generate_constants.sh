#!/bin/sh
if ! hash sourcery; then
    echo "Sourcery not found on your PATH"
    exit 1
fi
SOURCERY_ARGS="--args mixpanel=${MIXPANEL_TOKEN}"

echo "sourcery --prune --verbose --templates wallet/Stencil  --sources ${SRCROOT} --output ${SRCROOT}/Generated $SOURCERY_ARGS"

sourcery --prune --verbose --templates ./Stencil  --sources ${SRCROOT} --output ${SRCROOT}/wallet/Generated $SOURCERY_ARGS 



