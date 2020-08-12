#!/usr/bin/env bash

# imports
source ${KOGITO_HOME}/launch/kogito-kubernetes-client.sh
source ${KOGITO_HOME}/launch/logging.sh

# copies the generated monitoring files to
# $KOGITO_HOME/bin, that's the directory used to exchange files between builds
# TODO: copy those files directly to the final dir only when bin is not used to exchange data anymore
function copy_monitoring_files() {
    local monitoringDir="target"
    if [ ! -z "${ARTIFACT_DIR}" ]; then
        monitoringDir="${ARTIFACT_DIR}"
    fi

    log_info "---> [monitoring] Copying monitoring files..."
    if [ -d /tmp/src/${monitoringDir}/generated-resources/kogito/dashboards ]; then
        cp -v /tmp/src/${monitoringDir}/generated-resources/kogito/dashboards/* $KOGITO_HOME/bin/
        move_monitoring_files
    else
        log_info "---> [monitoring] Skip copying files, monitoring dashboards directory does not exist..."
    fi
}

# move_monitoring_files moves monitoring files from $KOGITO_HOME/bin to the final directory
# where those files will be handled by the runtime image.
# TODO: remove this function when s2i build move the KOGITO_HOME instead bin directory between images in chained builds
function move_monitoring_files() {
    log_info "---> [monitoring] Moving monitoring files to final directory"
    if ls $KOGITO_HOME/bin/*dashboard*.json &>/dev/null; then
        # copy to the final dir, so we keep bin clean
        cp -v $KOGITO_HOME/bin/*dashboard*.json $KOGITO_HOME/data/dashboards/
        generate_md5_monitoring_files
    else
        log_info "---> [monitoring] Skip copying files, $KOGITO_HOME/bin directory does not have dashboard files!"
    fi
}

# generate_md5_monitoring_files generates md5 files for each *dashboard*.json file found in $KOGITO_HOME/data/dashboards/
function generate_md5_monitoring_files() {
    if ls $KOGITO_HOME/data/dashboards/*dashboard*.json &>/dev/null; then
        log_info "---> [monitoring] generating md5 for monitoring files"
        for entry in "$KOGITO_HOME/data/dashboards"/*dashboard*.json; do
            md5sum ${entry} | awk '{ print $1 }' >${entry%.*}-md5.txt
            log_info "----> [monitoring] Generated checksum for ${entry} with the name: ${entry%.*}-md5.txt"
        done
    fi
}

# Updates the configMap for this Kogito Runtime instance 
# with the generated dashboards files mounted in the file system.
# Can be called multiple times or outside of a k8s cluster.
# If outside the cluster, just skips the update
function update_monitoring_configmap() {
    if ! is_running_on_kubernetes; then
        log_info "---> [monitoring] Not running on kubernetes cluster, skipping config map update"
        return 0
    fi

    local config_map=$(cat $KOGITO_HOME/podinfo/monitoringcm)
    local file_contents=""
    local file_name=""
    local md5=""
    local annotation=""
    local data=""
    local metadata=""
    local body=""

    if ls $KOGITO_HOME/data/dashboards/*dashboard*.json &>/dev/null; then
        for entry in "$KOGITO_HOME/data/dashboards"/*dashboard*.json; do
            # sanitize input
            file_contents=$(jq -aRs . <<<$(cat $entry))
            file_name=$(basename $entry)
            md5=$(cat ${entry%.*}-md5.txt)
            annotation="org.kie.kogito.monitoring.hash/${file_name%.*}"
            metadata="${metadata} \"${annotation}\": \"${md5}\","
            # doesn't need quotes since jq already added
            data="${data} \"${file_name}\": ${file_contents},"
        done
    fi

    if [ "${metadata}" != "" ]; then
        metadata="${metadata%,}" # cut last comma
    fi

    if [ "${data}" != "" ]; then
        data="${data%,}"
    fi

    body="[ { \"op\": \"replace\", \"path\": \"/metadata/annotations\", \"value\": { ${metadata} } }, { \"op\": \"replace\", \"path\": \"/data\", \"value\": { ${data} } } ]"
    log_info "---> [monitoring] About to patch configMap ${config_map}"
    # prints the raw data
    echo "Body: ${body}"
    printf "%s" "${body}" >$KOGITO_HOME/data/dashboards/configmap_patched.json
    response=$(patch_json_k8s_resource "api" "configmaps/${config_map}" $KOGITO_HOME/data/dashboards/configmap_patched.json)
    if [ "${response: -3}" != "200" ]; then
        log_warning "---> [monitoring] Fail to patch configMap ${config_map}, the Service Account might not have the necessary privileges"
        if [ ! -z "${response}" ]; then
            log_warning "---> [monitoring] Response message: ${response::-3} - HTTP Status code: ${response: -3}"
        fi
        return 1
    fi

    return 0
}
