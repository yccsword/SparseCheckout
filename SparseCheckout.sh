#!/bin/sh

UPDATE=${1}
RESPOSITORY_PATH=${2}
REMOTE_URL=${3}
COMMIT_BRANCH=${4}
CHECKOUT_LIST=${@:5:$#-4}
WORK_PATH="/dev/shm/.checkout_$(id -u)"

if [ ! -d "$WORK_PATH" ]; then
    mkdir -p $WORK_PATH
fi
cd "${WORK_PATH}"

git config --global core.sparseCheckout true

if [ ! -d ".git" ]; then
    git init
    git remote add origin "${REMOTE_URL}"
    for i in ${CHECKOUT_LIST}; do
        echo ${i} >> ".git/info/sparse-checkout"
    done
    git pull origin "${COMMIT_BRANCH}" --depth=1
else
    gitpath=`git remote -v | grep fetch | awk -F" " '{print $2}'`
    if [ "$gitpath" != "$REMOTE_URL" ]; then
        git remote set-url origin "${REMOTE_URL}"
        echo "" > .git/info/sparse-checkout
    fi
    for i in ${CHECKOUT_LIST}; do
        if [[ `grep -c ${i} ".git/info/sparse-checkout"` -eq '0' ]]; then
            echo ${i} >> ".git/info/sparse-checkout"
        else
            echo "Found! ${i}"
        fi
    done
fi

if [[ ${UPDATE} = "true" ]]; then
    git pull origin "${COMMIT_BRANCH}" --depth=1
fi

git checkout -qf ${COMMIT_BRANCH}
for i in ${CHECKOUT_LIST}; do
    mv ${i} $RESPOSITORY_PATH/
done

