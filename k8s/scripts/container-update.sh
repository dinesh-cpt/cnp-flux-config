set -x
ENV="$1"
#Install yq if not present
yq --version || (wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/3.2.0/yq_linux_amd64" && chmod +x /usr/local/bin/yq)

if grep -q "prod" <<< "$FLUX_TAG" ; then
  file_name=../../namespaces/$FLUX_WL_NS/$FLUX_WL_NAME/$FLUX_WL_NAME.yaml
else
  file_name=../../namespaces/$FLUX_WL_NS/$FLUX_WL_NAME/${ENV}.yaml
  
  touch $file_name
  
  #set basic manifest,to handle cases where it is created new
  yq w -i $file_name 'apiVersion' helm.fluxcd.io/v1
  yq w -i $file_name kind HelmRelease
  yq w -i $file_name metadata.name $FLUX_WL_NAME
  
  #add newly created patch to team kustomization
  grep -q $file_name $FLUX_WL_NS/kustomization.yaml ||  yq w -i $FLUX_WL_NS/kustomization.yaml "patchesStrategicMerge[+]" ../$file_name
fi

#set image
yq w -i $file_name spec.values.$FLUX_CONTAINER.image "$FLUX_IMG:$FLUX_TAG"