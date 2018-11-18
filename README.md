# ingress_test

Requirements
1. Google Cloud SDK - https://cloud.google.com/sdk/docs/downloads-versioned-archives
2. kubectl (To install it from gcloud - use Versioned archive installation)

Instaructions:
1. Launch `manage.sh` and follow step
2. One can skip GCP account installation if it was previously initialized(i.e. `gcloud init`)

TODO:
1. Add removal of service
2. Verify mapped services and their state
3. Add more verification for kubectl commands results
4. Improve 'skip' logic - skip only if step is verified (e.g GCP account exists/Router installed)
5. Template all YAMLs to be more agile with namespaces/etc
