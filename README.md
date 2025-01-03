# Jenkins-on-OCI
Deploy jenkins on oracle cloud infrastructure with terraform

prequisites:
direnv
terraform
oci-cli with a private key as a api key

#### create private keys for oci:
openssl genpkey -aes-256-cbc -algorithm RSA -out .oci/private.key -pkeyopt rsa_keygen_bits:4096

untested:
openssl genpkey -aes-256-cbc -algorithm RSA -out ~.oci/private.key -pkeyopt rsa_keygen_bits:4096 -outpubkey ~/./oci/public.ke

alternatively: openssl rsa -in ~/.oci/private.key -pubout > .oci/private.pub

private_key_path must be ~/.oci/private.key or change command in .envrc

uses terraform cloud as backend

## Weird error:
 Either the resource has been deleted or service Core Vcn need policy to access this resource. Policy reference: https://docs.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm