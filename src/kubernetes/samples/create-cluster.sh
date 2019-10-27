
# prep Azure CLI & Subscription
az extension add --name aks-preview
az extension update --name aks-preview
az feature register --name MultiAgentpoolPreview --namespace Microsoft.ContainerService
az provider register -n Microsoft.ContainerService

# the cluster (Resource Group exists from previous)
az aks create --verbose         \
--resource-group pyp-demo       \
--name pyptest4                 \
--location westeurope           \
--node-vm-size Standard_D2s_v3  \
--node-osdisk-size 100          \
--node-count 1                  \
--generate-ssh-keys             \
--windows-admin-password "***"  \
--windows-admin-username ***  \
--enable-vmss                   \
--network-plugin azure          \
--kubernetes-version 1.14.7
# the Windows nodes
az aks nodepool add             \
    --resource-group pyp-demo   \
    --cluster-name pyptest4     \
    --os-type Windows           \
    --name npwin1               \
    --node-count 1              \
    --kubernetes-version 1.14.7
# attach existing ACR
AKS_SP_ID=$(az aks show --resource-group pyp-demo --name pyptest3 --query servicePrincipalProfile.clientId -o tsv)
ACR_RESOURCE_ID=$(az acr list --resource-group pro-demo --query "[].{acrLoginServer:id}" --output tsv)
az role assignment create --assignee $AKS_SP_ID --scope $ACR_RESOURCE_ID --role Reader
####### >>>> az aks update --resource-group pyp-demo --name pyptest3 --attach-acr pypdemod7122a
# configure kubectl to use the new cluster
az aks get-credentials          \
    --resource-group pyp-demo   \
    --name pyptest3
kubectl config use-context pyptest3
# deploy the container mix
kubectl apply -f deployment/
# open the Dashboard
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks browse --resource-group pyp-demo --name pyptest3