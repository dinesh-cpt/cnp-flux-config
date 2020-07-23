set -x &&
yq --version || (wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/3.2.0/yq_linux_amd64" && chmod +x /usr/local/bin/yq)
file_name=../../namespaces/$FLUX_WL_NS/$FLUX_WL_NAME/sandbox.yaml
touch $file_name
if echo $FLUX_CONTAINER |grep "tests" - > /dev/null; then FLUX_CONTAINER=java.$FLUX_CONTAINER; fi
yq w -i $file_name 'apiVersion' helm.fluxcd.io/v1
yq w -i $file_name kind HelmRelease
yq w -i $file_name metadata.name $FLUX_WL_NAME
yq w -i $file_name spec.values.$FLUX_CONTAINER.image "$FLUX_IMG:$FLUX_TAG"
( grep -q $file_name $FLUX_WL_NS/kustomization.yaml ||  yq w -i $FLUX_WL_NS/kustomization.yaml "patchesStrategicMerge[+]" ../$file_name )